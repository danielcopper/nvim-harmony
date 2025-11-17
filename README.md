# nvim-harmony

**Zero-touch theming system for Neovim** - Configure once, theme everything.

Harmony works **with** your colorscheme to provide consistent borders, icons, and colors across all your plugins. Configure harmony once; it automatically themes telescope, mason, cmp, and more.

## Features

- **Zero-touch auto-configuration** - Plugins get themed automatically
- **Works with any colorscheme** - Extracts colors, doesn't replace them
- **Two-level theming** - Config (borders, icons) + Highlights (colors, backgrounds)
- **Per-plugin control** - Global settings with plugin-specific overrides
- **Neovim built-ins** - Diagnostics, LSP, fillchars, listchars
- **Transparency support** - Optional transparent backgrounds

## Installation

### Step 1: Add harmony plugin

```lua
-- lua/plugins/harmony.lua
return {
  "danielcopper/nvim-harmony",
  name = "harmony",
  lazy = false,
  priority = 1000,
  init = function()
    require("harmony.builtins").setup_early()
  end,
  config = function()
    require("harmony").setup({
      colorscheme = {
        name = "catppuccin",
        variant = "mocha",
      },
      borders = "none",  -- or "rounded", "single", "double"
    })
  end,
}
```

### Step 2: Import harmony specs

```lua
-- init.lua
require("lazy").setup({
  spec = {
    { import = "plugins" },
    { import = "harmony.specs" },  -- ← Add this line
  },
})
```

That's it! Telescope, mason, and other supported plugins are now automatically themed.

## How It Works

Harmony uses three interconnected systems to achieve zero-touch theming:

