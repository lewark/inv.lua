local Object = require 'object.Object'
local Common = require 'inv.Common'

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

function CraftManager:addMachine(self, device)
    local machineTable = self.machines[device.type]
    if not machineTable then
        machineTable = {}
        self.machines[device.type] = machineTable
    end
    machineTable[device.name] = device
end

function CraftManager:removeMachine(self, device)
    self.machines[device.type][device.name] = nil
end

function CraftManager:loadRecipes(self, filename)
    data = Common.loadJSON(filename)
    for i, recipe in ipairs(data) do
        for slot, item in pairs(recipe.output) do
            if not self.recipes[item.name] then
                self.recipes[item.name] = recipe
            end
            if not self.invManager.items[item.name] then
                local info = self.invManager.addItem(item.name)
                if item.tags then
                    info.tags = item.tags
                end
            end
            for tag, v in pairs(item. tags) do
                if v and not self.tagRecipes[tag] then
                    self.tagRecipes[tag] = recipe
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
        end
    end
    return nil
end

function CraftManager:pullOrCraftItemsExt(name,count,dest,destSlot)
    --print("pullOrCraftItemsExt")
    local n = self.invMgr:pullItemsExt(name,count,dest,destSlot)
    --print(n)
    if n < count then
        local m = self:craftItemsExt(name,count-n,dest,destSlot)
        return m + n
    end

    return n
end


return CraftManager
