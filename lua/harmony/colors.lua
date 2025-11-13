---@class Colors
---Color manipulation utilities for nvim-harmony
---Provides color space conversions and operations (lighten, darken, etc.)
local M = {}

---Convert hex color to RGB
---@param hex string Hex color (e.g., "#RRGGBB" or "#RGB")
---@return table {r, g, b} RGB values (0-255)
function M.hex_to_rgb(hex)
  -- Remove '#' if present
  hex = hex:gsub("#", "")

  -- Handle short format (#RGB -> #RRGGBB)
  if #hex == 3 then
    hex = hex:gsub("(.)", "%1%1")
  end

  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)

  return { r = r, g = g, b = b }
end

---Convert RGB to hex color
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@return string Hex color "#RRGGBB"
function M.rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", math.floor(r), math.floor(g), math.floor(b))
end

---Convert RGB to HSL
---@param r number Red (0-255)
---@param g number Green (0-255)
---@param b number Blue (0-255)
---@return table {h, s, l} H: 0-360, S: 0-100, L: 0-100
function M.rgb_to_hsl(r, g, b)
  r, g, b = r / 255, g / 255, b / 255

  local max = math.max(r, g, b)
  local min = math.min(r, g, b)
  local h, s, l = 0, 0, (max + min) / 2

  if max == min then
    h, s = 0, 0 -- achromatic
  else
    local d = max - min
    s = l > 0.5 and d / (2 - max - min) or d / (max + min)

    if max == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end

    h = h / 6
  end

  return { h = h * 360, s = s * 100, l = l * 100 }
end

---Convert HSL to RGB
---@param h number Hue (0-360)
---@param s number Saturation (0-100)
---@param l number Lightness (0-100)
---@return table {r, g, b} RGB values (0-255)
function M.hsl_to_rgb(h, s, l)
  h = h / 360
  s = s / 100
  l = l / 100

  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    local function hue2rgb(p, q, t)
      if t < 0 then t = t + 1 end
      if t > 1 then t = t - 1 end
      if t < 1 / 6 then return p + (q - p) * 6 * t end
      if t < 1 / 2 then return q end
      if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
      return p
    end

    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q

    r = hue2rgb(p, q, h + 1 / 3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1 / 3)
  end

  return { r = r * 255, g = g * 255, b = b * 255 }
end

---Lighten a color by percentage
---@param color string Hex color
---@param percentage number Amount to lighten (0-100)
---@return string Lightened hex color
function M.lighten(color, percentage)
  local rgb = M.hex_to_rgb(color)
  local hsl = M.rgb_to_hsl(rgb.r, rgb.g, rgb.b)

  -- Increase lightness
  hsl.l = math.min(100, hsl.l + percentage)

  local new_rgb = M.hsl_to_rgb(hsl.h, hsl.s, hsl.l)
  return M.rgb_to_hex(new_rgb.r, new_rgb.g, new_rgb.b)
end

---Darken a color by percentage
---@param color string Hex color
---@param percentage number Amount to darken (0-100)
---@return string Darkened hex color
function M.darken(color, percentage)
  local rgb = M.hex_to_rgb(color)
  local hsl = M.rgb_to_hsl(rgb.r, rgb.g, rgb.b)

  -- Decrease lightness
  hsl.l = math.max(0, hsl.l - percentage)

  local new_rgb = M.hsl_to_rgb(hsl.h, hsl.s, hsl.l)
  return M.rgb_to_hex(new_rgb.r, new_rgb.g, new_rgb.b)
end

---Saturate a color by percentage
---@param color string Hex color
---@param percentage number Amount to saturate (0-100)
---@return string Saturated hex color
function M.saturate(color, percentage)
  local rgb = M.hex_to_rgb(color)
  local hsl = M.rgb_to_hsl(rgb.r, rgb.g, rgb.b)

  -- Increase saturation
  hsl.s = math.min(100, hsl.s + percentage)

  local new_rgb = M.hsl_to_rgb(hsl.h, hsl.s, hsl.l)
  return M.rgb_to_hex(new_rgb.r, new_rgb.g, new_rgb.b)
end

---Desaturate a color by percentage
---@param color string Hex color
---@param percentage number Amount to desaturate (0-100)
---@return string Desaturated hex color
function M.desaturate(color, percentage)
  local rgb = M.hex_to_rgb(color)
  local hsl = M.rgb_to_hsl(rgb.r, rgb.g, rgb.b)

  -- Decrease saturation
  hsl.s = math.max(0, hsl.s - percentage)

  local new_rgb = M.hsl_to_rgb(hsl.h, hsl.s, hsl.l)
  return M.rgb_to_hex(new_rgb.r, new_rgb.g, new_rgb.b)
end

---Mix two colors together
---@param color1 string First hex color
---@param color2 string Second hex color
---@param ratio number Mix ratio (0-1), 0 = all color1, 1 = all color2
---@return string Mixed hex color
function M.mix(color1, color2, ratio)
  ratio = ratio or 0.5

  local rgb1 = M.hex_to_rgb(color1)
  local rgb2 = M.hex_to_rgb(color2)

  local r = rgb1.r * (1 - ratio) + rgb2.r * ratio
  local g = rgb1.g * (1 - ratio) + rgb2.g * ratio
  local b = rgb1.b * (1 - ratio) + rgb2.b * ratio

  return M.rgb_to_hex(r, g, b)
end

---Determine if a color is light or dark
---Uses relative luminance formula (WCAG)
---@param color string Hex color
---@return boolean True if light, false if dark
function M.is_light(color)
  local rgb = M.hex_to_rgb(color)

  -- Convert to linear RGB
  local function to_linear(c)
    c = c / 255
    if c <= 0.03928 then
      return c / 12.92
    else
      return math.pow((c + 0.055) / 1.055, 2.4)
    end
  end

  local r = to_linear(rgb.r)
  local g = to_linear(rgb.g)
  local b = to_linear(rgb.b)

  -- Calculate relative luminance
  local luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b

  return luminance > 0.5
end

---Calculate WCAG contrast ratio between foreground and background
---@param fg string Foreground hex color
---@param bg string Background hex color
---@return number Contrast ratio (1-21)
function M.contrast_ratio(fg, bg)
  local function get_luminance(color)
    local rgb = M.hex_to_rgb(color)

    -- Convert to linear RGB
    local function to_linear(c)
      c = c / 255
      if c <= 0.03928 then
        return c / 12.92
      else
        return math.pow((c + 0.055) / 1.055, 2.4)
      end
    end

    local r = to_linear(rgb.r)
    local g = to_linear(rgb.g)
    local b = to_linear(rgb.b)

    return 0.2126 * r + 0.7152 * g + 0.0722 * b
  end

  local l1 = get_luminance(fg)
  local l2 = get_luminance(bg)

  -- Ensure l1 is the lighter color
  if l2 > l1 then
    l1, l2 = l2, l1
  end

  return (l1 + 0.05) / (l2 + 0.05)
end

return M
