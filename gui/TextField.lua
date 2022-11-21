local expect = require "cc.expect"
local Widget = require "gui.Widget"

-- A text field that allows users to type text within it.
local TextField = Widget:subclass()

-- TextField constructor.
--
-- Parameters:
-- - root (Root): The root widget
-- - length (int): Width of the text field in characters.
-- - text (string): Initial contents of the TextField.
function TextField:init(root,length,text)
    -- TODO: Add auto-completion
    expect(1, root, "table")
    expect(2, length, "number")
    expect(3, text, "string")
    TextField.superClass.init(self,root)

    self.text = text
    self.color = colors.white
    self.textColor = colors.black
    self.cursorColor = colors.lightGray
    self.cursorScreenPos = {0,0}
    self.char = #self.text
    self.length = length
    self.scroll = 0
end

-- Event handler called when the text in a TextField is edited.
-- Override this method on an instance to set custom behavior.
function TextField:onChanged() end

-- Sets the text within the TextField
function TextField:setText(text)
    self.text = text
    self.dirty = true
end

-- Gets the text within the TextField
function TextField:getText()
    return self.text
end

function TextField:getPreferredSize()
    return {self.length,1}
end

function TextField:isCursorVisible()
    return (self.root.focus == self and self:containsPoint(unpack(self.cursorScreenPos)))
end

function TextField:render()
    term.setTextColor(self.textColor)
    term.setBackgroundColor(self.color)

    local myX,myY = self.pos[1], self.pos[2]

    for y=1,self.size[2] do
        term.setCursorPos(myX,myY+y-1)
        term.write(string.rep(" ",self.size[1]))
    end

    term.setCursorPos(myX,myY)
    term.write(string.sub(self.text,self.scroll+1,math.min(#self.text,self.scroll+self.size[1])))

    self.cursorScreenPos = {myX+self.char-1-self.scroll,myY}

    if self:isCursorVisible() then
        term.setCursorPos(unpack(self.cursorScreenPos))
        term.setBackgroundColor(self.cursorColor)
        local chr = " "
        if self.char <= #self.text then
            chr = string.sub(self.text,self.char,self.char)
        end
        term.write(chr)
    end
end

function TextField:moveCursor(newPos)
    expect(1, newPos, "number")
    self.char = math.min(math.max(newPos,1),#self.text+1)
    if self.char-self.scroll > self.size[1] then
        self.scroll = self.char - self.size[1]
    elseif self.char-self.scroll < 1 then
        self.scroll = self.char - 1
    end
end

function TextField:onKeyDown(key,held)
    if key == keys.backspace then
        self.text = string.sub(self.text,1,math.max(self.char-2,0)) .. string.sub(self.text,self.char,#self.text)
        self:moveCursor(self.char-1)
        self:onChanged()
    elseif key == keys.delete then
        self.text = string.sub(self.text,1,math.max(self.char-1,0)) .. string.sub(self.text,self.char+1,#self.text)
        self:onChanged()
    elseif key == keys.home then
        self:moveCursor(1)
    elseif key == keys['end'] then
        self:moveCursor(#self.text+1)
    elseif key == keys.left then
        self:moveCursor(self.char-1)
    elseif key == keys.right then
        self:moveCursor(self.char+1)
    end
    self.dirty = true
    return true
end

function TextField:onFocus(focused)
    term.setCursorBlink(focused)
    self.dirty = true
    return true
end

function TextField:focusPostRender()
    if self:isCursorVisible() then
        term.setCursorPos(unpack(self.cursorScreenPos))
        term.setCursorBlink(true)
    else
        term.setCursorBlink(false)
    end
end

function TextField:onCharTyped(chr)
    if self.root.focus == self then
        self.text = string.sub(self.text,1,self.char-1) .. chr .. string.sub(self.text,self.char,#self.text)
        self:moveCursor(self.char + 1)
        self.dirty = true
        self:onChanged()
    end
    return true
end

function TextField:onPaste(text)
    if self.root.focus == self then
        self.text = string.sub(self.text,1,self.char-1) .. text .. string.sub(self.text,self.char,#self.text)
        self:moveCursor(self.char + #text)
        self.dirty = true
        self:onChanged()
    end
    return true
end

function TextField:onMouseDown(button, x, y)
    self:mouseSelect(x,y)
    return true
end

function TextField:onMouseDrag(button, x, y)
    self:mouseSelect(x,y)
    return true
end

function TextField:mouseSelect(x, y)
    -- TODO: Add area selection
    expect(1, x, "number")
    expect(2, y, "number")
    self:moveCursor(x - self.pos[1] + 1 + self.scroll)
    self.dirty = true
end

return TextField
