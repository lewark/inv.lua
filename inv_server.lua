local InvManager = require 'inv_manager'
local common = require 'inv_common'
local CraftManager = require 'craft_manager'

local function main()
    local config = common.loadJSON("server.json")
    local recipes = common.loadJSON("recipes/minecraft.json")

    --print(textutils.serialize(recipes))

    mgr = InvManager:new(config.overrides or {})
    cmgr = CraftManager:new(mgr, recipes)

    --print(cmgr:pullOrCraftItemsExt("minecraft:wooden_pickaxe",10,"turtle_1",1))

    --print(textutils.serialize(cmgr:scanItemsCraftable()))
    --print(textutils.serialize(mgr.itemDB))

    rednet.open(common.getModemSide())
    --rednet.host(common.PROTOCOL,os.getComputerLabel())
    while true do
        evt = {os.pullEventRaw()}
        --print(textutils.serialize(evt))
        if evt[1] == "rednet_message" then
            local msg = evt[3]
            if cmgr[msg[1]] then
                print("Calling CraftManager")
                rednet.send(evt[2],cmgr[msg[1]](cmgr,unpack(msg[2])),common.PROTOCOL)
            elseif mgr[msg[1]] then
                rednet.send(evt[2],mgr[msg[1]](mgr,unpack(msg[2])),common.PROTOCOL)
            else
                --print("Unknown command "..msg[1])
            end
        elseif evt[1] == "terminate" then
            return
        end
    end
    --rednet.unhost(common.PROTOCOL)
    rednet.close(common.getModemSide())
end

main()