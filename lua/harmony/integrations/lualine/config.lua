-- Config generator for lualine
-- Parses harmony's lualine config and generates complete lualine.setup() options

local visual_presets = require("harmony.integrations.lualine.presets")
local components = require("harmony.integrations.lualine.components")

local M = {}

-- Default component layout
local defaults = {
  left = { "mode", "file", "branch", "git" },
  middle = {},
  right = { "diagnostics", "lsp", "encoding", "position", "root_dir" },
}

-- Map component name to component definition
local function get_component(name)
  local component = components[name]
  if not component then
    vim.notify(
      string.format("Harmony: Unknown lualine component '%s'", name),
      vim.log.levels.WARN
    )
    return nil
  end
  return component
end

-- Parse section config into list of component names
local function parse_section(section_config, default_components)
  if not section_config then
    return default_components
  end

  -- If it's just a string preset, use defaults
  if type(section_config) == "string" then
    return default_components
  end

  -- If it has sections array, use that
  if section_config.sections then
    return section_config.sections
  end

  return default_components
end

-- Get visual preset for a section
local function get_section_preset(section_config, global_preset)
  -- Section-specific preset takes precedence
  if type(section_config) == "table" and section_config.preset then
    return section_config.preset
  end

  -- Global preset
  if global_preset then
    return global_preset
  end

  -- Default preset
  return "default"
end

-- Distribute components across lualine sections
-- For left side: section a gets first component, sections b,c get the rest
-- For right side: distribute across x,y,z (and repeat if needed for individual sections style)
local function distribute_components(component_names, side)
  local result = {}

  if #component_names == 0 then
    return result
  end

  if side == "left" then
    -- Section a: first component (usually mode)
    result.lualine_a = { get_component(component_names[1]) }

    -- Section b: second component if exists
    if component_names[2] then
      result.lualine_b = { get_component(component_names[2]) }
    else
      result.lualine_b = {}
    end

    -- Section c: remaining components
    result.lualine_c = {}
    if #component_names > 2 then
      for i = 3, #component_names do
        local component = get_component(component_names[i])
        if component then
          table.insert(result.lualine_c, component)
        end
      end
    end
  else -- right side
    -- For right side, try to give each component its own section for "individual sections" look
    -- But we only have 3 sections (x, y, z), so distribute intelligently

    if #component_names == 1 then
      result.lualine_z = { get_component(component_names[1]) }
    elseif #component_names == 2 then
      result.lualine_y = { get_component(component_names[1]) }
      result.lualine_z = { get_component(component_names[2]) }
    elseif #component_names == 3 then
      result.lualine_x = { get_component(component_names[1]) }
      result.lualine_y = { get_component(component_names[2]) }
      result.lualine_z = { get_component(component_names[3]) }
    else
      -- More than 3 components: distribute with multiple components per section
      local per_section = math.ceil(#component_names / 3)
      local idx = 1

      result.lualine_x = {}
      for i = 1, math.min(per_section, #component_names - idx + 1) do
        local component = get_component(component_names[idx])
        if component then
          table.insert(result.lualine_x, component)
        end
        idx = idx + 1
      end

      if idx <= #component_names then
        result.lualine_y = {}
        for i = 1, math.min(per_section, #component_names - idx + 1) do
          local component = get_component(component_names[idx])
          if component then
            table.insert(result.lualine_y, component)
          end
          idx = idx + 1
        end
      end

      if idx <= #component_names then
        result.lualine_z = {}
        for i = idx, #component_names do
          local component = get_component(component_names[i])
          if component then
            table.insert(result.lualine_z, component)
          end
        end
      end
    end
  end

  return result
end

-- Generate complete lualine options from harmony config
function M.generate(user_config)
  user_config = user_config or {}

  -- Determine global preset
  local global_preset = user_config.preset

  -- Parse sections
  local left_components = parse_section(user_config.left, defaults.left)
  local middle_components = parse_section(user_config.middle, defaults.middle)
  local right_components = parse_section(user_config.right, defaults.right)

  -- Get visual presets for each section
  local left_preset_name = get_section_preset(user_config.left, global_preset)
  local right_preset_name = get_section_preset(user_config.right, global_preset)

  local left_preset = visual_presets[left_preset_name] or visual_presets.default
  local right_preset = visual_presets[right_preset_name] or visual_presets.default

  -- Distribute components across lualine sections
  local left_sections = distribute_components(left_components, "left")
  local right_sections = distribute_components(right_components, "right")

  -- Build final options
  local options = {
    options = {
      theme = "auto", -- Will be set by integration
      component_separators = left_preset.component_separators,
      section_separators = left_preset.section_separators,
      globalstatus = true,
      refresh = {
        statusline = 1000,
      },
    },
    sections = vim.tbl_extend("force", left_sections, right_sections),
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
    extensions = {},
  }

  return options
end

return M
