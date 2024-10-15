require("source.utils.Raw");
require("source.utils.Color");
importFile("SpriteBuiltIn");

require("source.objects.flixel.FlxObject");
FlxSprite = CreateClass("flixel.FlxSprite", "source.objects.flixel.FlxObject");

---Creates a new sprite
function FlxSprite:new(x, y)
    local sprite = FlxObject.new(self, x, y);

    sprite.__initialized = false;

    -- Create
    sprite.alpha = 1;
    sprite.color = 0xFFFFFF;

    sprite.__initialized = true;

    return sprite;
end

--#region Graphics

---Loads the given image to this sprite
---@param path string Image to load from
---@param xml ?string XML file to load frames from
function FlxSprite:loadGraphic(path, xml)
    path = tostring(path);

    if (xml ~= nil) then
        xml = tostring(xml);
    end

    loadGraphic(self.ID, path, xml);

    self.width = nil;
    self.width = -1;
    self.height = nil;
    self.height = -1;
    self:request();
end

---Makes a graphic for this sprite
---@param width number Width of the graphic
---@param height number Height of the graphic
---@param color number|string Color of the graphic
function FlxSprite:makeGraphic(width, height, color)
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

    -- Parse color + add alpha
    color = Color.parseColor(color);

    -- Make graphic
    self:call("makeGraphic", width, height, color);
end

--#endregion

--#region Animations

---Adds an animation with the given prefix
---@param name string Name of the animation
---@param prefix string Prefix of the animation
---@param frameRate integer Frame rate of the animation
---@param looped boolean Whether or not the animation is looped or just plays once
function FlxSprite:addByPrefix(name, prefix, frameRate, looped)
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
function FlxSprite:addByIndices(name, prefix, indices, frameRate, looped)
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
function FlxSprite:playAnimation(name, force)
    if (not force) then
        local anim = self:get("animation.curAnim");

        if (anim ~= nil) then
            return;
        end
    end

    self:call("animation.play", name, force);
end

--#endregion

--#region Setters

function FlxSprite:set_alpha(alpha)
    alpha = tonumber(alpha);

    if (alpha == nil) then
        return self.alpha;
    end

    -- Keep it between 0 and 1
    if (alpha > 1) then
        alpha = 1;
    elseif (alpha < 0) then
        alpha = 0;
    end

    return alpha;
end

--#endregion

return FlxSprite;
