local Task = require 'inv.task.Task'

local WaitTask = Task:subclass()

function WaitTask:init(server, parent, item)
    WaitTask.superClass.init(self, server, parent)
    self.item = item
end

function WaitTask:run()
    if #self.server.invManager:tryMatchAll({self.item}) == 0 then
        return true
    end
    return false
end

return WaitTask
