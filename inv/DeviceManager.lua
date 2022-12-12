local Object = require 'object.Object'

local Common = require 'inv.Common'
local Storage = require 'inv.device.Storage'
local Workbench = require 'inv.device.Workbench'
local Machine = require 'inv.device.Machine'
local ClientDevice = require 'inv.device.ClientDevice'

-- Manages network-attached devices, including storage and crafting machines.
-- Specialized behavior is delegated by Devices to the appropriate class
-- (either InvManager or CraftManager).
local DeviceManager = Object:subclass()

function DeviceManager:init(server, overrides)
    self.server = server
    -- table<string, Device>: Devices connected to this network.
    self.devices = {}

    -- table<string, table>: Configuration applied to specific device types.
    self.typeOverrides = {}
    -- table<string, table>: Configuration applied to individual devices by name.
    self.nameOverrides = {}

    for i,v in ipairs(overrides) do
        if v.type then
            self.typeOverrides[v.type] = v
        elseif v.name then
            self.nameOverrides[v.name] = v
        end
    end
end

-- Scans and adds all devices connected to the network.
-- Clears any existing loaded devices beforehand.
function DeviceManager:scanDevices()
    for name,device in pairs(self.devices) do
        device:destroy()
    end
    self.devices = {}

    for i,name in ipairs(peripheral.getNames()) do
        self:addDevice(name)
    end
end

-- Copies configuration entries to the given table.
-- Preexisting entries of the same name are overwritten.
function DeviceManager:copyConfig(entries, dest)
    if entries then
        for k,v in pairs(entries) do
            dest[k] = v
        end
    end
end

-- Gets all configuration for the given device name and type.
-- Device type settings are overridden by name-specific settings.
function DeviceManager:getConfig(name, deviceType)
    local config = {}
    self:copyConfig(self.typeOverrides[deviceType], config)
    self:copyConfig(self.nameOverrides[name], config)
    return config
end

-- Creates the appropriate Device for the given network peripheral
-- as specified in the server configuration.
function DeviceManager:createDevice(name)
    assert(name ~= Common.getNameLocal())

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

    if deviceType == "turtle" then
        return ClientDevice(self.server, name, deviceType)
    elseif deviceType == "workbench" then
        return Workbench(self.server, name, deviceType)
    end

    local config = self:getConfig(name, deviceType)

    if config.purpose == "crafting" then
        return Machine(self.server, name, deviceType, config)
    elseif config.purpose == "storage" or genericTypes["inventory"] then
        return Storage(self.server, name, deviceType, config)
    end

    return nil
end

-- Creates the appropriate Device for the given network peripheral,
-- then adds it to the device table.
function DeviceManager:addDevice(name)
    if self.devices[name] then
        print("double add device " .. name)
        self.devices[name]:destroy()
    end
    self.devices[name] = self:createDevice(name)
end

-- Removes a device from the device table, clearing any associated state.
function DeviceManager:removeDevice(name)
    local device = self.devices[name]
    if device then
        self.devices[name] = nil
        device:destroy()
    else
        print("double remove device " .. name)
    end
end

return DeviceManager
