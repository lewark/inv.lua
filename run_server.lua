local Server = require 'inv.Server'

function run()
    local s = Server()
    s:mainLoop()
end

run()

--local ok, res = xpcall(run, debug.traceback)
--textutils.pagedPrint(res)