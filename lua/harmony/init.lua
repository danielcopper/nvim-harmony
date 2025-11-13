---@class Harmony
---nvim-harmony: Centralized theming system for Neovim
---Works WITH colorschemes to provide consistent UI appearance
local M = {}

local config_module = require("harmony.config")
local extraction = require("harmony.extraction")

---Check if a plugin is installed
---@param plugin_name string Plugin name (for require)
---@return boolean Installed
local function is_plugin_installed(plugin_name)
  local ok, _ = pcall(require, plugin_name)
  return ok
end

---Discover available integrations
---@return table List of integration modules
local function discover_integrations()
  -- For now, hardcode the list of integrations
  -- Could be made dynamic by scanning the integrations directory
  local integration_names = {
    "telescope",
    -- Add more as we implement them: "notify", "mason", etc.
  }

  local integrations = {}
  for _, name in ipairs(integration_names) do
    local ok, integration = pcall(require, "harmony.integrations." .. name)
    if ok then
      table.insert(integrations, integration)
    else
      vim.notify(
        "Failed to load integration '" .. name .. "'",
        vim.log.levels.WARN
      )
    end
  end

  return integrations
end

---Apply highlight groups to Neovim
---@param highlights table Highlight groups { GroupName = { fg, bg, ... } }
local function apply_highlights(highlights)
  for group_name, group_def in pairs(highlights) do
    vim.api.nvim_set_hl(0, group_name, group_def)
  end
end

---Merge highlight overrides with generated highlights
---@param base_highlights table Generated highlights from integration
---@param overrides table|nil User highlight overrides
---@return table Merged highlights
local function merge_highlight_overrides(base_highlights, overrides)
  if not overrides then
    return base_highlights
  end

  -- Deep merge: user overrides only specific properties
  return vim.tbl_deep_extend("force", base_highlights, overrides)
end

---Run a single integration
---@param integration table Integration module
---@param colors table Color palette
---@param config table Main configuration
local function run_integration(integration, colors, config)
  local plugin_name = integration.plugin_name or integration.name

  -- Check if plugin is installed
  if not is_plugin_installed(plugin_name) then
    vim.notify(
      "Plugin '" .. plugin_name .. "' not installed, skipping integration",
      vim.log.levels.DEBUG
    )
    return
  end

  -- Check if integration is enabled
  if not config_module.is_plugin_enabled(integration.name) then
    vim.notify(
      "Integration '" .. integration.name .. "' disabled in config",
      vim.log.levels.DEBUG
    )
    return
  end

  -- Get plugin-specific config (merged with global)
  local plugin_config = config_module.get_plugin_config(integration.name)

  -- Run integration
  local ok, highlights = pcall(integration.setup, colors, plugin_config)
  if not ok then
    vim.notify(
      "Integration '" .. integration.name .. "' failed: " .. tostring(highlights),
      vim.log.levels.WARN
    )
    return
  end

  -- Apply highlight overrides (Level 2 customization)
  local highlight_overrides = config_module.get_highlight_overrides(integration.name)
  highlights = merge_highlight_overrides(highlights, highlight_overrides)

  -- Apply highlights
  apply_highlights(highlights)

  vim.notify(
    "Applied theming for " .. integration.name,
    vim.log.levels.DEBUG
  )
end

---Main setup function
---@param user_config table User configuration
function M.setup(user_config)
  user_config = user_config or {}

  -- Step 1: Load and validate configuration
  local config, err = config_module.load(user_config)
  if not config then
    vim.notify(
      "nvim-harmony configuration error: " .. tostring(err),
      vim.log.levels.ERROR
    )
    return
  end

  vim.notify("nvim-harmony: Configuration loaded", vim.log.levels.INFO)

  -- Step 2: Extract colors (loads colorscheme + extracts/generates palette)
  local colors = extraction.extract(config.colorscheme, config.colors)
  vim.notify(
    "nvim-harmony: Colors extracted for " .. config.colorscheme.name,
    vim.log.levels.INFO
  )

  -- Step 3: Icons are already merged in config (via config_module.get_icons())
  -- No additional action needed

  -- Step 4: Discover and run integrations
  local integrations = discover_integrations()
  vim.notify(
    "nvim-harmony: Found " .. #integrations .. " integration(s)",
    vim.log.levels.INFO
  )

  for _, integration in ipairs(integrations) do
    run_integration(integration, colors, config)
  end

  vim.notify("nvim-harmony: Setup complete", vim.log.levels.INFO)
end

---Get the current color palette (for advanced users)
---@return table|nil Color palette
function M.get_colors()
  local config = config_module.get()
  if not config then
    return nil
  end

  return extraction.extract(config.colorscheme, config.colors)
end

---Get the current configuration (for advanced users)
---@return table|nil Configuration
function M.get_config()
  return config_module.get()
end

---Get merged icons (for advanced users)
---@return table Icons
function M.get_icons()
  return config_module.get_icons()
end

-- Expose helpers for easy integration
local helpers = require("harmony.helpers")
M.border = helpers.border
M.diagnostic_signs = helpers.diagnostic_signs
M.lsp_kind_icons = helpers.lsp_kind_icons
M.telescope_borderchars = helpers.telescope_borderchars
M.format_cmp_item = helpers.format_cmp_item
M.cmp_window = helpers.cmp_window
M.lsp_hover = helpers.lsp_hover
M.lsp_signature = helpers.lsp_signature

return M
