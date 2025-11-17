---Noice.nvim integration for nvim-harmony
---Provides consistent theming for noice UI replacement plugin
return {
  name = "noice",
  plugin_name = "noice",

  ---Generate noice highlight groups
  ---@param colors table Color palette from extraction
  ---@param config table Plugin-specific configuration (merged)
  ---@return table Highlight groups to apply
  setup = function(colors, config)
    local utils = require("harmony.utils")

    -- Compute common colors
    local border_color = utils.compute_border_color(colors, config)
    local selection_bg = utils.get_selection_bg(colors)
    local bg = config.transparency.enabled and "NONE" or colors.float_bg
    local dimmed_fg = utils.get_dimmed_fg(colors)

    return {
      -- Main popup/window backgrounds
      NoicePopup = {
        bg = bg,
        fg = colors.float_fg,
      },

      NoicePopupBorder = {
        fg = border_color,
        bg = bg,
      },

      NoiceSplit = {
        bg = bg,
        fg = colors.float_fg,
      },

      NoiceSplitBorder = {
        fg = border_color,
        bg = bg,
      },

      -- Cmdline
      NoiceCmdline = {
        fg = colors.float_fg,
        bg = bg,
      },

      NoiceCmdlinePopup = {
        bg = bg,
        fg = colors.float_fg,
      },

      NoiceCmdlinePopupBorder = {
        fg = border_color,
        bg = bg,
      },

      NoiceCmdlinePopupBorderSearch = {
        fg = colors.accent_2 or colors.info,
        bg = bg,
      },

      NoiceCmdlinePopupBorderFilter = {
        fg = colors.warn,
        bg = bg,
      },

      NoiceCmdlinePopupBorderHelp = {
        fg = colors.info,
        bg = bg,
      },

      NoiceCmdlinePopupBorderLua = {
        fg = colors.accent_3 or colors.keyword,
        bg = bg,
      },

      NoiceCmdlinePopupBorderCalculator = {
        fg = colors.accent_1,
        bg = bg,
      },

      NoiceCmdlinePopupBorderCmdline = {
        fg = border_color,
        bg = bg,
      },

      NoiceCmdlinePopupBorderInput = {
        fg = colors.accent_1,
        bg = bg,
      },

      NoiceCmdlinePopupBorderIncRename = {
        fg = colors.warn,
        bg = bg,
      },

      NoiceCmdlineIcon = {
        fg = colors.accent_1 or colors.info,
      },

      NoiceCmdlineIconSearch = {
        fg = colors.accent_2 or colors.info,
      },

      -- Completion/Popupmenu
      NoicePopupmenu = {
        bg = bg,
        fg = colors.float_fg,
      },

      NoicePopupmenuBorder = {
        fg = border_color,
        bg = bg,
      },

      NoicePopupmenuSelected = {
        bg = selection_bg,
        fg = colors.float_fg,
        bold = true,
      },

      NoicePopupmenuMatch = {
        fg = colors.accent_1 or colors.info,
        bold = true,
      },

      -- Scrollbar
      NoiceScrollbar = {
        fg = border_color,
        bg = bg,
      },

      NoiceScrollbarThumb = {
        fg = colors.accent_1 or colors.info,
        bg = bg,
      },

      -- Message levels
      NoiceFormatLevelError = {
        fg = colors.error,
      },

      NoiceFormatLevelWarn = {
        fg = colors.warn,
      },

      NoiceFormatLevelInfo = {
        fg = colors.info,
      },

      NoiceFormatLevelDebug = {
        fg = dimmed_fg,
      },

      NoiceFormatLevelTrace = {
        fg = dimmed_fg,
      },

      NoiceFormatLevelOff = {
        fg = dimmed_fg,
      },

      -- Format elements
      NoiceFormatTitle = {
        fg = colors.accent_1 or colors.info,
        bold = true,
      },

      NoiceFormatDate = {
        fg = dimmed_fg,
      },

      NoiceFormatEvent = {
        fg = colors.accent_2,
      },

      NoiceFormatKind = {
        fg = colors.accent_3,
      },

      NoiceFormatProgressDone = {
        fg = colors.info,
        bold = true,
      },

      NoiceFormatProgressTodo = {
        fg = dimmed_fg,
      },

      -- Virtual text
      NoiceVirtualText = {
        fg = colors.accent_2 or colors.info,
        italic = true,
      },

      -- Mini view
      NoiceMini = {
        bg = bg,
        fg = colors.float_fg,
      },

      -- Confirmation
      NoiceConfirm = {
        bg = bg,
        fg = colors.float_fg,
      },

      NoiceConfirmBorder = {
        fg = border_color,
        bg = bg,
      },

      -- LSP-related
      NoiceLspProgressClient = {
        fg = colors.accent_1 or colors.info,
      },

      NoiceLspProgressSpinner = {
        fg = colors.accent_2 or colors.info,
      },

      NoiceLspProgressTitle = {
        fg = colors.float_fg,
      },

      -- Completion item kinds (link to existing CmpItemKind groups)
      NoiceCompletionItemKindDefault = { link = "CmpItemKind" },
      NoiceCompletionItemKindClass = { link = "CmpItemKindClass" },
      NoiceCompletionItemKindColor = { link = "CmpItemKindColor" },
      NoiceCompletionItemKindConstant = { link = "CmpItemKindConstant" },
      NoiceCompletionItemKindConstructor = { link = "CmpItemKindConstructor" },
      NoiceCompletionItemKindEnum = { link = "CmpItemKindEnum" },
      NoiceCompletionItemKindEnumMember = { link = "CmpItemKindEnumMember" },
      NoiceCompletionItemKindEvent = { link = "CmpItemKindEvent" },
      NoiceCompletionItemKindField = { link = "CmpItemKindField" },
      NoiceCompletionItemKindFile = { link = "CmpItemKindFile" },
      NoiceCompletionItemKindFolder = { link = "CmpItemKindFolder" },
      NoiceCompletionItemKindFunction = { link = "CmpItemKindFunction" },
      NoiceCompletionItemKindInterface = { link = "CmpItemKindInterface" },
      NoiceCompletionItemKindKeyword = { link = "CmpItemKindKeyword" },
      NoiceCompletionItemKindMethod = { link = "CmpItemKindMethod" },
      NoiceCompletionItemKindModule = { link = "CmpItemKindModule" },
      NoiceCompletionItemKindOperator = { link = "CmpItemKindOperator" },
      NoiceCompletionItemKindProperty = { link = "CmpItemKindProperty" },
      NoiceCompletionItemKindReference = { link = "CmpItemKindReference" },
      NoiceCompletionItemKindSnippet = { link = "CmpItemKindSnippet" },
      NoiceCompletionItemKindStruct = { link = "CmpItemKindStruct" },
      NoiceCompletionItemKindText = { link = "CmpItemKindText" },
      NoiceCompletionItemKindTypeParameter = { link = "CmpItemKindTypeParameter" },
      NoiceCompletionItemKindUnit = { link = "CmpItemKindUnit" },
      NoiceCompletionItemKindValue = { link = "CmpItemKindValue" },
      NoiceCompletionItemKindVariable = { link = "CmpItemKindVariable" },

      NoiceCompletionItemMenu = {
        fg = dimmed_fg,
      },

      NoiceCompletionItemWord = {
        fg = colors.float_fg,
      },
    }
  end,
}
