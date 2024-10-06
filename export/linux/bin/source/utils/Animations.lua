require("source.utils.Raw");

Animations = {};

---Plays the given animation if no animation is being played
---@param id number Object to check
---@param name string Name of the animation
function AnimationAdded(id, name)
    id = tonumber(id) or -1;
    name = tostring(name or "anim");

    local anim = Raw.get("flixel.FlxSprite", "animation.curAnim", id);

    if (anim == nil) then
        Raw.call("flixel.FlxSprite", "animation.play", id, name);
    end
end

---Adds an animation with the given prefix
---@param id number Object to add to
---@param name string Name of the animation
---@param prefix string Prefix of the animation
---@param frameRate number Frame rate of the animation
---@param looped boolean Whether or not the animation is looped or just plays once
function Animations.addByPrefix(id, name, prefix, frameRate, looped)
    -- Default values
    id = tonumber(id) or -1;
    name = tostring(name or "anim");
    prefix = tostring(prefix or "anim");
    frameRate = tonumber(frameRate) or 24;
    looped = looped ~= false;

    -- Calls
    Raw.call(
        "flixel.FlxSprite",
        "animation.addByPrefix",
        id,
        name,
        prefix,
        frameRate,
        looped
    );

    AnimationAdded(id, name);
end

---Adds an animation with the given indices
---@param id number Object to add to
---@param name string Name of the animation
---@param prefix string Prefix of the animation
---@param indices table Indices of the animation
---@param frameRate number Frame rate of the animation
---@param looped boolean Whether or not the animation is looped or just plays once
function Animations.addByIndices(id, name, prefix, indices, frameRate, looped)
    -- Default values
    id = tonumber(id) or -1;
    name = tostring(name or "anim");
    prefix = tostring(prefix or "anim");
    if (type(indices) ~= "table") then
        indices = {};
    end
    frameRate = tonumber(frameRate) or 24;
    looped = looped ~= false;

    -- Calls
    Raw.call(
        "flixel.FlxSprite",
        "animation.addByIndices",
        id,
        name,
        prefix,
        indices,
        "",
        frameRate,
        looped
    );

    AnimationAdded(id, name);
end
