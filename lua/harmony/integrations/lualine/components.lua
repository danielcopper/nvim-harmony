-- Pre-built lualine components
-- Users can reference these by name in their harmony config

local icons = require("harmony.icons")

local M = {}

-- Mode indicator with nvim icon (NORMAL, INSERT, VISUAL, etc. - full names)
M.mode = {
  "mode",
  icon = icons.ui.nvim,
}

-- Filename with modified indicator
M.file = {
  "filename",
  symbols = {
    modified = icons.ui.modified,
    readonly = icons.ui.lock,
    unnamed = "[No Name]",
    newfile = "[New]",
  },
}

-- Git branch
M.branch = {
  "branch",
  icon = icons.git.branch,
}

-- Git diff stats (added, modified, removed lines)
M.git = {
  "diff",
  symbols = {
    added = icons.git.add,
    modified = icons.git.change,
    removed = icons.git.delete,
  },
}

-- Diagnostic counts with symbols and colors
M.diagnostics = {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  symbols = {
    error = icons.diagnostics.error .. " ",
    warn = icons.diagnostics.warn .. " ",
    info = icons.diagnostics.info .. " ",
    hint = icons.diagnostics.hint .. " ",
  },
  colored = true,
}

-- LSP status with cog icon
M.lsp = {
  function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
      return ""
    end

    local client_names = {}
    for _, client in ipairs(clients) do
      table.insert(client_names, client.name)
    end

    return icons.ui.lsp .. " " .. table.concat(client_names, ", ")
  end,
  cond = function()
    return #vim.lsp.get_clients({ bufnr = 0 }) > 0
  end,
  color = { fg = "#7aa2f7" }, -- Will be overridden by theme colors
}

-- File encoding (utf-8, etc.)
M.encoding = {
  "encoding",
  icon = "󰉿",
  color = { fg = "#9ece6a" }, -- Will be overridden by theme colors
}

-- File type
M.filetype = {
  "filetype",
  colored = true,
  icon_only = false,
}

-- Line and column position with percentage
M.position = {
  function()
    local line = vim.fn.line(".")
    local col = vim.fn.col(".")
    local total = vim.fn.line("$")
    local percent = math.floor((line / total) * 100)
    return string.format("%s %d:%d %d%%%%", icons.ui.file, line, col, percent)
  end,
  color = { fg = "#bb9af7" }, -- Will be overridden by theme colors
}

-- Progress percentage in file (simple %)
M.progress = {
  "progress",
  icon = icons.ui.file,
}

-- Project root directory
M.root_dir = {
  function()
    local root = vim.fn.getcwd()
    local home = vim.env.HOME
    if root:find(home, 1, true) == 1 then
      root = "~" .. root:sub(#home + 1)
    end
    return icons.ui.folder .. vim.fn.fnamemodify(root, ":t")
  end,
  color = { fg = "#7dcfff" }, -- Will be overridden by theme colors
}

return M
