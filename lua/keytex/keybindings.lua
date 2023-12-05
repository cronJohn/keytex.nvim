local M = {}

local global_keybindings = {}

function M.create_keybinding(mode, key, action, override)
    local keymap = string.format('<%s-%s>', mode, key)
    local existing_mapping = vim.fn.maparg(keymap, mode)

    local metadata = {
        mode = mode,
        key = key,
        action = action,
        source = vim.fn.expand('%'),
        line = vim.fn.line('.')
    }

    if existing_mapping ~= '' and not override then
        print(string.format('Keybinding %s already exists. Skipping...', keymap))
        return
    end

    if override and existing_mapping ~= '' then
        vim.api.nvim_set_keymap(mode, key, action, { noremap = true, silent = true })
        print(string.format('Keybinding %s overridden successfully!', keymap))
    else
        vim.api.nvim_set_keymap(mode, key, action, { noremap = true, silent = true })
        print(string.format('Keybinding %s created successfully!', keymap))
    end

    -- Store the keybinding and metadata globally for future reference
    global_keybindings[keymap] = metadata
end

function M.print_keybindings()
    print('Current Keybindings:')
    for key, metadata in pairs(global_keybindings) do
        print(string.format('%s: %s -> %s (Set from: %s, Line: %s)', metadata.mode, key, metadata.action, metadata.source, metadata.line))
    end
end

return M
