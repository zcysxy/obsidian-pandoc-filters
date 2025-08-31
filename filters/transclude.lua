--[[
  Pandoc filter for Obsidian transclusion
  Embeds transcluded Markdown files using the transclusion syntax
  
  Usage: Write backslash-exclamation-double-brackets with filename to transclude filename.md
  The backslash is needed because pandoc drops the exclamation mark otherwise
  
  By github.com/zcysxy
--]]

local function read_file(filepath)
  local file = io.open(filepath, "r")
  if not file then
    return nil
  end
  local content = file:read("*all")
  file:close()
  return content
end

local function transclude_file(filename)
  -- Add .md extension if not present
  if not filename:match("%.md$") then
    filename = filename .. ".md"
  end
  
  -- Try to read the file
  local content = read_file(filename)
  if not content then
    -- Try relative path if absolute path failed
    local relative_path = "./" .. filename
    content = read_file(relative_path)
  end
  
  if not content then
    -- Return an error message if file cannot be found
    return {pandoc.Para({pandoc.Str("[File not found: " .. filename .. "]")})}
  end
  
  -- Parse the markdown content and return blocks
  local doc = pandoc.read(content, "markdown")
  return doc.blocks
end

-- Handle transclusion in paragraphs by looking for the pattern in text
function Para(para)
  -- Convert paragraph to string to check for transclusion pattern
  local para_str = pandoc.utils.stringify(para)
  
  -- Look for transclusion pattern (escaped exclamation mark version)
  local transclusion_pattern = "^!%[%[(.-)%]%]$"
  local filename = para_str:match(transclusion_pattern)
  
  if filename then
    -- Remove any heading or block references
    filename = filename:gsub("#.*$", "")
    
    -- Transclude the file
    local blocks = transclude_file(filename)
    return blocks
  end
  
  return para
end