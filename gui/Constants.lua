local Constants = {}

-- List of events that should only be passed to the topmost widget directly
-- under the mouse cursor (clicking, scrolling)
Constants.TOP_EVENTS = {
    ["mouse_click"] = true,
    ["mouse_scroll"] = true,
}

-- List of events that should be passed to the currently focused widget
-- (e.g. keyboard events)
Constants.FOCUS_EVENTS = {
    ["mouse_up"] = true,
    ["mouse_drag"] = true,
    ["char"] = true,
    ["key"] = true,
    ["key_up"] = true,
    ["paste"] = true,
}

-- Various special characters provided by ComputerCraft:
--
-- MINIMIZE, MAXIMIZE, STRIPES, TRI_RIGHT, TRI_LEFT, TRI_UP, TRI_DOWN,
-- ARROW_UP, ARROW_DOWN, ARROW_RIGHT, ARROW_LEFT, ARROW_LR, ARROW_UD
Constants.SpecialChars = {
    MINIMIZE=22,MAXIMIZE=23,STRIPES=127,
    TRI_RIGHT=16,TRI_LEFT=17,TRI_UP=30,TRI_DOWN=31,
    ARROW_UP=24,ARROW_DOWN=25,ARROW_RIGHT=26,ARROW_LEFT=27,ARROW_LR=29,ARROW_UD=18
}

-- Enum used to specify layouts within LinearContainers.
-- - LinearAxis.HORIZONTAL: X axis
-- - LinearAxis.VERTICAL: Y axis
Constants.LinearAxis = {HORIZONTAL=1,VERTICAL=2}

-- Enum used to specify layouts within LinearContainers.
-- - LinearAxis.CENTER: center the widget within its cell
-- - LinearAxis.START: align the widget to the top (HORIZONTAL container) or left (VERTICAL) of its cell
-- - LinearAxis.END: align the widget to the bottom (HORIZONTAL container) or right (VERTICAL) of its cell
Constants.LinearAlign = {CENTER=0,START=1,END=2}

-- Currently unused.
-- Constants.BoxAlign = {CENTER=0,TOP=1,BOTTOM=2,LEFT=3,RIGHT=4}

return Constants
