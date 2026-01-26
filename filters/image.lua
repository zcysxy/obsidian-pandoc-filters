---@diagnostic disable: undefined-global
--[[
  Process images
  Supports caption, Pandoc attributes, and Obsidian image alias.
  Also supports inline plots and pandoc-crossref subplots.

  Syntax: ![caption {attributes} | alias](/path/to/image)
  Example: ![caption {width=70% #fig:label} | 500x300](/path/to/image)
  All components are optional

  By github.com/zcysxy
--]]

local function get_raw_tex(para)
	para = para:walk {
		Math = function(el) return "$" .. el.text .. "$" end,
		Emph = function(el) return "\\textit{" .. pandoc.utils.stringify(el.content) .. "}" end,
		Strong = function(el) return "\\textbf{" .. pandoc.utils.stringify(el.content) .. "}" end,
		Code = function(el) return "\\textit{" .. el.text .. "}" end
	}
	return para
end

function Image(el) -- inline
	-- Remove Obsidian image alias (everything after '|')
	local caption = pandoc.utils.stringify(get_raw_tex(el.caption)):gsub('|.*$', '')

	-- Assign attributes
	local temp_caption, attr_str = caption:match('^(.-)%s*(%b{})%s*$')
	if attr_str then
		el.attr = pandoc.read('![]()' .. attr_str, 'markdown').blocks[1].content[1].attr
		caption = temp_caption
	end

	-- Extract caption
	caption = pandoc.read(caption, 'markdown')
	if next(caption.blocks) then
		el.caption = caption.blocks[1].content
	else
		el.caption = ""
	end

	return el
end

function Figure(el) -- block
	if #el.caption.long >= 1 then
		local caption = pandoc.utils.stringify(get_raw_tex(el.caption.long[1].content)):gsub('|.*$', '')
		local temp_caption, attr_str = caption:match('^(.-)%s*(%b{})%s*$')

		-- Assign attributes
		if attr_str then
			local attr = pandoc.read('![]()' .. attr_str, 'markdown').blocks[1].content[1].attr
			el.attr = attr
			el.content[1].content[1].attr = attr
			caption = temp_caption
		end

		-- Extract caption
		caption = pandoc.read(caption, 'latex')
		if next(caption.blocks) then
			caption = caption.blocks[1].content
		else
			caption = ""
		end
		el.caption.long[1].content = caption
		el.content[1].content[1].caption = caption
	end
	return el
end
