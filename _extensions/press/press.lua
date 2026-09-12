-- press: choose a LaTeX style, apply colour overrides, and fill the
-- title-page fields. Everything is injected into the LaTeX preamble in a fixed
-- order: common layout, style, colour overrides, cover fields.

local BUILTIN_STYLES = { lucid = true, classic = true, minimal = true }
local DEFAULT_STYLE = "lucid"

-- Former style names that still resolve, with a deprecation warning.
local STYLE_ALIASES = { dact = "lucid" }

-- Metadata key -> LaTeX colour name. Both spellings of the compound roles work.
local COLOR_ROLES = {
  ["ink"] = "pressink",
  ["strong"] = "pressstrong",
  ["accent"] = "pressaccent",
  ["accent-dark"] = "pressaccentdark",
  ["accentdark"] = "pressaccentdark",
  ["accent-light"] = "pressaccentlight",
  ["accentlight"] = "pressaccentlight",
  ["secondary"] = "presssecondary",
  ["muted"] = "pressmuted",
  ["rule"] = "pressrule",
  ["soft"] = "presssoft",
}

-- `press.cover` key -> macro read by the style's \maketitle.
local COVER_FIELDS = {
  { key = "title", macro = "presstitle" },
  { key = "subtitle", macro = "presssubtitle" },
  { key = "author", macro = "pressauthor" },
  { key = "institution", macro = "pressinstitution" },
  { key = "series", macro = "pressseries" },
  { key = "label", macro = "presslabel" },
  { key = "tagline", macro = "presstagline" },
  { key = "edition", macro = "pressedition" },
}

local function fail(message)
  error("press: " .. message, 0)
end

local function read_file(path)
  local handle = io.open(path, "r")
  if handle == nil then
    return nil
  end
  local content = handle:read("a")
  handle:close()
  return content
end

local function trim(text)
  return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Render a metadata value as LaTeX. A single paragraph is unwrapped so the
-- result can sit inside a line of the title page; lists are joined with
-- \presssep, which each style defines.
local function to_latex(value)
  local kind = pandoc.utils.type(value)
  if kind == "List" then
    local parts = {}
    for _, item in ipairs(value) do
      table.insert(parts, to_latex(item))
    end
    return table.concat(parts, "\\presssep{}")
  end

  local blocks
  if kind == "Inlines" then
    blocks = { pandoc.Plain(value) }
  elseif kind == "Blocks" then
    blocks = value
    if #blocks == 1 and (blocks[1].t == "Para" or blocks[1].t == "Plain") then
      blocks = { pandoc.Plain(blocks[1].content) }
    end
  else
    blocks = { pandoc.Plain({ pandoc.Str(pandoc.utils.stringify(value)) }) }
  end
  return trim(pandoc.write(pandoc.Pandoc(blocks), "latex"))
end

local function style_name(options)
  if options == nil or options.style == nil then
    return DEFAULT_STYLE
  end
  local name = pandoc.utils.stringify(options.style)
  local renamed = STYLE_ALIASES[name]
  if renamed ~= nil then
    quarto.log.warning("press: the style '" .. name .. "' is now called '" .. renamed
      .. "'. The old name will stop working in version 1.0.")
    return renamed
  end
  return name
end

local function resolve_custom_style(path)
  if pandoc.path.is_absolute(path) then
    return read_file(path)
  end
  local bases = {}
  if quarto.project ~= nil and quarto.project.directory ~= nil then
    table.insert(bases, quarto.project.directory)
  end
  if quarto.doc.input_file ~= nil then
    table.insert(bases, pandoc.path.directory(quarto.doc.input_file))
  end
  table.insert(bases, pandoc.system.get_working_directory())
  for _, base in ipairs(bases) do
    local content = read_file(pandoc.path.join({ base, path }))
    if content ~= nil then
      return content
    end
  end
  return nil
end

local function style_source(name)
  if BUILTIN_STYLES[name] then
    return read_file(quarto.utils.resolve_path("styles/" .. name .. ".tex"))
  end
  if name:match("%.tex$") then
    local content = resolve_custom_style(name)
    if content == nil then
      fail("style file '" .. name .. "' not found (paths are relative to the project or document)")
    end
    return content
  end
  fail("unknown style '" .. name .. "'. Use lucid, classic, minimal, or a path to a .tex file")
end

local function color_overrides(colors)
  if colors == nil then
    return ""
  end
  local lines = {}
  for key, value in pairs(colors) do
    local latex_name = COLOR_ROLES[key]
    if latex_name == nil then
      fail("unknown colour role '" .. key .. "' in press.colors")
    end
    local hex = pandoc.utils.stringify(value):gsub("^#", ""):upper()
    if not hex:match("^%x%x%x%x%x%x$") then
      fail("press.colors." .. key .. " must be a six-digit hex colour, got '" .. hex .. "'")
    end
    table.insert(lines, "\\definecolor{" .. latex_name .. "}{HTML}{" .. hex .. "}")
  end
  table.sort(lines)
  return table.concat(lines, "\n")
end

local function cover_definitions(cover)
  local lines = {}
  for _, field in ipairs(COVER_FIELDS) do
    local value = ""
    if cover ~= nil and cover[field.key] ~= nil then
      value = to_latex(cover[field.key])
    end
    table.insert(lines, "\\def\\" .. field.macro .. "{" .. value .. "}")
  end
  return table.concat(lines, "\n")
end

function Meta(meta)
  if not quarto.doc.is_format("latex") then
    return meta
  end

  local options = meta.press
  local name = style_name(options)

  quarto.doc.include_text("in-header", read_file(quarto.utils.resolve_path("tex/common.tex")))
  quarto.doc.include_text("in-header", "% press style: " .. name .. "\n" .. style_source(name))

  local overrides = color_overrides(options and options.colors)
  if overrides ~= "" then
    quarto.doc.include_text("in-header", "% press colour overrides\n" .. overrides)
  end

  quarto.doc.include_text("in-header", "% press cover fields\n" .. cover_definitions(options and options.cover))
  return meta
end
