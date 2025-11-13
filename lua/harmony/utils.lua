---@class IntegrationUtils
---Shared utilities for plugin integrations
---Optional helpers that integrations can use for common patterns
local M = {}

local colors_util = require("harmony.colors")

---Compute border color based on border style
---When borders="none", use a distinct background color instead
---@param colors table Color palette
---@param config table Plugin configuration
---@return string Border color (hex)
function M.compute_border_color(colors, config)
  if config.borders == "none" then
    -- No borders: use a slightly different bg color for distinction
    return colors.bg_light
  else
    -- Has borders: use border color
    return colors.border
  end
end

---Get a distinct background color
---Creates a background that's visibly different from the base
---@param colors table Color palette
---@param base_bg string|nil Base background color (defaults to colors.bg)
---@param amount number|nil Amount to darken/lighten (default: 5)
---@return string Distinct background color (hex)
function M.get_distinct_bg(colors, base_bg, amount)
  base_bg = base_bg or colors.bg
  amount = amount or 5

  -- Determine if background is light or dark
  if colors_util.is_light(base_bg) then
    -- Light background: darken it
    return colors_util.darken(base_bg, amount)
  else
    -- Dark background: lighten it
    return colors_util.lighten(base_bg, amount)
  end
end

---Get selection/highlight background color
---Creates a background suitable for selected items
---@param colors table Color palette
---@return string Selection background color (hex)
function M.get_selection_bg(colors)
  -- Use cursor_line color if available, otherwise create a distinct bg
  if colors.cursor_line then
    return colors.cursor_line
  end

  return M.get_distinct_bg(colors, colors.bg, 8)
end

---Get matching text color (for search results, fuzzy matches)
---@param colors table Color palette
---@return string Matching text color (hex)
function M.get_matching_fg(colors)
  -- Use accent color for matching text
  return colors.accent_1 or colors.info
end

---Blend border color with background for subtle borders
---@param colors table Color palette
---@param blend_amount number Blend ratio (0-1), higher = more background
---@return string Blended border color (hex)
function M.get_subtle_border(colors, blend_amount)
  blend_amount = blend_amount or 0.3
  return colors_util.mix(colors.border, colors.bg, blend_amount)
end

---Get dimmed foreground color (for less important text)
---@param colors table Color palette
---@return string Dimmed foreground color (hex)
function M.get_dimmed_fg(colors)
  return colors.muted or colors.fg_dark
end

---Create a set of standard window highlight groups
---Common pattern: Normal, Border, Title for floating windows
---@param prefix string Highlight group prefix (e.g., "Telescope")
---@param colors table Color palette
---@param config table Plugin configuration
---@return table Highlight groups
function M.create_window_highlights(prefix, colors, config)
  local border_color = M.compute_border_color(colors, config)

  return {
    [prefix .. "Normal"] = {
      bg = colors.float_bg,
      fg = colors.float_fg,
    },
    [prefix .. "Border"] = {
      fg = border_color,
      bg = config.transparency.enabled and "NONE" or colors.float_bg,
    },
    [prefix .. "Title"] = {
      fg = colors.accent_2 or colors.info,
      bold = true,
    },
  }
end

return M
