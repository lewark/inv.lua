local Object = require 'object.Object'

local Task = Object:subclass()

function Task:init()
    self.subTasks = {}
    self.parent = {}
end

return Task