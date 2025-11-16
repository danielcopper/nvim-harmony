---@class HarmonySpecs
---Declarative lazy.nvim plugin specs for auto-configuration
---These specs are imported by the user and merged with their own specs
local M = {}

---Check if a plugin is installed
---@param plugin_name string Plugin name (for require)
---@return boolean
local function is_plugin_installed(plugin_name)
  local ok, _ = pcall(require, plugin_name)
  return ok
end

---Generate a spec for nvim-notify
---@return table|nil Lazy.nvim plugin spec
local function notify_spec()
  if not is_plugin_installed("notify") then
    return nil
  end

  return {
    "rcarriga/nvim-notify",
    dependencies = { "harmony" },
    opts = function(_, opts)
      local presets = require("harmony.presets")
      return presets.get("notify", opts)
    end,
  }
end

---Generate a spec for telescope.nvim
---@return table|nil Lazy.nvim plugin spec
local function telescope_spec()
  if not is_plugin_installed("telescope") then
    return nil
  end

  return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "harmony" },
    opts = function(_, opts)
      local presets = require("harmony.presets")
      return presets.get("telescope", opts)
    end,
  }
end

---Generate a spec for mason.nvim
---@return table|nil Lazy.nvim plugin spec
local function mason_spec()
  if not is_plugin_installed("mason") then
    return nil
  end

  return {
    "williamboman/mason.nvim",
    dependencies = { "harmony" },
    opts = function(_, opts)
      local presets = require("harmony.presets")
      return presets.get("mason", opts)
    end,
  }
end

---Generate a spec for nvim-cmp
---@return table|nil Lazy.nvim plugin spec
local function cmp_spec()
  if not is_plugin_installed("cmp") then
    return nil
  end

  return {
    "hrsh7th/nvim-cmp",
    dependencies = { "harmony" },
    opts = function(_, opts)
      local presets = require("harmony.presets")
      return presets.get("cmp", opts)
    end,
  }
end

---Generate a spec for trouble.nvim
---@return table|nil Lazy.nvim plugin spec
local function trouble_spec()
  if not is_plugin_installed("trouble") then
    return nil
  end

  return {
    "folke/trouble.nvim",
    dependencies = { "harmony" },
    opts = function(_, opts)
      local presets = require("harmony.presets")
      return presets.get("trouble", opts)
    end,
  }
end

---Generate a spec for gitsigns.nvim
---@return table|nil Lazy.nvim plugin spec
local function gitsigns_spec()
  if not is_plugin_installed("gitsigns") then
    return nil
  end

  return {
    "lewis6991/gitsigns.nvim",
    dependencies = { "harmony" },
    opts = function(_, opts)
      local presets = require("harmony.presets")
      return presets.get("gitsigns", opts)
    end,
  }
end

---Generate a spec for neo-tree.nvim
---@return table|nil Lazy.nvim plugin spec
local function neo_tree_spec()
  if not is_plugin_installed("neo-tree") then
    return nil
  end

  return {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = { "harmony" },
    opts = function(_, opts)
      local presets = require("harmony.presets")
      return presets.get("neo_tree", opts)
    end,
  }
end

---Generate a spec for which-key.nvim
---@return table|nil Lazy.nvim plugin spec
local function which_key_spec()
  if not is_plugin_installed("which-key") then
    return nil
  end

  return {
    "folke/which-key.nvim",
    dependencies = { "harmony" },
    opts = function(_, opts)
      local presets = require("harmony.presets")
      return presets.get("which_key", opts)
    end,
  }
end

---Generate a spec for lualine.nvim
---@return table|nil Lazy.nvim plugin spec
local function lualine_spec()
  if not is_plugin_installed("lualine") then
    return nil
  end

  return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "harmony" },
    opts = function(_, opts)
      local presets = require("harmony.presets")
      return presets.get("lualine", opts)
    end,
  }
end

---Generate a spec for noice.nvim
---@return table|nil Lazy.nvim plugin spec
local function noice_spec()
  if not is_plugin_installed("noice") then
    return nil
  end

  return {
    "folke/noice.nvim",
    dependencies = { "harmony" },
    opts = function(_, opts)
      local presets = require("harmony.presets")
      return presets.get("noice", opts)
    end,
  }
end

---Get all harmony plugin specs for auto-configuration
---@return table List of lazy.nvim plugin specs
function M.get_all()
  local specs = {
    notify_spec(),
    telescope_spec(),
    mason_spec(),
    cmp_spec(),
    trouble_spec(),
    gitsigns_spec(),
    neo_tree_spec(),
    which_key_spec(),
    lualine_spec(),
    noice_spec(),
  }

  -- Filter out nil entries (plugins not installed)
  local result = {}
  for _, spec in ipairs(specs) do
    if spec then
      table.insert(result, spec)
    end
  end

  return result
end

-- When this module is imported by lazy.nvim via { import = "harmony.specs" },
-- lazy.nvim expects the module to return a list of plugin specs
return M.get_all()
