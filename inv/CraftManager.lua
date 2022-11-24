local Object = require 'object.Object'
local Common = require 'inv.Common'

local expect = require "cc.expect"
local expect, field = expect.expect, expect.field

local CraftManager = Object:subclass()

function CraftManager:init(server,recipes)
    self.server = server
    self.recipes = recipes
    self.localName = Common.getNameLocal()
    self.tasks = {}
end

function CraftManager:itemMatches(item,criteria)
    expect(1, item, "table")
    expect(2, criteria, "table")
    if criteria.name then
        return criteria.name == item.name
    elseif criteria.tag then
        --print(textutils.serialize(self.invMgr.itemDB))
        return (self.invMgr.itemDB[item.name] and self.invMgr.itemDB[item.name].tags[criteria.tag])
    end
    return false
end

function CraftManager:findRecipeSequence(item,items)
    -- if item.name then
        -- print("findRecipeSequence name "..item.name)
    -- else
        -- print("findRecipeSequence tag "..item.tag)
    -- end
    for k,recipe in pairs(self.recipes) do
        if self:itemMatches(recipe,item) then
            local combo = {}
            local items2 = Common.deepCopy(items)
            --print(textutils.serialize(items2))
            local recipe_valid = true
            for slot,ingredient in pairs(recipe.ingredients) do
                local found = false
                for i,stock in pairs(items2) do
                    --print(i.." "..textutils.serialize(stock))
                    if self:itemMatches(stock,ingredient) and stock.count >= 1 then
                        stock.count = stock.count - 1
                        found = true
                        break
                    end
                end
                if not found then
                    local subrecipe, items3 = self:findRecipeSequence(ingredient,items2)
                    if subrecipe then
                        for _,v in pairs(subrecipe) do
                            table.insert(combo,v)
                        end
                        items2 = items3
                        for i,stock in pairs(items2) do
                            --print(i.." "..textutils.serialize(stock))
                            if self:itemMatches(stock,ingredient) and stock.count >= 1 then
                                stock.count = stock.count - 1
                                --print("deducted stock post"..stock.name)
                                break
                            end
                        end
                    else
                        recipe_valid = false
                        break
                    end
                end
                if not recipe_valid then break end
            end
            if recipe_valid then
                if items2[recipe.name] then
                    items2[recipe.name].count = items2[recipe.name].count + (recipe.count or 1)
                else
                    items2[recipe.name] = {name=recipe.name, count=recipe.count}
                end
                table.insert(combo,recipe)
                return combo, items2
            end
        end
    end
    -- if item.name then
        -- print("nothing found for name "..item.name)
    -- else
        -- print("nothing found for tag "..item.tag)
    -- end--]]
    return nil, nil
end

function CraftManager:tryCraftRecipe(recipe)
    --print("tryCraftRecipe")
    local success = true
    for slot,item in pairs(recipe.ingredients) do
        slot = tonumber(slot)
        -- TODO: maybe split up this line
        local destSlot = (slot - 1) % 3 + (math.floor((slot - 1) / 3) * 4) + 1
        local n = 0
        if item.name then
            n = self.invMgr:pullItemsExt(item.name,1,self.localName,destSlot)
        elseif item.tag then
            n = self.invMgr:pullItemsByTag(item.tag,1,self.localName,destSlot)
        end
        if n == 0 then
            --print("unable to pull"..textutils.serialize(item))
            success = false
            break
        end
    end
    if success then
        turtle.craft()
        local i = turtle.getSelectedSlot()
        local n = turtle.getItemCount()
        self.invMgr:pushItemsExt(n,self.localName,i)
        --print("success"..n)
        return n
    end
    for i=1,16 do
        local n = turtle.getItemCount(i)
        if n > 0 then
            self.invMgr:pushItemsExt(n,self.localName,i)
        end
    end
    print("failure")
    return 0
end

function CraftManager:craftItemsExt(name,count,dest,destSlot)
    --print("craftItemsExt")
    local crafted = 0
    while crafted < count do
        --print("thinking")
        local items = self.invMgr:scanItems()
        --print(textutils.serialize(items))
        local sequence, items2 = self:findRecipeSequence({name=name},items)
        if sequence then
            local craft_error = false
            local n = 0
            
            for i,recipe in pairs(sequence) do
                print(i..". x"..(recipe.count or 1).." "..recipe.name)
            end
            for i,recipe in pairs(sequence) do
                print(i..". running")
                n = self:tryCraftRecipe(recipe)
                print(n.." "..(recipe.count or 1))
                if n ~= (recipe.count or 1) then
                    craft_error = true
                    break
                end
            end
            if craft_error then
                --print("Craft Error")
                break
            else
                crafted = crafted + n
                --print("crafted "..crafted.." of "..count)
                self.invMgr:pullItemsExt(name,n,dest,destSlot)
            end
        else
            --print("No sequence found")
            break
        end
    end
    return crafted
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

function CraftManager:scanItemsCraftable()
    local items = self.invMgr.items
    for k,recipe in pairs(self.recipes) do
        if not items[recipe.name] then
            self.invMgr:addItem(recipe.name)
        end
    end
    return items
end

return CraftManager
