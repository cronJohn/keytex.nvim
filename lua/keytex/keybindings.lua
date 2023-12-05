local M = {
    global_keybindings = {}
}

function M.create_keybinding(mode, key, action, options, should_output)
    options = options or {
        -- Defaults
        override = false,
        noremap = true,
        silent = true
    }

    should_output = should_output or false

    local user_override = options.override
    -- Must remove override from options table before passing to nvim_set_keymap
    options.override = nil

    local info = debug.getinfo(2, 'Sl')

    local metadata = {
        mode = mode,
        key = key,
        action = action,
        source = info.source,
        line = info.currentline
    }

    local keymap = string.format('<%s-%s>', mode, key)
    local existing_mapping = vim.fn.maparg(keymap, mode)

    if user_override or existing_mapping == '' then
        vim.api.nvim_set_keymap(mode, key, action, options)
        if should_output then
            print(string.format('Keybinding %s created successfully!', keymap))
        end
    else
        if should_output then
            print(string.format('Keybinding %s already exists. Skipping...', keymap))
        end
        return
    end

    M.global_keybindings[keymap] = metadata
end

function M.print_keybindings()
    print('Current Keybindings:')
    for key, metadata in pairs(M.global_keybindings) do
        print(string.format(
            'Mode: %-2s | Key: %-15s | Action: %-25s | Source: %-30s | Line: %s',
            metadata.mode, key, metadata.action, metadata.source, metadata.line
        ))
    end
end

return M
