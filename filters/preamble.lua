--[[
  Reusable LaTeX preambles
  Source the preamble file specified in the defaults file or the frontmatter

  By github.com/zcysxy
--]]

local logging = require "filters.logging"

function Meta (m)
    if m['preamble-file'] then
        preamble = pandoc.RawInline("tex", "\\usepackage{" .. m['preamble-file']:gsub("%.sty$", "") .. "}")
        header = m['header-includes'] and m['header-includes'] or pandoc.List()
        header[#header + 1] = preamble
        m["header-includes"] = header
    end
    return m
end
