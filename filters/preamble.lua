--[[
  Reusable LaTeX preambles
  Source the preamble file specified in the defaults file or the frontmatter

  By github.com/zcysxy
--]]

user_dir = PANDOC_STATE['user_data_dir']:gsub(" ", "\\space "):gsub("~", "\\string~") .. "/"
basic_preamble = [[
\usepackage{xcolor}
\usepackage{tcolorbox}
\tcbuselibrary{skins,breakable}
\usepackage{algorithm}
\usepackage[noEnd=false,indLines=false]{algpseudocodex}
\usepackage{tikz}
\usepackage{amsthm}
\newtheorem{theorem}{Theorem}[section]
\theoremstyle{definition}
\newtheorem{definition}{Definition}[section]
\newtheorem{assumption}{Assumption}[section]
]]


function Meta (m)
    header = m['header-includes'] and m['header-includes'] or pandoc.List()
    header[#header + 1] = pandoc.RawBlock("tex", basic_preamble)

    if m['preamble-file'] then
        preamble = pandoc.RawInline("tex", "\\usepackage{\"" .. user_dir .. m['preamble-file']:gsub("%.sty$", "") .. "\"}")
        header[#header + 1] = preamble
    end

    m["header-includes"] = header
    return m
end
