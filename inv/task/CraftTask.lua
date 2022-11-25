local Task = require 'inv.task.Task'
local WaitTask = require 'inv.task.WaitTask'

local CraftTask = Task:subclass()

function CraftTask:init(server, parent, recipe, dest, destSlot)
    CraftTask.superClass.init(self, server, parent)
    self.machine = nil
    self.recipe = recipe
    self.dest = dest
    self.destSlot = destSlot
end

function CraftTask:run()
    if not self.machine then
        local testInput = {}
        for slot, item in pairs(self.recipe.input) do
            table.insert(testInput, item)
        end
        local rem = self.server.invManager:tryMatchAll(testInput)
        if #rem > 0 then
            print("item dependencies required")
            for i, item in ipairs(rem) do
                local recipe = self.server.craftManager:findRecipe(item)
                if recipe then
                    self.server.taskManager:addTask(CraftTask(self.server, self, recipe))
                else
                    self.server.taskManager:addTask(WaitTask(self.server, self, item))
                end
            end
            return false
        end
        print(self.recipe.machine)
        self.machine = self.server.craftManager:findMachine(self.recipe.machine)
        if not self.machine then
            return false
        end
        print("crafting")
        self.machine:craft(self.recipe, self.dest, self.destSlot)
        print("craft finished")
    end
    print("pulling output")
    self.machine:pullOutput()
    print("pulling output finished")
    if not self.machine:busy() then
        return true
    end
    return false
end

return CraftTask
