local Object = require 'object.Object'
local Common = require 'inv.Common'

-- Represents an asynchronous operation performed by the network.
local Task = Object:subclass()

function Task:init(server, parent)
    self.server = server
    -- Task: Optional. The parent Task of which this Task is a sub-task.
    self.parent = parent
    -- table<int, Task>: Sub-tasks of this Task. The task will be suspended
    -- until these sub-tasks complete. Indexed by task ID.
    self.subTasks = {}
    -- The number of current sub-tasks.
    self.nSubTasks = 0
    -- This task's unique identifier.
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
