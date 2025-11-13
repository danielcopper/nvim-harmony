# Neovim Theming System - Planning Documentation

**Status:** In Progress - Planning Phase
**Last Updated:** 2025-11-10

---

## Project Vision

A centralized theming system for Neovim that makes UI appearance (borders, backgrounds, colors) dynamically controllable and automatically adapts to different colorschemes.

### Core Philosophy
- Single source of truth for all theming configuration
- Changes propagate to all plugins automatically
- Easy to extend and customize
- Override everything - sensible defaults that can be completely customized

---

## 🚧 System Overview (WIP - Updated as we design)

**Note:** This section provides a high-level overview of how the system works. It will be continuously updated as we make more design decisions.

### Core Flow

**What happens when the plugin loads:**

```
1. User provides configuration
   └─> require('plugin').setup({ colorscheme = {...}, borders = "rounded", ... })

2. Configuration validation & merging
   └─> Validate config (warn on errors)
   └─> Merge with sensible defaults
   └─> Apply override precedence: per-plugin > global > defaults

3. Load colorscheme
   └─> We execute: vim.cmd("colorscheme catppuccin-mocha")
   └─> Colorscheme plugin sets all its highlight groups

4. Color extraction
   └─> Query core highlight groups (Normal, FloatBorder, Comment, etc.)
   └─> Extract base colors (bg, fg, border, error, warn, etc.)
   └─> Generate color variants (bg_darker, bg_light, etc.) using utilities
   └─> OR use manual extractor if available for this colorscheme
   └─> Apply user's global color overrides from config

5. Icon loading
   └─> Load default icons (diagnostics, LSP, git, etc.)
   └─> Apply user's global icon overrides from config

6. Plugin integration
   └─> For each installed plugin with integration:
       - Check if enabled (default: true, unless user disabled)
       - Get plugin-specific config (borders, padding, colors, icons)
       - Apply per-plugin overrides with merging
       - Pass (colors, config, icons) to integration module
       - Integration returns highlight groups table
       - Apply highlights via vim.api.nvim_set_hl()

7. Complete
   └─> System ready, all highlights applied
```

### Core Components

**Modules we're building:**

| Component | Responsibility | Status |
|-----------|---------------|--------|
| **Config System** | Parse user config, validate, merge with defaults, handle overrides | ✅ Designed |
| **Colorscheme Loader** | Map colorscheme config to vim command, load colorscheme | ✅ Designed |
| **Color Extractor** | Extract colors from highlight groups, generate palette | ✅ Designed |
| **Color Utilities** | lighten, darken, mix, HSL conversion, contrast checking | ✅ Designed |
| **Manual Extractors** | Optional high-quality extractors for popular colorschemes | ✅ Designed |
| **Icon Manager** | Centralized icon definitions, apply overrides | ✅ Designed |
| **Integration Loader** | Load and execute plugin integrations | ✅ Designed |
| **Integration Modules** | Per-plugin modules that generate highlights | ✅ Designed |
| **Highlight Applicator** | Apply highlight groups with proper timing/priority | ✅ Designed |
| **Command Interface** | User commands (:Theme*) | ⏳ To design |
| **Extensibility API** | Allow users to add custom integrations | ✅ Designed |

### Data Flow

**How data moves through the system:**

```
User Config
    │
    ├─> Colorscheme Config ──> Colorscheme Loader ──> vim.cmd("colorscheme ...")
    │                                                          │
    │                                                          v
    │                                              Colorscheme sets highlights
    │                                                          │
    │                                                          v
    ├─> Global Settings ─────────────────┐         Color Extractor
    │   (borders, transparency, etc.)    │         (queries highlight groups)
    │                                     │                   │
    ├─> Global Color Overrides ──────────┼───────────────────┤
    │                                     │                   v
    │                                     │         Color Palette Generated
    ├─> Global Icon Overrides ───────────┼─────────┐         │
    │                                     │         │         │
    └─> Per-Plugin Overrides             │         │         │
        (borders, colors, icons, etc.)   │         │         │
                │                         │         │         │
                v                         v         v         v
          Integration Loader ──> Integration Module(colors, config, icons)
                                          │
                                          v
                                  Highlight Groups Table
                                  { TelescopeBorder = {...}, ... }
                                          │
                                          v
                                  Highlight Applicator
                                  (vim.api.nvim_set_hl)
                                          │
                                          v
                                  Applied to Neovim
```

### Key Design Decisions (So Far)

**✅ Decided:**

1. **Work WITH colorschemes** - Don't recreate, extract and selectively override
2. **We load the colorscheme** - User provides config, we execute vim.cmd()
3. **Hybrid extraction** - Auto-extraction + manual extractors for popular themes
4. **Simple flat palette** - No complex base_16/base_30 split
5. **Override everything** - Global defaults + per-plugin overrides with merging
6. **Selective overrides only** - Only change what our config requires
7. **Modular integrations** - One file per plugin, returns highlight table
8. **Configuration validation** - Warn/error, never silent fallbacks

**⏳ To Decide:**

- Integration loading mechanism
- Plugin lifecycle and timing
- Extensibility API
- Command interface
- Which plugins to support initially
- Distribution strategy
- Icon management details
- Hot-reload support

### Example: How Telescope Integration Works

```lua
-- User config
setup({
  colorscheme = { name = "catppuccin", variant = "mocha" },
  borders = "none",  -- global setting

  overrides = {
    telescope = {
      borders = "rounded"  -- telescope uses rounded despite global "none"
    }
  }
})

-- System flow:
-- 1. Load catppuccin-mocha (sets all catppuccin highlights)
-- 2. Extract colors → { bg = "#1e1e2e", border = "#89b4fa", ... }
-- 3. Load telescope integration with:
--    - colors: extracted palette
--    - config: { borders = "rounded" } (per-plugin override wins)
--    - icons: default icons
-- 4. Telescope integration returns:
--    {
--      TelescopeBorder = { fg = colors.border },
--      TelescopeNormal = { bg = colors.bg },
--      -- ...
--    }
-- 5. Apply highlights to Neovim
```

---

## Planning Process

We are following a structured planning approach before implementation:

