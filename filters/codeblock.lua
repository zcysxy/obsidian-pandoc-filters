---@diagnostic disable: undefined-global
--[[
  Transform Obsidian Plugins' code blocks

  Currently supports:
  - TikZ
  - Pseudocode

  By github.com/zcysxy
--]]

function CodeBlock(el)
	local class = el.attr.classes[1]

	-- WARNING: For all math-related code blocks, including pseudocode and TikZ,
	-- this filter removes double percent signs (%%), so you can add plugin-incompatible
	-- LaTeX commands after them, such as \label, \caption, and \centering.

	local content = el.text
	if class == "pseudo" or class == "tikz" then
		content = content:gsub("%%%%", "")

		if class == "tikz" then
			content = content:gsub("\\begin{document}", "\\begin{figure}[ht]")
					:gsub("\\end{document}", "\\end{figure}")
					:gsub("\\usepackage[^\n]*", "") --Note: "\usepackage{...}" are removed; re-add them in the frontmatter.
		end

		el = pandoc.RawBlock("latex", content)
	end

	return el
end
