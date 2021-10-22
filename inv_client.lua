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
    self.items = {}
    self.shiftPressed = false
    
    self.vbox = gui.LinearContainer:new(self,2,1,1)
    self.hbox = gui.LinearContainer:new(self,1,0,0)
    self.btnBox = gui.LinearContainer:new(self,1,1,0)
    self.spinBox = gui.LinearContainer:new(self,1,1,0)
    
    self.lbl = gui.Label:new(self,"[Nothing]")
    self.lbl.length = self.sidebarWidth
    self.lbl2 = gui.Label:new(self,"Count: 0")
    self.lbl2.length = self.sidebarWidth
    self.field = gui.TextField:new(self,4,"1")
    self.btnReq = gui.Button:new(self,"Request")
    self.list = gui.ListBox:new(self,10,10,{})
    self.sb = gui.ScrollBar:new(self,self.list)
    
    self.btnPrevSlot = gui.Button:new(self,string.char(gui.SpecialChars.TRI_LEFT))
    self.btnNextSlot = gui.Button:new(self,string.char(gui.SpecialChars.TRI_RIGHT))
    self.btnStore = gui.Button:new(self,"Store")
    self.btnRefresh = gui.Button:new(self,"Refresh")
    self.btnPlus = gui.Button:new(self,"+")
    self.btnMinus = gui.Button:new(self,"-")

    self:addChild(self.hbox)
    
    self.hbox:addChild(self.list,true,true,gui.LinearAlign.START)
    self.hbox:addChild(self.sb,false,true,gui.LinearAlign.START)
    self.hbox:addChild(self.vbox,false,true,gui.LinearAlign.START)
    
    self.vbox:addChild(self.btnRefresh,false,true,gui.LinearAlign.START)
    self.vbox:addChild(self.lbl,false,true,gui.LinearAlign.START)
    self.vbox:addChild(self.lbl2,false,true,gui.LinearAlign.START)
    self.vbox:addChild(self.spinBox,false,true,gui.LinearAlign.START)
    self.vbox:addChild(self.btnReq,false,true,gui.LinearAlign.START)
    self.vbox:addChild(self.btnBox,false,true,gui.LinearAlign.START)
    
    self.btnBox:addChild(self.btnPrevSlot,false,false,gui.LinearAlign.START)
    self.btnBox:addChild(self.btnStore,true,false,gui.LinearAlign.START)
    self.btnBox:addChild(self.btnNextSlot,false,false,gui.LinearAlign.START)
    
    self.spinBox:addChild(self.btnMinus,false,false,gui.LinearAlign.START)
    self.spinBox:addChild(self.field,true,false,gui.LinearAlign.START)
    self.spinBox:addChild(self.btnPlus,false,false,gui.LinearAlign.START)
    
    function self.list.onSelectionChanged(list)
        if self.list.selected >= 1 and self.list.selected <= #self.items then
            self.lbl.text = self.items[self.list.selected].displayName
            self.lbl2.text = "Count: "..self.items[self.list.selected].count
            self.btnReq.enabled = true
        else
            self.lbl.text = "[Nothing]"
            self.lbl2.text = "Count: 0"
            self.btnReq.enabled = false
        end
        self:onLayout()
    end
    
    function self.btnReq.onPressed(btn)
        if self.list.selected >= 1 and self.list.selected <= #self.items then
            local item = self.items[self.list.selected]
            local count = tonumber(self.field.text) or 0
            self:serverCall("pullOrCraftItemsExt",{item.name,count,self.localName,nil})
            self:fetchItems()
            self.list:onSelectionChanged()
        end
    end

    function self.btnRefresh.onPressed(btn)
        self:fetchItems()
        self.list:onSelectionChanged()
    end
    
    function self.btnStore.onPressed(btn)
        if self.shiftPressed then
            for i=1,16 do
                self:depositSlot(i)
            end
        else
            self:depositSlot(turtle.getSelectedSlot())
        end
        self:fetchItems()
        self.list:onSelectionChanged()
    end
    
    function self.btnPrevSlot.onPressed(btn)
        local n = (self.shiftPressed and 4) or 1
        self:moveSelection(-n)
    end
    
    function self.btnNextSlot.onPressed(btn)
        local n = (self.shiftPressed and 4) or 1
        self:moveSelection(n)
    end
    
    function self.btnPlus.onPressed(btn)
        local n = tonumber(self.field.text) or 0
        local mod = (self.shiftPressed and 64) or 1
        self.field.text = tostring(math.max(n+mod,0))
        self.field.dirty = true
    end
    
    function self.btnMinus.onPressed(btn)
        local n = tonumber(self.field.text) or 0
        local mod = (self.shiftPressed and 64) or 1
        self.field.text = tostring(math.max(n-mod,0))
        self.field.dirty = true
    end
    
    self:fetchItems()
end

function ClientUI:onKeyDown(key,held)
    if key == keys.leftShift and not held then
        self.shiftPressed = true
        self.btnStore.text = "S.All"
        self.btnStore.dirty = true
        self.btnPrevSlot.text = string.char(gui.SpecialChars.TRI_UP)
        self.btnNextSlot.text = string.char(gui.SpecialChars.TRI_DOWN)
        self.btnPrevSlot.dirty = true
        self.btnNextSlot.dirty = true
    end
end

function ClientUI:onKeyUp(key)
    if key == keys.leftShift then
        self.shiftPressed = false
        self.btnStore.text = "Store"
        self.btnStore.dirty = true
        self.btnPrevSlot.text = string.char(gui.SpecialChars.TRI_LEFT)
        self.btnNextSlot.text = string.char(gui.SpecialChars.TRI_RIGHT)
        self.btnPrevSlot.dirty = true
        self.btnNextSlot.dirty = true
    end
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
    --print("started fetch")
    local itemsByName = self:serverCall("scanItemsCraftable",{})
    self.items = {}
    self.list.items = {}
    for k,v in pairs(itemsByName) do
        table.insert(self.items,v)
    end
    -- TODO: Do based on name or displayName?
    table.sort(self.items, function(a, b) return a.displayName:lower() < b.displayName:lower() end)
    for k,v in pairs(self.items) do
        table.insert(self.list.items,v.displayName.." (x"..v.count..")")
    end
    --print("finished fetch")
    self:onLayout()
end

function ClientUI:depositSlot(slot)
    local count = turtle.getItemCount(slot)
    if count > 0 then
        self:serverCall("pushItemsExt",{count,self.localName,slot})
    end
end

function ClientUI:moveSelection(n)
    local slot = turtle.getSelectedSlot()
    slot = math.min(math.max(slot+n,1),16)
    turtle.select(slot)
end

rednet.open(getModemSide())
local root = ClientUI:new(config.serverID)
root:mainLoop()
rednet.close(getModemSide())