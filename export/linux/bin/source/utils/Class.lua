local function OnKeyChanged(table, key, value)
    local method;

    -- If field is private, skip
    if (string.sub(key, 1, 2) == '__') then
        goto set_value;
    end

    -- If table not initialized, skip
    if (not table.__initialized) then
        goto set_value;
    end

    -- Apply through setter
    method = table['set_' .. key];

    if (method ~= nil and value ~= nil) then
        value = method(table, value);
    end

    -- Mark value as dirty
    table.__dirtyFields[key] = value;

    -- Remove value
    value = nil;

    ::set_value::
    rawset(table, key, value);
end

function CreateClass(type, parentType)
    local class = nil;
    local parent = nil;

    -- Find parent
    if (parentType ~= nil) then
        parent = require(tostring(parentType));
    end

    if (parent ~= nil) then
        -- Create from parent
        class = setmetatable({}, parent);
    else
        -- Create from nothing
        class = {};
    end

    class.__index = class;
    class.__type = tostring(type); -- Set type for reference
    class.__initialized = false;
    class.__dirtyFields = {};
    class.__newindex = OnKeyChanged;

    return class;
end
