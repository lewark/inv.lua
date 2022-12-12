local Object = require 'object.Object'
local Item = require 'inv.Item'

local Recipe = Object:subclass()

function Recipe:init(spec)
    self.machine = spec.machine
    self.input = {}
    self.output = {}
    for slot, itemSpec in pairs(spec.input) do
        self.input[tonumber(slot)] = Item(itemSpec)
    end
    for slot, itemSpec in pairs(spec.output) do
        self.output[tonumber(slot)] = Item(itemSpec)
    end
end

return Recipe
