--[[-- # Columns - multiple column support in Pandoc's markdown.

This Lua filter provides support for multiple columns in
latex and html outputs. For details, see README.md.

@author Julien Dutant <julien.dutant@kcl.ac.uk>
@copyright 2021 Julien Dutant
@license MIT - see LICENSE file for details.
@release 1.1.3
]]

-- # Version control
local required_version = '2.9.0'
local version_err_msg = "ERROR: pandoc >= "..required_version
                .." required for columns filter"
-- pandoc 2.9 required for pandoc.List insert method
if PANDOC_VERSION == nil then -- if pandoc_version < 2.1
  error(version_err_msg)
elseif PANDOC_VERSION[1] < 3 and PANDOC_VERSION[2] < 9 then
  error(version_err_msg)
else  
  PANDOC_VERSION:must_be_at_least(required_version, version_err_msg)
end
local utils = require('pandoc.utils') -- this is superfluous in Pandoc >= 2.7 I think

-- # Internal settings

-- target_formats  filter is triggered when those formats are targeted
local target_formats = {
  "html.*",
  "latex",
}
local options = {
  raggedcolumns = false; -- global ragged columns option
}

-- # Helper functions

--- type: pandoc-friendly type function
-- panbdoc.utils.type is only defined in Pandoc >= 2.17
-- if it isn't, we extend Lua's type function to give the same values
-- as pandoc.utils.type on Meta objects: Inlines, Inline, Blocks, Block,
-- string and booleans
-- Caution: not to be used on non-Meta Pandoc elements, the
-- results will differ (only 'Block', 'Blocks', 'Inline', 'Inlines' in
-- >=2.17, the .t string in <2.17).
local type = utils.type or function (obj)
        local tag = type(obj) == 'table' and obj.t and obj.t:gsub('^Meta', '')
        return tag and tag ~= 'Map' and tag or type(obj)
    end

--- Test whether the target format is in a given list.
-- @param formats list of formats to be matched
-- @return true if match, false otherwise
local function format_matches(formats)
  for _,format in pairs(formats) do
    if FORMAT:match(format) then
      return true
    end
  end
  return false
end


--- Add a block to the document's header-includes meta-data field.
-- @param meta the document's metadata block
-- @param block Pandoc block element (e.g. RawBlock or Para) to be added to header-includes
-- @return meta the modified metadata block
local function add_header_includes(meta, block)

    local header_includes = pandoc.List:new()

    -- use meta['header-includes']

    if meta['header-includes'] then
      if type(meta['header-includes']) ==  'List' then
        header_includes:extend(meta['header-includes'])
      else
        header_includes:insert(meta['header-includes'])
      end
    end

    -- insert `block` in header-includes

    header_includes:insert(pandoc.MetaBlocks({block}))

    -- save header-includes in the document's meta

    meta['header-includes'] = header_includes

    return meta
end

--- Add a class to an element.
-- @param element Pandoc AST element
-- @param class name of the class to be added (string)
-- @return the modified element, or the unmodified element if the element has no classes
local function add_class(element, class)

  -- act only if the element has classes
  if element.attr and element.attr.classes then

    -- if the class is absent, add it
    if not element.attr.classes:includes(class) then
      element.attr.classes:insert(class)
    end

  end

  return element
end

--- Removes a class from an element.
-- @param element Pandoc AST element
-- @param class name of the class to be removed (string)
-- @return the modified element, or the unmodified element if the element has no classes
local function remove_class(element, class)

  -- act only if the element has classes
  if element.attr and element.attr.classes then

    -- if the class is present, remove it
    if element.attr.classes:includes(class) then
      element.attr.classes = element.attr.classes:filter(
        function(x)
          return not (x == class)
        end
        )
    end

  end

  return element
end

