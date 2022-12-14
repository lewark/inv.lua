local Object = require 'object.Object'
local CraftTask = require 'inv.task.CraftTask'
local Recipe = require 'inv.Recipe'

local expect = require "cc.expect"
local expect, field = expect.expect, expect.field

-- Manages crafting machines, recipes, and queuing of crafting tasks.
local CraftManager = Object:subclass()

function CraftManager:init(server)
    self.server = server
    -- table<string, Recipe>: Recipes known to this network, indexed by item ID.
    self.recipes = {}
    -- table<string, table<string, Machine>>: Crafting machines connected to
    -- this network, indexed by machine type and device name.
    self.machines = {}
end

-- Adds a crafting machine to the network, updating network state as necessary.
function CraftManager:addMachine(device)
    local machineTable = self.machines[device.type]
    if not machineTable then
        machineTable = {}
        self.machines[device.type] = machineTable
    end
    machineTable[device.name] = device
end

-- Removes a crafting machine from the network, updating network state as necessary.
function CraftManager:removeMachine(device)
    self.machines[device.type][device.name] = nil
end

-- Loads recipes from the given data.
-- Data should consist of an array of tables, with each table
-- in the format required by the Recipe class.
function CraftManager:loadRecipes(data)
    for i, spec in ipairs(data) do
        local recipe = Recipe(spec)
        for slot, item in pairs(recipe.output) do
            assert(item.name) -- output should not be generic
            if not self.recipes[item.name] then
                self.recipes[item.name] = recipe
                print("added recipe",item.name)
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

-- Finds a recipe to produce the given item,
-- returning nil if none is found.
function CraftManager:findRecipe(item)
    local results = self.server.invManager:resolveCriteria(item)
    for name, v in pairs(results) do
        local recipe = self.recipes[name]
        if recipe then
            print("recipe found",name)
            return recipe
        end
    end
    return nil
end

-- Finds a non-busy crafting machine of the given type,
-- returning nil if none is found.
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

-- First attempts to pull the requested amount of items out of the network,
-- then attempts to craft any remaining requested items.
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
