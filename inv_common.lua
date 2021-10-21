PROTOCOL = "inv"

function getModemSide()
    for _, side in pairs({"top","bottom","left","right","front","back"}) do
        if peripheral.getType(side) == "modem" then
            return side --peripheral.wrap(side)
        end
    end
    return nil
end

function getModem()
    return peripheral.wrap(getModemSide())
end

function getNameLocal()
    return getModem().getNameLocal()
end

function shallowCopy(tab)
    o = {}
    for k,v in pairs(tab) do
        o[k] = v
    end
    return o
end

-- Warning: Will explode with recursive table.
function deepCopy(tab)
    local o = {}
    for k,v in pairs(tab) do
        if type(v) == "table" then
            o[k] = deepCopy(v)
        else
            o[k] = v
        end
    end
    return o
end