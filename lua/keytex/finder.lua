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
    filter = filter or "key"
    opts = opts or {}

    pickers.new(opts, {
        prompt_title = "Keybindings",
        finder = finders.new_table{
            results = require('keytex.keybindings').global_keybindings,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = string.format(
                        'Mode: %-2s | Key: %-10s | Action: %-10s | Desc: %-10s | Source: %-20s | Line: %s',
                        vim.inspect(entry.mode), entry.key, entry.action, entry.description, entry.source, entry.line
                    ),
                    ordinal = tostring(entry[filter]),
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
