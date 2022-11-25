local Task = require 'inv.task.Task'

local FetchTask = Task:subclass()

function FetchTask:init(server, parent, item)
    FetchTask.superClass.init(self, server, parent)
    self.item = item
end

function FetchTask:run()

end

return FetchTask
