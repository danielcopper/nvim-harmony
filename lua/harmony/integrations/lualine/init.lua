---Lualine integration for nvim-harmony
---Generates lualine theme based on active colorscheme
return {
  name = "lualine",
  plugin_name = "lualine",

  ---Generate lualine theme
  ---@param colors table Color palette from extraction
  ---@param config table Plugin-specific configuration (merged)
  ---@return table Lualine theme table
  setup = function(colors, config)
    local color_utils = require("harmony.colors")

    -- Determine background colors based on transparency
    local bg = config.transparency.enabled and "NONE" or colors.bg
    local float_bg = config.transparency.enabled and "NONE" or colors.float_bg

    -- Generate section backgrounds with subtle variations
    -- Section 'a' will be mode-colored (defined per mode below)
    -- Sections b,c have progressively lighter/darker backgrounds
    local section_b_bg = config.transparency.enabled and "NONE"
      or color_utils.lighten(colors.bg, 5)
    local section_c_bg = bg

    -- For right side (x,y,z), use similar progression
    local section_x_bg = section_c_bg
    local section_y_bg = section_b_bg
    local section_z_bg = config.transparency.enabled and "NONE"
      or color_utils.lighten(colors.bg, 8)

    -- Common foreground
    local fg = colors.fg

    -- Define mode-specific colors for section 'a'
    -- Normal mode: blue/accent_1
    local normal_color = colors.accent_1 or colors.info
    -- Insert mode: green
    local insert_color = colors.catppuccin and colors.catppuccin.green
      or color_utils.lighten(colors.info, 20)
    -- Visual mode: purple/magenta
    local visual_color = colors.catppuccin and colors.catppuccin.mauve
      or colors.accent_3 or color_utils.lighten(colors.warn, 20)
    -- Replace mode: red
    local replace_color = colors.error
    -- Command mode: yellow
    local command_color = colors.warn

    -- Text color for section 'a' (dark text on colored background)
    local section_a_fg = colors.bg_darker or colors.bg

    -- Build theme table
    local theme = {
      normal = {
        a = { fg = section_a_fg, bg = normal_color, gui = "bold" },
        b = { fg = fg, bg = section_b_bg },
        c = { fg = fg, bg = section_c_bg },
        x = { fg = fg, bg = section_x_bg },
        y = { fg = fg, bg = section_y_bg },
        z = { fg = fg, bg = section_z_bg },
      },
      insert = {
        a = { fg = section_a_fg, bg = insert_color, gui = "bold" },
        b = { fg = fg, bg = section_b_bg },
        c = { fg = fg, bg = section_c_bg },
        x = { fg = fg, bg = section_x_bg },
        y = { fg = fg, bg = section_y_bg },
        z = { fg = fg, bg = section_z_bg },
      },
      visual = {
        a = { fg = section_a_fg, bg = visual_color, gui = "bold" },
        b = { fg = fg, bg = section_b_bg },
        c = { fg = fg, bg = section_c_bg },
        x = { fg = fg, bg = section_x_bg },
        y = { fg = fg, bg = section_y_bg },
        z = { fg = fg, bg = section_z_bg },
      },
      replace = {
        a = { fg = section_a_fg, bg = replace_color, gui = "bold" },
        b = { fg = fg, bg = section_b_bg },
        c = { fg = fg, bg = section_c_bg },
        x = { fg = fg, bg = section_x_bg },
        y = { fg = fg, bg = section_y_bg },
        z = { fg = fg, bg = section_z_bg },
      },
      command = {
        a = { fg = section_a_fg, bg = command_color, gui = "bold" },
        b = { fg = fg, bg = section_b_bg },
        c = { fg = fg, bg = section_c_bg },
        x = { fg = fg, bg = section_x_bg },
        y = { fg = fg, bg = section_y_bg },
        z = { fg = fg, bg = section_z_bg },
      },
      inactive = {
        a = { fg = colors.comment or fg, bg = bg },
        b = { fg = colors.comment or fg, bg = bg },
        c = { fg = colors.comment or fg, bg = bg },
        x = { fg = colors.comment or fg, bg = bg },
        y = { fg = colors.comment or fg, bg = bg },
        z = { fg = colors.comment or fg, bg = bg },
      },
    }

    -- Store theme for later retrieval
    _G._harmony_lualine_theme = theme

    return {}  -- No highlight groups needed, theme is applied via preset
  end,

  ---Get the generated theme
  ---@return table|nil Lualine theme table
  get_theme = function()
    return _G._harmony_lualine_theme
  end,
}
