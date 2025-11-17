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

-- Git diff stats (current file only, from gitsigns)
M.git_file = {
  "diff",
  colored = true,
  symbols = {
    added = icons.git.add,
    modified = icons.git.change,
    removed = icons.git.delete,
  },
  -- Let lualine's diff component handle visibility
  -- It will automatically hide for non-file buffers and files without changes
}

-- Git diff stats (repository-wide)
-- NOTE: This cannot use lualine's "diff" component because that only supports gitsigns (per-buffer)
-- We need a custom function to get repository-wide stats
M.git_repo = {
  function()
    -- Get repository-wide git status
    local handle = io.popen("git -C " .. vim.fn.getcwd() .. " diff --shortstat 2>/dev/null")
    if not handle then return "" end

    local result = handle:read("*a")
    handle:close()

    if result == "" then return "" end

    -- Parse: "X files changed, Y insertions(+), Z deletions(-)"
    local files_changed = result:match("(%d+) file") or "0"
    local added = result:match("(%d+) insertion") or "0"
    local removed = result:match("(%d+) deletion") or "0"

    -- Use lualine's diff highlight groups for coloring
    local parts = {}
    if tonumber(added) > 0 then
      table.insert(parts, "%#lualine_c_diff_added_normal#" .. icons.git.add .. added .. "%*")
    end
    if tonumber(files_changed) > 0 then
      table.insert(parts, "%#lualine_c_diff_modified_normal#" .. icons.git.change .. files_changed .. "%*")
    end
    if tonumber(removed) > 0 then
      table.insert(parts, "%#lualine_c_diff_removed_normal#" .. icons.git.delete .. removed .. "%*")
    end

    return #parts > 0 and table.concat(parts, " ") or ""
  end,
  cond = function()
    return vim.fn.isdirectory(".git") == 1
  end,
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
