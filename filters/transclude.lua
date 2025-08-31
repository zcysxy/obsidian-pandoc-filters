local logging = require("logging")

local function read_file(filepath)
	local file = io.open(filepath, "r")
	if not file then
		return nil
	end
	local content = file:read("*all")
	file:close()
	return content
end

local function slugify(text)
	text = text:lower():gsub("[^%w]+", "-"):gsub("^-+", ""):gsub("-+$", "")
	return text
end

-- Extracts the markdown content of a section by heading title (case-insensitive, trimmed)
local function extract_section(doc, heading)
	local idx_start, idx_end, heading_level
	for idx, block in pairs(doc.blocks) do
		if block.t == 'Header' then
			if slugify(pandoc.utils.stringify(block.c)) == slugify(heading) then
				idx_start = idx
				heading_level = block.level
			elseif idx_start and block.level <= heading_level then
				idx_end = idx-1
				break
			end
		end
	end

	-- trim blocks
	if not idx_start then
		idx_start = 1
	end
	if not idx_end then
		idx_end = #doc.blocks
	end
	return pandoc.Blocks{table.unpack(doc.blocks, idx_start, idx_end)}
end

-- Extracts the markdown content of a block by its identifier (e.g., ^block-id)
local function extract_block(doc, block_id)
	for idx, block in pairs(doc.blocks) do
		local content = block.c
		if content then
			local length = #content
			if length >= 1 and content[length].t == "Str" and content[length].text == block_id then
				if length > 1 then -- return this block
					block.c[length] = nil
					return pandoc.Blocks{block}
				else -- return previous block
					return pandoc.Blocks{doc.blocks[idx-1]}
				end
			end
		end
	end
	return nil
end

local function embed(img)
	local src = img.src
	local note_path, section, block
	local hash_idx = src:find('#')
	if hash_idx then
		note_path = src:sub(1, hash_idx-1)
		section = src:sub(hash_idx+1) -- section embed syntax: ![[note#section]]
		block_id = section:match("^%^.*") -- block embed syntax: ![[note#^block-id]]
	else
		note_path = src
	end

	-- Add extension .md if not present
	if not note_path:match('%.md$') then
		note_path = note_path .. '.md'
	end

	local note_content = read_file(note_path)
	if not note_content then -- let pandoc handle the image
		return img
	end

	local doc = pandoc.read(note_content, 'markdown')
	if not section then -- note embed
		return doc.blocks
	elseif not block_id then -- section embed
		local embed_content = extract_section(doc, section)
		if not embed_content then
			return doc.blocks -- or img
		else
			return embed_content
		end
	else -- block embed
		local embed_content = extract_block(doc, block_id)
		if not embed_content then
			return doc.blocks -- or img
		else
			return embed_content
		end
	end
end

function Pandoc(doc)
	local blocks = {}
	for _,el in pairs(doc.blocks) do
		if not el.t == 'Para' then
			table.insert(blocks, el)
		else
			local pre_emb_stop = 1
			for j, img in pairs(el.c) do
				if img.t == 'Image' then
					local embedded = embed(img)
					if pandoc.utils.type(embedded) == 'Blocks' then
						local pre_para = pandoc.Para({table.unpack(el.c, pre_emb_stop, j-1)})
						-- insert pre_para and embedded blocks
						if #pre_para.c > 0 then
							table.insert(blocks, pre_para)
						end
						table.insert(blocks, pandoc.Div(embedded, {class = 'embed ' .. pandoc.utils.stringify(img.caption), id=img.src}))
						pre_emb_stop = j + 1
					end
				end
			end

			-- insert remaining part of the paragraph
			if pre_emb_stop == 1 then
				table.insert(blocks, el)
			else
				local post_para = {table.unpack(el.c, pre_emb_stop)}
				table.insert(blocks, pandoc.Para(post_para))
			end
		end
	end
	return pandoc.Pandoc(blocks, doc.meta)
end