--- Set the value of an element's attribute.
-- @param element Pandoc AST element to be modified
-- @param key name of the attribute to be set (string)
-- @param value value to be set. If nil, the attribute is removed.
-- @return the modified element, or the element if it's not an element with attributes.
local function set_attribute(element,key,value)

  -- act only if the element has attributes
  if element.attr and element.attr.attributes then

    -- if `value` is `nil`, remove the attribute
    if value == nil then
      if element.attr.attributes[key] then
       element.attr.attributes[key] = nil
     end

    -- otherwise set its value
    else
      element.attr.attributes[key] = value
    end

  end

  return element
end

--- Add html style markup to an element's attributes.
-- @param element the Pandoc AST element to be modified
-- @param style the style markup to add (string in CSS)
-- @return the modified element, or the unmodified element if it's an element without attributes
local function add_to_html_style(element, style)

  -- act only if the element has attributes
  if element.attr and element.attr.attributes then

    -- if the element has style markup, append
    if element.attr.attributes['style'] then

      element.attr.attributes['style'] =
        element.attr.attributes['style'] .. '; ' .. style .. ' ;'

    -- otherwise create
    else

      element.attr.attributes['style'] = style .. ' ;'

    end

  end

  return element

end

--- Translate an English number name into a number.
-- Converts cardinals ("one") and numerals ("first").
-- Returns nil if the name isn't understood.
-- @param name an English number name (string)
-- @return number or nil
local function number_by_name(name)

  local names = {
    one = 1,
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9,
    ten = 10,
    first = 1,
    second = 2,
    third = 3,
    fourth = 4,
    fifth = 5,
    sixth = 6,
    seventh = 7,
    eighth = 8,
    ninth = 9,
    tenth = 10,
  }

  result = nil

  if name and names[name] then
      return names[name]
  end

end

--- Convert some CSS values (lengths, colous) to LaTeX equivalents.
-- Example usage: `css_values_to_latex("1px solid black")` returns
-- `{ length = "1pt", color = "black", colour = "black"}`.
-- @param css_str a CSS string specifying a value
-- @return table with keys `length`, `color` (alias `colour`) if found
local function css_values_to_latex(css_str)

  -- color conversion table
  --  keys are CSS values, values are LaTeX equivalents

  latex_colors = {
    -- xcolor always available
    black = 'black',
    blue = 'blue',
    brown = 'brown',
    cyan = 'cyan',
    darkgray = 'darkgray',
    gray = 'gray',
    green = 'green',
    lightgray = 'lightgray',
    lime = 'lime',
    magenta = 'magenta',
    olive = 'olive',
    orange = 'orange',
    pink = 'pink',
    purple = 'purple',
    red = 'red',
    teal = 'teal',
    violet = 'violet',
    white = 'white',
    yellow = 'yellow',
    -- css1 colors
    silver = 'lightgray',
    fuschia = 'magenta',
    aqua = 'cyan',
  }

  local result = {}

  -- look for color values
  --  by color name
  --  rgb, etc.: to be added

  local color = ''

  -- space in front simplifies pattern matching
  css_str = ' ' .. css_str

  -- look for colour names
  for text in string.gmatch(css_str, '[%s](%a+)') do

    -- if we have LaTeX equivalent of `text`, store it
    if latex_colors[text] then
      result['color'] = latex_colors[text]
    end

  end

  -- provide British spelling

  if result['color'] then
    result['colour'] = result['color']
  end

  -- look for lengths

  --  0 : converted to 0em
  if string.find(css_str, '%s0%s') then
   result['length'] = '0em'
  end

  --  px : converted to pt
  for text in string.gmatch(css_str, '(%s%d+)px') do
   result['length'] = text .. 'pt'
  end

  -- lengths units to be kept as is
  --  nb, % must be escaped
  --  nb, if several found, the latest type is preserved
  keep_units = { '%%', 'pt', 'mm', 'cm', 'in', 'ex', 'em' }

  for _,unit in pairs(keep_units) do

    -- .11em format
    for text in string.gmatch(css_str, '%s%.%d+'.. unit) do
      result['length'] = text
    end

    -- 2em and 1.2em format
    for text in string.gmatch(css_str, '%s%d+%.?%d*'.. unit) do
      result['length'] = text
    end

  end

  return result

