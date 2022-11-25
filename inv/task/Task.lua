local Object = require 'object.Object'
local Common = require 'inv.Common'

local Task = Object:subclass()

function Task:init(server, parent)
    self.server = server
    self.subTasks = {}
    self.nSubTasks = 0
    self.parent = parent
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
    if task.parent then
        task.parent.subTasks[task.id] = nil
        task.parent.nSubTasks = task.parent.nSubTasks - 1
    end
end

return Task
