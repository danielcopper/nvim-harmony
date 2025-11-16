# Automatic Plugin Configuration

Harmony automatically configures supported plugins with consistent theming. **Zero manual configuration needed!**

## How Auto-Configuration Works

Harmony uses a **specs system** that integrates with lazy.nvim's import feature to automatically inject theming into your plugins.

### The Three-Part System

1. **Specs** (`harmony.specs`) - Injects `opts` functions into plugin specs
2. **Presets** (`harmony.presets`) - Provides theming values (borders, icons, etc.)
3. **Integrations** (`harmony.integrations`) - Applies highlight groups (colors)

All three work together automatically when you import harmony.specs.

## Setup (Two Steps)

### Step 1: Add harmony plugin

```lua
-- lua/plugins/harmony.lua
{
  "danielcopper/nvim-harmony",
  name = "harmony",
  lazy = false,
  priority = 1000,
  init = function()
    require("harmony.builtins").setup_early()
  end,
  config = function()
    require("harmony").setup({
      colorscheme = { name = "catppuccin", variant = "mocha" },
      borders = "none",
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
    { import = "harmony.specs" },  -- ← This line enables auto-config
  },
})
```

**That's it!** All supported plugins (telescope, mason, nvim-notify, gitsigns, etc.) are automatically configured with harmony theming.

## What `{ import = "harmony.specs" }` Does

When lazy.nvim processes `{ import = "harmony.specs" }`:

1. Loads the `harmony.specs` module
2. Gets array of plugin specs from `specs.get_all()`
3. Each spec looks like:
   ```lua
   {
     "nvim-telescope/telescope.nvim",
     dependencies = { "harmony" },
     opts = function(_, opts)
       return require("harmony.presets").telescope(opts)
     end
   }
   ```
4. Lazy.nvim **merges** these specs with your plugin specs
5. Result: Your telescope spec now has harmony's `opts` function injected
6. When telescope loads, the opts function:
   - Gets your user config
   - Merges with harmony preset (borderchars, icons, etc.)
   - Returns combined config
   - Your values always win conflicts

### Example: Telescope Auto-Config

**Your telescope config** (before harmony):
```lua
{
  "nvim-telescope/telescope.nvim",
  keys = { ... },
  opts = {
    defaults = {
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
    },
  },
}
```

**After harmony specs import**, lazy.nvim merges it with harmony's spec. The result:
```lua
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "harmony" },  -- Added by harmony
  keys = { ... },                -- Your config
  opts = function(_, opts)        -- Injected by harmony
    -- opts contains your user config
    return require("harmony.presets").telescope(opts)
  end
}
```

When telescope loads:
1. Lazy calls the merged `opts` function
2. Function receives your config: `{ defaults = { sorting_strategy = "ascending", ... } }`
3. Harmony preset adds: `{ defaults = { borderchars = {...}, prompt_prefix = "🔍", ... } }`
4. Soft merge combines them (your values win)
5. Telescope.setup() receives:
   ```lua
   {
     defaults = {
       sorting_strategy = "ascending",  -- Your setting
       layout_strategy = "horizontal",   -- Your setting
       borderchars = { " ", " ", ... },  -- Harmony's
       prompt_prefix = "🔍  ",           -- Harmony's
     }
   }
   ```

## Supported Plugins

| Plugin | Auto-Config | Manual Required |
|--------|-------------|-----------------|
| telescope.nvim | ✅ Automatic | No |
| mason.nvim | ✅ Automatic | No |
| nvim-cmp | ✅ Automatic | No |
| nvim-notify | ✅ Automatic | No |
| which-key.nvim | ✅ Automatic | No |
| trouble.nvim | ✅ Automatic | No |
| gitsigns.nvim | ✅ Automatic | No |
| neo-tree.nvim | ✅ Automatic | No |
| lualine.nvim | ✅ Automatic | No |
| noice.nvim | ✅ Automatic | No |

## Your Settings Always Win

Harmony uses **soft merge** - your settings take priority:

**Your config:**
```lua
{
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      sorting_strategy = "ascending",
      borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },  -- Custom borders
    },
  },
}
```

