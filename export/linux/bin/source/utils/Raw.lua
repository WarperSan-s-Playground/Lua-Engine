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

-- Calls `callRaw` in the correct format
function Raw.call(class, name, id, ...)
    local path = FormatPath(class, name, id);
    return callRaw(path, { ... }).value;
end

-- Calls `setRaw` in the correct format
function Raw.set(class, name, id, value)
    local path = FormatPath(class, name, id);
    return setRaw(path, value).value;
end

-- Calls `getRaw` in the correct format
function Raw.get(class, name, id)
    local path = FormatPath(class, name, id);
    return getRaw(path).value;
end
