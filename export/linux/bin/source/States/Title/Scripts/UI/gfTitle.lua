require("source.utils.Raw");

-- Manual imports
importFile("DataBuiltIn");

local danceLeft = true;
local sprite;

function OnCreate()
    local FlxSprite = require("source.objects.flixel.FlxSprite");
    local data = getShared("TITLE_DATA").value;

    sprite = FlxSprite:new(
        tonumber(data["gfX"]),
        tonumber(data["gfY"])
    );

    sprite:loadGraphic("^/../Images/gfDanceTitle.png", "^/../XML/gfDanceTitle.xml");
    sprite:addByIndices("danceRight", "gfDance", { 30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }, 24, false);
    sprite:addByIndices("danceLeft", "gfDance", { 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29 }, 24, false);
end

function OnBeat()
    danceLeft = not danceLeft;
    local anim = '';

    if danceLeft then
        anim = 'danceRight';
    else
        anim = 'danceLeft';
    end

    sprite:playAnimation(anim, true);
end

function OnDestroy()
    sprite:destroy();
    sprite = nil;
end
