local M = {
    global_keybindings = {}
}

function M.setup()
    vim.api.nvim_create_user_command("Printkb", M.print_keybindings, {})
    vim.api.nvim_create_user_command("Inputkb",
        function()
            local mode = vim.fn.input("Mode: ")
            local key = vim.fn.input("Key: ")
            local action = vim.fn.input("Action: ")

            local success, options = pcall(function()
                return vim.fn.json_decode(vim.fn.input("Options (JSON format): "))
            end)

            if not success then
                options = {}
            end

            local should_output = false
            if vim.fn.input("Should Output: "):lower() == 'true' then
                should_output = true
                print("\n")
            end

            M.create_keybinding(mode, key, action, options, should_output)

        end,
        {}
    )

end

-- @param mode string|table: Mode short-name or a list of modes.
-- @param key string: The key combination for the keybinding.
-- @param action string|function: The action to be triggered by the keybinding.
-- @param options table|nil: Optional table of |:map-arguments|.
-- @param should_output boolean|nil: Optional flag to control whether to log keybind creation
function M.create_keybinding(mode, key, action, options, should_output)
    options = options or {
        -- Defaults
        unique = true,
    }

    should_output = should_output or false

    local info = debug.getinfo(2, 'Sl')
    local keymap = string.format('<%s-%s>', mode, key)

    local metadata = {
        mode = mode,
        key = key,
        action = action,
        source = info.source,
        line = info.currentline
    }

    local is_set, error = pcall(function()
        vim.keymap.set(mode, key, action, options)
    end)

    local output = ''

    if is_set then
        output = string.format('Keybinding %s created successfully!', keymap)
    else
        output = tostring(error)
    end

    if should_output then
        print(output)
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

function M.check_mapping_existence(modes, key)
    local all_modes = type(modes) == 'table' and modes or {modes} -- Convert modes to a single item table if it's a string

    for _, mode in ipairs(all_modes) do
        if vim.fn.maparg(string.format('<%s-%s>', mode, key), mode) ~= '' then
            return true
        end
    end

    return false
end


return M
