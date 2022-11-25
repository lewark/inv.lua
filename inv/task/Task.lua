local Object = require 'object.Object'
local Common = require 'inv.Common'

local Task = Object:subclass()

function Task:init(server, parent)
    self.server = server
    self.parent = parent
    self.subTasks = {}
    self.nSubTasks = 0
    self.id = server.taskManager:nextID()
    
    if self.parent then
        self.parent.subTasks[self.id] = self
        self.parent.nSubTasks = self.parent.nSubTasks + 1
    end
end

function Task:run()
    return true
end

function Task:destroy()
    if self.parent then
        self.parent.subTasks[self.id] = nil
        self.parent.nSubTasks = self.parent.nSubTasks - 1
    end
end

return Task
