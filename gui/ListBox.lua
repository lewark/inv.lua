local expect = require "cc.expect"
local ScrollWidget = require "gui.ScrollWidget"

-- List box. Allows an array of choices to be displayed, one of which can be
--   selected at a time. Can be scrolled using the mouse wheel or a ScrollBar
--   widget, and is able to efficiently display large amounts of items.
local ListBox = ScrollWidget:subclass()

-- ListBox constructor.
--
-- Parameters:
-- - root (Root): The root widget
-- - cols (int): The preferred width of the ListBox
-- - rows (int): The preferred height of the ListBox
-- - items (string[]): Items contained within the ListBox
function ListBox:init(root,cols,rows,items)
    expect(1, root, "table")
    expect(2, cols, "number")
    expect(3, rows, "number")
    expect(4, items, "table")
    ListBox.superClass.init(self,root)
    self.items = items
    self.cols = cols
    self.rows = rows
    self.bgColor = colors.white
    self.textColor = colors.black
    self.selBgColor = colors.cyan
    self.selTextColor = colors.white
    self.selected = 0
end

function ListBox:getPreferredSize()
    return {self.cols, self.rows}
end

function ListBox:render()
    for i=1,self.size[2] do
        term.setCursorPos(self.pos[1],self.pos[2]+i-1)
        local optText = ""
        local isOpt = false
        local idx = i+self.scroll

        if idx>=1 and idx<=#self.items then
            optText = string.sub(self.items[idx],1,self.size[1])
            isOpt = true
        end

        if isOpt and self.selected == idx then
            term.setBackgroundColor(self.selBgColor)
            term.setTextColor(self.selTextColor)
        else
            term.setBackgroundColor(self.bgColor)
            term.setTextColor(self.textColor)
        end

        term.write(optText..string.rep(" ",self.size[1]-#optText))
    end
end

function ListBox:onLayout()
    ListBox.superClass.onLayout(self)
    self:setScroll(self.scroll)
end

-- Event handler called when the selected item is changed.
-- Override this method to receive selection events.
function ListBox:onSelectionChanged() end

function ListBox:setSelected(n)
    expect(1, n, "number")
    n = math.min(math.max(n,1),#self.items)
    if self.selected ~= n then
        self.selected = n
        if self.scroll >= self.selected then
            self:setScroll(self.selected - 1)
        elseif self.scroll + self.size[2] < self.selected then
            self:setScroll(self.selected - self.size[2])
        end
        self:onSelectionChanged()
    end
end

function ListBox:getMaxScroll()
    return #self.items-self.size[2]
end

function ListBox:mouseSelect(x,y)
    expect(1, x, "number")
    expect(2, y, "number")
    self:setSelected(y-self.pos[2]+self.scroll+1)
    self.dirty = true
end

function ListBox:onMouseDown(button, x, y)
    self:mouseSelect(x,y)
    return true
end

function ListBox:onMouseDrag(button, x, y)
    self:mouseSelect(x,y)
    return true
end

function ListBox:onKeyDown(key,held)
    if key == keys.down then
        self:setSelected(self.selected+1)
    elseif key == keys.up then
        self:setSelected(self.selected-1)
    elseif key == keys.home then
        self:setSelected(1)
    elseif key == keys['end'] then
        self:setSelected(#self.items)
    elseif key == keys.pageUp then
        self:setSelected(self.selected-(self.size[2]-1))
    elseif key == keys.pageDown then
        self:setSelected(self.selected+(self.size[2]-1))
    end
    self.dirty = true
    return true
end

return ListBox
