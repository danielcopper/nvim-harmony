---@class Presets
---Automatic configuration presets for plugins
---Provides default configs that get soft-merged with user settings
local M = {}

local config_module = require("harmony.config")

---Check if a plugin is installed
---@param plugin_name string Plugin name (for require)
---@return boolean
local function is_plugin_installed(plugin_name)
  local ok, _ = pcall(require, plugin_name)
  return ok
end

---Get harmony helpers (cached)
---@return table Harmony helper functions
local function get_harmony()
  return require("harmony")
end

---Get harmony icons (cached)
---@return table Icon definitions
local function get_icons()
  local ok, icons = pcall(config_module.get_icons)
  if ok and icons then
    return icons
  end
  return require("harmony.icons")
end

---Get harmony colors (cached)
---@return table|nil Color palette
local function get_colors()
  local ok, harmony = pcall(get_harmony)
  if not ok then return nil end

  local ok2, colors = pcall(harmony.get_colors)
  if ok2 then
    return colors
  end
  return nil
end

---Get border style
---@return string Border style
local function get_border()
  local ok, harmony = pcall(get_harmony)
  if not ok then return "rounded" end

  local ok2, border = pcall(harmony.border)
  if ok2 then
    return border
  end
  return "rounded"
end

---Soft merge: Merge user and harmony configs, user values take priority for conflicts
---@param user_config table User's plugin configuration
---@param harmony_config table Harmony's default configuration
---@return table Merged configuration
local function soft_merge(user_config, harmony_config)
  -- "force" mode: harmony provides base, user overrides specific values
  -- This way if user has defaults.sorting_strategy and harmony has defaults.borderchars,
  -- both will be present in the final config
  return vim.tbl_deep_extend("force", harmony_config, user_config or {})
end

-- ============================================================================
-- Plugin Presets
-- ============================================================================

---Get nvim-notify default configuration
---@param user_opts table|nil User configuration
---@return table Merged configuration
function M.notify(user_opts)
  local harmony_opts = {
    border = get_border(),
    stages = "fade_in_slide_out",
    render = "compact",
  }

  -- Add background color for borderless mode
  if get_border() == "none" then
    local colors = get_colors()
    if colors then
      harmony_opts.background_colour = colors.bg_dark
    end
  end

  return soft_merge(user_opts, harmony_opts)
end

---Get telescope default configuration
---@param user_opts table|nil User configuration
---@return table Merged configuration
function M.telescope(user_opts)
  local icons = get_icons()

  local harmony_opts = {
    defaults = {
      borderchars = get_harmony().telescope_borderchars(),
      prompt_prefix = icons.ui.search .. "  ",
      selection_caret = " ",
      entry_prefix = " ",
    }
  }

  return soft_merge(user_opts, harmony_opts)
end

---Get mason default configuration
---@param user_opts table|nil User configuration
---@return table Merged configuration
function M.mason(user_opts)
  local icons = get_icons()

  local harmony_opts = {
    ui = {
      border = get_border(),
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  }

  return soft_merge(user_opts, harmony_opts)
end

---Get nvim-cmp default configuration
---@param user_opts table|nil User configuration
---@return table Merged configuration
function M.cmp(user_opts)
  local harmony = get_harmony()

  local harmony_opts = {
    window = harmony.cmp_window(),
    formatting = {
      format = harmony.format_cmp_item,
    },
  }

  return soft_merge(user_opts, harmony_opts)
end

---Get trouble.nvim default configuration
---@param user_opts table|nil User configuration
---@return table Merged configuration
function M.trouble(user_opts)
  local icons = get_icons()

  local harmony_opts = {
    icons = {
      indent = {
        middle = "├╴",
        last = "└╴",
        top = "│ ",
        ws = "  ",
      },
      folder_closed = icons.ui.folder,
      folder_open = icons.ui.folder_open,
      kinds = icons.lsp.kinds,
    },
  }

  return soft_merge(user_opts, harmony_opts)
end

---Get gitsigns default configuration
---@param user_opts table|nil User configuration
---@return table Merged configuration
function M.gitsigns(user_opts)
  local icons = get_icons()

  local harmony_opts = {
    signs = {
      add = { text = icons.git.add },
      change = { text = icons.git.change },
      delete = { text = icons.git.delete },
      topdelete = { text = icons.git.delete },
      changedelete = { text = icons.git.change },
      untracked = { text = icons.git.untracked },
    },
  }

  return soft_merge(user_opts, harmony_opts)
end

---Get neo-tree default configuration
---@param user_opts table|nil User configuration
---@return table Merged configuration
function M.neo_tree(user_opts)
  local icons = get_icons()

  local harmony_opts = {
    default_component_configs = {
      icon = {
        folder_closed = icons.ui.folder,
        folder_open = icons.ui.folder_open,
        folder_empty = icons.ui.folder_empty,
      },
      git_status = {
        symbols = {
          added = icons.git.add,
          modified = icons.git.change,
          deleted = icons.git.delete,
          renamed = icons.git.renamed,
          untracked = icons.git.untracked,
          ignored = icons.git.ignored,
          unstaged = icons.git.unstaged,
          staged = icons.git.staged,
          conflict = icons.git.conflict,
        },
      },
    },
  }

  return soft_merge(user_opts, harmony_opts)
end

---Get which-key default configuration
---@param user_opts table|nil User configuration
---@return table Merged configuration
function M.which_key(user_opts)
  local harmony_opts = {
    window = {
      border = get_border(),
    },
  }

  return soft_merge(user_opts, harmony_opts)
end

---Get lualine default configuration
---@param user_opts table|nil User configuration
---@return table Merged configuration
function M.lualine(user_opts)
  local icons = get_icons()

  local harmony_opts = {
    options = {
      icons_enabled = true,
    },
    sections = {
      lualine_b = {
        {
          "diagnostics",
          symbols = {
            error = icons.diagnostics.error .. " ",
            warn = icons.diagnostics.warn .. " ",
            info = icons.diagnostics.info .. " ",
            hint = icons.diagnostics.hint .. " ",
          },
        },
      },
    },
  }

  return soft_merge(user_opts, harmony_opts)
end

---Get noice default configuration
---@param user_opts table|nil User configuration
---@return table Merged configuration
function M.noice(user_opts)
  local harmony_opts = {
    presets = {
      lsp_doc_border = get_border() ~= "none",
    },
  }

  return soft_merge(user_opts, harmony_opts)
end

-- ============================================================================
-- Auto-apply system
-- ============================================================================

---Get preset for a plugin if available
---@param plugin_name string Plugin identifier (e.g., "notify", "telescope")
---@param user_opts table|nil User configuration
---@return table|nil Merged configuration or nil if no preset exists
function M.get(plugin_name, user_opts)
  if M[plugin_name] then
    return M[plugin_name](user_opts)
  end
  return user_opts
end

---List all available presets
---@return table List of plugin names with presets
function M.list()
  return {
    "notify",
    "telescope",
    "mason",
    "cmp",
    "trouble",
    "gitsigns",
    "neo_tree",
    "which_key",
    "lualine",
    "noice",
  }
end

return M
