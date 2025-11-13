---@class Helpers
---Convenience helpers to simplify integration with user configs
---Provides ONLY theming-related helpers (borders, icons, colors)
---Does NOT include keymappings, behaviors, or plugin functionality
local M = {}

local config_module = require("harmony.config")

---Get border style string
---Safe to call before setup() - returns default if not configured
---@return string Border style
function M.border()
  local ok, config = pcall(config_module.get)
  if ok and config then
    return config.borders
  end
  return "rounded" -- Default fallback
end

---Get diagnostic signs configuration
---Ready to use in vim.diagnostic.config({ signs = ... })
---@return table Diagnostic signs config
function M.diagnostic_signs()
  local ok, icons = pcall(config_module.get_icons)
  if not ok then
    -- Fallback to default icons if harmony not set up yet
    icons = require("harmony.icons")
  end

  return {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
      [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
      [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
      [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
    },
  }
end

---Get LSP kind icons for completion
---Ready to use in cmp formatting function
---@return table LSP kind icons
function M.lsp_kind_icons()
  local ok, icons = pcall(config_module.get_icons)
  if not ok then
    icons = require("harmony.icons")
  end

  return icons.lsp.kinds
end

---Get telescope borderchars based on current border style
---@return table Borderchars array for telescope
function M.telescope_borderchars()
  local border_style = M.border()

  if border_style == "none" then
    return { " ", " ", " ", " ", " ", " ", " ", " " }
  else
    -- Standard rounded/single/double borders
    return { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  end
end

---Format a completion item with LSP kind icons
---Use directly in cmp formatting.format
---@param entry any cmp entry
---@param vim_item any vim item
---@return table Formatted item
function M.format_cmp_item(entry, vim_item)
  local kind_icons = M.lsp_kind_icons()
  local kind_name = vim_item.kind

  vim_item.kind = " " .. (kind_icons[kind_name] or "") .. " "
  vim_item.menu = "    " .. (kind_name or "")

  return vim_item
end

---Get cmp window config with harmony borders
---@return table Window config for cmp
function M.cmp_window()
  local cmp = require("cmp")

  return {
    completion = cmp.config.window.bordered({
      border = M.border(),
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
    }),
    documentation = cmp.config.window.bordered({
      border = M.border(),
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
    }),
  }
end

---Get vim.lsp.handlers hover config with harmony borders
---Use: vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, harmony.lsp_hover())
---@return table LSP hover handler config
function M.lsp_hover()
  return {
    border = M.border(),
  }
end

---Get vim.lsp.handlers signature_help config with harmony borders
---Use: vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, harmony.lsp_signature())
---@return table LSP signature help handler config
function M.lsp_signature()
  return {
    border = M.border(),
  }
end

return M
