---@class Icons
---Centralized icon definitions for nvim-harmony
---Requires Nerd Fonts to display correctly
local M = {}

---Diagnostic icons (errors, warnings, info, hints)
M.diagnostics = {
  error = "󰅚",
  warn = "󰀪",
  info = "󰋽",
  hint = "󰌶",
}

---LSP completion item kind icons
M.lsp = {
  kinds = {
    Array         = " ",
    Boolean       = "󰨙 ",
    Class         = " ",
    Codeium       = "󰘦 ",
    Collapsed     = " ",
    Color         = "󰏘 ",
    Constant      = "󰏿 ",
    Constructor   = " ",
    Control       = " ",
    Copilot       = " ",
    Enum          = " ",
    EnumMember    = " ",
    Event         = " ",
    Field         = " ",
    File          = "󰈙 ",
    Folder        = "󰉋 ",
    Function      = "󰊕 ",
    Interface     = " ",
    Key           = " ",
    Keyword       = "󰌋 ",
    Method        = "󰊕 ",
    Module        = " ",
    Namespace     = "󰦮 ",
    Null          = " ",
    Number        = "󰎠 ",
    Object        = " ",
    Operator      = " ",
    Package       = " ",
    Property      = "󰜢 ",
    Reference     = " ",
    Snippet       = "󱄽 ",
    String        = " ",
    Struct        = "󰆼 ",
    Supermaven    = " ",
    TabNine       = "󰏚 ",
    Text          = " ",
    TypeParameter = " ",
    Unit          = "󰑭 ",
    Value         = "󰎠 ",
    Variable      = "󰀫 ",
  }
}

---Git status icons
M.git = {
  add       = " ",
  change    = " ",
  delete    = " ",
  renamed   = "󰁕 ",
  untracked = " ",
  ignored   = "󰈉 ",
  staged    = " ",
  conflict  = " ",
  branch    = " ",
}

---Debug Adapter Protocol (DAP) icons
M.dap = {
  breakpoint = " ",
  breakpoint_condition = " ",
  breakpoint_rejected = " ",
  stopped = "󰁕 ",
  log_point = ".>",
}

---General UI icons
M.ui = {
  folder = "󰉋 ",
  folder_open = " ",
  folder_empty = " ",
  file = "󰈙 ",
  symlink_file = " ",
  symlink_folder = " ",
  lock = " ",
  package = "󰏖 ",
  search = " ",
  close = "󰅗 ",
  check = " ",
  prompt = "󰠗 ",
  modified = "● ",
  arrow_right = " ",
  arrow_left = " ",
  spinner = " ",
  loading = "󰝲 ",
  foldopen = "",
  foldclose = "",
  foldsep = "│",
  -- Fillchars (vim.opt.fillchars)
  eob = " ",
  diff = "╱",
  fold = "·",
  fold_minimal = " ",
}

return M
