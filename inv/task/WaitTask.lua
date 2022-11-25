local Task = require 'inv.task.Task'

local WaitTask = Task:subclass()

function WaitTask:init(server, parent, item)
    WaitTask.superClass.init(self, server, parent)
    self.item = item
end

function WaitTask:print()
    print("waiting on items")
    if self.item.name then
        print(self.item.name)
    elseif self.item.tags then
        for k,v in pairs(self.item.tags) do
            print(k)
        end
    end
end

function WaitTask:run()
    if #self.server.invManager:tryMatchAll({self.item}) == 0 then
        return true
    end
    --self:print()
    return false
end

return WaitTask