### The Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. SETUP PHASE (You add harmony to lazy.nvim)              │
│    • Add { import = "harmony.specs" } to lazy.setup()      │
│    • Lazy merges harmony's specs with your plugin specs    │
│    • Result: Plugins now depend on harmony                 │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. HARMONY LOADS (priority 1000, loads early)              │
│    • Init: Configure Neovim built-ins                       │
│    • Config: Load colorscheme, extract colors              │
│    • Run integrations → apply highlight groups              │
│    • Setup ColorScheme autocmd for re-applying             │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. PLUGINS LOAD (telescope, mason, etc.)                   │
│    • Lazy calls plugin's opts function                     │
│    • Opts function calls harmony preset                    │
│    • Preset provides: borderchars, icons, prefixes         │
│    • Preset merges with your config (you win conflicts)    │
│    • Plugin.setup() receives combined config               │
└─────────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. RUNTIME (fully themed)                                   │
│    • Plugin uses harmony's config (borders, icons)          │
│    • Plugin windows use harmony's highlights (colors)       │
│    • Everything is consistent and themed                    │
└─────────────────────────────────────────────────────────────┘
```

### The Three Systems (All Work Together)

**1. Specs System** (`harmony.specs`)
- Injects harmony into plugin configurations via lazy.nvim import
- Adds `opts` function to each supported plugin
- Ensures harmony loads before plugins that depend on it

**2. Presets System** (`harmony.presets`)
- Provides config values when plugin's opts function runs
- Returns: borderchars, icons, prompt_prefix, etc.
- Merges with your config using soft merge (your values win)

**3. Integration System** (`harmony.integrations`)
- Generates highlight groups during harmony.setup()
- Sets colors for: TelescopeNormal, TelescopeBorder, etc.
- Re-applies after colorscheme changes (ColorScheme autocmd)

## Supported Plugins

| Plugin | Config Preset | Highlights | Status |
|--------|--------------|------------|---------|
| telescope.nvim | ✅ | ✅ | Full support |
| mason.nvim | ✅ | ✅ | Full support |
| lualine.nvim | ✅ | ✅ | Full support |
| noice.nvim | ✅ | ✅ | Full support |
| nvim-cmp | ✅ | ⏳ | Config only |
| nvim-notify | ✅ | ⏳ | Config only |
| which-key.nvim | ✅ | ⏳ | Config only |
| trouble.nvim | ✅ | ⏳ | Config only |
| gitsigns.nvim | ✅ | ⏳ | Config only |
| neo-tree.nvim | ✅ | ⏳ | Config only |

**Legend:**
- ✅ Full support: Both config preset and custom highlights
- ⏳ Config only: Config preset provided, uses colorscheme's highlights

## Configuration

### Basic Configuration

```lua
require("harmony").setup({
  colorscheme = {
    name = "catppuccin",     -- or "tokyonight", "gruvbox", etc.
    variant = "mocha",       -- colorscheme-specific variant
  },
  borders = "rounded",       -- "none", "single", "double", "rounded"
  transparency = {
    enabled = false,
  },
})
```

### Customization

```lua
require("harmony").setup({
  -- ... basic config ...

  -- Override colors
  colors = {
    accent_1 = "#ff6b9d",
    bg_dark = "#1a1b26",
  },

  -- Override icons
  icons = {
    ui = {
      search = "🔍",
    },
  },

  -- Per-plugin settings
  integrations = {
    telescope = {
      borders = "single",  -- Override just for telescope
    },
  },
})
```

### Important: Let Harmony Manage Presets

When using harmony's auto-configuration, **do not hardcode values that harmony manages** in your plugin configs. For example:

**❌ Don't do this in your noice config:**
```lua
{
  "folke/noice.nvim",
  opts = {
    presets = {
      lsp_doc_border = true,  -- Don't hardcode! Harmony manages this based on borders setting
    },
  },
}
```

**✅ Do this instead:**
```lua
{
  "folke/noice.nvim",
  opts = {
    presets = {
      -- Let harmony set lsp_doc_border based on your borders = "none" or "rounded" setting
      bottom_search = true,  -- You can still set your own workflow preferences
    },
  },
}
```

Harmony automatically configures:
- Border styles for all plugins (based on your `borders` setting)
- Icons (diagnostic symbols, LSP kinds, git icons)
- Colors and highlights

You configure:
- Workflow preferences (like noice's `bottom_search`, `command_palette`)
- Component layouts (like which lualine sections to show)
- Keymaps and behavior

### Lualine Configuration

Harmony provides a powerful abstraction layer for lualine, allowing you to configure your statusline with a simple, declarative interface.

**Simple preset style:**
```lua
require("harmony").setup({
  -- ... other config ...
  lualine = {
    preset = "rounded",  -- "default", "rounded", "square", "slant", "minimal", "bubble"
  },
})
```

**Custom component layout:**
```lua
require("harmony").setup({
  -- ... other config ...
  lualine = {
    preset = "rounded",
    left = {
      sections = { "mode", "branch", "git" },
    },
    right = {
      sections = { "diagnostics", "lsp", "filetype", "position", "progress", "root_dir" },
    },
  },
})
```

**Full control per section:**
```lua
require("harmony").setup({
  -- ... other config ...
  lualine = {
    left = {
      preset = "default",
      sections = { "mode", "file", "branch" },
    },
    middle = {},
    right = {
      preset = "rounded",
      sections = { "lsp", "diagnostics", "position" },
    },
  },
})
```

**Available components:**
- `mode` - Current mode indicator (NORMAL, INSERT, etc.)
- `file` - Filename with modified/readonly indicators
- `branch` - Git branch name
- `git_file` - Git diff stats for current file (from gitsigns, hidden for non-file buffers)
- `git_repo` - Repository-wide git diff stats (additions/changes/deletions with colors)
- `diagnostics` - Diagnostic counts (errors, warnings, etc.)
- `lsp` - Active LSP clients with cog icon
- `encoding` - File encoding (utf-8, etc.)
- `filetype` - File type with icon
- `position` - Line and column number with percentage
- `progress` - Percentage through file
- `root_dir` - Project root directory

**Visual presets:**
- `default` - Powerline/chevron style separators
- `rounded` - Rounded/pill style separators
- `square` - Square/block style separators
- `slant` - Diagonal/slanted separators
- `minimal` - No separators
- `bubble` - Rounded with gaps

For complete configuration options, see [CONFIG.md](CONFIG.md).

## Documentation

- **[AUTO_CONFIG.md](AUTO_CONFIG.md)** - How auto-configuration works (specs, presets)
- **[BUILTINS.md](BUILTINS.md)** - Neovim built-in configuration
- **[EXAMPLES.md](EXAMPLES.md)** - Usage examples and patterns
- **[CONFIG.md](CONFIG.md)** - Complete configuration reference

## Requirements

- Neovim 0.9.0+
- lazy.nvim plugin manager
- A colorscheme plugin (catppuccin, tokyonight, gruvbox, etc.)

## License

MIT
