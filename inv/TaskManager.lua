local Object = require 'object.Object'

-- Asynchronously manages crafting tasks
local TaskManager = Object:subclass()

function TaskManager:init(server)
    self.server = server
    -- table<int, Task>: Tasks that are currently performing an operation,
    -- e.g. counting and storing output items from a crafting machine.
    self.active = {}
    -- table<int, Task>: Tasks that are waiting for another task to complete.
    -- Indexed by task ID.
    self.sleeping = {}
    -- The last ID assigned to a task.
    self.lastID = 0
end

-- Returns the next available task ID for creating a new task.
function TaskManager:nextID()
    self.lastID = self.lastID + 1
    return self.lastID
end

-- Updates all running tasks, sleeping parent tasks when they create sub-tasks
-- and resuming them when the sub-tasks complete.
function TaskManager:update()
    --print("calling update")
    local i = 1
    while i <= #self.active do
        local task = self.active[i]
        if task:run() then
            table.remove(self.active, i)
            local parent = task.parent
            task:destroy()
            if parent and parent.nSubTasks == 0 then
                self.sleeping[parent.id] = nil
                table.insert(self.active, parent)
            end
        elseif task.nSubTasks > 0 then
            table.remove(self.active, i)
            self.sleeping[task.id] = task
        else
            i = i + 1
        end
    end
    if #self.active > 0 then
        return true
    end
    return false
end

-- Adds a new task, and designates it as active.
function TaskManager:addTask(task)
    table.insert(self.active, task)
end

return TaskManager
