--[[
Convert alternate checkbox syntax to inline tcboxes.
-- ]]

local tcbegin =
"\\begin{tcolorbox}[enhanced,nobeforeafter,tcbox raise base,boxrule=0.4pt,top=0mm,bottom=0mm,right=0mm,left=5mm,arc=1pt,boxsep=2pt,before upper={\\vphantom{dlg}},colframe=%s!50!black,coltext=black,colback=%s!10!white,overlay={\\begin{tcbclipinterior}\\fill[%s!10!white] (frame.south west) rectangle node[text=%s,font=\\sffamily\\bfseries\\small] {%s} ([xshift=5mm]frame.north west);\\end{tcbclipinterior}}]"
local tcend = "\\end{tcolorbox}"

local type_tbl = {
	["[!]"] = {
		color = "red",
		icon = "\\faExclamationCircle"
	},
	["[?]"] = {
		color = "orange",
		icon = "\\faQuestionCircle"
	},
	["[*]"] = {
		color = "Dandelion",
		icon = "\\faStar"
	},
	["[@]"] = {
		color = "ForestGreen",
		icon = "\\faBook"
	},
	["[~]"] = {
		color = "cyan",
		icon = "\\faInfoCircle"
	},
	["[&]"] = {
		color = "NavyBlue",
		icon = "\\faPaperclip"
	},
	["[+]"] = {
		color = "ForestGreen",
		icon = "\\faThumbsUp"
	},
	["[-]"] = {
		color = "red",
		icon = "\\faThumbsDown"
	},
	["[=]"] = {
		color = "gray",
		icon = "\\faBan"
	},
	["[>]"] = {
		color = "purple",
		icon = "\\faPaperPlane"
	},
	["[/]"] = {
		color = "teal",
		icon = "\\faAdjust"
	},
}

function BulletList(li)
	for _, item in pairs(li.c) do
		local start = item[1].c[1]
		if start.t == "Str" then
			local type = start.text:match("^%[.%]$")
			if type and type_tbl[type] then
				local color = type_tbl[type].color
				local icon = type_tbl[type].icon
				item[1].c[1] = pandoc.RawInline("latex", string.format(tcbegin, color, color, color, color, icon))
				item[1].c[#item[1].c + 1] = pandoc.RawInline("latex", tcend)
			end
		end
	end
	return li
end
