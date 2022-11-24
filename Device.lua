local Object = require 'object.Object'

local Device = Object:subclass()

function Device:init(system, name)
    self.system = system
    self.name = name
    self.interface = nil
    self.types = {}
    self.type = ""
    self.config = {}
    if self.name then
        self.interface = peripheral.wrap(self.name)
        self.types = peripheral.getType(self.name)
        self.type = ""
        for k,v in pairs(self.types) do
            -- TODO: is this redundant
            if v ~= "inventory" and v ~= "fluid_storage" and v ~= "energy_storage" then
                self.type = v
            end
        end
        self.config = self.system.getConfig(self.name, self.type)
    end
end

return Device