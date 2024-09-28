local rawUtils = {};

-- Calls `callRaw` in the correct format
function rawUtils.call(class, name, ...)
    return callRaw(class .. ':' .. name, { ... }).value;
end

-- Calls `setRaw` in the correct format
function rawUtils.set(class, name, id, value)
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

return rawUtils;