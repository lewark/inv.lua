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
    self.tagRecipes = {}
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
            if item.name then
                if not self.recipes[item.name] then
                    self.recipes[item.name] = recipe
                end
                if not self.server.invManager.items[item.name] then
                    local info = self.server.invManager:addItem(item.name)
                    if item.tag then
                        info.tags[item.tag] = true
                    end
                end
            end
            -- TODO: limited to one tag?
            if item.tag then
                if not self.tagRecipes[item.tag] then
                    self.tagRecipes[item.tag] = recipe
                end
            end
        end
    end
end

function CraftManager:itemMatches(item,criteria)
    expect(1, item, "table")
    expect(2, criteria, "table")
    if criteria.name then
        return criteria.name == item.name
    elseif criteria.tag then
        --print(textutils.serialize(self.invMgr.itemDB))
        return (self.invMgr.items[item.name] and self.invMgr.items[item.name].tags[criteria.tag])
    end
    return false
end

function CraftManager:findRecipe(item)
    if item.name then
        local recipe = self.recipes[item.name]
        if recipe then
            return recipe
        end
    end
    if item.tag then
        local recipe = self.tagRecipes[tag]
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
    else
        print("no",machineType,"found")
    end
    return nil
end

function CraftManager:pushOrCraftItemsTo(criteria,dest,destSlot)
    --print("pullOrCraftItemsExt")
    local n = self.server.invManager:pushItemsTo(criteria,dest,destSlot)

    --print(n)
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
                self.server.taskManager:addTask(CraftTask(self.server, nil, recipe))
            end
        end
    end
    print("push finished")
    return n
end

return CraftManager
