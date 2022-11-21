local Utility = {}

function Utility.startswith(str,substr)
    return string.sub(str,1,#substr) == substr
end

function Utility.contains(tbl,val)
    for k,v in pairs(tbl) do
        if v == val then return true end
    end
    return false
end

return Utility
