local Object = require 'object.Object'

local Recipe = Object:subclass()

function Recipe:init()
    self.input = {}
    self.output = {}
    self.machine = ""
end

return Recipe
