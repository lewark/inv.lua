require 'inv_server'

local function getName()
    for _, side in pairs({"top","bottom","left","right","front","back"}) do
        if peripheral.getType(side) == "modem" then
            return peripheral.wrap(side).getNameLocal()
        end
    end
    return nil
end

local server = InvServer:new()