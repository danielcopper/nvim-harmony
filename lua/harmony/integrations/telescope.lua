---Telescope.nvim integration for nvim-harmony
---Provides consistent theming for Telescope fuzzy finder
return {
  name = "telescope",
  plugin_name = "telescope",

  ---Generate telescope highlight groups
  ---@param colors table Color palette from extraction
  ---@param config table Plugin-specific configuration (merged)
  ---@return table Highlight groups to apply
  setup = function(colors, config)
    local utils = require("harmony.utils")

    -- Compute common colors
    local border_color = utils.compute_border_color(colors, config)
    local selection_bg = utils.get_selection_bg(colors)
    local matching_fg = utils.get_matching_fg(colors)
    local prompt_bg = utils.get_distinct_bg(colors, colors.float_bg, 3)
    local bg = config.transparency.enabled and "NONE" or colors.float_bg

    -- Title backgrounds (inspired by NvChad base46)
    -- Use specific colors for each title section
    -- For catppuccin: maroon (dark red), green, sapphire (blue-green)
    local title_fg = colors.bg_darker or colors.bg or "#000000" -- Dark text for colored backgrounds

    -- Get catppuccin-specific colors if available, otherwise use semantic colors
    local prompt_title_bg = (colors.catppuccin and colors.catppuccin.maroon) or colors.error
    local preview_title_bg = (colors.catppuccin and colors.catppuccin.green) or colors.accent_1
    local results_title_bg = (colors.catppuccin and colors.catppuccin.sapphire) or colors.accent_2

    return {
      -- Main window
      TelescopeNormal = {
        bg = bg,
        fg = colors.float_fg,
      },

      TelescopeBorder = {
        fg = border_color,
        bg = bg,
      },

      -- Prompt (input area)
      TelescopePromptNormal = {
        bg = config.transparency.enabled and "NONE" or prompt_bg,
        fg = colors.float_fg,
      },

      TelescopePromptBorder = {
        fg = border_color,
        bg = config.transparency.enabled and "NONE" or prompt_bg,
      },

      TelescopePromptTitle = {
        fg = title_fg,
        bg = config.transparency.enabled and "NONE" or prompt_title_bg,
        bold = true,
      },

      TelescopePromptPrefix = {
        fg = prompt_title_bg,
        bg = config.transparency.enabled and "NONE" or prompt_bg,
      },

      TelescopePromptCounter = {
        fg = utils.get_dimmed_fg(colors),
        bg = config.transparency.enabled and "NONE" or prompt_bg,
      },

      -- Results (list area)
      TelescopeResultsNormal = {
        bg = bg,
        fg = colors.float_fg,
      },

      TelescopeResultsBorder = {
        fg = border_color,
        bg = bg,
      },

      TelescopeResultsTitle = {
        fg = title_fg,
        bg = config.transparency.enabled and "NONE" or results_title_bg,
        bold = true,
      },

      -- Preview (preview area)
      TelescopePreviewNormal = {
        bg = bg,
        fg = colors.float_fg,
      },

      TelescopePreviewBorder = {
        fg = border_color,
        bg = bg,
      },

      TelescopePreviewTitle = {
        fg = title_fg,
        bg = config.transparency.enabled and "NONE" or preview_title_bg,
        bold = true,
      },

      -- Selection
      TelescopeSelection = {
        bg = selection_bg,
        fg = colors.float_fg,
        bold = true,
      },

      TelescopeSelectionCaret = {
        fg = colors.accent_1 or colors.info,
        bg = selection_bg,
        bold = true,
      },

      -- Matching text (fuzzy match highlights)
      TelescopeMatching = {
        fg = matching_fg,
        bold = true,
      },

      -- Line numbers in results/preview
      TelescopeResultsLineNr = {
        fg = colors.line_nr,
        bg = bg,
      },

      TelescopePreviewLine = {
        bg = selection_bg,
      },

      -- Special items
      TelescopeResultsComment = {
        fg = utils.get_dimmed_fg(colors),
        bg = bg,
      },

      TelescopeResultsIdentifier = {
        fg = colors.accent_3 or colors.keyword,
        bg = bg,
      },

      TelescopeResultsConstant = {
        fg = colors.accent_1 or colors.string,
        bg = bg,
      },

      TelescopeResultsField = {
        fg = colors.accent_2 or colors.func,
        bg = bg,
      },

      TelescopeResultsFunction = {
        fg = colors.accent_2 or colors.func,
        bg = bg,
      },

      TelescopeResultsMethod = {
        fg = colors.accent_2 or colors.func,
        bg = bg,
      },

      TelescopeResultsOperator = {
        fg = colors.fg,
        bg = bg,
      },

      TelescopeResultsStruct = {
        fg = colors.accent_3 or colors.keyword,
        bg = bg,
      },

      TelescopeResultsVariable = {
        fg = colors.fg,
        bg = bg,
      },

      -- File icons and paths
      TelescopeResultsFileIcon = {
        fg = colors.accent_1,
        bg = bg,
      },

      TelescopeResultsNumber = {
        fg = colors.accent_1 or colors.string,
        bg = bg,
      },

      -- Special cases
      TelescopeResultsDiffAdd = {
        fg = colors.info,
        bg = bg,
      },

      TelescopeResultsDiffChange = {
        fg = colors.warn,
        bg = bg,
      },

      TelescopeResultsDiffDelete = {
        fg = colors.error,
        bg = bg,
      },
    }
  end,
}
