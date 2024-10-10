require("source.utils.Raw");

FlxBasic = require("source.objects.flixel.FlxBasic");
FlxObject = setmetatable({}, FlxBasic);
FlxObject.__index = FlxObject;

function FlxObject:new(...)
    self.__type = self.__type or 'flixel.FlxObject';
    local obj = FlxBasic.new(self, ...);

    -- Create
    obj.width = 0;
    obj.height = 0;
    obj.x = 0;
    obj.y = 0;

    return obj;
end

---Sets the position of this object
---@param x ?number X position of this object
---@param y ?number Y position of this object
function FlxObject:setPosition(x, y)
    x = tonumber(x) or self.x or 0;
    y = tonumber(y) or self.y or 0;

    if (x ~= self.x) then
        self:set("x", x);
        self.x = x;
    end

    if (y ~= self.y) then
        self:set("y", y);
        self.y = y;
    end
end

---Sets the size of this object
---@param width ?number Width of this object's hitbox
---@param height ?number Height of this object's hitbox
function FlxObject:setSize(width, height)
    width = tonumber(width) or self.width or 0;
    height = tonumber(height) or self.height or 0;

    if (width ~= self.width) then
        self:set("width", width);
        self.width = width;
    end

    if (height ~= self.height) then
        self:set("height", height);
        self.height = height;
    end
end

return FlxObject;