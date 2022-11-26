local Object = require 'object.Object'
local Common = require 'inv.Common'
local CraftManager = require 'inv.CraftManager'
local DeviceManager = require 'inv.DeviceManager'
local InvManager = require 'inv.InvManager'
local RPCMethods = require 'inv.RPCMethods'
local TaskManager = require 'inv.TaskManager'

local Server = Object:subclass()

function Server:init()
    local config = Common.loadJSON("server.json")

    self.clients = {}

    self.invManager = InvManager(self)
    self.deviceManager = DeviceManager(self, config.overrides)
    self.craftManager = CraftManager(self)
    self.taskManager = TaskManager(self)
    self.rpcMethods = RPCMethods
    self.taskTimer = nil

    self.craftManager:loadRecipes("recipes/minecraft.json")
    self.deviceManager:scanDevices()
end

function Server:send(clientID, message)
    rednet.send(clientID, message, Common.PROTOCOL)
end

function Server:onMessage(clientID, message)
    if self.rpcMethods[message[1]] then
        self.rpcMethods[message[1]](self, clientID, unpack(message[2]))
    end
end

function Server:mainLoop()
    rednet.open(Common.getModemSide())
    while true do
        local runTasks = true
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
            runTasks = false
        end
        if runTasks and self.taskManager:update() then
            self.taskTimer = os.startTimer(1)
            print(#self.taskManager.active)
            --for i,t in pairs(self.taskManager.sleeping) do
            --    print("sleeping",i)
            --end
            --print(math.random(1,100))
        end
        local updated = self.invManager:getUpdatedItems()
        if updated then
            local message = {"items", updated}
            for clientID, clientName in pairs(self.clients) do
                self:send(clientID, message)
            end
        end
    end
    rednet.close(Common.getModemSide())
end

return Server
