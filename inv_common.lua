local common = {}

common.PROTOCOL = "inv"

function common.getModemSide()
    for _, side in pairs({"top","bottom","left","right","front","back"}) do
        if peripheral.getType(side) == "modem" and peripheral.wrap(side).getNameLocal then
            return side --peripheral.wrap(side)
        end
    end
    return nil
end

function common.getModem()
    return peripheral.wrap(common.getModemSide())
end

function common.getNameLocal()
    return common.getModem().getNameLocal()
end

function common.shallowCopy(tab)
    o = {}
    for k,v in pairs(tab) do
        o[k] = v
    end
    return o
end

-- Warning: Will explode with recursive table.
function common.deepCopy(tab)
    local o = {}
    for k,v in pairs(tab) do
        if type(v) == "table" then
            o[k] = common.deepCopy(v)
        else
            o[k] = v
        end
    end
    return o
end

function common.loadJSON(path)
    local file = io.open(shell.dir().."/"..path,"r")
    local data = file:read("*all")
    local config = textutils.unserialiseJSON(data)
    file:close()
    return config
end

return common