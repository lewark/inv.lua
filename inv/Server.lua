local Object = require 'object.Object'
local Common = require 'inv.Common'
local CraftManager = require 'inv.CraftManager'
local DeviceManager = require 'inv.DeviceManager'
local InvManager = require 'inv.InvManager'
local RPCManager = require 'inv.RPCManager'
local TaskManager = require 'inv.TaskManager'

local Server = Object:subclass()

function Server:init()
    local config = Common.loadJSON("server.json")

    self.invManager = InvManager(self)
    self.deviceManager = DeviceManager(self, config.overrides)
    self.craftManager = CraftManager(self)
    self.taskManager = TaskManager(self)
    self.rpcManager = RPCManager
    self.taskTimer = nil

    self.craftManager:loadRecipes("recipes/minecraft.json")
    self.deviceManager:scanDevices()
end

function Server:send(clientID, message)
    rednet.send(clientID, message, Common.PROTOCOL)
end

function Server:onMessage(clientID, message)
    if self.rpcManager[message[1]] then
        self.rpcManager[message[1]](self, clientID, unpack(message[2]))
    end
end

function Server:mainLoop()
    rednet.open(Common.getModemSide())
    while true do
        evt = {os.pullEventRaw()}
        if evt[1] == "rednet_message" then
            self:onMessage(evt[2], evt[3])
        elseif evt[1] == "peripheral" then
            self.deviceManager:addDevice(evt[2])
        elseif evt[1] == "peripheral_detach" then
            self.deviceManager:removeDevice(evt[2])
        elseif evt[1] == "terminate" then
            break
        elseif evt[1] == "timer" and evt[2] ~= self.taskTimer then
            continue
        end
        if self.taskManager:update() then
            self.taskTimer = os.startTimer(1)
        end
        print(#self.taskManager.active)
        for i,t in pairs(self.taskManager.sleeping) do
            print("sleeping",i)
        end
    end
    rednet.close(Common.getModemSide())
end

return Server
