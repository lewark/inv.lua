local expect = require "cc.expect"
local Object = require "gui.Object"

-- Base class for GUI elements.
local Widget = Object:subclass()

-- Widget constructor.
function Widget:init(root)
    expect(1, root, "table", "nil")
    self.size = {0,0}
    self.pos = {1,1}
    self.layout = {}
    self.dirty = true
    self.parent = nil
    self.root = root
end

-- Returns true if the coordinates x, y are within the widget's bounding box.
function Widget:containsPoint(x,y)
    expect(1, x, "number")
    expect(2, y, "number")
    return (
        x >= self.pos[1] and
        x < self.pos[1]+self.size[1] and
        y >= self.pos[2] and
        y < self.pos[2]+self.size[2]
    )
end

-- Event handler called when the GUI is repainted.
function Widget:onRedraw()
    if self.dirty then
        self:render()
        self.dirty = false
    end
end

-- Event handler called when the widget's layout is updated.
function Widget:onLayout()
    self.dirty = true
end

-- Returns the widget's preferred minimum size.
function Widget:getPreferredSize()
    return {0, 0}
end

-- Widget render callbacks. Override these to draw a widget.
function Widget:render() end
-- Post-render callback for focused widget. Used to position text field cursor.
function Widget:focusPostRender() end

-- Event handler called when a key is pressed or held and the widget is in focus.
function Widget:onKeyDown(key,held) return true end
-- Event handler called when a key is released and the widget is in focus.
function Widget:onKeyUp(key) return true end
-- Event handler called when a character is typed and the widget is in focus.
function Widget:onCharTyped(chr) return true end
-- Event handler called when text is pasted and the widget is in focus.
function Widget:onPaste(text) return true end
-- Event handler called when a mouse button is released and the widget is in focus.
function Widget:onMouseDown(btn,x,y) return true end
-- Event handler called when a mouse button is pressed over the widget.
function Widget:onMouseUp(btn,x,y) return true end
-- Event handler called when the mouse wheel is scrolled over the widget.
function Widget:onMouseScroll(dir,x,y) return true end
-- Event handler called when the widget is dragged.
function Widget:onMouseDrag(btn,x,y) return true end
-- Event handler called when the widget enters or leaves focus.
function Widget:onFocus(focused) return true end

-- Handles any input events recieved by the widget and passes them to
-- the appropriate handler functions. Return true from an event handler
-- to consume the event and prevent it from being passed on to other gui.
-- Event consumption is mainly useful for mouse_click and mouse_scroll.
function Widget:onEvent(evt)
    expect(1, evt, "table")
    if evt[1] == "mouse_drag" then
        return self:onMouseDrag(evt[2],evt[3],evt[4])
    elseif evt[1] == "mouse_up" then
        return self:onMouseUp(evt[2],evt[3],evt[4])
    elseif evt[1] == "mouse_click" then
        if self.root then
            self.root.focus = self
        end
        return self:onMouseDown(evt[2],evt[3],evt[4])
    elseif evt[1] == "mouse_scroll" then
        return self:onMouseScroll(evt[2],evt[3],evt[4])
    elseif evt[1] == "char" then
        return self:onCharTyped(evt[2])
    elseif evt[1] == "key" then
        return self:onKeyDown(evt[2],evt[3])
    elseif evt[1] == "key_up" then
        return self:onKeyUp(evt[2])
    elseif evt[1] == "paste" then
        return self:onPaste(evt[2])
    end
    return false
end

return Widget
