local Object = require 'object.Object'
local Common = require 'inv.Common'
local CraftTask = require 'inv.task.CraftTask'
local Recipe = require 'inv.Recipe'

local expect = require "cc.expect"
local expect, field = expect.expect, expect.field

local CraftManager = Object:subclass()

function CraftManager:init(server)
    self.server = server
    self.recipes = {}
    self.localName = Common.getNameLocal()
    self.machines = {}
    self.tasks = {}
end

function CraftManager:addMachine(device)
    local machineTable = self.machines[device.type]
    if not machineTable then
        machineTable = {}
        self.machines[device.type] = machineTable
    end
    machineTable[device.name] = device
end

function CraftManager:removeMachine(device)
    self.machines[device.type][device.name] = nil
end

function CraftManager:loadRecipes(filename)
    data = Common.loadJSON(filename)
    for i, spec in ipairs(data) do
        local recipe = Recipe(spec)
        for slot, item in pairs(recipe.output) do
            assert(item.name) -- output should not be generic
            if not self.recipes[item.name] then
                self.recipes[item.name] = recipe
            end
            local info = self.server.invManager.items[item.name]
            if not info then
                info = self.server.invManager:addItem(item.name)
            end
            if not info.detailed and item.tags then
                for tag, v in pairs(item.tags) do
                    info.tags[tag] = v
                end
                self.server.invManager:updateTags(info.name)
            end
        end
    end
end

function CraftManager:findRecipe(item)
    local results = self.server.invManager:resolveCriteria(item)
    for name, v in results do
        local recipe = self.recipes[item.name]
        if recipe then
            return recipe
        end
    end
    return nil
end

function CraftManager:findMachine(machineType)
    local machinesOfType = self.machines[machineType]
    if machinesOfType then
        for name, machine in pairs(machinesOfType) do
            if not machine:busy() then
                return machine
            end
            print(name,"busy")
        end
    end
    print("no",machineType,"found")
    return nil
end

function CraftManager:pushOrCraftItemsTo(criteria,dest,destSlot)
    local n = self.server.invManager:pushItemsTo(criteria,dest,destSlot)

    if n < criteria.count then
        local recipe = self:findRecipe(criteria)
        if recipe then
            local nOut = 0
            for slot, item in pairs(recipe.output) do
                if criteria:matches(item) then
                    nOut = item.count
                    break
                end
            end

            local toMake = criteria.count - n
            local crafts = math.ceil(toMake / nOut)
            for i=1,crafts do
                self.server.taskManager:addTask(CraftTask(self.server, nil, recipe, dest, destSlot))
            end
        end
    end
    return n
end

return CraftManager
