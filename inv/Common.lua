local Common = {}

Common.PROTOCOL = "inv"

Common.SIDES = {"top","bottom","left","right","front","back"}

function Common.getModemSide()
    for i, side in ipairs(Common.SIDES) do
        if peripheral.getType(side) == "modem" and peripheral.wrap(side).getNameLocal then
            return side --peripheral.wrap(side)
        end
    end
    return nil
end

function Common.getModem()
    return peripheral.wrap(Common.getModemSide())
end

function Common.getNameLocal()
    return Common.getModem().getNameLocal()
end

function Common.shallowCopy(tab)
    o = {}
    for k,v in pairs(tab) do
        o[k] = v
    end
    return o
end

-- Warning: Will explode with recursive table.
function Common.deepCopy(tab)
    local o = {}
    for k,v in pairs(tab) do
        if type(v) == "table" then
            o[k] = Common.deepCopy(v)
        else
            o[k] = v
        end
    end
    return o
end

function Common.loadJSON(path)
    local file = io.open(shell.dir().."/"..path,"r")
    local data = file:read("*all")
    local config = textutils.unserialiseJSON(data)
    file:close()
    return config
end

function Common.removeItem(t, item)
    for i=1,#t do
        if t[i] == item then
            table.remove(t, i)
            return
        end
    end
end

function Common.integerKeys(t)
    local x = {}
    for k, v in t do
        x[tonumber(k)] = v
    end
    return x
end

return Common
