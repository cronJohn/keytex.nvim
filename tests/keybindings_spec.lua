local keybindings = require('keytex.keybindings')

local function keybinding_exists(mode, key)
    local keymap = vim.api.nvim_get_keymap(mode)
    for _, mapping in ipairs(keymap) do
        if mapping.lhs == key then
            return true
        end
    end
    return false
end

describe('Test keybind creation', function()
    it('should create and print keybindings', function()
        local key_a = 'a'
        local key_b = 'b'
        local key_c = 'c'

        keybindings.create_keybinding('n', key_a, ':echo "a key pressed"<CR>')
        keybindings.create_keybinding('n', key_b, ':echo "b key pressed"<CR>')
        keybindings.create_keybinding('v', key_c, 'c', false)

        assert(keybinding_exists('n', key_a), 'Keybinding "' .. key_a .. '" not created successfully')
        assert(keybinding_exists('n', key_b), 'Keybinding "' .. key_b .. '" not created successfully')
        assert(keybinding_exists('v', key_c), 'Keybinding "' .. key_c .. '" not created successfully')
    end)

    it('should create keybindings with and without override', function()
        local key_d = 'd'

        keybindings.create_keybinding('n', key_d, ':echo "d key pressed"<CR>', { override = false })
        keybindings.create_keybinding('n', key_d, ':echo "d key overridden"<CR>', { override = true })

        assert(keybinding_exists('n', key_d), 'Keybinding "' .. key_d .. '" not overridden successfully')
    end)
end)
