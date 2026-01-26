--[[
  Shift Markdown headings
  to avoid duplicate H1 titles

  Variable: heading_shift (integer)
  If heading_shift = 1, then H2 headings will be shifted to H1, H3 to H2, etc.

  By github.com/zcysxy
--]]

Title = nil

-- Get variable
function Get_meta(m)
  Heading_shift = m.heading_shift
  if Heading_shift then
    Heading_shift = m.heading_shift[1].text
    assert(tonumber(Heading_shift), "heading_shift must be a number")
  end
  -- assert heading_shift is a number
  Title = m.title

  -- Remove Markdown H1 if title is set
  if not Heading_shift then
    if Title then
      Heading_shift = 1
    else
      Heading_shift = 0
    end
  end

  return m
end

function Shift_headings(h)
  h.level = h.level - Heading_shift
  if h.level > 0 then
    return h
  else
    return {}
  end
end

return { { Meta = Get_meta }, { Header = Shift_headings } }
