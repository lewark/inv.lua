local expect = require "cc.expect"
local Widget = require "gui.Widget"
local Constants = require "gui.Constants"

-- Base class for all widgets that can contain other gui widgets.
local Container = Widget:subclass()

-- Container constructor.
function Container:init(root)
    expect(1, root, "table", "nil")
    Container.superClass.init(self,root)
    self.children = {}
end

-- Add a child widget to the Container.
function Container:addChild(child,...)
    expect(1, child, "table")
    table.insert(self.children,child)
end

function Container:onRedraw()
    Container.superClass.onRedraw(self)
    for _,widget in pairs(self.children) do
        widget:onRedraw()
    end
end

function Container:onEvent(evt)
    expect(1, evt, "table")
    local ret = Container.superClass.onEvent(self,evt)
    if Constants.TOP_EVENTS[evt[1]] then
        for i=#self.children,1,-1 do
            local widget = self.children[i]
            if widget:containsPoint(evt[3],evt[4]) and widget:onEvent(evt) then
                return true
            end
        end
    elseif not Constants.FOCUS_EVENTS[evt[1]] then
        for i=1,#self.children do
            local widget = self.children[i]
            if widget:onEvent(evt) then
                return true
            end
        end
    end
    return ret
end

function Container:onLayout()
    Container.superClass.onLayout(self)
    self:layoutChildren()
    for _,widget in pairs(self.children) do
        widget:onLayout()
    end
end

-- Updates the position and size of all widgets within the Container.
-- Specialized behavior is provided by subclasses of Container.
function Container:layoutChildren() end

return Container
