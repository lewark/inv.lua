local Object = require 'object.Object'

local TaskManager = Object:subclass()

function TaskManager:init(server)
    self.server = server
    self.active = {}
    self.sleeping = {}
    self.lastID = 0
end

function TaskManager:nextID()
    self.lastID = self.lastID + 1
    return self.lastID
end

function TaskManager:update()
    for i, task in
end

return TaskManager
