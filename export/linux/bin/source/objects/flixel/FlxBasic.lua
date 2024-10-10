require("source.utils.Class");

FlxBasic = CreateClass("flixel.FlxBasic");

---Creates a new instance of FlxBasic
function FlxBasic:new(...)
    local basic = setmetatable({}, self);

    -- Create object
    basic.ID = Raw.create(self.__type, ...);
    basic.__type = self.__type;
    basic.__dirtyFields = {};
    basic.__initialized = true;

    return basic;
end

---Destroys this instance
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

--#region Dirty

local function setValues(obj, values)
    for key, _ in pairs(values) do
        rawset(
            obj,
            key,
            values[key]
        );
    end
end

---Submits the changes to the engine
function FlxBasic:submit()
    -- If nothing to submit, skip
    if (next(self.__dirtyFields) == nil) then
        warn('Tried to submit changes of an object that has no changes.');
        return;
    end

    submitChanges(self.ID, self.__dirtyFields);
    setValues(self, self.__dirtyFields);

    -- Clear dirty fields
    self.__dirtyFields = {};
end

---Requests the engine to return the desired values
---@param onlyDirty boolean Only update the values marked as dirty
function FlxBasic:request(onlyDirty)
    onlyDirty = onlyDirty ~= false; -- True by default

    local valuesToUpdate = {};

    -- Add dirty fields
    for key, _ in pairs(self.__dirtyFields) do
        valuesToUpdate[#valuesToUpdate + 1] = key;
    end

    -- Add all fields
    if (not onlyDirty) then
        for key, _ in pairs(self) do
            -- Add public fields
            if (string.sub(key, 1, 2) ~= '__') then
                valuesToUpdate[#valuesToUpdate + 1] = key;
            end
        end
    end

    local updatedValues = getChanges(self.ID, valuesToUpdate).value;

    -- Set updated values
    setValues(self, updatedValues);

    -- Clear dirty fields
    self.__dirtyFields = {};
end

--#endregion

return FlxBasic;
