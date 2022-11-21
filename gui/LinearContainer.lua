local expect = require "cc.expect"
local Constants = require "gui.Constants"
local Container = require "gui.Container"

-- Container that arranges child widgets in a horizontal or vertical line.
-- Padding at the edges and spacing between widgets can be specified.
-- Child widgets may be set to fill the primary and/or secondary axes of the container.
-- If multiple widgets are set to fill the primary axis, then the free space
-- will be evenly distributed between them.
local LinearContainer = Container:subclass()

-- LinearContainer constructor.
--
-- Parameters:
-- - root (Root): The root widget
-- - axis (LinearAxis): The primary axis of this container (HORIZONAL or VERTICAL).
-- - spacing (int): Spacing between contained gui.
-- - padding (int): Padding between the first/last widgets and the container's edge.
function LinearContainer:init(root,axis,spacing,padding)
    expect(1, root, "table")
    expect(2, axis, "number")
    expect(3, spacing, "number")
    expect(4, padding, "number")
    LinearContainer.superClass.init(self,root)
    self.axis = axis
    self.spacing = spacing
    self.padding = padding
end

-- Adds a widget to the LinearContainer
--
-- Parameters:
-- - child (Widget): the widget to add
-- - fillPrimary (bool): whether the widget should fill the main axis specified in the constructor
-- - fillSecondary (bool): whether the widget should fill the other axis perpendicular to the primary one
-- - align (LinearAlign): whether the widget should be centered, left-aligned, or right-aligned
function LinearContainer:addChild(child,fillPrimary,fillSecondary,align)
    expect(1, child, "table")
    expect(2, fillPrimary, "boolean")
    expect(3, fillSecondary, "boolean")
    expect(4, align, "number")
    LinearContainer.superClass.addChild(self,child)
    child.layout.fillPrimary = fillPrimary
    child.layout.fillSecondary = fillSecondary
    child.layout.align = align
end

function LinearContainer:getSecondaryAxis()
    if self.axis == Constants.LinearAxis.HORIZONTAL then
        return Constants.LinearAxis.VERTICAL
    end
    return Constants.LinearAxis.HORIZONTAL
end

function LinearContainer:getPreferredSize()
    local axis2 = self:getSecondaryAxis()

    local prefSize = {self.padding * 2,self.padding * 2}
    for i=1,#self.children do
        local child = self.children[i]
        local c_prefSize = child:getPreferredSize()
        prefSize[axis2] = math.max(prefSize[axis2],c_prefSize[axis2] + self.padding * 2)
        prefSize[self.axis] = prefSize[self.axis] + c_prefSize[self.axis]
        if i ~= #self.children then
            prefSize[self.axis] = prefSize[self.axis] + self.spacing
        end
    end

    return prefSize
end

function LinearContainer:layoutChildren()
    local axis2 = self:getSecondaryAxis()

    local space_free = self.size[self.axis] - self.padding * 2
    local childrenFill = 0
    local preferred_sizes = {}

    for i=1,#self.children do
        local child = self.children[i]
        local prefSize = child:getPreferredSize()
        table.insert(preferred_sizes, prefSize)

        if child.layout.fillPrimary then
            childrenFill = childrenFill + 1
        else
            space_free = space_free - prefSize[self.axis]
        end
        if i ~= #self.children then
            space_free = space_free - self.spacing
        end
    end

    local currentPos = self.pos[self.axis] + self.padding
    local fillCount = 0

    for i=1,#self.children do
        local child = self.children[i]
        local size = 0
        local prefSize = preferred_sizes[i]

        if child.layout.fillPrimary then
            fillCount = fillCount + 1

            size = math.max((math.floor(space_free * fillCount / childrenFill)
                - math.floor(space_free * (fillCount-1) / childrenFill)),0)
        else
            size = prefSize[self.axis]
        end

        child.pos[self.axis] = currentPos
        child.size[self.axis] = size

        local cell_size = self.size[axis2] - self.padding * 2

        if child.layout.fillSecondary then
            child.size[axis2] = cell_size
        else
            child.size[axis2] = math.min(prefSize[axis2],cell_size)
        end

        if child.layout.align == Constants.LinearAlign.CENTER then
            child.pos[axis2] = self.pos[axis2]+self.padding+math.floor((cell_size-child.size[axis2])/2)
        elseif child.layout.align == Constants.LinearAlign.START then
            child.pos[axis2] = self.pos[axis2]+self.padding
        elseif child.layout.align == Constants.LinearAlign.END then
            child.pos[axis2] = self.pos[axis2]+self.size[axis2]-self.padding-child.size[axis2]
        end

        currentPos = currentPos + size + self.spacing
    end
end

return LinearContainer
