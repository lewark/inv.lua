local Object = require 'object.Object'
local InvManager = require 'inv.InvManager'
local Common = require 'inv.Common'
local CraftManager = require 'inv.CraftManager'

local Server = Object:subclass()

function Server:init()
    local config = Common.loadJSON("server.json")
    --local recipes = Common.loadJSON("recipes/minecraft.json")

    self.deviceManager = DeviceManager(self, config.overrides)
    self.invManager = InvManager(self)
    --self.craftManager = CraftManager(self)

    self.deviceManager:scanDevices()
    self.invManager:scanInventories()
end

function Server:mainLoop()

    --print(textutils.serialize(recipes))

    --print(cmgr:pullOrCraftItemsExt("minecraft:wooden_pickaxe",10,"turtle_1",1))

    --print(textutils.serialize(cmgr:scanItemsCraftable()))
    --print(textutils.serialize(mgr.itemDB))

    rednet.open(Common.getModemSide())
    --rednet.host(Common.PROTOCOL,os.getComputerLabel())
    while true do
        evt = {os.pullEventRaw()}
        --print(textutils.serialize(evt))
        if evt[1] == "rednet_message" then
            local msg = evt[3]
            if cmgr[msg[1]] then
                print("Calling CraftManager")
                rednet.send(evt[2],cmgr[msg[1]](cmgr,unpack(msg[2])),Common.PROTOCOL)
            elseif mgr[msg[1]] then
                rednet.send(evt[2],mgr[msg[1]](mgr,unpack(msg[2])),Common.PROTOCOL)
            else
                --print("Unknown command "..msg[1])
            end
        elseif evt[1] == "peripheral" then
            self.deviceManager:addDevice(evt[2])
            self.invManager:scanItems()
        elseif evt[1] == "peripheral_detach" then
            self.deviceManager:removeDevice(evt[2])
            self.invManager:scanItems()
        elseif evt[1] == "terminate" then
            return
        end
    end
    --rednet.unhost(Common.PROTOCOL)
    rednet.close(Common.getModemSide())
end

return Server
