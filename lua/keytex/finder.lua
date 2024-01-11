local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local M = {}

function M.keymap_picker(opts, filter)
    opts = opts or {}
    filter = filter or "key"

    pickers.new(opts, {
        prompt_title = "Keymappings",
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
