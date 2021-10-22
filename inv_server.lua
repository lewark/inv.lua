require 'inv_manager'
require 'inv_common'
require 'craft_manager'

local config_path = shell.dir().."/server.json"
local file = io.open(config_path,"r")
local data = file:read("*all")
local config = textutils.unserialiseJSON(data)
file:close()

file = io.open(shell.dir().."/recipes/minecraft.json","r")
data = file:read("*all")
--print(data)
local recipes = textutils.unserialiseJSON(data)
file:close()

--print(textutils.serialize(recipes))

mgr = InvManager:new(config.overrides or {})
cmgr = CraftManager:new(mgr, recipes)

--print(cmgr:pullOrCraftItemsExt("minecraft:wooden_pickaxe",10,"turtle_1",1))

--print(textutils.serialize(cmgr:scanItemsCraftable()))
--print(textutils.serialize(mgr.itemDB))

rednet.open(getModemSide())
--rednet.host(PROTOCOL,os.getComputerLabel())
while true do
    evt = {os.pullEventRaw()}
    --print(textutils.serialize(evt))
    if evt[1] == "rednet_message" then
        local msg = evt[3]
        if cmgr[msg[1]] then
            print("Calling CraftManager")
            rednet.send(evt[2],cmgr[msg[1]](cmgr,unpack(msg[2])),PROTOCOL)
        elseif mgr[msg[1]] then
            rednet.send(evt[2],mgr[msg[1]](mgr,unpack(msg[2])),PROTOCOL)
        else
            --print("Unknown command "..msg[1])
        end
    elseif evt[1] == "terminate" then
        return
    end
end
--rednet.unhost(PROTOCOL)
rednet.close(getModemSide())