end

--- Ensures that a string specifies a LaTeX length
-- @param text text to be checked
-- @return text if it is a LaTeX length, `nil` otherwise
local function ensures_latex_length(text)

  -- LaTeX lengths units
  --  nb, % must be escaped in lua patterns
  units = { '%%', 'pt', 'mm', 'cm', 'in', 'ex', 'em' }

  local result = nil

  -- ignore spaces, controls and punctuation other than
  -- dot, plus, minus
  text = string.gsub(text, "[%s%c,;%(%)%[%]%*%?%%%^%$]+", "")

  for _,unit in pairs(units) do

    -- match .11em format and 1.2em format
    if string.match(text, '^%.%d+'.. unit .. '$') or
      string.match(text, '^%d+%.?%d*'.. unit .. '$') then

      result = text

    end

  end

  return result
end


-- # Filter-specific functions

--- Process the metadata block.
-- Adds any needed material to the document's metadata block.
-- @param meta the document's metadata element
local function process_meta(meta)

  -- in LaTeX, require the `multicols` package
  if FORMAT:match('latex') then

    return add_header_includes(meta,
      pandoc.RawBlock('latex', '\\usepackage{multicol}\n'))

  end

  -- in html, ensure that the first element of `columns` div
  -- has a top margin of zero (otherwise we get white space
  -- on the top of the first column)
  -- idem for the first element after a `column-span` element
  if FORMAT:match('html.*') then

    html_header = [[
<style>
/* Styles added by the columns.lua pandoc filter */
  .columns :first-child {margin-top: 0;}
  .column-span + * {margin-top: 0;}
</style>
]]

    return add_header_includes(meta, pandoc.RawBlock('html', html_header))

  end

  return meta

end

