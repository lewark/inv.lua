local Object = require 'object.Object'
local ItemCriteria = require 'inv.ItemCriteria'

local Recipe = Object:subclass()

function Recipe:init(spec)
    self.machine = spec.machine
    self.input = {}
    self.output = {}
    for slot, itemSpec in pairs(spec.input) do
        self.input[tonumber(slot)] = ItemCriteria(itemSpec)
    end
    for slot, itemSpec in pairs(spec.output) do
        self.output[tonumber(slot)] = ItemCriteria(itemSpec)
    end
end

return Recipe
