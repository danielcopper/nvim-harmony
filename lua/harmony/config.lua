---@class Config
---Configuration system for nvim-harmony
---Handles validation, defaults, and merging of user configuration
local M = {}

-- Internal state
local _config = nil

---Default configuration
local defaults = {
  colorscheme = {
    name = "default",
    variant = nil,
  },

  borders = "rounded",

  transparency = {
    enabled = false,
  },

  margins = {
    top = 1,
    bottom = 1,
    left = 2,
    right = 2,
  },

  padding = {
    top = 0,
    bottom = 0,
    left = 0,
    right = 0,
  },

  colors = {},
  icons = {},
  overrides = {},
}

---Valid border styles (Neovim built-ins)
local valid_borders = {
  "none",
  "single",
  "double",
  "rounded",
  "solid",
  "shadow",
}

---Validate colorscheme configuration
---@param cs table Colorscheme config
---@return boolean, string|nil Valid, error message
local function validate_colorscheme(cs)
  if type(cs) ~= "table" then
    return false, "colorscheme must be a table"
  end

  if not cs.name or type(cs.name) ~= "string" then
    return false, "colorscheme.name is required and must be a string"
  end

  if cs.variant and type(cs.variant) ~= "string" then
    return false, "colorscheme.variant must be a string"
  end

  return true
end

---Validate border style
---@param border string Border style
---@return boolean, string|nil Valid, error message
local function validate_border(border)
  if type(border) ~= "string" then
    return false, "borders must be a string"
  end

  for _, valid in ipairs(valid_borders) do
    if border == valid then
      return true
    end
  end

  return false, "invalid border style '" .. border .. "'. Valid styles: " .. table.concat(valid_borders, ", ")
end

---Validate transparency config
---@param transparency table Transparency config
---@return boolean, string|nil Valid, error message
local function validate_transparency(transparency)
  if type(transparency) ~= "table" then
    return false, "transparency must be a table"
  end

  if transparency.enabled ~= nil and type(transparency.enabled) ~= "boolean" then
    return false, "transparency.enabled must be a boolean"
  end

  return true
end

---Validate margins/padding config
---@param spacing table Margins or padding config
---@param name string "margins" or "padding"
---@return boolean, string|nil Valid, error message
local function validate_spacing(spacing, name)
  if type(spacing) ~= "table" then
    return false, name .. " must be a table"
  end

  for _, key in ipairs({ "top", "bottom", "left", "right" }) do
    if spacing[key] and type(spacing[key]) ~= "number" then
      return false, name .. "." .. key .. " must be a number"
    end
  end

  return true
end

---Validate user configuration
---@param config table User configuration
---@return boolean, string|nil Valid, error message
local function validate_config(config)
  if type(config) ~= "table" then
    return false, "config must be a table"
  end

  -- Validate colorscheme (required)
  if not config.colorscheme then
    return false, "colorscheme configuration is required"
  end
  local ok, err = validate_colorscheme(config.colorscheme)
  if not ok then
    return false, err
  end

  -- Validate borders (optional)
  if config.borders then
    ok, err = validate_border(config.borders)
    if not ok then
      return false, err
    end
  end

  -- Validate transparency (optional)
  if config.transparency then
    ok, err = validate_transparency(config.transparency)
    if not ok then
      return false, err
    end
  end

  -- Validate margins (optional)
  if config.margins then
    ok, err = validate_spacing(config.margins, "margins")
    if not ok then
      return false, err
    end
  end

  -- Validate padding (optional)
  if config.padding then
    ok, err = validate_spacing(config.padding, "padding")
    if not ok then
      return false, err
    end
  end

  -- Validate overrides (optional)
  if config.overrides then
    if type(config.overrides) ~= "table" then
      return false, "overrides must be a table"
    end

    -- Validate each plugin override
    for plugin_name, plugin_config in pairs(config.overrides) do
      if type(plugin_config) ~= "table" then
        return false, "overrides." .. plugin_name .. " must be a table"
      end

      -- Validate enabled flag
      if plugin_config.enabled ~= nil and type(plugin_config.enabled) ~= "boolean" then
        return false, "overrides." .. plugin_name .. ".enabled must be a boolean"
      end

      -- Validate borders override
      if plugin_config.borders then
        ok, err = validate_border(plugin_config.borders)
        if not ok then
          return false, "overrides." .. plugin_name .. "." .. err
        end
      end

      -- Validate spacing overrides
      if plugin_config.margins then
        ok, err = validate_spacing(plugin_config.margins, "margins")
        if not ok then
          return false, "overrides." .. plugin_name .. "." .. err
        end
      end

      if plugin_config.padding then
        ok, err = validate_spacing(plugin_config.padding, "padding")
        if not ok then
          return false, "overrides." .. plugin_name .. "." .. err
        end
      end
    end
  end

  return true
end

---Merge user icons with default icons
---@param user_icons table User icon overrides
---@return table Merged icons
local function merge_icons(user_icons)
  local default_icons = require("harmony.icons")
  return vim.tbl_deep_extend("force", default_icons, user_icons or {})
end

---Load and validate configuration
---@param user_config table User configuration
---@return table|nil, string|nil Merged configuration, error message
function M.load(user_config)
  -- Validate user config
  local ok, err = validate_config(user_config)
  if not ok then
    return nil, err
  end

  -- Merge with defaults
  _config = vim.tbl_deep_extend("force", defaults, user_config)

  -- Merge icons
  _config.merged_icons = merge_icons(_config.icons)

  return _config
end

---Get the loaded configuration
---@return table Configuration
function M.get()
  if not _config then
    error("Configuration not loaded. Call config.load() first.")
  end
  return _config
end

---Get configuration for a specific plugin
---Merges global settings with per-plugin overrides
---@param plugin_name string Plugin name
---@return table Plugin-specific configuration
function M.get_plugin_config(plugin_name)
  if not _config then
    error("Configuration not loaded. Call config.load() first.")
  end

  local plugin_override = _config.overrides[plugin_name] or {}

  -- Build merged config
  local plugin_config = {
    borders = plugin_override.borders or _config.borders,
    transparency = plugin_override.transparency or _config.transparency,
    margins = vim.tbl_deep_extend("force", _config.margins, plugin_override.margins or {}),
    padding = vim.tbl_deep_extend("force", _config.padding, plugin_override.padding or {}),
    colors = vim.tbl_deep_extend("force", _config.colors, plugin_override.colors or {}),
    colorscheme = _config.colorscheme,
    enabled = plugin_override.enabled,
  }

  return plugin_config
end

---Check if a plugin integration is enabled
---@param plugin_name string Plugin name
---@return boolean Enabled
function M.is_plugin_enabled(plugin_name)
  if not _config then
    return true -- Default to enabled
  end

  local plugin_override = _config.overrides[plugin_name]
  if not plugin_override then
    return true -- No override = enabled
  end

  if plugin_override.enabled == false then
    return false
  end

  return true
end

---Get highlight overrides for a plugin
---@param plugin_name string Plugin name
---@return table|nil Highlight overrides
function M.get_highlight_overrides(plugin_name)
  if not _config then
    return nil
  end

  local plugin_override = _config.overrides[plugin_name]
  if not plugin_override then
    return nil
  end

  return plugin_override.highlights
end

---Get merged icons (global defaults + user overrides)
---@return table Icons
function M.get_icons()
  if not _config then
    return require("harmony.icons")
  end

  return _config.merged_icons
end

return M
