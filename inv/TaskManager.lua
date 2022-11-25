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
    local i = 1
    while i <= #self.active do
        local task = self.active[i]
        if task.run() then
            table.remove(self.active, i)
            if task.parent then
                task.parent.subTasks[task.id] = nil
                task.parent.nSubTasks = task.parent.nSubTasks - 1
                if task.parent.nSubTasks == 0 then
                    self.sleeping[task.parent.id] = nil
                    table.insert(self.tasks, task.parent)
                end
            end
        elseif task.nSubTasks > 0 then
            table.remove(self.active, i)
            self.sleeping[task.id] = task
        else
            i = i + 1
        end
    end
end

function TaskManager:addTask(task)
    table.insert(self.active, task)
end

function TaskManager:addSubtask(task, parent)
    parent.subTasks[task.id] = task
    parent.nSubTasks = parent.nSubTasks + 1
    self:addTask(task)
end

return TaskManager
