-- Define a base class
FlxBasic = {};
FlxBasic.__index = FlxBasic;

function FlxBasic:new(type, ...)
    local basic = setmetatable({}, self);

    -- Create object
    basic.ID = Raw.create(type, ...);

    -- Set values
    basic.__type = type;

    return basic;
end

function FlxBasic:destroy()
    destroyRaw(self.__type, self.ID, false);
end

--#region Raw

function FlxBasic:call(name, ...)
    return Raw.call(self.__type, name, self.ID, ...);
end

function FlxBasic:get(name)
    return Raw.get(self.__type, name, self.ID);
end

function FlxBasic:set(name, value)
    return Raw.set(self.__type, name, self.ID, value);
end

--#endregion

return FlxBasic;
