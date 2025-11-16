--[[
  nvim-harmony Test Configuration

  This file contains example configurations for testing nvim-harmony.

  Usage:
  1. Make sure this repo is loaded by your plugin manager (e.g., lazy.nvim)
  2. Copy one of the configs below to your init.lua
  3. Restart Neovim and open Telescope to see the theming

  For lazy.nvim, add to your plugins:
  {
    "danielcopper/nvim-harmony",
    name = "harmony",
    dependencies = {
      "catppuccin/nvim",                -- Your colorscheme
      "nvim-telescope/telescope.nvim",  -- Plugins you want to theme
    },
    config = function()
      require('harmony').setup({
        -- your config here
      })
    end
  }
--]]

-- ============================================================================
-- Example 1: Minimal Configuration
-- ============================================================================
-- Just specify colorscheme, everything else uses sensible defaults

local minimal_config = {
  colorscheme = {
    name = "catppuccin",
    variant = "mocha", -- mocha, macchiato, frappe, or latte
  },
}

-- ============================================================================
-- Example 2: Standard Configuration
-- ============================================================================
-- Customize global settings that apply to all plugins

local standard_config = {
  colorscheme = {
    name = "catppuccin",
    variant = "mocha",
  },

  -- Global settings
  borders = "rounded", -- none, single, double, rounded, solid, shadow
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
}

-- ============================================================================
-- Example 3: Configuration with Per-Plugin Overrides
-- ============================================================================
-- Override settings for specific plugins

local override_config = {
  colorscheme = {
    name = "catppuccin",
    variant = "mocha",
  },

  borders = "rounded", -- Global default

  overrides = {
    -- Telescope-specific overrides
    telescope = {
      borders = "single", -- Use single borders for telescope only

      -- Can also override colors for telescope specifically
      colors = {
        -- bg = "#1a1a1a",  -- Custom background for telescope
      },

      -- Or override specific highlight groups directly
      highlights = {
        -- TelescopeBorder = { fg = "#89b4fa", bold = true },
      },
    },
  },
}

-- ============================================================================
-- Example 4: Advanced Configuration
-- ============================================================================
-- Full customization with color overrides and highlight overrides

local advanced_config = {
  colorscheme = {
    name = "catppuccin",
    variant = "mocha",
  },

  borders = "rounded",
  transparency = {
    enabled = false,
  },

  -- Global color overrides (affects all plugins)
  colors = {
    -- Override any extracted color
    -- bg_dark = "#15151a",
    -- border = "#89b4fa",
  },

  -- Global icon overrides
  icons = {
    diagnostics = {
      -- error = "X",
      -- warn = "!",
    },
  },

  overrides = {
    telescope = {
      -- Level 1: Config-based customization
      borders = "rounded",
      transparency = {
        enabled = false,
      },

      -- Level 2: Direct highlight overrides
      highlights = {
        TelescopeSelection = {
          bg = "#45475a",
          bold = true,
        },
        TelescopeMatching = {
          fg = "#f38ba8",
          bold = true,
        },
      },
    },
  },
}

-- ============================================================================
-- Example 5: Transparent Background
-- ============================================================================

local transparent_config = {
  colorscheme = {
    name = "catppuccin",
    variant = "mocha",
  },

  borders = "rounded",
  transparency = {
    enabled = true, -- Enable transparency
  },
}

-- ============================================================================
-- Example 6: No Borders Configuration
-- ============================================================================
-- Use distinct backgrounds instead of borders

local no_borders_config = {
  colorscheme = {
    name = "catppuccin",
    variant = "mocha",
  },

  borders = "none", -- No borders, uses bg colors for distinction
}

-- ============================================================================
-- To use one of these configs, uncomment the following line:
-- ============================================================================

-- require('harmony').setup(minimal_config)
-- require('harmony').setup(standard_config)
-- require('harmony').setup(override_config)
-- require('harmony').setup(advanced_config)
-- require('harmony').setup(transparent_config)
-- require('harmony').setup(no_borders_config)

-- Or define your own:
require('harmony').setup({
  colorscheme = {
    name = "catppuccin",
    variant = "mocha",
  },
  borders = "rounded",
})