**Completed Topics:**
1. ✅ **Define exact functionality scope** - Borders, padding, transparency, icons, colors
2. ✅ **Design configuration system** - Setup structure, overrides, merging, validation
3. ✅ **Design color extraction architecture** - Hybrid extraction, palette generation, utilities
4. ✅ **Design plugin integration system** - Module structure, loading flow, utilities
6. ✅ **Design icon management system** - Icon definitions, categories, overrides
8. ✅ **Design extensibility system** - Two-level overrides (config + highlights), no custom integrations initially

**Skipped Topics (will address during implementation):**
5. ⏭️ **Hot-reload mechanism** - Low priority, restart is fast enough
9. ⏭️ **Plugin lifecycle and timing system** - Too abstract, will figure out when implementing

**Decision Topics - Quick Wins:**
10. ✅ **Initial plugin support** - telescope, nvim-notify, mason (POC)
11. ✅ **Distribution strategy** - Standard Neovim plugin, lazy.nvim local support
12. ✅ **Project name and branding** - nvim-harmony
13. ✅ **Directory structure** - Standard Neovim plugin layout

**Deferred Topics (will address when needed):**
7. ⏭️ **Command and API surface** - Skip for POC, add later if needed
14. ⏭️ **Comprehensive architecture docs** - This document IS the architecture docs
15. ⏭️ **API documentation** - Will create during/after implementation

**Progress: 10/15 complete (67%), 5 deferred**
**🎉 Core planning complete - ready to implement!**

**Note:** Project naming and structure comes AFTER we design the architecture, so we know what we're building first.

---

## Topic #1: Functionality Scope ✅

### IN SCOPE

#### Border Management
- **Supported styles:** nvim built-ins only (none, single, rounded, double, etc.)
- **Global defaults:** Single border style applied to all plugins by default
- **Per-plugin overrides:** Each plugin can have its own border style
- **No custom border characters** (not needed for initial version)

#### Padding & Spacing
- **Context-aware padding:** Different padding per colorscheme + per border + per plugin
  - Example: Mason might need extra top padding in certain colorscheme/border combinations
- **Per-plugin padding overrides:** Each plugin can have custom padding
- **Window margins/gaps:** Support for configuring margins around windows

#### Transparency
- **Global transparency:** All or nothing approach
- **No per-plugin transparency** (keep it simple)

#### Icon Management
- **Centralized icon definitions:** Single source for all icons (LSP kinds, diagnostics, git, DAP, UI)
- **Per-plugin icon overrides:** Plugins can use different icons if needed
- **Nerd Fonts dependency:** Nerd fonts required, may add unicode fallbacks later
- **Override philosophy:** Users can override any icon

#### Color & Highlight Management
- **All relevant highlight groups themed:** Internal mapping system to capture all highlight groups
  - Plugin-specific highlights
  - Native Neovim UI (statusline, tabline, popups)
- **Colorscheme variant support:** Support multiple variants (e.g., catppuccin-mocha, catppuccin-latte)
- **Simple diagnostic colors:** Error/warn/info/hint use colors from selected colorscheme
- **Override everything:** Users can override any color
  - Global color overrides
  - Per-plugin color overrides

#### Philosophy
- **Sensible defaults + complete customization**
- **Global settings with per-plugin overrides**
- **Simple for basic use, powerful for advanced use**

### OUT OF SCOPE (Initial Version)

#### Not Implementing Now
- Custom border characters
- Per-plugin transparency levels
- Background intensity/dimming (other plugins exist for this)
- Complex semantic tokens theming
- Complex treesitter theming
- Hot-reload/runtime changes (nice to have, but nvim restart is fast)

