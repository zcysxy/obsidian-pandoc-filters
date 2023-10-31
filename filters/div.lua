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

function Div(el)
  if el.classes[1] == 'hidden' then
    return {}
  else
    return el
  end
end

