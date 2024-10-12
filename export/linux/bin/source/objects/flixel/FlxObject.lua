require("source.utils.Class");

FlxObject = CreateClass("flixel.FlxObject", "source.objects.flixel.FlxBasic");

function FlxObject:new(x, y, ...)
    local obj = FlxBasic.new(self, ...);

    obj.__initialized = false;

    -- Set valuesToUpdate
    obj.width = 0;
    obj.height = 0;
    obj.x = 0;
    obj.y = 0;

    obj.__initialized = true;

    x = tonumber(x) or 0;
    y = tonumber(y) or 0;

    if (x ~= obj.x or y ~= obj.y) then

        if (x ~= obj.x) then
            obj.x = nil;
            obj.x = x;
        end

        if (y ~= obj.y) then
            obj.y = nil;
            obj.y = y;
        end

        obj:submit();
    end

    return obj;
end

--#region Setters

function FlxObject:set_x(x)
    x = tonumber(x);

    if (x == nil) then
        return self.x;
    end

    return x;
end

function FlxObject:set_y(y)
    y = tonumber(y);

    if (y == nil) then
        return self.y;
    end

    return y;
end

function FlxObject:set_width(width)
    width = tonumber(width);

    if (width == nil) then
        return self.width;
    end

    return width;
end

function FlxObject:set_height(height)
    height = tonumber(height);

    if (height == nil) then
        return self.height;
    end

    return height;
end

--#endregion

return FlxObject;
