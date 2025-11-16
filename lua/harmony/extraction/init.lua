---@class Extraction
---Color extraction system for nvim-harmony
---Extracts colors from loaded colorschemes and generates palettes
local M = {}

local colors_util = require("harmony.colors")

---Build colorscheme command from config
---Maps colorscheme names and variants to vim colorscheme commands
---@param cs_config table Colorscheme config { name = "...", variant = "..." }
---@return string Colorscheme command to execute
function M.build_colorscheme_command(cs_config)
  local name = cs_config.name
  local variant = cs_config.variant

  -- Known colorscheme mappings
  local mappings = {
    catppuccin = function(v)
      return "catppuccin-" .. (v or "mocha")
    end,

    gruvbox = function(v)
      if v then
        vim.o.background = v -- "dark" or "light"
      end
      return "gruvbox"
    end,

    tokyonight = function(v)
      return "tokyonight-" .. (v or "night")
    end,

    nord = function()
      return "nord"
    end,

    onedark = function()
      return "onedark"
    end,

    kanagawa = function(v)
      return v and ("kanagawa-" .. v) or "kanagawa"
    end,

    -- Fallback: use name as-is
    default = function(n, _)
      return n
    end,
  }

  local mapper = mappings[name] or mappings.default
  return mapper(variant, name)
end

---Get highlight group with fallback chain
---Tries multiple highlight group names until one with colors is found
---@param fallback_chain table List of highlight group names to try
---@return table|nil Highlight definition { fg, bg, ... } or nil
local function get_hl_safe(fallback_chain)
  for _, hl_name in ipairs(fallback_chain) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_name, link = false })
    if ok and hl and (hl.fg or hl.bg) then
      return hl
    end
  end

  -- Ultimate fallback: Normal group
  return vim.api.nvim_get_hl(0, { name = "Normal", link = false })
end

---Convert nvim highlight color to hex string
---@param color number|nil Color from nvim_get_hl (decimal number)
---@return string|nil Hex color "#RRGGBB" or nil
local function color_to_hex(color)
  if not color then
    return nil
  end

  -- nvim_get_hl returns colors as decimal numbers
  return string.format("#%06x", color)
end

---Extract base colors from core highlight groups
---Queries Neovim highlight groups after colorscheme is loaded
---@return table Base colors extracted from highlight groups
local function extract_base_colors()
  -- Normal group (base colors)
  local normal = get_hl_safe({ "Normal" })
  local bg = color_to_hex(normal.bg) or "#000000"
  local fg = color_to_hex(normal.fg) or "#ffffff"

  -- Float window colors
  local float = get_hl_safe({ "NormalFloat", "Normal" })
  local float_bg = color_to_hex(float.bg) or bg
  local float_fg = color_to_hex(float.fg) or fg

  -- Border color
  local border_hl = get_hl_safe({ "FloatBorder", "VertSplit", "Normal" })
  local border = color_to_hex(border_hl.fg) or fg

  -- Muted/secondary colors
  local comment = get_hl_safe({ "Comment" })
  local muted = color_to_hex(comment.fg) or fg

  local line_nr = get_hl_safe({ "LineNr" })
  local line_nr_fg = color_to_hex(line_nr.fg) or muted

  -- Subtle background variant
  local cursor_line = get_hl_safe({ "CursorLine", "Normal" })
  local cursor_line_bg = color_to_hex(cursor_line.bg) or bg

  -- Diagnostic/semantic colors
  local error_hl = get_hl_safe({ "DiagnosticError", "Error" })
  local error_fg = color_to_hex(error_hl.fg) or "#ff0000"

  local warn_hl = get_hl_safe({ "DiagnosticWarn", "WarningMsg" })
  local warn_fg = color_to_hex(warn_hl.fg) or "#ffaa00"

  local info_hl = get_hl_safe({ "DiagnosticInfo", "Info" })
  local info_fg = color_to_hex(info_hl.fg) or "#00aaff"

  local hint_hl = get_hl_safe({ "DiagnosticHint", "Hint" })
  local hint_fg = color_to_hex(hint_hl.fg) or "#00ff00"

  -- Common syntax colors (for accents)
  local string_hl = get_hl_safe({ "String" })
  local string_fg = color_to_hex(string_hl.fg) or fg

  local func_hl = get_hl_safe({ "Function" })
  local func_fg = color_to_hex(func_hl.fg) or fg

  local keyword_hl = get_hl_safe({ "Keyword" })
  local keyword_fg = color_to_hex(keyword_hl.fg) or fg

  return {
    bg = bg,
    fg = fg,
    float_bg = float_bg,
    float_fg = float_fg,
    border = border,
    muted = muted,
    line_nr = line_nr_fg,
    cursor_line = cursor_line_bg,
    error = error_fg,
    warn = warn_fg,
    info = info_fg,
    hint = hint_fg,
    string = string_fg,
    func = func_fg,
    keyword = keyword_fg,
  }
