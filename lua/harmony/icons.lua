---@class Icons
---Centralized icon definitions for nvim-harmony
---Requires Nerd Fonts to display correctly
local M = {}

---Diagnostic icons (errors, warnings, info, hints)
M.diagnostics = {
  error = "󰅚",
  warn = "󰀪",
  info = "",
  hint = "󰌶",
}

---LSP completion item kind icons
M.lsp = {
  kinds = {
    Text = "󰉿",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰜢",
    Variable = "󰀫",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "󰑭",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈙",
    Reference = "󰈇",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "󰙅",
    Event = "",
    Operator = "󰆕",
    TypeParameter = "",
  },
}

---Git status icons
M.git = {
  add = "",
  change = "",
  delete = "",
  renamed = "",
  untracked = "",
  ignored = "",
  staged = "",
  conflict = "",
}

---Debug Adapter Protocol (DAP) icons
M.dap = {
  breakpoint = "",
  breakpoint_condition = "",
  breakpoint_rejected = "",
  stopped = "",
  log_point = "",
}

---General UI icons
M.ui = {
  folder = "",
  folder_open = "",
  folder_empty = "",
  file = "",
  symlink = "",
  lock = "",
  package = "",
  search = "",
  close = "",
  check = "",
  prompt = "",
  modified = "●",
}

return M
