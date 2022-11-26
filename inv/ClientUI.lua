local Common = require 'inv.Common'

local Button = require 'gui.Button'
local Constants = require 'gui.Constants'
local Label = require 'gui.Label'
local LinearContainer = require 'gui.LinearContainer'
local ListBox = require 'gui.ListBox'
local Root = require 'gui.Root'
local ScrollBar = require 'gui.ScrollBar'
local TextField = require 'gui.TextField'

--print(textutils.serialize(serverCall(0,"pullOrCraftItemsExt",{"minecraft:stick",10,"turtle_1",1})))

local config_path = "client.json"

local ClientUI = Root:subclass()

function ClientUI:init(client)
    ClientUI.superClass.init(self)
    
    self.client = client
    
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
        self.client:fetchItems()
    end
    
    if turtle then
        function self.btnReq.onPressed(btn)
            self:requestItem()
        end
    
        function self.btnStore.onPressed(btn)
            if self.modPressed then
                for i=1,16 do
                    self.client:depositSlot(i)
                end
            else
                self.client:depositSlot(turtle.getSelectedSlot())
            end
            self.list:onSelectionChanged()
        end
        
        function self.btnPrevSlot.onPressed(btn)
            local n = (self.modPressed and 4) or 1
            self.client:moveSelection(-n)
        end
        
        function self.btnNextSlot.onPressed(btn)
            local n = (self.modPressed and 4) or 1
            self.client:moveSelection(n)
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
    self:onLayout()
end

function ClientUI:setModifier(mod)
    self.modPressed = mod
    if turtle then
        if mod then
            self.btnStore.text = "S.All"
            self.btnPrevSlot.text = string.char(Constants.SpecialChars.TRI_UP)
            self.btnNextSlot.text = string.char(Constants.SpecialChars.TRI_DOWN)
        else
            self.btnStore.text = "Store"
            self.btnPrevSlot.text = string.char(Constants.SpecialChars.TRI_LEFT)
            self.btnNextSlot.text = string.char(Constants.SpecialChars.TRI_RIGHT)
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

function ClientUI:updateList()
    self.items = {}
    self.list.items = {}
    for k,v in pairs(self.client.items) do
        table.insert(self.items,v)
    end
    table.sort(self.items, function(a, b) return a.displayName:lower() < b.displayName:lower() end)
    for k,v in pairs(self.items) do
        local count = self:formatCount(v.count)
        local line = self:padToWidth(v.displayName,self.list.size[1]-#count)
        table.insert(self.list.items,line .. count)
    end
    --print("finished fetch")
    self.list:onSelectionChanged()
    self:onLayout()
end

function ClientUI:onEvent(evt)
    --print(evt[1])
    if evt[1] == "rednet_message" then
        self.client:onMessage(unpack(evt))
    end
    return ClientUI.superClass.onEvent(self, evt)
end

function ClientUI:padToWidth(str, n)
    local l = #str
    if l > n then
        return str:sub(1, n)
    elseif l < n then
        return str .. string.rep(" ",n-l)
    end
    return str
end

function ClientUI:formatCount(n)
    local suffix = ""
    if n >= 1000000 then
        n = math.floor(n / 1000000)
        suffix = "M"
    elseif n >= 1000 then
        n = math.floor(n / 1000)
        suffix = "k"
    end
    return "x" .. tostring(n) .. suffix
end

function ClientUI:requestItem()
    if self.list.selected >= 1 and self.list.selected <= #self.items then
        local item = self.items[self.list.selected]
        local count = tonumber(self.field.text) or 0
        self.client:requestItem(item, count)
    end
end

return ClientUI
