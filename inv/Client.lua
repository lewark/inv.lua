local Common = require 'inv.Common'
local ClientUI = require 'inv.ClientUI'
local Object = require 'object.Object'

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

function Client:fetchItems()
    self:serverCall("listItems",{})
end

function Client:depositSlot(slot)
    local detail = turtle.getItemDetail(slot, true)
    if detail and detail.count > 0 then
        self:serverCall("storeItem",{self.localName,detail,slot})
    end
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
    self:serverCall("register",{})
    self:fetchItems()
    self.ui:mainLoop()
    self:serverCall("unregister",{})
    rednet.close(Common.getModemSide())
end

function Client:onMessage(evt, fromID, msg, protocol)
    print(msg)
    if fromID == self.serverID then
        if msg[1] == "items" then
            for k, v in pairs(msg[2]) do
                self.items[k] = v
                print(k)
            end
            self.ui:updateList()
        end
    end
end

return Client
