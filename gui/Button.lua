local expect = require "cc.expect"
local Widget = require "gui.Widget"

-- Can be clicked using the mouse, triggering a custom onPressed() callback.
local Button = Widget:subclass()

-- Button constructor.
--
-- Parameters:
-- - root (Root): The root widget
-- - text (string): Text to display on the Button.
function Button:init(root,text)
    expect(1, root, "table")
    expect(2, text, "string")
    Button.superClass.init(self,root)
    self.text = text
    self.color = colors.blue
    self.pushedColor = colors.cyan
    self.textColor = colors.white
    self.disabledColor = colors.gray
    self.held = false
    self.enabled = true
end

-- Event handler called when a Button is pressed.
-- Override this method on a Button instance to set its behavior.
function Button:onPressed() end

function Button:getPreferredSize()
    return {#self.text+2,1}
end

function Button:render()
    --getSuper(Button).render(self)
    -- TODO: render outline when focused
    if not self.enabled then
        term.setBackgroundColor(self.disabledColor)
    elseif self.held then --self.root.focus == self then
        term.setBackgroundColor(self.pushedColor)
    else
        term.setBackgroundColor(self.color)
    end
    term.setTextColor(self.textColor)
    local myX,myY = self.pos[1], self.pos[2]

    for y=1,self.size[2] do
        term.setCursorPos(myX,myY+y-1)
        term.write(string.rep(" ",self.size[1]))
    end

    if self.size[2] > 0 then
        local text_x = myX + math.max(math.floor((self.size[1]-#self.text)/2),0)
        local text_y = myY + math.max(math.floor((self.size[2]-1)/2),0)
        term.setCursorPos(text_x,text_y)
        term.write(string.sub(self.text,1,math.min(#self.text,self.size[1])))
    end
end

function Button:onMouseDown(btn,x,y)
    if self.enabled then
        self.held = true
        self.dirty = true
    end
    return true
end

function Button:onMouseUp(btn,x,y)
    if self.enabled then
        self.held = false
        self.dirty = true
        if self:containsPoint(x,y) then
            self:onPressed()
        end
    end
    return true
end

function Button:onKeyDown(key,held)
    if self.enabled and (not held) and (key == keys.space or key == keys.enter) then
        self.held = true
        self.dirty = true
    end
    return true
end

function Button:onKeyUp(key)
    if self.enabled and (key == keys.space or key == keys.enter) then
        self.held = false
        self.dirty = true
        self:onPressed()
    end
    return true
end

function Button:onFocus(focused)
    if self.enabled then
        self.dirty = true
    end
    return true
end

return Button
