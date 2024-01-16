local keybindings = require('keytex.keybindings')
local check_exists = require('keytex.keybindings').check_mapping_existence


describe('Test keybind creation', function()
    it('should create keybindings', function()
        local key_1 = 'key1'
        local key_2 = 'key2'
        local key_3 = 'key3'
        local key_3_mode_table = { 'v' }
        local key_4 = 'key4'
        local key_4_mode_table = { 'n', 'i', 'x', 'o' }

        keybindings.create_keybinding('n', key_1, ':echo "key 1"')
        keybindings.create_keybinding('n', key_2, ':echo "key 2"')
        keybindings.create_keybinding(key_3_mode_table, key_3, ':echo "key 3"', {})
        keybindings.create_keybinding(key_4_mode_table, key_4, ':echo "key 4"', {})

        assert(check_exists('n', key_1), 'Keybinding "' .. key_1 .. '" not created successfully')
        assert(check_exists('n', key_2), 'Keybinding "' .. key_2 .. '" not created successfully')
        assert(check_exists(key_3_mode_table, key_3), 'Keybinding "' .. key_3 .. '" not created successfully')
        assert(check_exists(key_4_mode_table, key_4), 'Keybinding "' .. key_4 .. '" not created successfully')
    end)

    it("shouldn't create keybindings with unique", function()
        local key_5 = 'key5'

        keybindings.create_keybinding('n', key_5, ':echo "e key pressed"<CR>', {unique = true})

        -- Must be deferred otherwise there's a race condition when testing async
        vim.defer_fn(function()
            local is_created, _ = pcall(function()
                keybindings.create_keybinding('n', key_5, ':echo "key e override"<CR>', {unique = true})
            end)

            -- Check if new keybindings exist
            assert(not is_created, 'Keybinding was overridden')
        end, 0)

    end)
end)
