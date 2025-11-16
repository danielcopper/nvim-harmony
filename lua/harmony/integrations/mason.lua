---Mason.nvim integration for nvim-harmony
---Provides consistent theming for Mason package manager UI
return {
  name = "mason",
  plugin_name = "mason",

  ---Generate mason highlight groups
  ---@param colors table Color palette from extraction
  ---@param config table Plugin-specific configuration (merged)
  ---@return table Highlight groups to apply
  setup = function(colors, config)
    local utils = require("harmony.utils")

    -- Get title text color (dark text on colored backgrounds)
    local title_fg = colors.bg_darker or colors.bg or "#000000"

    -- Get catppuccin-specific colors if available, otherwise use semantic colors
    local header_bg = (colors.catppuccin and colors.catppuccin.maroon) or colors.error
    local highlight_bg = (colors.catppuccin and colors.catppuccin.green) or colors.accent_1
    local muted_bg = colors.bg_light or colors.cursor_line

    return {
      -- Main header (top of Mason window)
      MasonHeader = {
        fg = title_fg,
        bg = header_bg,
        bold = true,
      },

      -- Highlighted text (e.g., package names, important info)
      MasonHighlight = {
        fg = colors.info or colors.accent_2,
      },

      -- Highlighted block (e.g., installed badge, version tags)
      MasonHighlightBlock = {
        fg = title_fg,
        bg = highlight_bg,
      },

      MasonHighlightBlockBold = {
        link = "MasonHighlightBlock",
      },

      -- Secondary headers (section titles)
      MasonHeaderSecondary = {
        link = "MasonHighlightBlock",
      },

      -- Muted/dimmed text (descriptions, secondary info)
      MasonMuted = {
        fg = utils.get_dimmed_fg(colors),
      },

      -- Muted block (de-emphasized sections)
      MasonMutedBlock = {
        fg = utils.get_dimmed_fg(colors),
        bg = config.transparency.enabled and "NONE" or muted_bg,
      },

      -- Additional groups for better integration
      MasonMutedBlockBold = {
        fg = utils.get_dimmed_fg(colors),
        bg = config.transparency.enabled and "NONE" or muted_bg,
        bold = true,
      },

      -- Error state (failed installations)
      MasonError = {
        fg = colors.error,
      },

      -- Warning state
      MasonWarning = {
        fg = colors.warn,
      },

      -- Pending/loading state
      MasonPending = {
        fg = colors.info,
      },

      -- Success state
      MasonSuccess = {
        fg = colors.accent_1 or colors.hint,
      },
    }
  end,
}
