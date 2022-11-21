local expect = require "cc.expect"
local Constants = require "gui.Constants"
local Widget = require "gui.Widget"

-- Scroll bar. Allows greater control over a scrolling widget such as a ListBox.
local ScrollBar = Widget:subclass()

-- ScrollBar constructor.
--
-- Parameters:
-- - root (Root): The root widget
-- - scrollWidget (ScrollWidget): The widget this ScrollBar should scroll
function ScrollBar:init(root,scrollWidget)
    -- todo: add horizontal scrollbars
    expect(1, root, "table")
    expect(2, scrollWidget, "table")
    ScrollBar.superClass.init(self,root)
    self.scrollWidget = scrollWidget
    scrollWidget.scrollbar = self
    self.dragOffset = 0
    self.grab = 0
    self.barColor = colors.blue
    self.textColor = colors.white
    self.pressedColor = colors.cyan
    self.disabledColor = colors.gray
    self.bgColor = colors.white
    self.bgPressedColor = colors.gray
end

function ScrollBar:getPreferredSize()
    return {1, 1}
end

function ScrollBar:canScroll()
    return (self.scrollWidget:getMaxScroll() > 0)
end

function ScrollBar:getBarPos()
    local scroll = self.scrollWidget.scroll
    local h = self:getBarHeight()
    local maxScroll = self.scrollWidget:getMaxScroll()
    return math.floor((scroll/maxScroll)*(self.size[2]-2-h)+0.5)+1
end

function ScrollBar:getBarHeight()
    local maxScroll = self.scrollWidget:getMaxScroll()
    return math.max(math.floor((self.size[2]-2)*self.scrollWidget.size[2]/(maxScroll+self.scrollWidget.size[2])+0.5),1)
end

function ScrollBar:render()
    -- kinda odd that the code to render a scrollbar is much longer
    -- than that to render a list box (the thing you actually care about)
    local enabled = self:canScroll()
    local barColor = self.barColor

    if not enabled then
        barColor = self.disabledColor
    end

    term.setTextColor(self.textColor)

    if self.drag == 4 then
        term.setBackgroundColor(self.pressedColor)
    else
        term.setBackgroundColor(barColor)
    end
    term.setCursorPos(self.pos[1],self.pos[2])
    term.write(string.char(Constants.SpecialChars.TRI_UP))

    if self.drag == 5 then
        term.setBackgroundColor(self.pressedColor)
    else
        term.setBackgroundColor(barColor)
    end
    term.setCursorPos(self.pos[1],self.pos[2]+self.size[2]-1)
    term.write(string.char(Constants.SpecialChars.TRI_DOWN))

    if enabled then
        local barPos = self:getBarPos()
        local barHeight = self:getBarHeight()
        local handleColor = barColor
        local bgTColor = self.bgColor
        local bgBColor = self.bgColor
        if self.drag == 1 then
            handleColor = self.pressedColor
        end
        if self.drag == 2 then
            bgTColor = self.bgPressedColor
        end
        if self.drag == 3 then
            bgBColor = self.bgPressedColor
        end

        for i=1,self.size[2]-2 do
            term.setCursorPos(self.pos[1],self.pos[2]+i)
            if i < barPos then
                term.setBackgroundColor(bgTColor)
            elseif i >= barPos and i < barPos+barHeight then
                term.setBackgroundColor(handleColor)
            else
                term.setBackgroundColor(bgBColor)
            end
            term.write(" ")
        end
    else
        term.setBackgroundColor(self.disabledColor)
        for i=1,self.size[2]-2 do
            term.setCursorPos(self.pos[1],self.pos[2]+i)
            term.write(" ")
        end
    end
end

function ScrollBar:onMouseScroll(dir, x, y)
    self.scrollWidget:setScroll(self.scrollWidget.scroll+dir*self.scrollWidget.scrollSpeed)
    return true
end

function ScrollBar:onMouseDown(btn, x, y)
    -- BUG: can sometimes scroll to invalid locations on edge cases (3 unit tall scrollbar)
    -- todo: add timer to repeat buttons on hold
    if self:canScroll() then
        if y == self.pos[2] then
            self.drag = 4
            self.scrollWidget:setScroll(self.scrollWidget.scroll-1)
        elseif y == self.pos[2]+self.size[2]-1 then
            self.drag = 5
            self.scrollWidget:setScroll(self.scrollWidget.scroll+1)
        else
            local barPos = self:getBarPos()
            local barHeight = self:getBarHeight()
            if y < self.pos[2] + barPos then
                self.scrollWidget:setScroll(self.scrollWidget.scroll-self.scrollWidget.size[2])
                self.drag = 2
            elseif y < self.pos[2] + barPos + barHeight then
                self.drag = 1
                self.dragOffset = y - self.pos[2] - barPos
            else
                self.scrollWidget:setScroll(self.scrollWidget.scroll+self.scrollWidget.size[2])
                self.drag = 3
            end
        end
        self.dirty = true
    end
    return true
end

function ScrollBar:onMouseDrag(btn, x, y)
    if self:canScroll() and self.drag == 1 then
        local barHeight = self:getBarHeight()
        local size = self.size[2]-2
        local maxScroll = self.scrollWidget:getMaxScroll()
        local scroll = math.floor((y-self.pos[2]-self.dragOffset-1)*(maxScroll/(size-barHeight))+0.5)
        self.scrollWidget:setScroll(scroll)
    end
    return true
end

function ScrollBar:onMouseUp(btn, x, y)
    self.drag = 0
    self.dirty = true
    self.root.focus = self.scrollWidget
    return true
end

return ScrollBar
