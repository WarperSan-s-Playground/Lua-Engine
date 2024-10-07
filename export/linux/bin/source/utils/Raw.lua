importFile("RawBuiltIn");

Raw = {};

function FormatPath(class, name, id)
    local path = '';

    if (id ~= nil) then
        class = class .. '{' .. id .. '}';
    end

    if (class ~= nil) then
        path = path .. class .. ':';
    end

    if (name ~= nil) then
        path = path .. name;
    end

    return path;
end

---Calls `getRaw()` with the correct format
---@param class string Full name of the class
---@param name string Path to the value to get
---@param id nil|integer ID of the object to get (optional)
---@return any value Value fetched
function Raw.get(class, name, id)
    local path = FormatPath(class, name, id);
    local getMessage = getRaw(path);

    if (getMessage.isError) then
        error("Error while getting '" .. path .. "': " .. getMessage.message);
    end

    return getMessage.value;
end

---Calls `setRaw()` with the correct format
---@param class string Full name of the class
---@param name string Path to the value to get
---@param id nil|integer ID of the object to get (optional)
---@param value any Value to set to
function Raw.set(class, name, id, value)
    local path = FormatPath(class, name, id);
    local setMessage = setRaw(path, value);

    if (setMessage.isError) then
        error("Error while setting '" .. path .. "': " .. setMessage.message);
    end
end

--- Calls `callRaw()` with the correct format
---@param class string Full name of the class
---@param name string Path to the value to get
---@param id nil|integer ID of the object to get (optional)
---@param ... any Arguments of the call
---@return any value Return value
function Raw.call(class, name, id, ...)
    local path = FormatPath(class, name, id);
    local callMessage = callRaw(path, { ... });

    if (callMessage.isError) then
        error("Error while calling '" .. path .. "': " .. callMessage.message);
    end

    return callMessage.value;
end
