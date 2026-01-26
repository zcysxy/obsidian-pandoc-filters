---@diagnostic disable: undefined-global
--[[
  Pandoc filter for Obsidian transclusion

	Supports both inline and standalone transclusion.
	Supports note, section, and block embeds.

  By github.com/zcysxy
--]]

local function slugify(text)
	text = text:lower():gsub("[^%w]+", "-"):gsub("^-+", ""):gsub("-+$", "")
	return text
end

local function read_file(filepath)
	if not filepath:match('%.md$') then
		filepath = filepath .. '.md'
	end

	local file = io.open(filepath, "r")
	if not file then
		return nil
	end
	local content = file:read("*all")
	file:close()
	return content
end

local function extract_section(doc, heading)
	local idx_start, idx_end, heading_level
	for idx, block in pairs(doc.blocks) do
		if block.t == 'Header' then
			-- case-insensitive and trimmed
			if slugify(pandoc.utils.stringify(block.c)) == slugify(heading) then
				idx_start = idx
				heading_level = block.level
			elseif idx_start and block.level <= heading_level then
				idx_end = idx-1
				break
			end
		end
	end

	if not idx_start then
		idx_start = 1 -- transclude whole document if section not found
	end
	if not idx_end then
		idx_end = #doc.blocks
	end

	return pandoc.Blocks{table.unpack(doc.blocks, idx_start, idx_end)}
end

--TODO: blockquotes, lists
local function extract_block(doc, block_id)
	for idx, block in pairs(doc.blocks) do
		local content = block.c
		if content then
			local length = #content
			-- The block ID should be at the end of the line
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
	local embed_type = 'Blocks'
	local src = img.src -- pipe excluded
	local inline_flag = pandoc.utils.stringify(img.caption):match('inline')
	local note_path, section, block_id
	local hash_idx = src:find('#')
	if hash_idx then
		note_path = src:sub(1, hash_idx-1)
		section = src:sub(hash_idx+1) -- section embed syntax: ![[note#section]]
		block_id = section:match("^%^.*") -- block embed syntax: ![[note#^block-id]]
	else
		note_path = src
	end

	if note_path == '' then -- self-reference
		note_path = PANDOC_STATE.input_files[1]
	end

	local note_content = read_file(note_path)
	if not note_content then -- let pandoc handle the image
		embed_type = 'Image'
		return img, embed_type
	end

	local doc = pandoc.read(note_content, 'markdown')
	if not section then -- note embed
		return doc.blocks, embed_type
	elseif not block_id then -- section embed
		local embed_content = extract_section(doc, section)
		if not embed_content then
			return doc.blocks, embed_type -- or img
		else
			return embed_content, embed_type
		end
	else -- block embed
		local embed_content = extract_block(doc, block_id)
		if not embed_content then
			return doc.blocks, embed_type -- or img
		else
			if inline_flag then
				embed_type = 'Inlines'
				if #embed_content == 1 and embed_content[1].t == 'Para' then
					embed_content = embed_content[1]
				else
					embed_content = pandoc.utils.blocks_to_inlines(embed_content)
				end
			end
			return embed_content, embed_type
		end
	end
end

function Pandoc(doc)
	local blocks = {}

	for _,el in pairs(doc.blocks) do
		if el.t == 'Para' then
			local pre_emb_stop = 1 -- keeps track of last block embed position
			local running_para = {}

			for j, img in pairs(el.c) do
				if img.t ~= 'Image' then -- not a link
					goto continue
				end

				local embedded, embed_type = embed(img)
				if embed_type == 'Image' then -- not an embed
					goto continue
				end

				-- Encounter an embed, update running_para and tracker
				local inter_para = pandoc.Para({table.unpack(el.c, pre_emb_stop, j-1)})
				table.insert(running_para, inter_para)
				pre_emb_stop = j + 1

				if embed_type == 'Blocks' then
					-- Insert running_para to blocks and empty it
					if #running_para > 0 then
						table.insert(blocks, pandoc.utils.blocks_to_inlines(running_para,{nil}))
						running_para = {}
					end
					-- Insert embedded blocks
					table.insert(blocks, pandoc.Div(embedded, {class = 'embed ' .. pandoc.utils.stringify(img.caption), id=img.src}))
					-- Update embed tracker
				end

				if embed_type == 'Inlines' then
					-- Expand running_para with embedded inlines
					table.insert(running_para, embedded)
				end

				::continue::
			end

			-- Insert running_para and remaining para
			if pre_emb_stop == 1 then
				table.insert(blocks, el)
			else
				table.insert(running_para, pandoc.Para({table.unpack(el.c, pre_emb_stop)}))
				table.insert(blocks, pandoc.utils.blocks_to_inlines(running_para,{nil}))
			end

		elseif el.t == 'Figure' then
			local el_img = el.content[1].content[1]
			local embedded = embed(el_img)
			table.insert(blocks, pandoc.Div(embedded, {class = 'embed ' .. pandoc.utils.stringify(el_img.caption), id=el_img.src}))

		else
			table.insert(blocks, el)
		end
	end
	return pandoc.Pandoc(blocks, doc.meta)
end

