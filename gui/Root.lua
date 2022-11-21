local expect = require "cc.expect"
local Container = require "gui.Container"
local Constants = require "gui.Constants"

-- The root widget of the user interface. Handles focus, resizing, and other events.
local Root = Container:subclass()

-- Root constructor.
function Root:init()
    Root.superClass.init(self,nil)
    self.focus = nil
    self.size = {term.getSize()}
    self.backgroundColor = colors.lightGray
end

-- Called internally to render the root's first frame.
function Root:show()
    self:onLayout()
    self:onRedraw()
end

function Root:onRedraw()
    Root.superClass.onRedraw(self)
    if self.focus then
        self.focus:focusPostRender()
    end
end

function Root:onEvent(evt)
    expect(1, evt, "table")
    local focus = self.focus
    local ret = Root.superClass.onEvent(self,evt)

    if self.focus and Constants.FOCUS_EVENTS[evt[1]] and self.focus:onEvent(evt) then
        ret = true
    end

    if evt[1] == "term_resize" then
        self.size = {term.getSize()}
        self:onLayout()
        ret = true
    end

    if self.focus ~= focus then
        if focus then
            focus:onFocus(false)
        end
        if self.focus then
            self.focus:onFocus(true)
        end
    end

    self:onRedraw()

    return ret
end

function Root:layoutChildren()
    -- TODO: make rendering respect layers
    --for _,widget in pairs(self.children) do
    if #self.children >= 1 then
        local widget = self.children[1]
        widget.pos = {1,1}
        widget.size = {self.size[1],self.size[2]}
    end
    --end
end

function Root:render()
    term.setBackgroundColor(self.backgroundColor)
    term.clear()
end

-- Shows the GUI and runs its event loop.
function Root:mainLoop()
    self:show()
    while true do
        evt = {os.pullEventRaw()}
        self:onEvent(evt)
        if evt[1] == "terminate" then
            break
        end
    end
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.setCursorPos(1,1)
    term.clear()
end

return Root
