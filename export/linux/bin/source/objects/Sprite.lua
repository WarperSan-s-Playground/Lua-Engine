require("source.utils.Raw");
importFile("SpriteBuiltIn");

FlxObject = require("source.objects.flixel.FlxObject");
Sprite = setmetatable({}, FlxObject);
Sprite.__index = Sprite;

---Creates a new sprite
---@param x number X Position
---@param y number Y Position
function Sprite:new(x, y)
    local sprite = FlxObject.new(self, "flixel.FlxSprite");

    -- Create
    sprite:setPosition(
        tonumber(x) or 0,
        tonumber(y) or 0
    );
    sprite._alpha = 1;
    sprite._color = 0xFFFFFF;

    return sprite;
end

--#region Graphics

---Loads the given image to this sprite
---@param path string Image to load from
---@param xml ?string XML file to load frames from
function Sprite:loadGraphic(path, xml)
    path = tostring(path);
    xml = tostring(xml);

    loadGraphic(self.ID, path, xml);
end

---Makes a graphic for this sprite
---@param width number Width of the graphic
---@param height number Height of the graphic
---@param color number|string Color of the graphic
function Sprite:makeGraphic(width, height, color)
    -- Parse width
    width = tonumber(width) or 0;

    if (width < 0) then
        width = 0;
    end

    -- Parse height
    height = tonumber(height) or 0;

    if (height < 0) then
        height = 0;
    end

    -- Parse color
    color = color or 'white'; --Raw.call("flixel.util.FlxColor", "fromString", nil, color or "#FFFFFF");

    -- Make graphic
    makeGraphic(self.ID, width, height, color);
end

--#endregion

--#region Properties

---Sets the alpha of this sprite
---@param alpha number Alpha value
function Sprite:setAlpha(alpha)
    -- If NaN, skip
    if (tonumber(alpha) == nil) then
        return;
    end

    -- Keep it between 0 and 1
    if (alpha > 1) then
        alpha = 1;
    elseif (alpha < 0) then
        alpha = 0;
    end

    self:set('alpha', alpha);
    self._alpha = alpha;
end

---Sets the color of this sprite
---@param color number Color of this sprite in HEX in the format ARGB
function Sprite:setColor(color)
    self:set('color', color);
    self._color = color;
end

--#endregion

--#region Animations

---Adds an animation with the given prefix
---@param name string Name of the animation
---@param prefix string Prefix of the animation
---@param frameRate integer Frame rate of the animation
---@param looped boolean Whether or not the animation is looped or just plays once
function Sprite:addByPrefix(name, prefix, frameRate, looped)
    -- Default values
    name = tostring(name or "anim");
    prefix = tostring(prefix or "anim");
    frameRate = tonumber(frameRate) or 24;
    looped = looped ~= false;

    -- Calls
    self:call(
        "animation.addByPrefix",
        name,
        prefix,
        frameRate,
        looped
    );

    self:playAnimation(name, false);
end

---Adds an animation with the given indices
---@param name string Name of the animation
---@param prefix string Prefix of the animation
---@param indices table Indices of the animation
---@param frameRate integer Frame rate of the animation
---@param looped boolean Whether or not the animation is looped or just plays once
function Sprite:addByIndices(name, prefix, indices, frameRate, looped)
    -- Default values
    name = tostring(name or "anim");
    prefix = tostring(prefix or "anim");
    if (type(indices) ~= "table") then
        indices = {};
    end
    frameRate = tonumber(frameRate) or 24;
    looped = looped ~= false;

    -- Calls
    self:call(
        "animation.addByIndices",
        name,
        prefix,
        indices,
        "",
        frameRate,
        looped
    );

    self:playAnimation(name, false);
end

---Plays the animation with the given name
---@param name string Name of the animation
---@param force boolean Force the animation to play
function Sprite:playAnimation(name, force)
    if (not force) then
        local anim = self:get("animation.curAnim");

        if (anim ~= nil) then
            return;
        end
    end

    self:call("animation.play", name, force);
end

--#endregion

return Sprite;
