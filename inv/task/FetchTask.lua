local Task = require 'inv.task.Task'

-- Fetches or crafts items from the network.
-- Currently unfinished and unused.
local FetchTask = Task:subclass()

function FetchTask:init(server, parent, criteria)
    FetchTask.superClass.init(self, server, parent)
    self.item = criteria
    self.moved = 0
    self.started = false
end

function FetchTask:run()
    -- TODO: add constructor parameters for dest, destSlot
    self.moved = self.moved + self.server.invManager:pushItemsTo(criteria,dest,destSlot)
    -- TODO: does criteria.count need to be updated based on self.moved?

    if self.moved < criteria.count then
        local recipe = self:findRecipe(criteria)
        if recipe then
            --local nOut = 0
            --for slot, item in pairs(recipe.output) do
            --    if criteria:matches(item) then
            --        nOut = item.count
            --        break
            --    end
            --end
            local toMake = criteria.count - n
            local crafts = math.ceil(toMake / nOut)
            for i=1,crafts do
                self.server.taskManager:addTask(CraftTask(self.server, self, recipe))
            end
        end
    end
    
    if self.moved >= self.criteria.count then
        return true
    end
    return false
end

return FetchTask
