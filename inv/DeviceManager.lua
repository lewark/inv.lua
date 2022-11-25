local Object = require 'object.Object'

local Common = require 'inv.Common'
local Storage = require 'inv.device.Storage'
local Workbench = require 'inv.device.Workbench'
local Machine = require 'inv.device.Machine'
local ClientDevice = require 'inv.device.ClientDevice'

local DeviceManager = Object:subclass()

function DeviceManager:init(server, overrides)
    self.server = server
    self.devices = {}

    self.typeOverrides = {}
    self.nameOverrides = {}

    for i,v in ipairs(overrides) do
        if v.type then
            self.typeOverrides[v.type] = v
        elseif v.name then
            self.nameOverrides[v.name] = v
        end
    end
end

function DeviceManager:scanDevices()
    for name,device in pairs(self.devices) do
        device:destroy()
    end
    self.devices = {}

    for i,name in ipairs(peripheral.getNames()) do
        self:addDevice(name)
    end
end

function DeviceManager:copyConfig(entries, dest)
    if entries then
        for k,v in pairs(entries) do
            dest[k] = v
        end
    end
end

function DeviceManager:getConfig(name, deviceType)
    local config = {}
    self:copyConfig(self.typeOverrides[deviceType], config)
    self:copyConfig(self.nameOverrides[name], config)
    return config
end

function DeviceManager:createDevice(name)
    --print("createDevice '"..name.."'")
    if name == Common.getNameLocal() then
        print("self add in createDevice")
        return nil
    end

    local types = { peripheral.getType(name) }
    local deviceType = nil
    local genericTypes = {}

    for k,v in pairs(types) do
        if v == "inventory" or v == "fluid_storage" or v == "energy_storage" then
            genericTypes[v] = true
        else
            deviceType = v
        end
    end

    --print("type",deviceType)

    if deviceType == "turtle" then
        return ClientDevice(self.server, name, deviceType)
    end
    
    if deviceType == "workbench" then
        return Workbench(self.server, name, deviceType)
    end

    local config = self:getConfig(name, deviceType)
    --print(config.purpose)

    if config.purpose == "crafting" then
        --print("crafting")
        return Machine(self.server, name, deviceType, config)
    elseif config.purpose == "storage" or genericTypes["inventory"] then
        return Storage(self.server, name, deviceType, config)
    end

    return nil
end

function DeviceManager:addDevice(name)
    --print("addDevice",name)
    if self.devices[name] then
        print("double add device " .. name)
        self.devices[name]:destroy()
    end
    self.devices[name] = self:createDevice(name)
end

function DeviceManager:removeDevice(name)
    --print("removeDevice",name)
    local device = self.devices[name]
    if device then
        self.devices[name] = nil
        device:destroy()
    else
        print("double remove device " .. name)
    end
end

return DeviceManager
