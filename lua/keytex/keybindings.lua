local M = {
    global_keybindings = {},
    error_log          = {},
    save_file          = ""

}
local function log_error(err_msg)
    table.insert(M.error_log, err_msg)
end

---
-- Sets up user commands for managing keybindings.
-- - Creates the "Printkb" command to print a list of global keybindings.
-- - Creates the "PrintkbErr" command to print all errors related to `create_keybinding`
-- - Creates the "Inputkb" command to interactively input and create a new keybinding.
--
-- The "Inputkb" command prompts the user for the mode, key, action, options (in JSON format),
-- and whether the keybinding creation status should be output.
--
-- Usage:
-- ```
-- :Printkb          " Prints a list of global keybindings
-- :PrintkbErr       " Prints a list of keybinding creation errors
-- :Inputkb          " Prompts the user for keybinding details and creates a new keybinding
-- ```
function M.setup(config)
    M.save_file = config.save_file

    vim.api.nvim_create_user_command("Printkb", M.print_keybindings, {})
    vim.api.nvim_create_user_command("PrintkbErr", M.print_error_log, {})
    vim.api.nvim_create_user_command("Inputkb",
    function()
            local mode = vim.fn.input("Mode: ")
            local key = vim.fn.input("Key: ")
            local action = vim.fn.input("Action: ")

            local function parse_input(input)
                local success, result = pcall(function() return loadstring("return " .. input)() end)
                if not success then
                    log_error(result)
                end
                return success and type(result) == "table" and result or nil
            end

            local vks_opt = parse_input(vim.fn.input("VKS options (Lua table format): ")) or {}
            local usr_opt = parse_input(vim.fn.input("User options (Lua table format): "))

            M.create_keybinding(mode, key, action, vks_opt, usr_opt)

            -- usr_opt.save is meant solely for this user command
            if usr_opt ~= nil and usr_opt.save then
                M.save_to_file(string.format("vim.keymap.set('%s', '%s', %s, %s)\n", mode, key, action, vim.inspect(vks_opt)))
            end

        end, {})
    end


---
-- Creates a keybinding using the specified mode, key, and action.
--
-- @param mode string|table: Mode short-name or a list of modes.
-- @param key string: The key combination for the keybinding.
-- @param action string|function: The action to be triggered by the keybinding.
-- @param vks_opt table: Options specific to vim.keymap.set (|:map-arguments|).
-- @param usr_opt table: Optional table to control function behavior.
--   - `mark` (boolean): If true, add the keybinding to the global list without attempting to create it (default: false).
--   - `output` (boolean): If true, print keybinding creation status to the console (default: false).
function M.create_keybinding(mode, key, action, vks_opt, usr_opt)
    vks_opt = vim.tbl_extend('keep', vks_opt or {}, {
        -- Defaults
        desc = "No description",
        silent = true,
        unique = true,
    })
    usr_opt = vim.tbl_extend('keep', usr_opt or {}, {
        -- Defaults
        mark = false,
        output = false,
    })

    local info = debug.getinfo(2, 'Sl')
    local keybinding = string.format("<%s-%s> -> %s | %s", mode, key, action, vks_opt.desc)

    local metadata = {
        mode = vim.inspect(mode),
        key = key,
        action = action,
        description = vks_opt.desc,
        fqn = keybinding,
        source = info.source:sub(2),
        line = info.currentline
    }

    if usr_opt.mark then
        table.insert(M.global_keybindings, metadata)
        return
    end

    local is_set, error = pcall(function()
        vim.keymap.set(mode, key, action, vks_opt)
    end)

    local output = error and string.format('\nError setting keymap:\n %s', error) or string.format('\nSuccessfully created:\n %s', keybinding)

    if not is_set then
        log_error(error)
    else
        table.insert(M.global_keybindings, metadata)
    end

    if usr_opt.output then
        print(output)
    end
end


---
-- Prints the current global keybindings.
--
-- If there are no keybindings, it prints a message indicating that no keybindings were found.
--
function M.print_keybindings()
    if #M.global_keybindings == 0 then
        print('No keybindings found.')
        return
    end

    print('Current Keybindings:')
    for _, metadata in ipairs(M.global_keybindings) do
        print(string.format(
            'Mode: %-2s | Key: %-15s | Action: %-25s | Desc: %-25s | Source: %-30s | Line: %s',
            vim.inspect(metadata.mode), metadata.key, metadata.action, metadata.description, metadata.source, metadata.line
        ))
    end
end


---
-- Prints the entries in the error log, if any.
-- The error log contains information about failed `create_keybinding` attempts.
function M.print_error_log()
    if #M.error_log == 0 then
        print('No errors logged.')
        return
    end

    print('Error Log:')

    for _, error_entry in ipairs(M.error_log) do
        print(error_entry)
    end
end


---
-- Checks if a keybinding exists for the specified mode and key combination.
--
-- @param modes string|table: Mode short-name or a list of modes.
-- @param key string: The key combination to check for.
-- @return boolean: True if the keybinding exists in any of the specified modes, false otherwise.
function M.check_mapping_existence(modes, key)
    local all_modes = type(modes) == 'table' and modes or {modes} -- Convert modes to a single item table if it's a string

    for _, mode in ipairs(all_modes) do
        local keybinding = vim.api.nvim_get_keymap(mode)

        for _, mapping in ipairs(keybinding) do
            if mapping.lhs == key then
                return true
            end
        end
    end

    return false
end

function M.save_to_file(text_to_write)
    local err_msg
    local success, file = pcall(io.open, M.save_file, "a")

    if success and file ~= nil then
        success, err_msg = pcall(file.write, file, text_to_write)

        if not success then
            log_error(err_msg)
        end

        success, err_msg = pcall(file.close, file)

        if not success then
            log_error(err_msg)
        end
    else
        log_error("Can't open file: " .. file)
    end

end

return M
