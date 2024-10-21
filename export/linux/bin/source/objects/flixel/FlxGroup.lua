require("source.utils.Raw");

FlxSprite = require("source.objects.flixel.FlxSprite");
FlxGroup = setmetatable({}, FlxSprite);
FlxGroup.__index = FlxGroup;
FlxGroup.__type = "flixel.group.FlxTypedGroup";

function FlxGroup:new(x, y)
    local group = FlxSprite.new(self, x, y);

    group.__initialized = false;

    -- Create
    group.__members = {};

    group.__initialized = true;

    return group;
end

---Adds the given object to this group
---@param obj table Instance of a FlxBasic
function FlxGroup:add(obj, keepPosition)
    -- If already present, skip
    for _, value in ipairs(self.__members) do
        if (value == obj) then
            return obj;
        end
    end

    -- Find the first null value and place it there
    for i, value in ipairs(self.__members) do
        if (value == nil) then
            self.members[i] = obj;
            return obj;
        end
    end

    if (not keepPosition) then
        local x = obj.x;
        local y = obj.y;
        obj.x = nil;
        obj.x = self.x + x;
        obj.y = nil;
        obj.y = self.y + y;
        obj:submit();
    end

    -- Add to end of array
    addToGroup(self.ID, obj.ID);
    self.__members[#self.__members + 1] = obj;
    return obj;
end

---Removes the given object from this group
---@param obj table Instance of a FlxBasic
function FlxGroup:remove(obj)
    for i, value in ipairs(self.__members) do
        if (value == obj) then
            removeFromGroup(self.ID, obj.ID);
            self.__members[i] = nil;
            return;
        end
    end
end

function FlxGroup:getMembers()
    return self.__members;
end

return FlxGroup;
