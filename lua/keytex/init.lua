local M = {}

local kb = require('keytex.keybindings')
local finder = require('keytex.finder')


--config = {
--    save_file: <string>,
--
--}
function M.setup(config)
    if not config then
        config = {
            save_file = os.getenv("HOME") .. "/.config/nvim/gen-kb.lua",
        }
    end

    kb.setup(config)
    finder.setup()
end

return M
