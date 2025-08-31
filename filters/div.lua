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

logging = require 'logging'

function Inlines(el)
  if next(el) and el[1].tag == "Str" and el[#el].tag == "Str" and el[1].text:match('^%%%%') and el[#el].text:match('^%%%%') then
	el[1] = '::: hidden\n'
	el[#el] = ':::\n'
	return {}
  end
  return el
end

function Div(el)
  if el.classes[1] == 'hidden' then
    return {}
	elseif el.classes:includes('embed') then
		local latex_begin_string = "\\begin{tcolorbox}[boxrule=0.5pt,colback=lightgray!10!white,colframe=lightgray!75!black,coltitle=black,fonttitle=\\small\\ttfamily,detach title,after upper={\\par\\hfill\\tcbtitle},title=" .. el.identifier .. "]\n"
		local latex_end_string = "\\end{tcolorbox}\n"
    return { pandoc.RawBlock("latex", latex_begin_string) } ..
        el.content ..
        { pandoc.RawBlock("latex", latex_end_string) }
  else
    return el
  end
end

