require 'inv_manager'
require 'inv_common'

mgr = InvManager:new()

rednet.open(getModemSide())
--rednet.host(PROTOCOL,os.getComputerLabel())
while true do
    evt = {os.pullEventRaw()}
    if evt[1] == "rednet_message" then
        local msg = evt[3]
        if mgr[msg[1]] then
            rednet.send(evt[2],mgr[msg[1]](mgr,unpack(msg[2])),PROTOCOL)
        end
    elseif evt[1] == "terminate" then
        return
    end
end
--rednet.unhost(PROTOCOL)
rednet.close(getModemSide())