--- Convert explicit columnbreaks.
-- This function converts any explict columnbreak markup in an element
-- into a single syntax: a Div with class `columnbreak`.
-- Note: if there are `column` Divs in the element we keep them
-- in case they harbour further formatting (e.g. html classes). However
-- we remove their `column` class to avoid double-processing when
-- column fields are nested.
-- @param elem Pandoc native Div element
-- @return elem modified as needed
local function convert_explicit_columbreaks(elem)

  -- if `elem` ends with a `column` Div, this last Div should
  -- not generate a columnbreak. We tag it to make sure we don't convert it.

  if #elem.content > 0
    and elem.content[#elem.content].t == 'Div'
    and elem.content[#elem.content].classes:includes('column') then

    elem.content[#elem.content] =
      add_class(elem.content[#elem.content], 'column-div-in-last-position')

  end

  -- processes `column` Divs and `\columnbreak` LaTeX RawBlocks
  filter = {

    Div = function (el)

      -- syntactic sugar: `column-break` converted to `columnbreak`
      if el.classes:includes("column-break") then

        el = add_class(el,"columnbreak")
        el = remove_class(el,"column-break")

      end

      if el.classes:includes("column") then

        -- with `column` Div, add a break if it's not in last position
        if not el.classes:includes('column-div-in-last-position') then

          local breaking_div = pandoc.Div({})
          breaking_div = add_class(breaking_div, "columnbreak")

          el.content:insert(breaking_div)

        -- if it's in the last position, remove the custom tag
        else

          el = remove_class(el, 'column-div-in-last-position')

        end

        -- remove `column` classes, but leave the div and other
        -- attributes the user might have added
        el = remove_class(el, 'column')

      end

      return el
    end,

    RawBlock = function (el)
      if el.format == "tex" and el.text == '\\columnbreak' then

        local breaking_div = pandoc.Div({})
        breaking_div = add_class(breaking_div, "columnbreak")

        return breaking_div

      else

        return el

      end

    end

  }

  return pandoc.walk_block(elem, filter)

end

--- Tag an element with the number of explicit columnbreaks it contains.
-- Counts the number of epxlicit columnbreaks contained in an element and
-- tags the element with a `number_explicit_columnbreaks` attribute.
-- In the process columnbreaks are tagged with the class `columnbreak_already_counted`
-- in order to avoid double-counting when multi-columns are nested.
-- @param elem Pandoc element (native Div element of class `columns`)
-- @return elem with the attribute `number_explicit_columnbreaks` set.
local function tag_with_number_of_explicit_columnbreaks(elem)

  local number_columnbreaks = 0

  local filter = {

    Div = function(el)

      if el.classes:includes('columnbreak') and
        not el.classes:includes('columnbreak_already_counted')  then

          number_columnbreaks = number_columnbreaks + 1
          el = add_class(el, 'columnbreak_already_counted')

      end

      return el

    end
  }

  elem = pandoc.walk_block(elem, filter)

  elem = set_attribute(elem, 'number_explicit_columnbreaks',
      number_columnbreaks)

  return elem

end

--- Consolidate aliases for column attributes.
-- Provides syntacic sugar: unifies various ways of
-- specifying attributes of a multi-column environment.
-- When several specifications conflit, favours `column-gap` and
-- `column-rule` specifications.
-- @param elem Pandoc element (Div of class `columns`) with column attributes.
-- @return elem modified as needed.
local function consolidate_colattrib_aliases(elem)

  if elem.attr and elem.attr.attributes then

    -- `column-gap` if the preferred syntax is set, erase others
    if elem.attr.attributes["column-gap"] then

      elem = set_attribute(elem, "columngap", nil)
      elem = set_attribute(elem, "column-sep", nil)
      elem = set_attribute(elem, "columnsep", nil)

    -- otherwise fetch and unset any alias
    else

      if elem.attr.attributes["columnsep"] then

        elem = set_attribute(elem, "column-gap",
            elem.attr.attributes["columnsep"])
        elem = set_attribute(elem, "columnsep", nil)

      end

      if elem.attr.attributes["column-sep"] then

        elem = set_attribute(elem, "column-gap",
            elem.attr.attributes["column-sep"])
        elem = set_attribute(elem, "column-sep", nil)

      end

      if elem.attr.attributes["columngap"] then

        elem = set_attribute(elem, "column-gap",
            elem.attr.attributes["columngap"])
        elem = set_attribute(elem, "columngap", nil)

      end

    end

    -- `column-rule` if the preferred syntax is set, erase others
    if elem.attr.attributes["column-rule"] then

      elem = set_attribute(elem, "columnrule", nil)

    -- otherwise fetch and unset any alias
    else

      if elem.attr.attributes["columnrule"] then

        elem = set_attribute(elem, "column-rule",
            elem.attr.attributes["columnrule"])
        elem = set_attribute(elem, "columnrule", nil)

      end

    end

  end

  return elem

end

--- Pre-process a Div of class `columns`.
-- Converts explicit column breaks into a unified syntax
-- and count the Div's number of columns.
-- When several columns are nested Pandoc will apply
-- this filter to the innermost `columns` Div first;
-- we use that feature to prevent double-counting.
-- @param elem Pandoc element to be processes (Div of class `columns`)
-- @return elem modified as needed
local function preprocess_columns(elem)

  -- convert any explicit column syntax in a single format:
  -- native Divs with class `columnbreak`

  elem = convert_explicit_columbreaks(elem)

  -- count explicit columnbreaks

  elem = tag_with_number_of_explicit_columnbreaks(elem)

  return elem
end

--- Determine the number of column in a `columns` Div.
-- Looks up two attributes in the Div: the user-specified
-- `columns-count` and the filter-generated `number_explicit_columnbreaks`
-- which is based on the number of explicit breaks specified.
-- The final number of columns will be 2 or whichever of `column-count` and
-- `number_explicit_columnbreaks` is the highest. This ensures there are
-- enough columns for all explicit columnbreaks.
-- This provides a single-column when the user specifies `column-count = 1` and
-- there are no explicit columnbreaks.
-- @param elem Pandoc element (Div of class `columns`) whose number of columns is to be determined.
-- @return number of columns (number, default 2).
local function determine_column_count(elem)

    -- is there a specified column count?
  local specified_column_count = 0
  if elem.attr.attributes and elem.attr.attributes['column-count'] then
      specified_column_count = tonumber(
        elem.attr.attributes["column-count"])
  end

  -- is there an count of explicit columnbreaks?
  local number_explicit_columnbreaks = 0
  if elem.attr.attributes and elem.attr.attributes['number_explicit_columnbreaks'] then

      number_explicit_columnbreaks = tonumber(
        elem.attr.attributes['number_explicit_columnbreaks']
        )

      set_attribute(elem, 'number_explicit_columnbreaks', nil)

  end

  -- determines the number of columns
  -- default 2
  -- recall that number of columns = nb columnbreaks + 1

  local number_columns = 2

  if specified_column_count > 0 or number_explicit_columnbreaks > 0 then

      if (number_explicit_columnbreaks + 1) > specified_column_count then
        number_columns = number_explicit_columnbreaks + 1
      else
        number_columns = specified_column_count
      end

  end

  return number_columns

end

--- Convert a pandoc Header to a list of inlines for latex output.
-- @param header Pandoc Header element
-- @return list of Inline elements
local function header_to_latex_and_inlines(header)

-- @todo check if level interpretation has been shifted, e.g. section is level 2
-- @todo we could check the Pandoc state to check whether hypertargets are required?

  local latex_header = {
    'section',
    'subsection',
    'subsubsection',
    'paragraph',
    'subparagraph',
  }

  -- create a list if the header's inlines
  local inlines = pandoc.List:new(header.content)

  -- wrap in a latex_header if available

  if header.level and latex_header[header.level] then

    inlines:insert(1, pandoc.RawInline('latex',
        '\\' .. latex_header[header.level] .. '{'))
    inlines:insert(pandoc.RawInline('latex', '}'))

  end

  -- wrap in a link if available
  if header.identifier then

    inlines:insert(1, pandoc.RawInline('latex',
        '\\hypertarget{' .. header.identifier .. '}{%\n'))
    inlines:insert(pandoc.RawInline('latex',
        '\\label{' .. header.identifier .. '}}'))

  end

  return inlines

end

--- Format column span in LaTeX.
-- Formats a bit of text spanning across all columns for LaTeX output.
-- If the colspan is only one block, it is turned into an option
-- of a new `multicol` environment. Otherwise insert it is
-- inserted between the two `multicol` environments.
-- @param elem Pandoc element that is supposed to span across all
--    columns.
-- @param number_columns number of columns in the present environment.
-- @return a pandoc RawBlock element in LaTeX format
local function format_colspan_latex(elem, number_columns)

    local result = pandoc.List:new()

    -- does the content consists of a single header?

    if #elem.content == 1 and elem.content[1].t == 'Header' then

      -- create a list of inlines
      inlines = pandoc.List:new()
      inlines:insert(pandoc.RawInline('latex',
        "\\end{multicols}\n"))
      inlines:insert(pandoc.RawInline('latex',
        "\\begin{multicols}{".. number_columns .."}["))
      inlines:extend(header_to_latex_and_inlines(elem.content[1]))
      inlines:insert(pandoc.RawInline('latex',"]\n"))

      -- insert as a Plain block
      result:insert(pandoc.Plain(inlines))

      return result

    else

      result:insert(pandoc.RawBlock('latex',
        "\\end{multicols}\n"))
      result:extend(elem.content)
      result:insert(pandoc.RawBlock('latex',
        "\\begin{multicols}{".. number_columns .."}"))
      return result

    end

end

--- Format columns for LaTeX output
-- @param elem Pandoc element (Div of "columns" class) containing the
--    columns to be formatted.
-- @return elem with suitable RawBlocks in LaTeX added
local function format_columns_latex(elem)

  -- make content into a List object
  pandoc.List:new(elem.content)

  -- how many columns?
  number_columns = determine_column_count(elem)

  -- set properties and insert LaTeX environment
  --  we wrap the entire environment in `{...}` to
  --  ensure properties (gap, rule) don't carry
  --  over to following columns

  local latex_begin = '{'
  local latex_end = '}'
  local ragged = options.raggedcolumns

  -- override global ragged setting?
  if elem.classes:includes('ragged')
      or elem.classes:includes('raggedcolumns')
      or elem.classes:includes('ragged-columns') then
        ragged = true
  elseif elem.classes:includes('justified')
      or elem.classes:includes('justifiedcolumns')
      or elem.classes:includes('justified-columns') then
        ragged = false
  end
  if ragged then
    latex_begin = latex_begin..'\\raggedcolumns'
  end

  if elem.attr.attributes then

    if elem.attr.attributes["column-gap"] then

      local latex_value = ensures_latex_length(
        elem.attr.attributes["column-gap"])

      if latex_value then

        latex_begin = latex_begin ..
          "\\setlength{\\columnsep}{" .. latex_value .. "}\n"

      end

      -- remove the `column-gap` attribute
      elem = set_attribute(elem, "column-gap", nil)

    end

    if elem.attr.attributes["column-rule"] then

      -- converts CSS value string to LaTeX values
      local latex_values = css_values_to_latex(
        elem.attr.attributes["column-rule"])

      if latex_values["length"] then

        latex_begin = latex_begin ..
          "\\setlength{\\columnseprule}{" ..
          latex_values["length"] .. "}\n"

      end

      if latex_values["color"] then

        latex_begin = latex_begin ..
          "\\renewcommand{\\columnseprulecolor}{\\color{" ..
          latex_values["color"] .. "}}\n"

      end


      -- remove the `column-rule` attribute
      elem = set_attribute(elem, "column-rule", nil)

    end

  end

  latex_begin = latex_begin ..
    "\\begin{multicols}{" .. number_columns .. "}\n"
  latex_end = "\\end{multicols}\n" .. latex_end

  elem.content:insert(1, pandoc.RawBlock('latex', latex_begin))
  elem.content:insert(pandoc.RawBlock('latex', latex_end))

  -- process blocks contained in `elem`
  --  turn any explicit columnbreaks into LaTeX markup
  --  turn `column-span` Divs into LaTeX markup

  filter = {

    Div = function(el)

      if el.classes:includes("columnbreak") then
        return pandoc.RawBlock('latex', "\\columnbreak\n")
      end

      if el.classes:includes("column-span-to-be-processed") then
        return format_colspan_latex(el, number_columns)
      end

    end

  }

  elem = pandoc.walk_block(elem, filter)

  return elem

end


--- Formats columns for html output.
-- Uses CSS3 style added to the elements themselves.
-- @param elem Pandoc element (Div of `columns` style)
-- @return elem with suitable html attributes
local function format_columns_html(elem)

  -- how many columns?
  number_columns = determine_column_count(elem)

  -- add properties to the `columns` Div

  elem = add_to_html_style(elem, 'column-count: ' .. number_columns)
  elem = set_attribute(elem, 'column-count', nil)

  if elem.attr.attributes then

    if elem.attr.attributes["column-gap"] then

      elem = add_to_html_style(elem, 'column-gap: ' ..
        elem.attr.attributes["column-gap"])

      -- remove the `column-gap` attribute
      elem = set_attribute(elem, "column-gap")

    end

    if elem.attr.attributes["column-rule"] then

      elem = add_to_html_style(elem, 'column-rule: ' ..
        elem.attr.attributes["column-rule"])

      -- remove the `column-rule` attribute
      elem = set_attribute(elem, "column-rule", nil)

    end

  end

  -- convert any explicit columnbreaks in CSS markup

  filter = {

    Div = function(el)

      -- format column-breaks
      if el.classes:includes("columnbreak") then

        el = add_to_html_style(el, 'break-after: column')

        -- remove columbreaks class to avoid double processing
        -- when nested
        -- clean up already-counted tag
        el = remove_class(el, "columnbreak")
        el = remove_class(el, "columnbreak_already_counted")

      -- format column-spans
      elseif el.classes:includes("column-span-to-be-processed") then

        el = add_to_html_style(el, 'column-span: all')

        -- remove column-span-to-be-processed class to avoid double processing
        -- add column-span class to allow for styling
        el = add_class(el, "column-span")
        el = remove_class(el, "column-span-to-be-processed")

      end

      return el

    end

  }

  elem = pandoc.walk_block(elem, filter)

  return elem

end


-- # Main filters

--- Formating filter.
-- Applied last, converts prepared columns in target output formats
-- @field Div looks for `columns` class
format_filter = {

  Div = function (element)

    -- pick up `columns` Divs for formatting
    if element.classes:includes ("columns") then

      if FORMAT:match('latex') then
        element = format_columns_latex(element)
      elseif FORMAT:match('html.*') then
        element = format_columns_html(element)
      end

      return element

    end

  end
}

--- Preprocessing filter.
-- Processes meta-data fields and walks the document to pre-process
-- columns blocks. Determine how many columns they contain, tags the
-- last column Div, etc. Avoids double-counting when columns environments
-- are nested.
-- @field Div looks for `columns` class
-- @field Meta processes the metadata block
preprocess_filter = {

  Div = function (element)

      -- send `columns` Divs to pre-processing
      if element.classes:includes("columns") then
        return preprocess_columns(element)
      end

    end,

  Meta = function (meta)

    return process_meta(meta)

  end
}

--- Syntactic sugar filter.
-- Provides alternative ways of specifying columns properties.
-- Kept separate from the pre-processing filter for clarity.
-- @field Div looks for Div of classes `columns` (and related) and `column-span`
syntactic_sugar_filter = {

  Div = function(element)

      -- convert "two-columns" into `columns` Divs
      for _,class in pairs(element.classes) do

        -- match xxxcolumns, xxx_columns, xxx-columns
        -- if xxx is the name of a number, make
        -- a `columns` div and set its `column-count` attribute
        local number = number_by_name(
          string.match(class,'(%a+)[_%-]?columns$')
          )

        if number then

          element = set_attribute(element,
              "column-count", tostring(number))
          element = remove_class(element, class)
          element = add_class(element, "columns")

        end

      end

      -- allows different ways of specifying `columns` attributes
      if element.classes:includes('columns') then

        element = consolidate_colattrib_aliases(element)

      end

      -- `column-span` syntax
      -- mark up as "to-be-processed" to avoid
      --  double processing when nested
      if element.classes:includes('column-span') or
        element.classes:includes('columnspan') then

        element = add_class(element, 'column-span-to-be-processed')
        element = remove_class(element, 'column-span')
        element = remove_class(element, 'columnspan')

      end

    return element

  end

}

--- Read options filter
read_options_filter = {
  Meta = function (meta)

    if not meta then return end

    -- global vertical ragged / justified settings
    if meta.raggedcolumns or meta['ragged-columns'] then
      options.raggedcolumns = true
    elseif meta.justifiedcolumns or meta['justified-columns'] then
      options.raggedcolumns = false
    end

  end
}

-- Main statement returns filters only if the
-- target format matches our list. The filters
-- returned are applied in the following order:
-- 1. `syntatic_sugar_filter` deals with multiple syntax
-- 2. `preprocessing_filter` converts all explicit
--    columnbreaks into a common syntax and tags
--    those that are already counted. We must do
--    that for all `columns` environments before
--    turning any break back into LaTeX `\columnbreak` blocks
--    otherwise we mess up the count in nested `columns` Divs.
-- 3. `format_filter` formats the columns after the counting
--    has been done
if format_matches(target_formats) then
  return {
    read_options_filter,
    syntactic_sugar_filter,
    preprocess_filter,
    format_filter
  }
else
  return
end