#### Future Features
- Persistent config storage
- Preview system for colorschemes/borders
- Full UI for configuration (reference: https://github.com/nvzone/volt)

---

## Topic #2: Configuration System ✅

**Status:** Complete

### Core Principles

1. **Override Precedence:** Per-plugin overrides → Global config → Sensible defaults
2. **Merge Behavior:** Nested objects merge/extend (keeps parent values unless explicitly overridden)
3. **Special Keywords:** `"default"` keyword to explicitly reference system defaults (e.g., `{ 0, 1, "default", 1 }`)
4. **Auto-enable:** Theming automatically enabled for all installed plugins (can be disabled with `enabled = false`)
5. **Validation:** Validate config and warn/error on issues - NO silent fallbacks to defaults
6. **Minimal Config:** Should work with just colorscheme specified

### Configuration Schema

```lua
require('theme').setup({
  -- REQUIRED: Colorscheme configuration
  colorscheme = {
    name = "catppuccin",   -- colorscheme name
    variant = "mocha"      -- variant (optional for colorschemes without variants)
  },

  -- OPTIONAL: Global settings (all have sensible defaults)
  borders = "rounded",     -- none|single|rounded|double|etc. (nvim built-ins only)

  transparency = {
    enabled = true         -- nested for future extensibility
  },

  margins = {              -- window margins
    top = 1,
    bottom = 1,
    left = 2,
    right = 2
  },

  padding = {              -- window padding
    top = 0,
    bottom = 0,
    left = 0,
    right = 0
  },

  -- Global color overrides (override extracted colorscheme colors)
  colors = {
    bg_dark = "#123456",
    border = "#abcdef",
    -- ... any standardized color name
  },

  -- Global icon overrides
  icons = {
    diagnostics = {
      error = "󰅚",
      warn = "󰀪",
      info = "",
      hint = ""
    },
    -- ... other icon categories
  },

  -- Per-plugin overrides (highest precedence)
  overrides = {
    mason = {
      enabled = false,     -- opt-out of theming for this plugin

      borders = "single",  -- plugin-specific border override

      margins = {
        top = 2            -- merges with global margins (only top changes)
      },

      colors = {
        bg = "#abcdef"     -- plugin-specific color overrides
      },

      icons = {
        -- plugin-specific icon overrides
      },

      -- Context-aware padding (hybrid approach)
      padding = {
        default = { top = 1, bottom = 1 },
        ["catppuccin-mocha"] = { top = 2 },      -- colorscheme-specific
        ["rounded"] = { top = 1, bottom = 2 }    -- border-specific
      }
    },

    telescope = {
      -- ... telescope overrides
    }
  }
})
```

### Configuration Features

#### Nested Structure for Overrides
- Clean, organized structure
- Groups all plugin-specific settings together
- Easy to read and maintain

#### Context-Aware Padding
- **Hybrid approach:** Sensible defaults provided by us
- **User override capability:** Can specify padding rules per colorscheme or border style
- **Use case:** Some plugins need different padding in certain colorscheme/border combinations

#### Consistent Override Pattern
- Every setting follows the same pattern: global → per-plugin
- Applies to: borders, margins, padding, colors, icons
- Makes configuration intuitive and predictable

#### Merging Behavior
- Nested objects merge/extend by default
- Example: Global `padding = { top = 1, bottom = 2 }` + Plugin `padding = { top = 3 }` = Result `{ top = 3, bottom = 2 }`
- Can use `"default"` keyword to explicitly reference system defaults

#### Validation Strategy
- Validate configuration on setup
- Warn/error on issues:
  - Invalid plugin names
  - Invalid colorscheme names
  - Invalid border styles
  - Type mismatches
- **Never silently fall back to defaults** (worst practice)

#### Minimal Configuration
```lua
require('theme').setup({
  colorscheme = { name = "catppuccin", variant = "mocha" }
})
```
- This should "just work" with sensible defaults
- All other settings optional
- Defaults reflect maintainer preferences

### Impact on Other Systems

**⚠️ Dependencies Created:**
- **Color Extraction (Topic #3):** Must support variant handling
- **Plugin Integration (Topic #4):** Must handle enabled/disabled flag
- **Icon Management (Topic #6):** Must support global + per-plugin override pattern
- **Extensibility (Topic #8):** Custom integrations must follow override pattern

**🔗 Cross-cutting Concerns:**
- Configuration merging logic affects all subsystems
- Validation system needs to know about all valid colorschemes, plugins, border styles
- Context-aware padding requires colorscheme + border state to be available at integration time

---

## Topic #3: Color Extraction Architecture ✅

**Status:** Complete

### Research: NvChad base46 Analysis

Completed comprehensive analysis of NvChad's base46 theming system:
- **What they do:** Manual theme definitions (93 themes), dual palette (base_16 + base_30), compilation/caching
- **Key insight:** They don't use actual colorscheme plugins - they recreate colors manually
- **What we adopt:** Modular integrations, color manipulation utilities, optional caching
- **What we avoid:** Manual theme recreation, required compilation, NvChad coupling
- **Our differentiator:** Auto-extract from existing colorscheme plugins (work WITH them, not replace)

### Core Approach

**Philosophy: Work WITH Existing Colorschemes**

We do NOT recreate colorschemes. Instead:
1. User's colorscheme plugin loads (catppuccin, gruvbox, etc.)
2. Colorscheme sets all its highlight groups via `vim.api.nvim_set_hl()`
3. We extract colors from those ALREADY SET highlight groups
4. We build our own palette from extracted colors
5. We selectively override ONLY what our config requires

**Example:**
```lua
-- 1. We load user's colorscheme
vim.cmd("colorscheme catppuccin-mocha")

-- 2. Extract colors from existing highlights
local colors = extract_colors()

-- 3. Only override when needed
if config.borders == "none" and plugin == "notify" then
  -- Make notify more visible without borders
  vim.api.nvim_set_hl(0, "NotifyBackground", {
    bg = darken(colors.bg, 10)
  })
end
```

### How Neovim Colorschemes Work

**Important Context:**
- Colorschemes do NOT expose a standard palette structure
- No fixed number of colors or standard color names
- They simply call `vim.api.nvim_set_hl()` for each highlight group
- Different colorschemes define different highlight groups
- No Neovim-wide standardization (except Base16 specification, rarely followed strictly)

**What colorschemes do:**
```lua
vim.api.nvim_set_hl(0, "Normal", { fg = "#abb2bf", bg = "#282c34" })
vim.api.nvim_set_hl(0, "Comment", { fg = "#5c6370", italic = true })
vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#61afef" })
-- Or link to base groups
vim.api.nvim_set_hl(0, "SomeGroup", { link = "FloatBorder" })
```

### Extraction Strategy: Hybrid Approach

**Decision: Option 3 - Manual Extractors + Auto-extraction Fallback**

**Approach:**
1. **Manual extractors** for popular colorschemes (high quality, predictable)
2. **Auto-extraction** with generated variants as fallback (broad compatibility)
3. Start with auto-extraction, add manual extractors incrementally

**Why hybrid?**
- Manual extractors ensure quality for popular colorschemes
- Auto-extraction provides compatibility for long-tail colorschemes
- Can improve quality over time by adding more manual extractors
- Best balance of quality vs effort

### Auto-Extraction Process

**Step 1: Load Colorscheme**
```lua
-- We load the colorscheme (not the user)
local colorscheme_name = build_colorscheme_command(config.colorscheme)
vim.cmd("colorscheme " .. colorscheme_name)
```

**Step 2: Extract Base Colors from Core Highlight Groups**
```lua
local function extract_base_colors()
  return {
    -- Base colors from Normal
    bg = get_hl("Normal").bg,
    fg = get_hl("Normal").fg,

    -- Float window colors
    float_bg = get_hl("NormalFloat").bg or get_hl("Normal").bg,
    float_fg = get_hl("NormalFloat").fg or get_hl("Normal").fg,

    -- Border color
    border = get_hl("FloatBorder").fg or get_hl("Normal").fg,

    -- Muted/secondary colors
    muted = get_hl("Comment").fg,
    line_nr = get_hl("LineNr").fg,

    -- Subtle background variant
    cursor_line = get_hl("CursorLine").bg,

    -- Diagnostic/semantic colors
    error = get_hl("DiagnosticError").fg or get_hl("Error").fg,
    warn = get_hl("DiagnosticWarn").fg or get_hl("WarningMsg").fg,
    info = get_hl("DiagnosticInfo").fg,
    hint = get_hl("DiagnosticHint").fg,

    -- Common syntax colors (for accents if needed)
    string = get_hl("String").fg,
    func = get_hl("Function").fg,
    keyword = get_hl("Keyword").fg,
  }
end
```

**Step 3: Generate Color Variants**
```lua
local function generate_palette(base_colors)
  return {
    -- Base colors (extracted)
    bg = base_colors.bg,
    fg = base_colors.fg,
    float_bg = base_colors.float_bg,
    border = base_colors.border,
    muted = base_colors.muted,

    -- Generated variants
    bg_darker = darken(base_colors.bg, 10),
    bg_dark = darken(base_colors.bg, 5),
    bg_light = lighten(base_colors.bg, 5),
    bg_lighter = lighten(base_colors.bg, 10),

    fg_dark = darken(base_colors.fg, 10),
    fg_light = lighten(base_colors.fg, 10),

    -- Semantic colors
    error = base_colors.error,
    warn = base_colors.warn,
    info = base_colors.info,
    hint = base_colors.hint,

    -- Accent colors (from syntax if needed)
    accent_1 = base_colors.string,
    accent_2 = base_colors.func,
    accent_3 = base_colors.keyword,
  }
end
```

### Manual Extractor Example

For popular colorschemes where we know the exact structure:

```lua
-- extractors/catppuccin.lua
return function(variant)
  -- Catppuccin exposes its palette
  local palette = require("catppuccin.palettes").get_palette(variant)

  return {
    bg = palette.base,
    bg_dark = palette.mantle,
    bg_darker = palette.crust,
    bg_light = palette.surface0,
    bg_lighter = palette.surface1,

    fg = palette.text,
    fg_dark = palette.subtext1,

    border = palette.overlay0,
    muted = palette.overlay1,

    error = palette.red,
    warn = palette.yellow,
    info = palette.blue,
    hint = palette.teal,

    -- Full access to all catppuccin colors
    -- ...
  }
end
```

### Color Manipulation Utilities

**Required utilities** (implement or adapt from base46):

```lua
-- Color space conversions
hex_to_rgb(hex) → {r, g, b}
rgb_to_hex(r, g, b) → "#rrggbb"
rgb_to_hsl(r, g, b) → {h, s, l}
hsl_to_rgb(h, s, l) → {r, g, b}

-- Color operations
lighten(color, percentage) → lighter_color
darken(color, percentage) → darker_color
saturate(color, percentage) → more_saturated
desaturate(color, percentage) → less_saturated
mix(color1, color2, ratio) → mixed_color

-- Analysis
is_light(color) → boolean  -- Determine if color is light or dark
contrast_ratio(fg, bg) → number  -- WCAG contrast ratio
```

**Why we need these:**
- Generate color variants from base colors
- Create distinct backgrounds when borders="none"
- Ensure adequate contrast for accessibility
- Adapt colors to different contexts

### Palette Structure

**Simple flat structure** (no base_16/base_30 split needed):

```lua
colors = {
  -- Background variants (darkest to lightest)
  bg_darker = "#...",
  bg_dark = "#...",
  bg = "#...",
  bg_light = "#...",
  bg_lighter = "#...",

  -- Float-specific
  float_bg = "#...",
  float_fg = "#...",

  -- Foreground variants
  fg_dark = "#...",
  fg = "#...",
  fg_light = "#...",

  -- UI elements
  border = "#...",
  muted = "#...",    -- For less important text

  -- Semantic colors
  error = "#...",
  warn = "#...",
  info = "#...",
  hint = "#...",

  -- Accent colors (from syntax)
  accent_1 = "#...",
  accent_2 = "#...",
  accent_3 = "#...",
}
```

### Colorscheme Variant Handling

**Mapping config to colorscheme command:**

```lua
local function build_colorscheme_command(cs_config)
  -- cs_config = { name = "catppuccin", variant = "mocha" }

  -- Map known colorschemes
  local mappings = {
    catppuccin = function(variant)
      return "catppuccin-" .. (variant or "mocha")
    end,

    gruvbox = function(variant)
      if variant then
        vim.o.background = variant  -- "dark" or "light"
      end
      return "gruvbox"
    end,

    tokyonight = function(variant)
      return "tokyonight-" .. (variant or "night")
    end,

    -- Fallback: simple name
    default = function(name, variant)
      return name
    end
  }

  local mapper = mappings[cs_config.name] or mappings.default
  return mapper(cs_config.variant)
end
```

### Fallback Strategy

**Handling missing highlight groups:**

```lua
local function get_hl_safe(name, fallback_chain)
  for _, hl_name in ipairs(fallback_chain) do
    local hl = vim.api.nvim_get_hl(0, { name = hl_name })
    if hl and (hl.fg or hl.bg) then
      return hl
    end
  end

  -- Ultimate fallback
  return vim.api.nvim_get_hl(0, { name = "Normal" })
end

-- Usage:
local border = get_hl_safe("FloatBorder", {"FloatBorder", "VertSplit", "Normal"}).fg
```

### Integration with Configuration System

**User color overrides** (from Topic #2) take precedence:

```lua
-- 1. Extract/generate base palette
local colors = extract_and_generate_palette()

-- 2. Apply global color overrides from config
colors = merge(colors, config.colors or {})

-- 3. Per-plugin overrides applied at integration time
-- (handled in plugin integration system)
```

### Impact on Other Systems

**⚠️ Dependencies Created:**
- **Plugin Integration (Topic #4):** Integrations receive the extracted palette
- **Icon Management (Topic #6):** May need access to palette for colored icons
- **Extensibility (Topic #8):** Custom integrations must receive palette

**🔗 Cross-cutting Concerns:**
- Extraction must happen BEFORE applying any integrations
- Color utilities must be available to all integration modules
- Palette structure must be documented for custom integrations

### Future Improvements

**📋 TODO / Future Enhancements:**

1. **Intelligent Auto-categorization**
   - Analyze ALL background colors used in colorscheme
   - Sort by lightness (HSL)
   - Auto-assign to bg_darker, bg_dark, bg, bg_light categories
   - More accurate than generating variants
   - **Complexity:** High - might guess wrong
   - **Priority:** Low - generate variants works well enough

2. **More Manual Extractors**
   - Add manual extractors for: gruvbox, tokyonight, nord, onedark, kanagawa, rose-pine
   - Provides better quality for popular colorschemes
   - **Priority:** Medium - can add incrementally

3. **Color Analysis Tools**
   - Detect colorscheme "personality" (vibrant vs muted, warm vs cool)
   - Use analysis to make better override decisions
   - **Priority:** Low - nice to have

4. **Contrast Validation**
   - Check WCAG contrast ratios for accessibility
   - Warn if overrides create poor contrast
   - **Priority:** Medium - important for accessibility

5. **Caching Extracted Palettes**
   - Cache extracted + generated palettes to disk
   - Skip extraction on subsequent loads
   - Invalidate when colorscheme changes
   - **Priority:** Medium - performance optimization

6. **Terminal Color Extraction**
   - Extract and set terminal colors (like base46's term.lua)
   - Ensures terminal matches editor
   - **Priority:** Low - scope creep

### Design Decisions Summary

✅ **Decided:**
- Work WITH existing colorscheme plugins (not recreate)
- WE load the colorscheme via vim.cmd()
- Extract from core highlight groups + generate variants
- Hybrid approach: manual extractors + auto-extraction fallback
- Simple flat palette structure
- Implement color manipulation utilities
- Per-colorscheme command mapping

🔧 **Implementation Notes:**
- Start with auto-extraction only
- Add manual extractors incrementally for popular colorschemes
- Use fallback chains for missing highlight groups
- Color utilities can be adapted from base46's implementation

---

## Topic #4: Plugin Integration System ✅

**Status:** Complete

### Core Concept

Plugin integrations are modular components that generate highlight groups for specific Neovim plugins. Each integration receives colors, configuration, and icons, then returns a table of highlight group definitions.

### Integration Module Structure

**Chosen approach: Metadata + Setup Function (Option B+)**

```lua
-- integrations/telescope.lua
return {
  name = "telescope",              -- Integration identifier
  plugin_name = "telescope",       -- Plugin name for installation check

  setup = function(colors, config)
    -- Optional: Use shared utilities
    local utils = require("ourplugin.integration_utils")

    -- Optional: Load icons
    local icons = require("ourplugin.icons")

    -- Generate highlights based on config
    local border_color = config.borders == "none"
      and colors.bg_light
      or colors.border

    return {
      TelescopeBorder = { fg = border_color },
      TelescopeNormal = { bg = colors.bg },
      TelescopePrompt = { bg = colors.float_bg },
      -- ... more highlight groups
    }
  end
}
```

**Why this structure:**
- ✅ Metadata for installation checking
- ✅ Simple for basic integrations
- ✅ Flexible for complex logic
- ✅ Minimal boilerplate
- ✅ Icons via require (not parameter) - keeps it simple

### Integration Loading Flow

```
For each integration in integrations directory:
  1. Load integration module
  2. Check if user disabled it in config → SKIP if disabled
  3. Check if plugin installed → SKIP if not installed
  4. Get plugin-specific config (merged global + per-plugin overrides)
  5. Call integration.setup(colors, config)
  6. Receive highlight groups table
  7. Apply highlights via vim.api.nvim_set_hl()
```

### Installation Detection

**Simple approach: pcall(require)**

```lua
local function is_plugin_installed(plugin_name)
  local ok, _ = pcall(require, plugin_name)
  return ok
end
```

**Why simple:**
- Works for most plugins
- No dependency on plugin manager (lazy.nvim, packer, etc.)
- Easy to understand
- Good enough for initial version

**Future improvement:** Could add plugin manager-specific detection for better accuracy

### Configuration Passed to Integrations

**What integrations receive in `config` parameter:**

```lua
config = {
  -- Global settings
  borders = "rounded",
  transparency = { enabled = true },
  margins = { top = 1, bottom = 1, left = 2, right = 2 },
  padding = { top = 0, bottom = 0, left = 0, right = 0 },

  -- Colorscheme info (for context-aware logic)
  colorscheme = {
    name = "catppuccin",
    variant = "mocha"
  },

  -- Per-plugin overrides (already merged with global)
  -- If plugin has overrides, they're already applied to above values
}
```

**Notes:**
- Config is pre-merged (per-plugin overrides already applied)
- Integration doesn't need to handle merging logic
- Colorscheme info available for context-aware decisions
- Other plugin configs excluded (not needed)

### Context-Aware Logic

**Where it lives: In each integration**

Context-aware logic (different behavior based on colorscheme + border combination) lives in individual integrations, not shared utilities.

**Why:**
- Too plugin-specific to generalize
- Each plugin has unique requirements
- Keeps integrations self-contained
- Can be refactored to utilities later if patterns emerge

**Example:**
```lua
-- In mason integration
setup = function(colors, config)
  local padding = { top = 1, bottom = 1 }

  -- Context-aware adjustment
  if config.colorscheme.name == "catppuccin" and config.borders == "rounded" then
    padding.top = 2  -- Need extra padding for this combo
  end

  -- ... use padding in highlight generation
end
```

### Shared Utilities

**Available but optional: integration_utils module**

```lua
-- integration_utils.lua
local M = {}

-- Common helpers any integration can use
function M.compute_border_color(colors, config)
  if config.borders == "none" then
    return colors.bg_light
  else
    return colors.border
  end
end

function M.get_distinct_bg(colors, base_bg, amount)
  local color_utils = require("ourplugin.colors")
  return color_utils.darken(base_bg, amount or 5)
end

-- ... more common patterns

return M
```

**Usage in integration:**
```lua
setup = function(colors, config)
  local utils = require("ourplugin.integration_utils")
  local border = utils.compute_border_color(colors, config)
  -- ...
end
```

**Benefits:**
- Avoid code duplication
- Consistent behavior across integrations
- Simple integrations don't need to use them
- Complex integrations have tools available

### Highlight Application

**Simple and direct:**

```lua
local highlights = integration.setup(colors, config)

for group_name, group_def in pairs(highlights) do
  vim.api.nvim_set_hl(0, group_name, group_def)
end
```

**No special handling needed** (for now):
- No transparency processing (integrations handle it if needed)
- No validation (trust integration output)
- No modification (apply as-is)

**Future considerations:**
- Could add validation/error checking
- Could auto-handle transparency globally
- Could add highlight priority system
- Keep it simple initially

### Error Handling

**Approach: Skip and warn**

If an integration fails:
1. Log warning with integration name and error
2. Continue with other integrations
3. Don't crash the entire system

```lua
local ok, highlights = pcall(integration.setup, colors, config)
if not ok then
  vim.notify("Integration '" .. integration.name .. "' failed: " .. highlights, vim.log.levels.WARN)
  return
end
```

### Integration Discovery

**To be decided in implementation:**
- Option A: Scan integrations directory for .lua files
- Option B: Explicit list in main module
- Option C: Lazy-load as needed

Not critical for architecture planning - implementation detail.

### Impact on Other Systems

**⚠️ Dependencies Created:**
- **Icon Management (Topic #6):** Integrations need to require icons module
- **Extensibility (Topic #8):** Custom integrations must follow this interface
- **Lifecycle/Timing (Topic #9):** Need to determine when to run integrations

**🔗 Cross-cutting Concerns:**
- Integration loading happens AFTER color extraction and icon loading
- Config must be fully merged before passing to integrations
- Shared utilities must be available before any integration loads

### Design Decisions Summary

✅ **Decided:**
- Metadata + setup function structure
- Simple installation check via pcall(require)
- Skip if disabled OR not installed
- Pass colors + config (icons via require)
- Context-aware logic in each integration
- Shared utilities available but optional
- Simple highlight application (no special processing)
- Skip and warn on errors

🔧 **Implementation Notes:**
- Keep integrations simple and focused
- Don't over-engineer initially
- Can add complexity later if needed
- Trust integration authors to do the right thing

---

## Remaining Topics

### Topic #5: Hot-Reload Mechanism
- **SKIPPED** - Low priority, restart is fast enough
- May revisit in future

### Topic #6: Icon Management System ✅

**Status:** Complete

### Core Concept

Centralized icon definitions used across all integrations. Icons follow the same override pattern as colors: global defaults + per-plugin overrides.

### Icon Structure

```lua
-- icons.lua
return {
  diagnostics = {
    error = "󰅚",
    warn = "󰀪",
    info = "",
    hint = "󰌶"
  },

  lsp = {
    kinds = {
      Text = "󰉿",
      Method = "󰆧",
      Function = "󰊕",
      Constructor = "",
      Field = "󰜢",
      Variable = "󰀫",
      Class = "󰠱",
      Interface = "",
      Module = "",
      Property = "󰜢",
      Unit = "󰑭",
      Value = "󰎠",
      Enum = "",
      Keyword = "󰌋",
      Snippet = "",
      Color = "󰏘",
      File = "󰈙",
      Reference = "󰈇",
      Folder = "󰉋",
      EnumMember = "",
      Constant = "󰏿",
      Struct = "󰙅",
      Event = "",
      Operator = "󰆕",
      TypeParameter = ""
    }
  },

  git = {
    add = "",
    change = "",
    delete = "",
    renamed = "",
    untracked = "",
    ignored = "",
    staged = "",
    conflict = ""
  },

  dap = {
    breakpoint = "",
    breakpoint_condition = "",
    breakpoint_rejected = "",
    stopped = "",
    log_point = ""
  },

  ui = {
    folder = "",
    folder_open = "",
    folder_empty = "",
    file = "",
    symlink = "",
    lock = "",
    package = "",
    search = "",
    close = "",
    check = "",
    prompt = "",
    modified = "●"
  }
}
```

### Override Pattern

**Same as colors: global + per-plugin overrides**

```lua
setup({
  -- Global icon overrides
  icons = {
    diagnostics = {
      error = "X",  -- Override just error icon
      warn = "!"
    },
    git = {
      add = "+"
    }
  },

  -- Per-plugin icon overrides
  overrides = {
    telescope = {
      icons = {
        folder = "F",  -- Telescope uses different folder icon
        file = "f"
      }
    }
  }
})
```

**Merging behavior:**
- Same as colors: deep merge
- User overrides only what they want to change
- Unspecified icons keep their defaults

### How Integrations Access Icons

**Via require (not passed as parameter):**

```lua
-- integrations/telescope.lua
return {
  name = "telescope",
  plugin_name = "telescope",

  setup = function(colors, config)
    local icons = require("ourplugin.icons")

    -- Use icons in highlight generation
    local folder_icon = icons.ui.folder

    return {
      -- ... highlights using icons if needed
    }
  end
}
```

**Why require:**
- Simpler function signature
- Icons always available when needed
- Consistent with other utilities
- Integrations only require what they need

### Icon Categories

**Defined categories (sufficient for initial version):**

1. **diagnostics** - Error, warn, info, hint icons
2. **lsp.kinds** - LSP completion item kinds (all 25 standard kinds)
3. **git** - Git status icons
4. **dap** - Debug adapter protocol icons
5. **ui** - General UI icons (folders, files, etc.)

**Future expansion:**
- Can add more categories as needed
- Can add subcategories within existing categories
- User can add custom categories via overrides

### Icon Loading & Override Application

**Flow:**

```
1. Load default icons from icons.lua
2. Apply global icon overrides from config.icons
3. When integration loads:
   - Integration requires icon module
   - Gets icons with global overrides already applied
   - Per-plugin overrides handled by config system (merged into config)
4. Integration uses icons as needed
```

**Note:** Per-plugin icon overrides could be passed via config or handled separately. Implementation detail to decide during development.

### Dependencies

**Nerd Fonts required:**
- All default icons use Nerd Fonts
- No unicode fallbacks for initial version
- Future: Could add fallback option

### Impact on Other Systems

**⚠️ Dependencies Created:**
- **Integrations (Topic #4):** Already designed to require icons
- **Configuration (Topic #2):** Already supports icon overrides
- **Extensibility (Topic #8):** Custom integrations can use icon system

**🔗 Cross-cutting Concerns:**
- Icons must be loaded before integrations run
- Override merging happens in config system
- No special utilities needed for icons (just data)

### Design Decisions Summary

✅ **Decided:**
- Centralized icon definitions in icons.lua
- Same override pattern as colors (global + per-plugin)
- Integrations access via require
- Five categories: diagnostics, lsp, git, dap, ui
- Nerd Fonts required (no fallbacks initially)
- Deep merge for overrides

🔧 **Implementation Notes:**
- Keep icon definitions organized by category
- Easy to add new categories
- No special processing needed
- Pure data structure

---

## Remaining Topics

### Topic #7: Command and API Surface
- User commands (`:Theme*` commands)
- Lua API for advanced users
- Integration API for plugin authors

### Topic #8: Extensibility System ✅

**Status:** Complete

### Core Concept

Users have two levels of control over plugin theming: indirect (via config/colors that affect integration generation) and direct (override specific highlight groups).

### Two Levels of Customization

**Level 1: Config-based (Indirect) - Already Covered**

Affect how integrations generate highlights:

```lua
overrides = {
  telescope = {
    borders = "single",           -- Integration uses this
    colors = { bg = "#custom" },  -- Integration uses this
    padding = { top = 2 }         -- Integration uses this
  }
}
```

These get passed to the integration, which generates highlights based on them.

**Level 2: Highlight Overrides (Direct) - NEW**

Override specific highlight groups directly:

```lua
overrides = {
  telescope = {
    -- Level 1: Config (affects generation)
    borders = "single",

    -- Level 2: Direct highlight overrides
    highlights = {
      TelescopeBorder = { fg = "#123456" },
      TelescopeTitle = { fg = "#abcdef", bold = true },
      -- Only override what you want different
    }
  }
}
```

### Precedence & Flow

```
1. Integration generates highlights
   └─> Uses colors, config (borders, padding, etc.)
   └─> Returns highlight groups table

2. User's highlight overrides merge on top
   └─> Only specified groups are overridden
   └─> Unspecified groups use integration's values

3. Final merged result applied to Neovim
   └─> vim.api.nvim_set_hl() for each group
```

**Example:**

```lua
-- Integration generates:
{
  TelescopeBorder = { fg = "#89b4fa", bg = "#1e1e2e" },
  TelescopeTitle = { fg = "#cdd6f4", bold = true },
  TelescopePrompt = { bg = "#313244" }
}

-- User overrides:
highlights = {
  TelescopeBorder = { fg = "#custom" }
}

-- Final result:
{
  TelescopeBorder = { fg = "#custom", bg = "#1e1e2e" },  -- fg overridden
  TelescopeTitle = { fg = "#cdd6f4", bold = true },      -- unchanged
  TelescopePrompt = { bg = "#313244" }                    -- unchanged
}
```

### Merge Behavior

**Deep merge for highlight properties:**

```lua
-- Integration:
TelescopeBorder = { fg = "#aaa", bg = "#111", bold = true }

// User override:
TelescopeBorder = { fg = "#custom" }

// Result:
TelescopeBorder = { fg = "#custom", bg = "#111", bold = true }
```

User only specifies what they want to change, rest is preserved.

### Why Two Levels?

**Level 1 (Config/Colors):**
- Semantic control ("use rounded borders")
- Consistent across similar elements
- Integration handles implementation details
- Easier for users (don't need to know highlight group names)

**Level 2 (Highlights):**
- Precise control over specific groups
- For advanced users who know what they want
- Escape hatch when Level 1 isn't enough
- No need to replace entire integration

### Adding Custom Integrations

**Not supported initially.**

Users who want integrations for unsupported plugins can:
1. Fork the project
2. Add integration file following our structure
3. Submit PR if they want to contribute back

**Why not initially:**
- Keeps system simpler
- Can add later if there's demand
- Fork approach works fine for advanced users
- Focus on solid core first

**Future consideration:**
Could add custom integration paths later:
```lua
setup({
  custom_integrations = {
    myplugin = function(colors, config)
      return { ... }
    end
  }
})
```

### Complete Override Example

**User wants to customize Telescope extensively:**

```lua
require('ourplugin').setup({
  colorscheme = { name = "catppuccin", variant = "mocha" },
  borders = "rounded",

  overrides = {
    telescope = {
      -- Level 1: Change how integration works
      borders = "none",  -- Override global setting
      colors = {
        bg = "#1a1a1a",  -- Custom background
      },

      -- Level 2: Fine-tune specific highlights
      highlights = {
        TelescopeBorder = { fg = "#ff0000" },           -- Exact control
        TelescopeSelection = { bg = "#2a2a2a", bold = true },
        TelescopeMatching = { fg = "#00ff00", italic = true }
      }
    }
  }
})
```

### Impact on Other Systems

**⚠️ Dependencies Created:**
- **Integration System (Topic #4):** Must support highlight merging
- **Configuration System (Topic #2):** Already supports nested overrides structure

**🔗 Cross-cutting Concerns:**
- Highlight merging happens after integration generates highlights
- Must preserve properties not specified in override
- Config merging (Level 1) happens before integration runs
- Highlight merging (Level 2) happens after integration runs

### Design Decisions Summary

✅ **Decided:**
- Two levels of customization: config/colors + direct highlights
- Highlight overrides via `highlights` key in per-plugin overrides
- Deep merge behavior (preserve unspecified properties)
- Not supporting custom integrations initially (fork if needed)
- Precedence: integration generates → user highlights merge → apply

🔧 **Implementation Notes:**
- Merge logic must be deep (preserve fg if only bg overridden, etc.)
- Highlight overrides are optional
- Most users will only use Level 1 (config/colors)
- Level 2 is escape hatch for advanced customization

---

## Topic #9: Plugin Lifecycle and Timing System

**Status:** Skipped - Will address during implementation

Too abstract to design without seeing how things actually work. Will figure out:
- Load order
- When highlights get applied
- Handling lazy-loaded plugins
- Integration with plugin configs

---

## Topic #10: Initial Plugin Support ✅

**Status:** Complete

### POC Plugin List

Starting with three plugins to prove the concept:

1. **telescope** - Fuzzy finder, complex UI with multiple sections
2. **nvim-notify** - Notification system, good test for borders/backgrounds
3. **mason** - LSP installer UI, context-aware padding example

**Why these three:**
- Different UI patterns (search, notifications, lists)
- Popular and widely used
- Good coverage of theming challenges
- Enough to validate the architecture

**Future plugins:**
- nvim-cmp (completion)
- lualine (statusline)
- nvim-tree/neo-tree (file explorer)
- DAP UI
- And more as needed

---

## Topic #11: Distribution Strategy ✅

**Status:** Complete

### Approach: Standard Neovim Plugin

**Distribution:**
- Standard Neovim plugin structure
- Developed locally first
- Published to GitHub later
- Installed via plugin managers (lazy.nvim, packer, etc.)

**Local Development:**
```lua
-- In lazy.nvim config
{
  dir = "~/path/to/nvimthemingproject",  -- Local path
  name = "themeplugin",  -- Will decide actual name
  config = function()
    require('themeplugin').setup({ ... })
  end
}
```

**Why this approach:**
- Standard pattern everyone knows
- Easy local development with lazy.nvim
- Simple to publish later
- No special tooling needed
- Works with all plugin managers

---

## Remaining Topics

### Topic #12: Project Name and Branding ✅

**Status:** Complete

### Project Name: **nvim-harmony**

**Rationale:**
- Captures the core concept: harmonizing UI appearance across plugins
- Easy to remember and pronounce
- Not too technical, approachable
- `.nvim` suffix follows convention

### Naming Conventions

**Module name:**
```lua
require('harmony').setup({ ... })
```

**Commands (if we add them):**
```vim
:Harmony          " Main command
:HarmonyReload    " Reload theme
:HarmonyInspect   " Inspect current colors/config
```

**GitHub repo:** `nvim-harmony`
**Lua module:** `harmony`
**Main namespace:** `harmony.*`

### File naming examples:
- `lua/harmony/init.lua` - Main entry point
- `lua/harmony/config.lua` - Configuration system
- `lua/harmony/colors.lua` - Color utilities
- `lua/harmony/integrations/telescope.lua` - Telescope integration

---

## Remaining Topics

### Topic #13: Directory Structure ✅

**Status:** Complete

### File Organization

```
nvim-harmony/
├── lua/
│   └── harmony/
│       ├── init.lua              # Main entry point, setup() function
│       ├── config.lua            # Config validation & merging
│       ├── colors.lua            # Color utilities (lighten, darken, HSL, etc.)
│       ├── icons.lua             # Centralized icon definitions
│       ├── extraction/
│       │   ├── init.lua          # Auto-extraction logic
│       │   └── manual/
│       │       ├── catppuccin.lua  # Manual extractor for catppuccin
│       │       ├── gruvbox.lua     # Manual extractor for gruvbox
│       │       └── ...             # More as needed
│       ├── integrations/
│       │   ├── telescope.lua     # Telescope integration
│       │   ├── notify.lua        # nvim-notify integration
│       │   ├── mason.lua         # Mason integration
│       │   └── ...               # More integrations
│       └── utils.lua             # Shared integration utilities
├── README.md                      # User documentation
├── LICENSE                        # License file
└── PLANNING.md                    # This planning document
```

### Module Responsibilities

**lua/harmony/init.lua**
- Main entry point
- `setup(config)` function
- Orchestrates the entire flow:
  1. Load and validate config
  2. Load colorscheme
  3. Extract colors
  4. Load icons
  5. Run integrations
  6. Apply highlights

**lua/harmony/config.lua**
- Config schema definition
- Validation logic
- Merging (defaults + user config + overrides)
- Config access functions

**lua/harmony/colors.lua**
- Color manipulation utilities
- hex_to_rgb, rgb_to_hsl, etc.
- lighten, darken, saturate, desaturate, mix
- contrast_ratio, is_light

**lua/harmony/icons.lua**
- Icon definitions by category
- diagnostics, lsp, git, dap, ui
- Returns icon table (data only)

**lua/harmony/extraction/init.lua**
- Auto-extraction logic
- extract_base_colors() - queries highlight groups
- generate_palette() - creates variants
- Checks for manual extractors first, falls back to auto

**lua/harmony/extraction/manual/*.lua**
- Per-colorscheme extractors
- Each returns palette table
- Direct access to colorscheme internals

**lua/harmony/integrations/*.lua**
- Per-plugin integration modules
- Each exports: name, plugin_name, setup(colors, config)
- Returns highlight groups table

**lua/harmony/utils.lua**
- Shared utilities for integrations
- compute_border_color, get_distinct_bg, etc.
- Optional helpers integrations can use

### Import Examples

```lua
-- User's init.lua
require('harmony').setup({ ... })

-- Within the plugin
local config = require('harmony.config')
local colors = require('harmony.colors')
local icons = require('harmony.icons')
local extraction = require('harmony.extraction')
local utils = require('harmony.utils')

-- Load specific integration
local telescope_integration = require('harmony.integrations.telescope')

-- Load manual extractor
local catppuccin_extractor = require('harmony.extraction.manual.catppuccin')
```

### Future Additions

**Optional future files:**
- `lua/harmony/commands.lua` - User commands (:Harmony*)
- `lua/harmony/cache.lua` - Caching extracted palettes
- `lua/harmony/api.lua` - Public API for advanced users
- `doc/harmony.txt` - Vim help documentation

---

## Remaining Topics

### Topic #7: Command and API Surface
- User commands (`:Harmony*` commands)
- Lua API for advanced users
- Integration API for plugin authors

**Status:** Skip for now - will add commands later if needed

### Topic #14: Comprehensive Architecture Documentation
**Status:** This document (PLANNING.md) serves as the architecture documentation

### Topic #15: API Documentation and Usage Examples
**Status:** To be created before/during implementation
- API documentation
- Usage examples

---

## Notes & Ideas

- Consider volt for future UI implementation: https://github.com/nvzone/volt
- Keep it simple initially - can always add complexity later
- Focus on making it easy for users to override anything
- Architecture decisions deferred until we discuss all aspects
