# Built-in Configuration

Harmony provides automatic configuration for Neovim built-ins (vim.diagnostic, vim.lsp, etc.) that need to be set early, before plugins load.

## Two-Phase Loading

Harmony uses a two-phase loading system to ensure everything is configured at the right time:

### Phase 1: `init` (Early Setup)
Runs **before** Harmony fully loads. Configures:
- `vim.diagnostic.config()` - Diagnostic signs and UI
- `vim.lsp.handlers` - LSP hover/signature windows
- `vim.opt.fillchars` - Window separators and borders
- `vim.opt.listchars` - Whitespace visualization

### Phase 2: `config` (Main Setup)
Runs **after** Harmony loads. Handles:
- Colorscheme loading
- Color extraction
- Plugin integrations
- Auto-configuration of plugins

## Load Order Diagram

```
┌─────────────────────────────────────────────────────────┐
│ 1. Lazy.nvim starts loading plugins (priority order)   │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ 2. Harmony init block runs (priority 1000)             │
│    └─ builtins.setup_early()                           │
│       ├─ vim.diagnostic.config()  ✓                    │
│       ├─ vim.lsp.handlers         ✓                    │
│       ├─ vim.opt.fillchars        ✓                    │
│       └─ vim.opt.listchars        ✓                    │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ 3. Harmony config block runs                           │
│    └─ harmony.setup()                                  │
│       ├─ Load colorscheme         ✓                    │
│       ├─ Extract colors            ✓                    │
│       ├─ Apply integrations        ✓                    │
│       └─ Auto-patch plugins        ✓                    │
└─────────────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│ 4. Other plugins load with Harmony theming applied     │
└─────────────────────────────────────────────────────────┘
```

## Basic Usage

```lua
{
  "danielcopper/nvim-harmony",
  lazy = false,
  priority = 1000,
  init = function()
    -- Phase 1: Early built-in setup
    require("harmony.builtins").setup_early()
  end,
  config = function()
    -- Phase 2: Main harmony setup
    require("harmony").setup({
      colorscheme = {
        name = "catppuccin",
        variant = "mocha",
      },
      borders = "none",
    })
  end,
}
```

## What Gets Configured?

### vim.diagnostic.config

**Configured:**
```lua
{
  signs = {
    text = {
      [ERROR] = "󰅚",
      [WARN] = "󰀪",
      [HINT] = "󰌶",
      [INFO] = "󰋽",
    },
  },
  float = {
    border = "rounded",  -- or "none" based on harmony config
  },
  virtual_text = {
    spacing = 4,
    prefix = "●",
  },
  severity_sort = true,
}
```

**Affects:**
- Diagnostic signs in sign column
- Diagnostic floating windows
- Virtual text appearance

### vim.lsp.handlers

**Configured:**
```lua
vim.lsp.handlers["textDocument/hover"]
vim.lsp.handlers["textDocument/signatureHelp"]
```

**Affects:**
- LSP hover windows (K command)
- Signature help popups

### vim.opt.fillchars

**Borderless mode (`borders = "none"`):**
```lua
{
  horiz = " ",
  vert = " ",
  eob = " ",  -- end of buffer
  fold = " ",
  -- ... all set to spaces or minimal
}
```

**Bordered mode:**
```lua
{
  horiz = "─",
  vert = "│",
  fold = "·",
  foldopen = "",
  foldclose = "",
  -- ... box drawing characters
}
```

**Affects:**
- Window separators
- Fold indicators
- End-of-buffer tildes (~)

### vim.opt.listchars

**Configured:**
```lua
{
  tab = "→ ",
  trail = "·",
  nbsp = "␣",
  extends = "…",
  precedes = "…",
}
```

**Affects:**
- Whitespace visualization (when `:set list`)

## Selective Configuration

Disable specific built-in configurations:

```lua
init = function()
  require("harmony.builtins").setup_early({
    diagnostics = true,   -- ✓ Configure
    lsp_handlers = true,  -- ✓ Configure
    fillchars = false,    -- ✗ Don't configure (I'll do it myself)
    listchars = false,    -- ✗ Don't configure
  })
end
```

## Manual Override

Want to configure something yourself? Just do it after harmony's init:

```lua
init = function()
  -- Harmony sets defaults
  require("harmony.builtins").setup_early()

  -- Your overrides take precedence (run after)
  vim.diagnostic.config({
    virtual_text = false,  -- Disable virtual text
  })

  vim.opt.fillchars = {
    eob = "~",  -- Show end-of-buffer tildes
  }
end
```

## Skip Built-in Setup Entirely

If you want to configure everything manually:

```lua
{
  "danielcopper/nvim-harmony",
  lazy = false,
  priority = 1000,
  -- NO init block - skip built-in setup
  config = function()
    require("harmony").setup({
      colorscheme = { name = "catppuccin" },
    })
  end,
}
```

Then configure built-ins yourself:
```lua
-- In your init.lua or separate config file
vim.diagnostic.config({ ... })
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(...)
vim.opt.fillchars = { ... }
```

## Fallback Behavior

If Harmony config isn't loaded yet during `init`, built-ins use sensible defaults:
- **Border:** `"rounded"`
- **Icons:** Hardcoded Nerd Font glyphs
- **Colors:** Not needed until config phase

This ensures built-ins work even if there's a timing issue.

## FAQ

**Q: Do I have to use `setup_early()`?**
A: No, but recommended. Without it, you'll need to configure diagnostics/LSP handlers yourself.

**Q: Can I mix harmony built-ins with my own config?**
A: Yes! Your config after `setup_early()` will override harmony's defaults.

**Q: Why separate `init` and `config` blocks?**
A: `init` runs before plugins load (needed for diagnostics/LSP). `config` runs after all plugins are registered (needed for auto-patching).

**Q: What if I don't like harmony's diagnostic config?**
A: Either disable it in `setup_early({ diagnostics = false })` or override it after.

## See Also

- [AUTO_CONFIG.md](AUTO_CONFIG.md) - Automatic plugin configuration
- [README.md](README.md) - General usage
- [EXAMPLES.md](EXAMPLES.md) - Plugin integration examples
