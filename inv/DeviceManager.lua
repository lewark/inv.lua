local Object = require 'object.Object'

local Common = require 'inv.Common'
local Storage = require 'inv.device.Storage'
local Workbench = require 'inv.device.Workbench'
local Machine = require 'inv.device.Machine'

local DeviceManager = Object:subclass()

function DeviceManager:init(server, overrides)
    self.server = server
    self.devices = {}

    self.typeOverrides = {}
    self.nameOverrides = {}

    for _,v in pairs(overrides) do
        if v.type then
            mgr.typeOverrides[v.type] = v
        elseif v.name then
            mgr.nameOverrides[v.name] = v
        end
    end
end

function DeviceManager:scanDevices()
    for name,device in pairs(self.devices) do
        device.destroy()
    end
    self.devices = {}

    self.devices[common.getNameLocal()] = Workbench(self.server)
    for i,name in ipairs(peripheral.getNames()) do
        self:createDevice(name)
    end
end

function DeviceManager:copyConfig(entries, dest)
    if entries then
        for k,v in pairs(entries) do
            dest[k] = v
        end
    end
end

function DeviceManager:getConfig(device)
    local config = {}
    self:copyConfig(self.typeOverrides[device.type], config)
    self:copyConfig(self.nameOverrides[device.name], config)
    return config
end

function DeviceManager:createDevice(name)
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

    if deviceType == "turtle" and name != common.getNameLocal() then
        return ClientDevice(self.server, name, deviceType)
    end

    local config = self:getConfig(name, deviceType)

    if config.purpose == "crafting" then
        return Machine(self.server, name, deviceType, config)
    elseif config.purpose == "storage" or genericTypes["inventory"] then
        return Storage(self.server, name, deviceType, config)
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
