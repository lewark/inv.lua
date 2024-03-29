local Task = require 'inv.task.Task'

-- Waits for a missing item that has no known recipe.
local WaitTask = Task:subclass()

function WaitTask:init(server, parent, item)
    WaitTask.superClass.init(self, server, parent)
    -- The Item this task is waiting for.
    self.item = item
end

function WaitTask:print()
    write("waiting on items")
    if self.item.name then
        write(" " .. self.item.name)
    elseif self.item.tags then
        for k,v in pairs(self.item.tags) do
            write(" " .. k)
        end
    end
    print()
end

function WaitTask:run()
    if #self.server.invManager:tryMatchAll({self.item}) == 0 then
        return true
    end
    self:print()
    return false
end

return WaitTask