**Result:**
- Your custom borderchars are used (not harmony's)
- Your sorting_strategy is preserved
- Harmony's other settings (prompt_prefix, etc.) are added

## Manual Presets (Without Auto-Config)

If you **don't** use `{ import = "harmony.specs" }`, you can still use presets manually:

### Method 1: In your plugin config

```lua
{
  "rcarriga/nvim-notify",
  dependencies = { "harmony" },
  opts = function(_, opts)
    return require("harmony.presets").notify(opts)
  end,
}
```

### Method 2: In config function

```lua
{
  "rcarriga/nvim-notify",
  dependencies = { "harmony" },
  config = function()
    local opts = require("harmony.presets").notify({
      timeout = 5000,  -- Your custom setting
    })
    require("notify").setup(opts)
    vim.notify = require("notify")
  end,
}
```

**When to use manual presets:**
- You don't want to use `{ import = "harmony.specs" }`
- You need fine-grained control over when presets are applied
- You want to support a plugin harmony doesn't have specs for yet

## Available Presets

All presets are in `require("harmony.presets")`:

```lua
presets.notify(opts)      -- nvim-notify
presets.telescope(opts)   -- telescope.nvim
presets.mason(opts)       -- mason.nvim
presets.cmp(opts)         -- nvim-cmp
presets.trouble(opts)     -- trouble.nvim
presets.gitsigns(opts)    -- gitsigns.nvim
presets.neo_tree(opts)    -- neo-tree.nvim
presets.which_key(opts)   -- which-key.nvim
presets.lualine(opts)     -- lualine.nvim
presets.noice(opts)       -- noice.nvim
```

List available presets:
```lua
:lua vim.print(require("harmony.presets").list())
```

## What Each Preset Configures

| Preset | What It Adds |
|--------|-------------|
| `notify` | Border style, stages, render mode, background color (for borderless) |
| `telescope` | Borderchars, prompt prefix (🔍), selection caret, entry prefix |
| `mason` | Border style, package status icons (✓, ➜, ✗) |
| `cmp` | Window borders, formatting with LSP kind icons |
| `trouble` | LSP kind icons, folder icons, indent guides |
| `gitsigns` | Git status signs (add, change, delete, etc.) |
| `neo_tree` | Folder icons, git status symbols |
| `which_key` | Window border |
| `lualine` | Diagnostic symbols in statusline |
| `noice` | LSP doc border setting |

## Examples

### Telescope with Custom Overrides

```lua
{
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      -- Your custom settings
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = { prompt_position = "top" },
      },
      -- Harmony will add: borderchars, prompt_prefix, selection_caret
    },
  },
}
```

Result (auto-merged):
```lua
{
  defaults = {
    sorting_strategy = "ascending",     -- Yours
    layout_strategy = "horizontal",      -- Yours
    layout_config = { ... },             -- Yours
    borderchars = { " ", " ", ... },     -- Harmony's
    prompt_prefix = "🔍  ",              -- Harmony's
    selection_caret = " ",              -- Harmony's
  }
}
```

### Gitsigns Auto-Configuration

**Before** (manual approach):
```lua
config = function()
  local icons = require("harmony.icons")
  require("gitsigns").setup({
    signs = {
      add = { text = icons.git.add },
      change = { text = icons.git.change },
      delete = { text = icons.git.delete },
      topdelete = { text = icons.git.delete },
      changedelete = { text = icons.git.change },
      untracked = { text = icons.git.untracked },
    },
  })
end
```

**After** (with `{ import = "harmony.specs" }`):
```lua
-- Nothing! It's automatic. Just install gitsigns normally:
{
  "lewis6991/gitsigns.nvim",
  opts = {},  -- Or add your custom gitsigns settings here
}
```

## Custom Plugin Support

For plugins harmony doesn't support yet, you can create custom presets:

```lua
-- In your config
local harmony = require("harmony")

-- Create a custom preset
harmony.presets.my_plugin = function(user_opts)
  local icons = harmony.get_icons()
  local harmony_opts = {
    border = harmony.border(),
    icons = {
      folder = icons.ui.folder,
      file = icons.ui.file,
    },
  }
  return vim.tbl_deep_extend("force", harmony_opts, user_opts or {})
end

-- Use it manually
{
  "author/my-plugin",
  dependencies = { "harmony" },
  opts = function(_, opts)
    return require("harmony.presets").my_plugin(opts)
  end,
}
```

## FAQ

**Q: Is `{ import = "harmony.specs" }` required?**
A: For zero-touch auto-config, yes. Without it, you need to manually use presets in each plugin config.

**Q: Will it override my custom plugin settings?**
A: No! Soft merge ensures your settings always take priority. Harmony only fills in missing values.

**Q: What if I want to configure one plugin manually?**
A: Just configure it normally. Your config will be merged with harmony's preset automatically.

**Q: Can I disable auto-config for one plugin?**
A: Just don't include that plugin in your config, or override all harmony settings with your own.

**Q: What happens if I have both `opts` and `config` in my plugin spec?**
A: Lazy.nvim will:
   1. Call the (merged) opts function to get config
   2. Pass that config to your config function
   3. Your config function should use the opts parameter: `config = function(_, opts)`

**Q: Do I need manual presets if I use `{ import = "harmony.specs" }`?**
A: No! Specs import does everything automatically. Manual presets are only for users who don't want to use the import.

**Q: How do I know what values harmony is adding?**
A: Check the [preset source code](lua/harmony/presets/init.lua) or CONFIG.md for what each preset provides.
