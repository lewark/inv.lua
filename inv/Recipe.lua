local Object = require 'object.Object'

local Recipe = Object:subclass()

function Recipe:init(spec)
    self.machine = spec.machine
    self.input = {}
    self.output = {}
    for slot, itemSpec in pairs(spec.input) do
        self.input[slot] = ItemCriteria(itemSpec)
    end
    for slot, itemSpec in pairs(spec.output) do
        self.output[slot] = ItemCriteria(itemSpec)
    end
end

return Recipe
