local expect = require "cc.expect"

-- Creates an instance of a class, and then calls the class's init() method
-- with the provided arguments.
local function new(self, ...)
    local instance = setmetatable({},{__index=self})
    instance.class = self
    ret, msg = pcall(instance.init, instance, ...)
    if not ret then
        error(msg, 2) -- propagate error up to caller
    end
    return instance
end

-- Implements basic inheritance features.
local Object = {}

setmetatable(Object, {__call=new})

-- Object constructor.
--
-- To create an instance of an Object, call Object(args), which will instantiate
-- the class and then call the Object's constructor to set up the instance.
-- The process works the same way for subclasses: just replace Object with the
-- name of the class you are instantiating.
--
-- Internally, the constructor is named Object:init(...). Override this init
-- method to specify initialization behavior for an Object subclass. An object's
-- init() method may call its super class's init() if desired
-- (use ClassName.superClass.init(self,...))
function Object:init(...) end

-- Creates a subclass of an existing class.
function Object:subclass()
    return setmetatable({superClass=self},{__index=self,__call=new})
end

-- Returns true if the Object is an instance of the provided class or a subclass.
function Object:instanceof(class)
    expect(1, class, "table")
    local c = self.class
    while c ~= nil do
        if c == class then
            return true
        end
        c = c.superClass
    end
    return false
end

return Object
