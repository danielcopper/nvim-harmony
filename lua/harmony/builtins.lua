---@class Builtins
---Early configuration for Neovim built-ins
---Called from init block before harmony fully loads
local M = {}

---Get icons with fallback if harmony not loaded yet
---@return table Icon definitions
local function get_icons()
  local ok, harmony_icons = pcall(require, "harmony.icons")
  if ok then
    return harmony_icons
  end

  -- Fallback icons if harmony.icons not available yet
  return {
    diagnostics = {
      error = "󰅚",
      warn = "󰀪",
      info = "󰋽",
      hint = "󰌶",
    },
  }
end

---Get border style with fallback
---@return string Border style
local function get_border()
  local ok, config = pcall(require, "harmony.config")
  if ok then
    local ok2, cfg = pcall(config.get)
    if ok2 and cfg then
      return cfg.borders
    end
  end
  return "rounded" -- Default fallback
end

---Setup vim.diagnostic configuration
---@param icons table Icon definitions
local function setup_diagnostics(icons)
  vim.diagnostic.config({
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
        [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
        [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
        [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
      },
    },
    float = {
      border = get_border(),
    },
    virtual_text = {
      spacing = 4,
      prefix = "●",
    },
    severity_sort = true,
  })
end

---Setup LSP handlers
---@param border string Border style
local function setup_lsp_handlers(border)
  -- Hover handler
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = border }
  )

  -- Signature help handler
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    { border = border }
  )
end

---Setup fillchars for window separators
---@param border_style string Border style
local function setup_fillchars(border_style)
  local icons = get_icons()

  if border_style == "none" then
    -- Minimal separators for borderless mode
    vim.opt.fillchars = {
      horiz = " ",
      horizup = " ",
      horizdown = " ",
      vert = " ",
      vertleft = " ",
      vertright = " ",
      verthoriz = " ",
      eob = icons.ui.eob,
      diff = icons.ui.diff,
      fold = icons.ui.fold_minimal,
      foldopen = icons.ui.foldopen,
      foldclose = icons.ui.foldclose,
      foldsep = " ",
    }
  else
    -- Standard fillchars for bordered mode
    vim.opt.fillchars = {
      horiz = "─",
      horizup = "┴",
      horizdown = "┬",
      vert = "│",
      vertleft = "┤",
      vertright = "├",
      verthoriz = "┼",
      eob = icons.ui.eob,
      diff = icons.ui.diff,
      fold = icons.ui.fold,
      foldopen = icons.ui.foldopen,
      foldclose = icons.ui.foldclose,
      foldsep = icons.ui.foldsep,
    }
  end
end

---Setup listchars for whitespace visualization
local function setup_listchars()
  vim.opt.listchars = {
    tab = "→ ",
    trail = "·",
    nbsp = "␣",
    extends = "…",
    precedes = "…",
  }
end

---Early setup for Neovim built-ins
---Call this from the init block of harmony plugin
---@param opts table|nil Configuration options
function M.setup_early(opts)
  opts = opts or {}

  -- Default: enable all built-in configurations
  -- NOTE: lsp_handlers defaults to false because it requires config to be loaded
  -- LSP handlers are set in harmony.setup() instead (config phase)
  local config = vim.tbl_deep_extend("force", {
    diagnostics = true,
    lsp_handlers = false,
    fillchars = true,
    listchars = true,
  }, opts)

  local icons = get_icons()
  local border = get_border()

  if config.diagnostics then
    setup_diagnostics(icons)
  end

  if config.lsp_handlers then
    setup_lsp_handlers(border)
  end

  if config.fillchars then
    setup_fillchars(border)
  end

  if config.listchars then
    setup_listchars()
  end
end

return M
