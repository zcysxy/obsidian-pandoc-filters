-- Function needs to have a name so that recurion can work.
-- That is why it is outside the returned table.
local logging = require('logging')

local function read_file(filepath)
	local file = io.open(filepath, "r")
	if not file then
		return nil
	end
	local content = file:read("*all")
	file:close()
	return content
end

local function embed(img)
	local note_path = img.src
	-- Add extension .md if not present
	if not note_path:match('%.md$') then
		note_path = note_path .. '.md'
	end
	local note_content = read_file(note_path)

	if not note_content then
		return img
	end
	local doc = pandoc.read(note_content, 'markdown')
	return doc.blocks
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
						for _, b in pairs(embedded) do
							table.insert(blocks, b)
						end
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


