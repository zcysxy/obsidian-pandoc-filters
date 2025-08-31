--[[
  Reusable LaTeX preambles
  Source the preamble file specified in the defaults file or the frontmatter

  By github.com/zcysxy
--]]

user_dir = PANDOC_STATE['user_data_dir']:gsub(" ", "\\space "):gsub("~", "\\string~") .. "/"
basic_preamble = [[
\usepackage[dvipsnames]{xcolor}
\usepackage{tcolorbox,mathtools,fontawesome5}
\tcbuselibrary{skins,breakable}
\usepackage{algorithm}
\usepackage[noEnd=false,indLines=false]{algpseudocodex}
\newcommand{\Input}{\item[\textbf{Input:}]}
\usepackage{tikz}
% \renewcommand{\hl}{\bgroup\markoverwith
%  {\textcolor{yellow}{\rule[-.5ex]{2pt}{2.5ex}}}\ULon}
\usepackage{amsthm}
\makeatletter
\@ifundefined{theorem}{\newtheorem{theorem}{Theorem}[section]}{}
\@ifundefined{fact}{\newtheorem{fact}{Fact}[section]}{}
\@ifundefined{proposition}{\newtheorem{proposition}{Proposition}[section]}{}
\makeatother
\theoremstyle{definition}
\makeatletter
\@ifundefined{definition}{\newtheorem{definition}{Definition}[section]}{}
\@ifundefined{assumption}{\newtheorem{assumption}{Assumption}[section]}{}
\@ifundefined{question}{\newtheorem{question}{Question}[section]}{}
\@ifundefined{example}{\newtheorem{example}{Example}[section]}{}
\makeatother
\theoremstyle{remark}
\makeatletter
\@ifundefined{remark}{\newtheorem{remark}{Remark}}{}
\makeatother
\usepackage[normalem]{ulem} % use normalem to protect \emph
\usepackage{soul}
\makeatletter
\def\cleartheorem#1{%
	\expandafter\let\csname #1\endcsname\relax
	\expandafter\let\csname c@#1\endcsname\relax
}
\makeatother
]]


function Meta (m)
    local header = m['header-includes'] and m['header-includes'] or pandoc.List()
	table.insert(header, 1, pandoc.RawBlock("tex", basic_preamble))

    if m['preamble-file'] then
        preamble = pandoc.RawInline("tex", "\\usepackage{\"" .. user_dir .. m['preamble-file']:gsub("%.sty$", "") .. "\"}")
		table.insert(header, 1, preamble)
    end

    m["header-includes"] = header
    return m
end
