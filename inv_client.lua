local Common = require 'inv_common'

local Button = require 'gui.Button'
local Constants = require 'gui.Constants'
local LinearContainer = require 'gui.LinearContainer'
local ListBox = require 'gui.ListBox'
local Root = require 'gui.Root'
local ScrollBar = require 'gui.ScrollBar'
local TextField = require 'gui.TextField'

--print(textutils.serialize(serverCall(0,"pullOrCraftItemsExt",{"minecraft:stick",10,"turtle_1",1})))

local config_path = "client.json"

local ClientUI = Root:subclass()

function ClientUI:init(serverID)
    ClientUI.superClass.init(self)
    
    self.serverID = serverID
    if turtle then
        self.localName = Common.getNameLocal()
    end
    self.sidebarWidth = math.floor(self.size[1] / 3)
    self.items = {}
    self.modPressed = false
    
    self.vbox = LinearContainer(self,2,1,1)
    self.hbox = LinearContainer(self,1,0,0)
    
    self.list = ListBox(self,10,10,{})
    self.sb = ScrollBar(self,self.list)

    self.btnRefresh = Button(self,"Refresh")
    self.lbl = Label(self,"[Nothing]")
    self.lbl.length = self.sidebarWidth
    self.lbl2 = Label(self,"Count: 0")
    self.lbl2.length = self.sidebarWidth

    self:addChild(self.hbox)
    
    self.hbox:addChild(self.list,true,true,Constants.LinearAlign.START)
    self.hbox:addChild(self.sb,false,true,Constants.LinearAlign.START)
    self.hbox:addChild(self.vbox,false,true,Constants.LinearAlign.START)
    
    self.vbox:addChild(self.btnRefresh,false,true,Constants.LinearAlign.START)
    self.vbox:addChild(self.lbl,false,true,Constants.LinearAlign.START)
    self.vbox:addChild(self.lbl2,false,true,Constants.LinearAlign.START)
    
    if turtle then
        self.spinBox = LinearContainer(self,1,1,0)
        self.btnBox = LinearContainer(self,1,1,0)
        
        self.field = TextField(self,4,"1")
        self.btnReq = Button(self,"Request")
    
        self.btnPrevSlot = Button(self,"")
        self.btnNextSlot = Button(self,"")
        self.btnStore = Button(self,"")
        self.btnPlus = Button(self,"+")
        self.btnMinus = Button(self,"-")
        
        self:setModifier(false)
        
        self.btnBox:addChild(self.btnPrevSlot,false,false,Constants.LinearAlign.START)
        self.btnBox:addChild(self.btnStore,true,false,Constants.LinearAlign.START)
        self.btnBox:addChild(self.btnNextSlot,false,false,Constants.LinearAlign.START)
        
        self.spinBox:addChild(self.btnMinus,false,false,Constants.LinearAlign.START)
        self.spinBox:addChild(self.field,true,false,Constants.LinearAlign.START)
        self.spinBox:addChild(self.btnPlus,false,false,Constants.LinearAlign.START)
        
        self.vbox:addChild(self.spinBox,false,true,Constants.LinearAlign.START)
        self.vbox:addChild(self.btnReq,false,true,Constants.LinearAlign.START)
        self.vbox:addChild(self.btnBox,false,true,Constants.LinearAlign.START)
    end
    
    function self.list.onSelectionChanged(list)
        if self.list.selected >= 1 and self.list.selected <= #self.items then
            self.lbl.text = self.items[self.list.selected].displayName
            self.lbl2.text = "Count: "..self.items[self.list.selected].count
            if turtle then
                self.btnReq.enabled = true
            end
        else
            self.lbl.text = "[Nothing]"
            self.lbl2.text = "Count: 0"
            if turtle then
                self.btnReq.enabled = false
            end
        end
        self:onLayout()
    end
    
    function self.btnRefresh.onPressed(btn)
        self:fetchItems()
        self.list:onSelectionChanged()
    end
    
    if turtle then
        function self.btnReq.onPressed(btn)
            if self.list.selected >= 1 and self.list.selected <= #self.items then
                local item = self.items[self.list.selected]
                local count = tonumber(self.field.text) or 0
                self:serverCall("pullOrCraftItemsExt",{item.name,count,self.localName,nil})
                self:fetchItems()
                self.list:onSelectionChanged()
            end
        end
    
        function self.btnStore.onPressed(btn)
            if self.modPressed then
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
            local n = (self.modPressed and 4) or 1
            self:moveSelection(-n)
        end
        
        function self.btnNextSlot.onPressed(btn)
            local n = (self.modPressed and 4) or 1
            self:moveSelection(n)
        end
        
        function self.btnPlus.onPressed(btn)
            local n = tonumber(self.field.text) or 0
            local mod = (self.modPressed and 64) or 1
            self.field.text = tostring(math.max(n+mod,0))
            self.field.dirty = true
        end
        
        function self.btnMinus.onPressed(btn)
            local n = tonumber(self.field.text) or 0
            local mod = (self.modPressed and 64) or 1
            self.field.text = tostring(math.max(n-mod,0))
            self.field.dirty = true
        end
    end
    
    self:fetchItems()
end

function ClientUI:setModifier(mod)
    self.modPressed = mod
    if turtle then
        if mod then
            self.btnStore.text = "S.All"
            self.btnPrevSlot.text = string.char(gui.SpecialChars.TRI_UP)
            self.btnNextSlot.text = string.char(gui.SpecialChars.TRI_DOWN)
        else
            self.btnStore.text = "Store"
            self.btnPrevSlot.text = string.char(gui.SpecialChars.TRI_LEFT)
            self.btnNextSlot.text = string.char(gui.SpecialChars.TRI_RIGHT)
        end
        self.btnStore.dirty = true
        self.btnPrevSlot.dirty = true
        self.btnNextSlot.dirty = true
    end
end

function ClientUI:onKeyDown(key,held)
    if (key == keys.leftShift or key == keys.leftCtrl) and not held then
        self:setModifier(true)
    end
end

function ClientUI:onKeyUp(key)
    if (key == keys.leftShift or key == keys.leftCtrl) then
        self:setModifier(false)
    end
end

function ClientUI:serverCall(func, args)
    rednet.send(self.serverID, {func, args})
    while true do
        -- TODO: Properly utilize coroutines
        id, message = rednet.receive(Common.PROTOCOL)
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

local function main()
    local config = Common.loadJSON(config_path)
    rednet.open(Common.getModemSide())
    local root = ClientUI(config.serverID)
    root:mainLoop()
    rednet.close(Common.getModemSide())
end

main()