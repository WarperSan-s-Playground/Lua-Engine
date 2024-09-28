Raw = {};

-- Calls `callRaw` in the correct format
function Raw.call(class, name, ...)
    return callRaw(class .. ':' .. name, { ... }).value;
end

-- Calls `setRaw` in the correct format
function Raw.set(class, name, id, value)
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

    return setRaw(path, value).value;
end