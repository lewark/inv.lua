local expect = require "cc.expect"
local Widget = require "gui.Widget"

-- Displays custom text.
local Label = Widget:subclass()

-- Label constructor.
--
-- Parameters:
-- - root (Root): The root widget
-- - text (string): Text to display on the Label.
function Label:init(root,text)
    expect(1, root, "table")
    expect(2, text, "string")
    Label.superClass.init(self,root)
    self.text = text
    self.backgroundColor = colors.lightGray
    self.textColor = colors.black
    self.length = 0
end

-- Returns the label's text padded or trimmed to the size of the label.
function Label:padText()
    if #self.text > self.size[1] then
        return string.sub(self.text,1,math.min(#self.text,self.size[1]))
    elseif #self.text < self.size[1] then
        return self.text .. string.rep(" ",self.size[1]-#self.text)
    end
    return self.text
end

function Label:render()
    if self.size[2] > 0 then
        term.setBackgroundColor(self.backgroundColor)
        term.setTextColor(self.textColor)
        term.setCursorPos(self.pos[1],self.pos[2])
        term.write(self:padText())
    end
end

function Label:getPreferredSize()
    if self.length > 0 then
        return {self.length,1}
    else
        return {#self.text,1}
    end
end

return Label
