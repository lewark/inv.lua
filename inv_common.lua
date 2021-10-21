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