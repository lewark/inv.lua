local Object = require 'object.Object'
local Common = require 'inv.Common'

local Task = Object:subclass()

function Task:init(server, parent)
    self.server = server
    self.subTasks = {}
    self.parent = parent
    self.id = server.taskManager.nextID()
end

function Task:run()
    return true
end

return Task
