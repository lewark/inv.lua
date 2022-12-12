local Common = require 'inv.Common'
local ClientUI = require 'inv.ClientUI'
local Object = require 'object.Object'
local Item = require 'inv.Item'

local Client = Object:subclass()

function Client:init(serverID)
    self.ui = ClientUI(self)

    self.serverID = serverID
    if turtle then
        self.localName = Common.getNameLocal()
    end

    self.items = {}
end

function Client:serverCall(func, args)
    rednet.send(self.serverID, {func, args}, Common.PROTOCOL)
end

function Client:fetchItems(refresh)
    self:serverCall("listItems",{refresh})
end

function Client:depositSlots(startSlot, endSlot)
    if not endSlot then
        endSlot = startSlot
    end
    local items = {}
    local nSlots = 0
    for slot=startSlot,endSlot do
        if turtle.getItemCount(slot) > 0 then
            local info = turtle.getItemDetail(slot, false)
            items[slot] = info
            local entry = self.items[info.name]
            if not entry or not entry.detailed then
                --[[if not entry then
                    entry = Item(info)
                    entry.count = 0
                    self.items[info.name] = entry
                end]]
                local detail = turtle.getItemDetail(slot, true)
                --entry:setDetails(detail)
                items[slot] = detail
            end
            nSlots = nSlots + 1
        end
    end
    if nSlots > 0 then
        self:serverCall("storeItems",{self.localName,items})
    end
end

function Client:depositAll()
    self:depositSlots(1,16)
end

function Client:requestItem(item, count)
    self:serverCall("requestItem",{self.localName,item.name,count})
end

function Client:moveSelection(n)
    local slot = turtle.getSelectedSlot()
    slot = math.min(math.max(slot+n,1),16)
    turtle.select(slot)
end

function Client:mainLoop()
    --local config = Common.loadJSON(config_path)
    rednet.open(Common.getModemSide())
    self:fetchItems()
    self.ui:mainLoop()
    self:serverCall("unregister",{})
    rednet.close(Common.getModemSide())
end

function Client:onMessage(evt, fromID, msg, protocol)
    if fromID == self.serverID then
        if msg[1] == "items" then
            for k, v in pairs(msg[2]) do
                self.items[k] = Item(v)
            end
            self.ui:updateList()
        end
    end
end

return Client
