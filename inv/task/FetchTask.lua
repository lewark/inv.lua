local Task = require 'inv.task.Task'

local FetchTask = Task:subclass()

function FetchTask:init(server, parent, criteria)
    FetchTask.superClass.init(self, server, parent)
    self.item = criteria
end

return FetchTask
