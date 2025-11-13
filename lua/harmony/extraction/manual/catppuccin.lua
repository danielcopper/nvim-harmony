---Manual color extractor for Catppuccin colorscheme
---Provides high-quality color mappings using Catppuccin's palette API
---@param variant string|nil Catppuccin variant (mocha, macchiato, frappe, latte)
---@return table Color palette matching harmony's structure
return function(variant)
  variant = variant or "mocha"

  -- Get catppuccin palette
  local has_catppuccin, palettes = pcall(require, "catppuccin.palettes")
  if not has_catppuccin then
    error("Catppuccin palette not found. Is catppuccin installed?")
  end

  local palette = palettes.get_palette(variant)

  -- Map to harmony's standardized structure
  return {
    -- Background variants (darkest to lightest)
    bg_darker = palette.crust,    -- Darkest background
    bg_dark = palette.mantle,     -- Dark background
    bg = palette.base,            -- Main background
    bg_light = palette.surface0,  -- Light background
    bg_lighter = palette.surface1, -- Lighter background

    -- Float-specific
    float_bg = palette.mantle,
    float_fg = palette.text,

    -- Foreground variants
    fg_dark = palette.subtext0,
    fg = palette.text,
    fg_light = palette.text,

    -- UI elements
    border = palette.overlay0,
    muted = palette.overlay1,
    line_nr = palette.overlay0,
    cursor_line = palette.surface0,

    -- Semantic colors
    error = palette.red,
    warn = palette.yellow,
    info = palette.blue,
    hint = palette.teal,

    -- Accent colors (using catppuccin's vibrant colors)
    accent_1 = palette.green,
    accent_2 = palette.sapphire,
    accent_3 = palette.mauve,

    -- Additional catppuccin colors (available for integrations)
    -- These can be used by integrations that want catppuccin-specific colors
    catppuccin = {
      rosewater = palette.rosewater,
      flamingo = palette.flamingo,
      pink = palette.pink,
      mauve = palette.mauve,
      red = palette.red,
      maroon = palette.maroon,
      peach = palette.peach,
      yellow = palette.yellow,
      green = palette.green,
      teal = palette.teal,
      sky = palette.sky,
      sapphire = palette.sapphire,
      blue = palette.blue,
      lavender = palette.lavender,
    },
  }
end
