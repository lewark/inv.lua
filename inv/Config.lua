-- Provides methods for loading and parsing configuration files.
local Config = {}

-- Converts a path relative to the source directory into an absolute path.
function Config.convertPath(path)
    return shell.dir() .. "/" .. path
end

-- Reads and parses a JSON file, returning its contents as a table.
function Config.loadJSON(filename)
    local file = io.open(filename, "r")
    local data = file:read("*all")
    local config = textutils.unserialiseJSON(data)
    file:close()
    return config
end

-- Loads a directory of JSON files.
-- Each file is expected to contain either a single JSON object or an array of
-- JSON objects. Each JSON object is appended to a table, which is returned.
function Config.loadDirectory(directory)
    local path = Config.convertPath(directory)
    local filenames = fs.list(path)
    local entries = {}
    for i, filename in ipairs(filenames) do
        local config = Config.loadJSON(path .. "/" .. filename)
        if config[1] then
            -- file contains a list of entries
            for j, entry in ipairs(config) do
                table.insert(entries, entry)
            end
        elseif next(config) then
            -- file contains a single entry
            table.insert(entries, config)
        end
    end
    return entries
end

return Config