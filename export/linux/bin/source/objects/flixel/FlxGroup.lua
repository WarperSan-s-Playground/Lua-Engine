require("source.utils.Raw");
importFile("GroupBuiltIn");

FlxSprite = require("source.objects.flixel.FlxSprite");
FlxGroup = setmetatable({}, FlxSprite);
FlxGroup.__index = FlxGroup;
FlxGroup.__type = "flixel.group.FlxTypedGroup";

function FlxGroup:new()
    local group = FlxSprite.new(self);

    group.__initialized = false;

    -- Create
    group.members = {};

    group.__initialized = true;

    return group;
end

---Adds the given object to this group
---@param obj table Instance of a FlxBasic
function FlxGroup:add(obj)
    -- If already present, skip
    for _, value in ipairs(self.members) do
        if (value == obj) then
            return obj;
        end
    end

    -- Find the first null value and place it there
    for i, value in ipairs(self.members) do
        if (value == nil) then
            self.members[i] = obj;
            return obj;
        end
    end

    -- Add to end of array
    addToGroup(self.ID, obj.ID);
    self.members[#self.members + 1] = obj;
    return obj;
end

---Removes the given object from this group
---@param obj table Instance of a FlxBasic
function FlxGroup:remove(obj)
    -- If invalid argument, error
    if (not IsInstanceOf(obj, FlxBasic)) then
        return;
    end

    for i, value in ipairs(self.members) do
        if (value == obj) then
            removeFromGroup(self.ID, obj.ID);
            self.members[i] = nil;
            return;
        end
    end
end

return FlxGroup;
