local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local M = {}

---
-- Opens a Telescope window for searching and exploring keybindings.
--
-- @param filter string: The initial filtering method. It can be one of the following:
--   - `mode`: Filters by the mode the keybinding is in (e.g., *n*ormal, *v*isual, *i*nsert).
--   - `key`: Filters by the key combination.
--   - `action`: Filters by what the keybinding maps to.
--   - `description`: Filters by the description of the keybinding.
--   - `source`: Filters by the file where the keybinding is defined.
--   - `line`: Filters by the line number where the keybinding is located.
-- @param opts table: Optional table of configuration options for Telescope.

function M.keybinding_picker(filter, opts)
    filter = filter or "mode-*key-action-description"
    opts = opts or {}

    local formats = {}
    local ordinal_field = nil

    for _, format in ipairs(vim.fn.split(filter, '-')) do
        local buf = format
        if string.find(buf, "*", 1, true) then
            ordinal_field = buf:gsub("*", "")
            buf = buf:gsub("*", "")
        end

        table.insert(formats, buf)
    end

    pickers.new(opts, {
        prompt_title = "Keybindings",
        finder = finders.new_table{
            results = require('keytex.keybindings').global_keybindings,
            entry_maker = function(entry)
                local display_values = {}
                for _, format in ipairs(formats) do
                    table.insert(display_values, tostring(entry[format]))
                end

                return {
                    value = entry,
                    display = table.concat(display_values, " | "),
                    ordinal = ordinal_field and tostring(entry[ordinal_field]) or tostring(entry[formats[1]]),
                    path    = entry.source,
                    lnum    = entry.line,
                }
            end
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(bufnr)
            actions.select_default:replace(function()
                actions.close(bufnr)
                local selection = action_state.get_selected_entry()
                vim.cmd(string.format("edit +%s %s", selection.value.line, selection.value.source))
            end)
            return true
        end,
    }):find()
end


return M