end

---Generate full color palette with variants
---Creates lighter/darker variants of base colors
---@param base_colors table Base colors from extract_base_colors()
---@return table Complete color palette
local function generate_palette(base_colors)
  return {
    -- Base colors (extracted)
    bg = base_colors.bg,
    fg = base_colors.fg,
    float_bg = base_colors.float_bg,
    float_fg = base_colors.float_fg,
    border = base_colors.border,
    muted = base_colors.muted,
    line_nr = base_colors.line_nr,
    cursor_line = base_colors.cursor_line,

    -- Generated background variants (darkest to lightest)
    bg_darker = colors_util.darken(base_colors.bg, 10),
    bg_dark = colors_util.darken(base_colors.bg, 5),
    bg_light = colors_util.lighten(base_colors.bg, 5),
    bg_lighter = colors_util.lighten(base_colors.bg, 10),

    -- Generated foreground variants
    fg_dark = colors_util.darken(base_colors.fg, 10),
    fg_light = colors_util.lighten(base_colors.fg, 10),

    -- Semantic colors
    error = base_colors.error,
    warn = base_colors.warn,
    info = base_colors.info,
    hint = base_colors.hint,

    -- Accent colors (from syntax)
    accent_1 = base_colors.string,
    accent_2 = base_colors.func,
    accent_3 = base_colors.keyword,
  }
end

---Load colorscheme and extract colors
---Tries manual extractor first, falls back to auto-extraction
---@param cs_config table Colorscheme config { name = "...", variant = "..." }
---@param color_overrides table|nil User color overrides from config
---@return table Color palette
function M.extract(cs_config, color_overrides)
  color_overrides = color_overrides or {}

  -- Load the colorscheme
  local colorscheme_cmd = M.build_colorscheme_command(cs_config)
  local ok, err = pcall(vim.cmd.colorscheme, colorscheme_cmd)

  if not ok then
    vim.schedule(function()
      vim.notify(
        "Failed to load colorscheme '" .. colorscheme_cmd .. "': " .. tostring(err),
        vim.log.levels.ERROR
      )
    end)
    -- Continue with default colors
  end

  -- Try manual extractor first
  local manual_path = "harmony.extraction.manual." .. cs_config.name
  local has_manual, manual_extractor = pcall(require, manual_path)

  local palette
  if has_manual and type(manual_extractor) == "function" then
    -- Use manual extractor
    palette = manual_extractor(cs_config.variant)
    vim.notify("Using manual extractor for " .. cs_config.name, vim.log.levels.DEBUG)
  else
    -- Fallback to auto-extraction
    local base_colors = extract_base_colors()
    palette = generate_palette(base_colors)
    vim.notify("Using auto-extraction for " .. cs_config.name, vim.log.levels.DEBUG)
  end

  -- Apply user color overrides
  palette = vim.tbl_deep_extend("force", palette, color_overrides)

  return palette
end

return M
