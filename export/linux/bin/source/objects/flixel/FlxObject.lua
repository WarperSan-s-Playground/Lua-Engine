require("source.utils.Class");

FlxObject = CreateClass("flixel.FlxObject", "source.objects.flixel.FlxBasic");
FlxObject.x = 0;
FlxObject.y = 0;
FlxObject.width = 0;
FlxObject.height = 0;

function FlxObject:new(...)
    return FlxBasic.new(self, ...);
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
