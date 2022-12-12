local Object = require 'object.Object'
local Common = require 'inv.Common'

-- Represents an asynchronous operation performed by the network.
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

-- Continues the operation being performed by this task.
-- Returns true if the operation is complete.
function Task:run()
    return true
end

-- Destroys the task, cleaning up associated state.
function Task:destroy()
    if self.parent then
        self.parent.subTasks[self.id] = nil
        self.parent.nSubTasks = self.parent.nSubTasks - 1
    end
end

return Task
