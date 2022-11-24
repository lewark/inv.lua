local Object = require 'object.Object'

local Storage = require 'inv.device.Storage'
local Workbench = require 'inv.device.Workbench'
local Machine = requrie 'inv.device.Machine'

local DeviceManager = Object:subclass()

function DeviceManager:init(system)
    self.system = system
    self.devices = {}
end

function createDevice(name)
    local types = peripheral.getType(name)
    local deviceType = nil
    local genericTypes = {}
    for k,v in pairs(types) do
        if v == "inventory" or v == "fluid_storage" or v == "energy_storage" then
            genericTypes[v] = true
        else
            deviceType = v
        end
    end

    local config = self.system.getConfig(name, deviceType)
    if config.purpose == "crafting" then
        return Machine(self.system, name, deviceType)
    elseif config.purpose == "storage" or genericTypes["inventory"] then
        return Storage(self.system, name, deviceType)
    end
    return nil
end

function DeviceManager:addDevice(name)
    self.devices[name] = self:createDevice(name)
end

function DeviceManager:removeDevice(name)
    self.devices[name]:destroy()
    self.devices[name] = nil
end

return DeviceManager
