local Common = require 'inv.Common'

local Button = require 'gui.Button'
local Constants = require 'gui.Constants'
local Label = require 'gui.Label'
local LinearContainer = require 'gui.LinearContainer'
local ListBox = require 'gui.ListBox'
local Root = require 'gui.Root'
local ScrollBar = require 'gui.ScrollBar'
local TextField = require 'gui.TextField'

local ClientUI = Root:subclass()

function ClientUI:init(client)
    ClientUI.superClass.init(self)
    
    self.moveKeys = {w=-4,s=4,a=-1,d=1}
    self.client = client
    
    self.sidebarWidth = math.floor(self.size[1] / 3)
    self.items = {}
    self.modPressed = false
    
    self.vbox = LinearContainer(self,2,1,1)
    self.hbox = LinearContainer(self,1,0,0)
    
    self.list = ListBox(self,10,10,{})
    self.sb = ScrollBar(self,self.list)

    self.btnRefresh = Button(self,"")
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
    
    self.blockKeys = {}
    self.blockKeys[self.list] = true
    self.blockKeys[self.sb] = true
    
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
        
        self.btnBox:addChild(self.btnPrevSlot,false,false,Constants.LinearAlign.START)
        self.btnBox:addChild(self.btnStore,true,false,Constants.LinearAlign.START)
        self.btnBox:addChild(self.btnNextSlot,false,false,Constants.LinearAlign.START)
        
        self.spinBox:addChild(self.btnMinus,false,false,Constants.LinearAlign.START)
        self.spinBox:addChild(self.field,true,false,Constants.LinearAlign.START)
        self.spinBox:addChild(self.btnPlus,false,false,Constants.LinearAlign.START)
        
        self.vbox:addChild(self.spinBox,false,true,Constants.LinearAlign.START)
        self.vbox:addChild(self.btnReq,false,true,Constants.LinearAlign.START)
        self.vbox:addChild(self.btnBox,false,true,Constants.LinearAlign.START)
        
        self.blockKeys[self.field] = true
    end
    
    self:setModifier(false)
    
    function self.list.onSelectionChanged(list)
        if self.list.selected >= 1 and self.list.selected <= #self.items then
            self.lbl.text = self.items[self.list.selected]:getName()
            self.lbl2.text = "Count: "..self.items[self.list.selected].count
            if turtle then
                self.btnReq.enabled = true
                self.btnReq.dirty = true
            end
        else
            self.lbl.text = "[Nothing]"
            self.lbl2.text = "Count: 0"
            if turtle then
                self.btnReq.enabled = false
                self.btnReq.dirty = true
            end
        end
        self.lbl.dirty = true
        self.lbl2.dirty = true
    end
    
    function self.btnRefresh.onPressed(btn)
        self.client:fetchItems(self.modPressed)
    end
    
    if turtle then
        function self.btnReq.onPressed(btn)
            self:requestItem()
        end
    
        function self.btnStore.onPressed(btn)
            self:storeItem()
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
            self:adjustItemCount(1)
        end
        
        function self.btnMinus.onPressed(btn)
            self:adjustItemCount(-1)
        end
    end
    self:onLayout()
end

-- Sets whether or not the modifier key is pressed, updating the UI as appropriate.
function ClientUI:setModifier(mod)
    self.modPressed = mod
    if mod then
        self.btnRefresh.text = "ScanNet"
    else
        self.btnRefresh.text = "Refresh"
    end
    self.btnRefresh.dirty = true
    
    if turtle then
        if mod then
            self.btnStore.text = " All "
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
    if not held then
        if (key == keys.leftShift or key == keys.leftCtrl) then
            self:setModifier(true)
        end
        local block = self.blockKeys[self.focus]
        if not block then
            if key == keys.up or key == keys.down
                or key == keys.left or key == keys.right then
                self.list:onKeyDown(key, held)
            end
        end
    end
    return true
end

function ClientUI:onCharTyped(chr)
    if self.focus == self.list or not self.blockKeys[self.focus] then
        local l = chr:lower()
        if l == "q" then
            self:requestItem()
        elseif chr == "e" then
            self:storeCurrentItem()
        elseif chr == "E" then
            self.client:depositAll()
        elseif chr == "=" then
            self:adjustItemCount(1)
        elseif chr == "+" then
            self:adjustItemCount(1, true)
        elseif chr == "-" then
            self:adjustItemCount(-1)
        elseif chr == "_" then
            self:adjustItemCount(-1, true)
        elseif self.moveKeys[l] then
            self.client:moveSelection(self.moveKeys[l])
        end
    end
    return true
end

function ClientUI:onKeyUp(key)
    if (key == keys.leftShift or key == keys.leftCtrl) then
        self:setModifier(false)
    end
end

-- Updates the list of stored items, including item counts
function ClientUI:updateList()
    self.items = {}
    self.list.items = {}
    for k,v in pairs(self.client.items) do
        table.insert(self.items,v)
    end
    table.sort(self.items, function(a, b) return a:getName():lower() < b:getName():lower() end)
    for k,v in pairs(self.items) do
        local count = self:formatCount(v.count)
        local line = self:padToWidth(v:getName(),self.list.size[1]-#count)
        table.insert(self.list.items,line .. count)
    end
    self.list.dirty = true
    self.sb.dirty = true
    self.list:onSelectionChanged()
end

function ClientUI:onEvent(evt)
    if evt[1] == "rednet_message" then
        self.client:onMessage(unpack(evt))
    end
    return ClientUI.superClass.onEvent(self, evt)
end

-- Pads a string to the specified width.
-- TODO: merge w/ duplicate code in Label
function ClientUI:padToWidth(str, n)
    local l = #str
    if l > n then
        return str:sub(1, n)
    elseif l < n then
        return str .. string.rep(" ",n-l)
    end
    return str
end

-- Formats an item count, using k or M for thousands/millions
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

-- Requests the currently selected item.
function ClientUI:requestItem()
    if self.list.selected >= 1 and self.list.selected <= #self.items then
        local item = self.items[self.list.selected]
        local count = tonumber(self.field.text) or 0
        self.client:requestItem(item, count)
    end
end

function ClientUI:storeCurrentItem()
    self.client:depositSlots(turtle.getSelectedSlot())
end

function ClientUI:adjustItemCount(amount, forceMod)
    local n = tonumber(self.field.text) or 0
    local mod = ((self.modPressed or forceMod) and 64) or 1
    self.field.text = tostring(math.max(n+amount*mod,0))
    self.field.dirty = true
end

function ClientUI:storeItem()
    if self.modPressed then
        self.client:depositAll()
    else
        self:storeCurrentItem()
    end
end

return ClientUI
