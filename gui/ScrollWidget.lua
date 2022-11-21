local expect = require "cc.expect"
local Widget = require "gui.Widget"

-- Base class for scrollable widgets
local ScrollWidget = Widget:subclass()

function ScrollWidget:init(root)
    expect(1, root, "table")
    ScrollWidget.superClass.init(self,root)
    self.scroll = 0
    self.scrollSpeed = 3
    self.scrollbar = nil
end

-- Returns the scroll range of the widget
function ScrollWidget:getMaxScroll()
    return 0
end

function ScrollWidget:setScroll(scroll)
    expect(1, scroll, "number")
    local maxScroll = self:getMaxScroll()
    if scroll > maxScroll then
        scroll = maxScroll
    end
    if scroll < 0 then
        scroll = 0
    end
    if self.scroll ~= scroll then
        self.scroll = scroll
        self.dirty = true
        if self.scrollbar then
            self.scrollbar.dirty = true
        end
    end
end

function ScrollWidget:onMouseScroll(dir, x, y)
    self:setScroll(self.scroll+dir*self.scrollSpeed)
    return true
end

return ScrollWidget
