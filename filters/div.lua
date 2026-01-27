---@diagnostic disable: undefined-global
--[[
  Custom Pandoc Divs

  Pandoc divs syntx:
    ::: {.class1 .class2}
    content
    :::

  Current supported classes:
    - hidden: hide the div

  By github.com/zcysxy
--]]

-- Obsidian comments (%%)
-- Inline comments
function Inlines(el)
	if not next(el) or #el <= 1 then
		return el
	end

	local comment_flag = false
	for i, item in next, el do
		if item.t == "Str" and item.text == "%%" then
			comment_flag = not comment_flag
			table.remove(el, i)
		elseif comment_flag then
			table.remove(el, i)
		end
	end

	return el
end

-- Block comments
BLK_CMT_FLAG = false
function Block(el)
	if el.t == "Para" and next(el.content) and el.content[1].text == "%%" then
		BLK_CMT_FLAG = not BLK_CMT_FLAG
		return {}
	elseif BLK_CMT_FLAG then
		return {}
	else
		return el
	end
end

function Div(el)
	-- Hidden
	if el.classes[1] == 'hidden' then
		return {}
	end

	-- LaTeX environments
	-- NOTE: write env=envname (e.g., env=definition) in the div attributes to specify the LaTeX environment name
	local envname = el.attr.attributes.env
	if envname then
		local title = el.attr.attributes.title or ""
		local latex_begin_string = "\\begin{" .. envname .. "}[" .. title .. "]\n"
		local latex_end_string = "\n\\end{" .. envname .. "}\n"
		return { pandoc.RawBlock("latex", latex_begin_string) } ..
				el.content ..
				{ pandoc.RawBlock("latex", latex_end_string) }
		-- if the first and last div blocks are paragraphs then we can
		-- bring the environment begin/end closer to the content
		-- if div.content[1].t == "Para" and div.content[#div.content].t == "Para" then
		--   table.insert(div.content[1].content, 1, pandoc.RawInline('tex', beginEnv .. "\n"))
		--   table.insert(div.content[#div.content].content, pandoc.RawInline('tex', "\n" .. endEnv))
		-- else
		--   table.insert(div.content, 1, pandoc.RawBlock('tex', beginEnv))
		--   table.insert(div.content, pandoc.RawBlock('tex', endEnv))
		-- end
	end

	-- Embeds
	if el.classes:includes('embed') and not (el.classes:includes('naked') or el.classes:includes('strict')) then
		local latex_begin_string =
		"\\begin{tcolorbox}[enhanced,breakable,skin first=enhanced,skin middle=enhanced,skin last=enhanced,boxrule=0.5pt,colback=lightgray!10!white,colframe=lightgray!75!black,coltitle=black,fonttitle=\\small\\ttfamily,detach title,after upper={\\par\\hfill\\tcbtitle},title=" ..
		el.identifier:gsub('([_#^])', '\\%1{}') .. "]\n"
		local latex_end_string = "\n\\end{tcolorbox}\n"
		return { pandoc.RawBlock("latex", latex_begin_string) } ..
				el.content ..
				{ pandoc.RawBlock("latex", latex_end_string) }
	end

	return el
end
