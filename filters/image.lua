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

	-- Wrapfig
	-- WARNING: make sure the image you want to wrap
	-- text around is an line element
	-- WARNING: check if `wrapfig` package is loaded before use
	if el.attr.attributes.wrapfig then
		local wf_width = el.attr.attributes.wrapfig
		local wf_width_persent = wf_width:match('(%d+)%%$')
		if wf_width_persent then
			wf_width = string.format('%.2f\\textwidth', tonumber(wf_width_persent) / 100)
		end
		-- Position: r (right, default), l (left), i (inside), o (outside)
		local wf_pos = el.attr.attributes.wrapfig_pos or 'r'
		-- Overhang: additional space to the figure, default 0pt
		local wf_overhang = el.attr.attributes.wrapfig_overhang or '0pt'

		local wrapfig_begin = pandoc.RawInline('latex', string.format('\\begin{wrapfigure}{%s}[%s]{%s}', wf_pos, wf_overhang, wf_width))
		local wrapfig_end = pandoc.RawInline('latex', '\\end{wrapfigure}')
		el = pandoc.Inlines({wrapfig_begin, el, wrapfig_end})
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
			attr.identifier = ""
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
