local expect = require "cc.expect"
local Widget = require "gui.Widget"

-- A text area for editing multi-line text. Unfinished.
local TextArea = Widget:subclass()

-- TextArea constructor.
--
-- Parameters:
-- - root (Root): The root widget
-- - cols (int): The preferred width of the text area
-- - rows (int): The preferred height of the text area
-- - text (string): Initial contents of the text area
function TextArea:init(root,cols,rows,text)
    -- TODO: rewrite, use virtual lines for text wrapping
    --        and allow wrapping to be disabled
    expect(1, root, "table")
    expect(2, cols, "number")
    expect(3, rows, "number")
    expect(4, text, "string")
    TextArea.superClass.init(self,root)

    self.text = {}
    self:setText(text)
    self.color = colors.white
    self.textColor = colors.black
    self.rows = rows
    self.cols = cols
    self.cursorScreenPos = {0,0}
    self.charX = #self.text
    self.charY = 1
end

function TextArea:getPreferredSize()
    return {self.cols, self.rows}
end

-- Sets the text within the text area.
function TextArea:setText(text)
    -- BUG: double newlines are combined
    expect(1, text, "string")
    self.text = {}
    for line in text:gmatch("[^\r?\n]+") do
        table.insert(self.text,line)
    end
    self.dirty = true
end

-- Gets the text within the text area.
function TextArea:getText()
    return table.concat(self.text,"\n")
end

function TextArea:render()
    -- TODO: add scrolling
    -- BUG: cursor does not render at width
    term.setTextColor(self.textColor)
    term.setBackgroundColor(self.color)

    local myX,myY = self.pos[1], self.pos[2]

    for y=1,self.size[2] do
        term.setCursorPos(myX,myY+y-1)
        term.write(string.rep(" ",self.size[1]))
    end

    local y = 0
    local lY = 0
    for i=1,#self.text do
        local text = self.text[i]
        --if self.root.focus == self and i == self.charY then
        --    term.setBackgroundColor(colors.lightGray)
        --else
        --    term.setBackgroundColor(self.color)
        --end
        while (text ~= "") and (y < self.size[2]) do
            local chr = self.size[1]
            local substr = string.sub(text,1,chr)
            text = string.sub(text,chr+1,#text)
            term.setCursorPos(myX,myY+y+i-1)
            term.write(substr)
            if text ~= "" then
                y = y + 1
                if i < self.charY then
                    lY = lY + 1
                end
            end
        end
    end
    --term.write(string.sub(self.text,1,math.min(#self.text,self.size[1])))
    if self.root.focus == self then
        self.cursorScreenPos = {myX+(self.charX%self.size[1]-1),myY+lY+math.floor(self.charX/self.size[1])+self.charY-1}
        term.setCursorPos(unpack(self.cursorScreenPos))
        term.setBackgroundColor(colors.lightGray)
        local chr = " "
        if self.charX <= #self.text[self.charY] then
            chr = string.sub(self.text[self.charY],self.charX,self.charX)
        end
        term.write(chr)
        --    term.write("I")
    end
end

function TextArea:onKeyDown(key,held)
    -- TODO: Add DELETE key, fix up/down behavior with wrapped strings
    if key == keys.backspace then
        if (self.charY > 1) and (self.charX == 1) then
            local text = table.remove(self.text,self.charY)
            self.charY = self.charY - 1
            local text2 = self.text[self.charY]
            self.charX = #self.text[self.charY]+1
            self.text[self.charY] = text2 .. text
        elseif self.charX > 1 then
            local text = self.text[self.charY]
            self.text[self.charY] = string.sub(text,1,self.charX-2) .. string.sub(text,self.charX,#text)
            self.charX = math.max(1,self.charX-1)
        end
    elseif key == keys.left then
        if (self.charX == 1) and (self.charY > 1) then
            self.charY = self.charY - 1
            self.charX = #self.text[self.charY]+1
        else
            self.charX = math.max(1,self.charX-1)
        end
    elseif key == keys.right then
        local text = self.text[self.charY]
        if (self.charX == #text+1) and (self.charY < #self.text) then
            self.charX = 1
            self.charY = self.charY + 1
        else
            self.charX = math.min(#text+1,self.charX+1)
        end
    elseif key == keys.down then
        if self.charX + self.size[1] <= #self.text[self.charY]+1 then
            self.charX = self.charX + self.size[1]
        elseif self.charY < #self.text then
            self.charY = self.charY+1
            self.charX = math.min(self.charX,#self.text[self.charY]+1)
        else
            self.charX = #self.text[self.charY]
        end
    elseif key == keys.up then
        if self.charX - self.size[1] >= 1 then
            self.charX = self.charX - self.size[1]
        elseif self.charY > 1 then
            self.charY = self.charY-1
            self.charX = math.min(self.charX,#self.text[self.charY]+1)
        else
            self.charX = 1
        end
    elseif key == keys.enter then
        local text = self.text[self.charY]
        local newline = string.sub(text,self.charX,#text)
        self.text[self.charY] = string.sub(text,1,self.charX-1)
        self.charX = 1
        self.charY = self.charY + 1
        table.insert(self.text,self.charY,newline)
    end
    self.dirty = true
    return true
end

function TextArea:onFocus(focused)
    term.setCursorBlink(focused)
    self.dirty = true
    return true
end

function TextArea:focusPostRender()
    term.setCursorPos(unpack(self.cursorScreenPos))
end

function TextArea:onCharTyped(chr)
    local text = self.text[self.charY]
    self.text[self.charY] = string.sub(text,1,self.charX-1) .. chr .. string.sub(text,self.charX,#text)
    self.charX = self.charX + 1
    self.dirty = true
    return true
end

function TextArea:onPaste(text)
    local text_line = self.text[self.charY]
    self.text[self.charY] = string.sub(text_line,1,self.charX-1) .. text .. string.sub(text_line,self.charX,#text_line)
    self.charX = self.charX + #text
    self.dirty = true
    return true
end

function TextArea:onMouseDown(button, x, y)
    self:mouseSelect(x,y)
    return true
end

function TextArea:onMouseDrag(button, x, y)
    self:mouseSelect(x,y)
    return true
end

function TextArea:mouseSelect(x, y)
    -- TODO: Add area selection
    -- BUG: Off-by-one error, behaves wrongly when a line is exactly the widget width
    expect(1, x, "number")
    expect(2, y, "number")
    local myX,myY = self.pos[1],self.pos[2]
    local t_y = 1
    self.charY = 0
    for i=1,#self.text do
        for j=1,math.floor(#self.text[i]/self.size[1])+1 do
            if t_y == y - myY + 1 then
                self.charY = i
                self.charX = math.min(x+(j-1)*self.size[1],#self.text[i]+1)
            end
            t_y = t_y + 1
        end
        if self.charY ~= 0 then break end
    end
    if self.charY == 0 then
        self.charY = #self.text
        self.charX = #self.text[self.charY]+1
    end
    self.dirty = true
end

return TextArea
