# nvim-harmony

A centralized theming system for Neovim that works **with** your favorite colorschemes to provide consistent UI appearance across plugins.

## Philosophy

- **Work with colorschemes, not against them** - Extract and selectively override, don't recreate
- **Single source of truth** - Configure borders, colors, icons, padding in one place
- **Override everything** - Sensible defaults with complete customization
- **Per-plugin control** - Global settings with per-plugin overrides

## Status

**POC Phase**: Currently supports Telescope integration. More plugins coming soon!

## Features

- Automatic color extraction from any colorscheme
- Manual extractors for popular colorschemes (Catppuccin included)
- Consistent borders, backgrounds, and colors across plugins
- Two-level customization:
  - Config-based (borders, padding, margins)
  - Direct highlight overrides for fine control
- Centralized icon management
- Transparency support

## Installation

### Using lazy.nvim

```lua
{
  dir = "~/Repos/nvim-harmony",
  name = "harmony",
  dependencies = {
    "nvim-telescope/telescope.nvim", -- Example plugin
    "catppuccin/nvim",                -- Example colorscheme
  },
  config = function()
    require('harmony').setup({
      colorscheme = {
        name = "catppuccin",
        variant = "mocha",
      },
      borders = "rounded",
    })
  end,
}
```

## Quick Start

### Minimal Configuration

```lua
require('harmony').setup({
  colorscheme = {
    name = "catppuccin",
    variant = "mocha",
  },
})
```

That's it! Everything else uses sensible defaults.

### Standard Configuration

```lua
require('harmony').setup({
  colorscheme = {
    name = "catppuccin",
    variant = "mocha",
  },

  -- Global settings
  borders = "rounded",  -- none, single, double, rounded, solid, shadow
  transparency = {
    enabled = false,
  },

  -- Per-plugin overrides
  overrides = {
    telescope = {
      borders = "single",  -- Override just for telescope
    },
  },
})
```

### Advanced Configuration

```lua
require('harmony').setup({
  colorscheme = {
    name = "catppuccin",
    variant = "mocha",
  },

  borders = "rounded",

  -- Global color overrides
  colors = {
    bg_dark = "#15151a",
    border = "#89b4fa",
  },

  -- Per-plugin customization
  overrides = {
    telescope = {
      -- Level 1: Config-based
      borders = "rounded",

      -- Level 2: Direct highlight overrides
      highlights = {
        TelescopeSelection = { bg = "#45475a", bold = true },
        TelescopeMatching = { fg = "#f38ba8", bold = true },
      },
    },
  },
})
```

### Using Harmony in Your Plugin Configs

Harmony provides **helper functions** to simplify integration with other plugins:

```lua
local harmony = require("harmony")

-- Use in diagnostics
vim.diagnostic.config({
  float = { border = harmony.border() },
  signs = harmony.diagnostic_signs(),
})

-- Use in nvim-cmp
cmp.setup({
  window = harmony.cmp_window(),
  formatting = {
    format = harmony.format_cmp_item,
  },
})

-- Use in Telescope
telescope.setup({
  defaults = {
    borderchars = harmony.telescope_borderchars(),
  },
})

-- Use in LSP handlers
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  harmony.lsp_hover()
)
```

**See [EXAMPLES.md](EXAMPLES.md) for complete integration examples!**

## Supported Plugins

Currently implemented:
- ✅ Telescope

Coming soon:
- ⏳ nvim-notify
- ⏳ Mason
- ⏳ nvim-cmp
- ⏳ lualine
- ⏳ nvim-tree / neo-tree

## Supported Colorschemes

All colorschemes work via auto-extraction. Manual extractors (higher quality) available for:
- ✅ Catppuccin (mocha, macchiato, frappe, latte)

## Configuration Options

### Required

- `colorscheme.name` - Colorscheme name (string)
- `colorscheme.variant` - Colorscheme variant (string, optional)

### Global Settings

- `borders` - Border style (default: "rounded")
- `transparency.enabled` - Enable transparency (default: false)
- `margins` - Window margins (table)
- `padding` - Window padding (table)
- `colors` - Color overrides (table)
- `icons` - Icon overrides (table)

### Per-Plugin Overrides

```lua
overrides = {
  [plugin_name] = {
    enabled = true,        -- Enable/disable theming for this plugin
    borders = "rounded",   -- Override border style
    colors = {},          -- Override colors
    highlights = {},      -- Direct highlight group overrides
  }
}
```

## Development

### Project Structure

```
nvim-harmony/
├── lua/harmony/
│   ├── init.lua              # Main entry point
│   ├── config.lua            # Configuration system
│   ├── colors.lua            # Color utilities
│   ├── icons.lua             # Icon definitions
│   ├── utils.lua             # Integration utilities
│   ├── extraction/
│   │   ├── init.lua          # Auto-extraction
│   │   └── manual/
│   │       └── catppuccin.lua # Manual extractors
│   └── integrations/
│       └── telescope.lua     # Plugin integrations
├── PLANNING.md               # Architecture documentation
├── test_config.lua           # Example configurations
└── README.md                 # This file
```

### Testing

1. Install the plugin locally using lazy.nvim (see Installation above)
2. Check `test_config.lua` for example configurations
3. Restart Neovim
4. Open Telescope (`:Telescope find_files`) to see the theming

### Debug Logging

Set Neovim's log level to see debug messages:

```lua
vim.o.verbose = 1
```

Or use `:messages` to see setup logs.

## Roadmap

- [x] Core architecture
- [x] Color extraction system
- [x] Telescope integration
- [ ] Add more plugin integrations
- [ ] Add more manual colorscheme extractors
- [ ] Command interface (`:Harmony*` commands)
- [ ] Hot-reload support
- [ ] Cache extracted palettes

## Contributing

This is currently in POC phase. Contributions welcome once the core stabilizes!

## License

MIT (to be added)

## Credits

Inspired by [NvChad's base46](https://github.com/NvChad/base46) theming system.
