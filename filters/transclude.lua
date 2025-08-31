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

function Image(img)
	local note_path = img.src
	-- Add extension .md if not present
	if not note_path:match('%.md$') then
		note_path = note_path .. '.md'
	end
	local note_content = read_file(note_path)

	-- Return to pandoc if file cannot be found
	if not note_content then
		return img
	end

	local doc = pandoc.read(note_content, 'markdown')
	logging.temp('msg:', doc)
	return pandoc.utils.blocks_to_inlines(doc.blocks)
end

