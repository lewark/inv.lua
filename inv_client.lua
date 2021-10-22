require 'inv_common'
local gui = require 'gui'

--print(textutils.serialize(serverCall(0,"pullOrCraftItemsExt",{"minecraft:stick",10,"turtle_1",1})))

local config_path = shell.dir().."/client.json"

local file = io.open(config_path,"r")
local data = file:read("*all")
local config = textutils.unserialiseJSON(data)
file:close()

local ClientUI = gui.Root:subclass()

function ClientUI:init(serverID)
    ClientUI.superClass.init(self)
    
    self.serverID = serverID
    self.localName = getNameLocal()
    self.sidebarWidth = math.floor(self.size[1] / 3)
    
    self.vbox = gui.LinearContainer:new(self,2,1,1)
    self.hbox = gui.LinearContainer:new(self,1,0,0)
    self.lbl = gui.Label:new(self,"Hello!")
    self.lbl.length = self.sidebarWidth
    self.lbl2 = gui.Label:new(self,"Hello!")
    self.lbl2.length = self.sidebarWidth
    self.field = gui.TextField:new(self,4,"1")
    self.btn1 = gui.Button:new(self,"Request")
    self.list = gui.ListBox:new(self,10,10,{})
    self.sb = gui.ScrollBar:new(self,self.list)
    
    self.items = {}

    self.list.onSelectionChanged = function(list)
        if self.list.selected >= 1 and self.list.selected <= #self.items then
            self.lbl.text = self.items[self.list.selected].displayName
            self.lbl2.text = "Count: "..self.items[self.list.selected].count
            self.btn1.enabled = true
        else
            self.lbl.text = "[Nothing selected]"
            self.lbl2.text = "Count: 0"
            self.btn1.enabled = false
        end
        self:onLayout()
    end
    
    self.btn1.onPressed = function(btn)
        if self.list.selected >= 1 and self.list.selected <= #self.items then
            local item = self.items[self.list.selected]
            local count = tonumber(self.field.text)
            self:serverCall("pullOrCraftItemsExt",{item.name,count,self.localName,nil})
            self:fetchItems()
            self.list:onSelectionChanged()
        end
    end

    --btn3.color = colors.cyan
    --btn3.pushedColor = colors.green
    -- function btn1:onPressed()
        -- shell.run("worm")
    -- end
    -- function btn2:onPressed()
        -- btn1.enabled = true
        -- btn1.dirty = true
    --end

    self:addChild(self.hbox)
    self.hbox:addChild(self.list,true,true,gui.LinearAlign.START)
    self.hbox:addChild(self.sb,false,true,gui.LinearAlign.START)
    self.hbox:addChild(self.vbox,false,true,gui.LinearAlign.START)
    self.vbox:addChild(self.lbl,false,true,gui.LinearAlign.START)
    self.vbox:addChild(self.lbl2,false,true,gui.LinearAlign.START)
    self.vbox:addChild(self.field,false,true,gui.LinearAlign.START)
    self.vbox:addChild(self.btn1,false,true,gui.LinearAlign.START)
    
    self:fetchItems()
end

function ClientUI:serverCall(func, args)
    rednet.send(self.serverID, {func, args})
    while true do
        -- TODO: Properly utilize coroutines
        id, message = rednet.receive(PROTOCOL)
        if id == self.serverID then
            return message
        end
    end
end

function ClientUI:fetchItems()
    print("started fetch")
    local itemsByName = self:serverCall("scanItemsCraftable",{})
    self.items = {}
    self.list.items = {}
    for k,v in pairs(itemsByName) do
        table.insert(self.items,v)
    end
    -- TODO: Do based on name or displayName?
    table.sort(self.items, function(a, b) return a.name:lower() < b.name:lower() end)
    for k,v in pairs(self.items) do
        table.insert(self.list.items,v.displayName.." (x"..v.count..")")
    end
    print("finished fetch")
    self:onLayout()
end

rednet.open(getModemSide())
local root = ClientUI:new(config.serverID)
root:mainLoop()
rednet.close(getModemSide())