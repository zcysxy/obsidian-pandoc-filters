-- [[
-- Transform mathjax/katex non-compatible syntax for LaTeX.
--
-- By github.com/zcysxy
-- ]]

function Math (el)
    el.text = el.text:gsub("\\mathbb{1}", "\\mathbbm{1}")
    el.text = el.text:gsub('%%\\label', '\\label')
    el.text = el.text:gsub('\\tag{.-}%%', '')
    el.text = el.text:gsub('%%%%', '')
    return el
end

