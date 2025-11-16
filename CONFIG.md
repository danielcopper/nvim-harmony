# Configuration Reference

Complete guide to configuring nvim-harmony.

## Table of Contents

- [Basic Configuration](#basic-configuration)
- [Colorscheme Configuration](#colorscheme-configuration)
- [Border Styles](#border-styles)
- [Color Overrides](#color-overrides)
- [Icon Customization](#icon-customization)
- [Per-Plugin Configuration](#per-plugin-configuration)
- [Highlight Overrides](#highlight-overrides)
- [Transparency](#transparency)

## Basic Configuration

```lua
require("harmony").setup({
  colorscheme = {
    name = "catppuccin",
    variant = "mocha",
  },
  borders = "rounded",
  transparency = {
    enabled = false,
  },
})
```

## Colorscheme Configuration

### Supported Colorschemes

Harmony works with any Neovim colorscheme. It has manual extractors for optimal results with:
- **catppuccin** (variants: latte, frappe, macchiato, mocha)
- More manual extractors coming soon (tokyonight, gruvbox, nord)

For other colorschemes, harmony uses automatic color extraction.

### Configuration

```lua
colorscheme = {
  name = "catppuccin",      -- Colorscheme name
  variant = "mocha",        -- Variant (if supported)
  set_built_in = true,      -- Let harmony load the colorscheme (default: true)
}
```

### Load Colorscheme Manually

If you want to load the colorscheme yourself:

```lua
-- In your colorscheme plugin config
require("catppuccin").setup(...)
vim.cmd.colorscheme("catppuccin-mocha")

-- In harmony config
require("harmony").setup({
  colorscheme = {
    name = "catppuccin",
    variant = "mocha",
    set_built_in = false,  -- Don't let harmony load it
  },
})
```

## Border Styles

Global border style for all plugins:

```lua
borders = "rounded"  -- Options: "none", "single", "double", "rounded"
```

### Border Style Examples

- **"none"** - No borders (uses spaces, clean look)
- **"single"** - Single line borders (`─`, `│`, `┌`, etc.)
- **"double"** - Double line borders (`═`, `║`, `╔`, etc.)
- **"rounded"** - Rounded corners (`─`, `│`, `╭`, `╮`, `╯`, `╰`)

### Per-Plugin Border Override

```lua
integrations = {
  telescope = {
    borders = "single",  -- Override just for telescope
  },
  mason = {
    borders = "double",
  },
}
```

## Color Overrides

Harmony extracts colors from your colorscheme. You can override any color:

```lua
colors = {
  -- Background variants
  bg_darker = "#1a1b26",
  bg_dark = "#24283b",
  bg = "#1f2335",
  bg_light = "#292e42",
  bg_lighter = "#3b4261",

  -- Foreground variants
  fg_darker = "#9aa5ce",
  fg_dark = "#a9b1d6",
  fg = "#c0caf5",
  fg_light = "#cfc9de",
  fg_lighter = "#e0def4",

  -- Float windows
  float_bg = "#1f2335",
  float_fg = "#c0caf5",

  -- Semantic colors
  error = "#f7768e",
  warn = "#e0af68",
  info = "#7aa2f7",
  hint = "#1abc9c",
  success = "#9ece6a",

  -- Accents
  accent_1 = "#7aa2f7",
  accent_2 = "#bb9af7",

  -- UI elements
  border = "#414868",
  selection = "#364a82",
}
```

## Icon Customization

Harmony provides a complete icon set. You can override any icon:

### UI Icons

```lua
icons = {
  ui = {
    search = " ",
    folder = " ",
    folder_open = " ",
    folder_empty = " ",
    file = " ",
    close = "✕",
    check = "✓",
    error = "✗",
    warning = "⚠",
    info = "ℹ",
    hint = "💡",
  },
}
```

### LSP Kind Icons

```lua
icons = {
  lsp = {
    kinds = {
      Text = "",
      Method = "",
      Function = "",
      Constructor = "",
      Field = "",
      Variable = "",
      Class = "",
      Interface = "",
      Module = "",
      Property = "",
      Unit = "",
      Value = "",
      Enum = "",
      Keyword = "",
      Snippet = "",
      Color = "",
      File = "",
      Reference = "",
      Folder = "",
      EnumMember = "",
      Constant = "",
      Struct = "",
      Event = "",
      Operator = "",
      TypeParameter = "",
    },
  },
}
```

### Diagnostic Icons

```lua
icons = {
  diagnostics = {
    error = "",
    warn = "",
    hint = "",
    info = "",
  },
}
```

### Git Icons

```lua
icons = {
  git = {
    add = "",
    change = "",
    delete = "",
    renamed = "➜",
    untracked = "★",
    ignored = "◌",
    unstaged = "✗",
    staged = "✓",
    conflict = "",
  },
}
```

### Fillchars Icons

```lua
icons = {
  fillchars = {
    foldopen = "",
    foldclose = "",
    foldsep = "│",
    eob = " ",       -- End of buffer
    diff = "╱",
    fold = "·",
    fold_minimal = " ",
  },
}
```

## Per-Plugin Configuration

Override settings for specific plugins:

```lua
integrations = {
  telescope = {
    enabled = true,         -- Enable/disable integration
    borders = "single",     -- Override border style
    colors = {             -- Override colors
      prompt_bg = "#1f2335",
    },
    highlight_overrides = { -- Override specific highlights
      TelescopePromptTitle = {
        fg = "#ff0000",
        bg = "#000000",
        bold = true,
      },
    },
  },

  mason = {
    enabled = true,
    borders = "rounded",
  },
}
```

## Highlight Overrides

For fine-grained control, override specific highlight groups:

```lua
integrations = {
  telescope = {
    highlight_overrides = {
      TelescopeNormal = {
        fg = "#c0caf5",
        bg = "#1f2335",
      },
      TelescopeBorder = {
        fg = "#414868",
        bg = "#1f2335",
      },
      TelescopePromptTitle = {
        fg = "#1a1b26",
        bg = "#7aa2f7",
        bold = true,
      },
      -- Any telescope highlight group can be overridden
    },
  },
}
```

## Transparency

Enable transparent backgrounds for floating windows:

```lua
transparency = {
  enabled = true,
}
```

When enabled:
- Floating window backgrounds become transparent
- Borders remain visible
- Title backgrounds remain visible (for visual separation)

### Per-Plugin Transparency

You can't override transparency per-plugin (it's a global setting). But you can use highlight overrides to fine-tune:

```lua
integrations = {
  telescope = {
    highlight_overrides = {
      TelescopeNormal = {
        bg = "NONE",  -- Force transparent for this specific highlight
      },
    },
  },
}
```

## Complete Example

```lua
require("harmony").setup({
  -- Colorscheme
  colorscheme = {
    name = "catppuccin",
    variant = "mocha",
  },

  -- Global border style
  borders = "rounded",

  -- Transparency
  transparency = {
    enabled = false,
  },

  -- Color overrides
  colors = {
    accent_1 = "#7aa2f7",
    accent_2 = "#bb9af7",
    border = "#414868",
  },

  -- Icon overrides
  icons = {
    ui = {
      search = "🔍",
      folder = "📁",
    },
    diagnostics = {
      error = "✗",
      warn = "⚠",
    },
  },

  -- Per-plugin configuration
  integrations = {
    telescope = {
      enabled = true,
      borders = "none",
      highlight_overrides = {
        TelescopePromptTitle = {
          fg = "#1a1b26",
          bg = "#f5e0dc",
          bold = true,
        },
      },
    },

    mason = {
      enabled = true,
      borders = "single",
    },
  },
})
```

## Helper Functions

For advanced use cases, harmony exposes helper functions:

```lua
local harmony = require("harmony")

-- Get current color palette
local colors = harmony.get_colors()

-- Get border style
local border = harmony.border()  -- Returns "rounded", "none", etc.

-- Get border characters (for manual use)
local border_chars = harmony.border_chars()  -- Returns array of 8 chars

-- Get telescope-specific border characters
local tel_chars = harmony.telescope_borderchars()  -- Returns array

-- Format a cmp item (for nvim-cmp)
local formatted = harmony.format_cmp_item(entry, vim_item)

-- Get cmp window config
local window_config = harmony.cmp_window()
```

These are rarely needed (presets handle everything automatically), but available for edge cases.
