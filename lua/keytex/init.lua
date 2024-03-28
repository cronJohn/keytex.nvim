local M = {}

local kb = require('keytex.keybindings')
local finder = require('keytex.finder')


function M.setup(config)
    kb.setup()
    finder.setup()
end

return M
