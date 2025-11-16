# Integration Examples

This document shows how to integrate harmony with common Neovim plugins using the simplified helper API.

## Core Principle

Harmony provides **theming helpers only** - borders, icons, and colors. It does **NOT** include keymappings, behaviors, or plugin functionality.

---

## LSP Configuration

### Diagnostics

```lua
{
  "neovim/nvim-lspconfig",
  dependencies = { "harmony" },
  config = function()
    local harmony = require("harmony")

    -- Diagnostic configuration
    vim.diagnostic.config({
      update_in_insert = false,
      severity_sort = true,
      underline = {
        severity = vim.diagnostic.severity.ERROR,
      },
      virtual_text = {
        spacing = 4,
        prefix = "●",
      },
      float = {
        border = harmony.border(),  -- ← Use harmony border
        source = "always",
      },
      signs = harmony.diagnostic_signs(),  -- ← Use harmony icons
    })
  end,
}
```

### LSP Handlers (Hover & Signature Help)

```lua
-- In your LSP on_attach function
local harmony = require("harmony")

-- Configure hover with harmony borders
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  harmony.lsp_hover()
)

-- Configure signature help with harmony borders
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  harmony.lsp_signature()
)
```

---

## nvim-cmp (Completion)

```lua
{
  "hrsh7th/nvim-cmp",
  dependencies = { "harmony", "hrsh7th/cmp-nvim-lsp" },
  config = function()
    local cmp = require("cmp")
    local harmony = require("harmony")

    cmp.setup({
      -- Your snippet and mapping config here...
      snippet = { ... },
      mapping = { ... },
      sources = { ... },

      -- Harmony theming
      window = harmony.cmp_window(),  -- ← Use harmony borders

      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = harmony.format_cmp_item,  -- ← Use harmony icons
      },
    })
  end,
}
```

Or if you want custom formatting:

```lua
formatting = {
  fields = { "kind", "abbr", "menu" },
  format = function(entry, vim_item)
    local kind_icons = harmony.lsp_kind_icons()
    local kind_name = vim_item.kind

    -- Customize format however you want
    vim_item.kind = (kind_icons[kind_name] or "?") .. " " .. kind_name
    vim_item.menu = entry.source.name

    return vim_item
  end,
},
```

---

## Telescope

**What Harmony provides:**
- 🎨 Highlight groups (borders, backgrounds, titles, selection, matching text)
- 🔲 Border characters via `harmony.telescope_borderchars()`

**What you configure:**
- 🔍 Prompt icon (`prompt_prefix`) - Harmony only colors it, you choose the icon
- ⚙️ All other telescope settings (layout, keymaps, etc.)

```lua
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "harmony", "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local harmony = require("harmony")

    telescope.setup({
      defaults = {
        -- Harmony theming
        borderchars = harmony.telescope_borderchars(),  -- ← Use harmony borders

        -- Your custom config (prompts, layout, etc.)
        prompt_prefix = "   ",  -- ← You choose the icon, harmony colors it
        selection_caret = " ",
        entry_prefix = " ",

        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          width = 0.87,
          height = 0.80,
        },

        path_display = { "smart" },

        -- Your custom keymappings
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            -- ... your other mappings
          },
        },
      },
    })
  end,
}
```

---

## Mason (LSP Installer)

**What Harmony provides:**
- 🎨 Highlight groups (headers, highlights, muted text, status colors)
- 🔲 Border style via `harmony.border()`

**What you configure:**
- ⚙️ UI icons (installed, pending, uninstalled)
- ⚙️ Mason settings (install path, max concurrent installers, etc.)

```lua
{
  "williamboman/mason.nvim",
  dependencies = { "harmony" },
  config = function()
    local mason = require("mason")
    local harmony = require("harmony")

    mason.setup({
      ui = {
        border = harmony.border(),  -- ← Use harmony border
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })
  end,
}
```

---

## Which-key

```lua
{
  "folke/which-key.nvim",
  dependencies = { "harmony" },
  config = function()
    local wk = require("which-key")
    local harmony = require("harmony")

    wk.setup({
      window = {
        border = harmony.border(),  -- ← Use harmony border
      },
    })
  end,
}
```

---

## nvim-notify

```lua
{
  "rcarriga/nvim-notify",
  dependencies = { "harmony" },
  config = function()
    local notify = require("notify")
    local harmony = require("harmony")

    notify.setup({
      -- Your custom config
      timeout = 3000,
      max_width = 50,

      -- Harmony theming (when we add notify integration)
      render = "default",
    })

    vim.notify = notify
  end,
}
```

---

## Summary

### Harmony Helpers Available

- `harmony.border()` - Get border style string
- `harmony.diagnostic_signs()` - Get diagnostic signs config
- `harmony.lsp_kind_icons()` - Get LSP kind icons table
- `harmony.telescope_borderchars()` - Get telescope borderchars
- `harmony.format_cmp_item(entry, vim_item)` - Format cmp items with icons
- `harmony.cmp_window()` - Get cmp window config
- `harmony.lsp_hover()` - Get LSP hover handler config
- `harmony.lsp_signature()` - Get LSP signature help config

### What Harmony Does NOT Do

- ❌ Keymappings
- ❌ Plugin behaviors
- ❌ Completion sources
- ❌ Telescope pickers
- ❌ LSP server configurations

### What You Still Configure

- ✅ All keymappings
- ✅ Plugin-specific functionality
- ✅ Layout and positioning
- ✅ Completion sources and priorities
- ✅ Custom behaviors

Harmony is **only for theming** - making your UI consistent and beautiful!
