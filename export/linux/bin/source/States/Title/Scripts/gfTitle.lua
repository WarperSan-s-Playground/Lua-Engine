require("source.utils.Raw");
require("source.utils.Animations");

-- Manual imports
importFile("DataBuiltIn");
importFile("SpriteBuiltIn");

local danceLeft = false;
local ID = -1;

local DANCE_RIGHT_INDICES = { 30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 };
local DANCE_LEFT_INDICES = { 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29 };

function OnCreate()
    local data = getShared("TITLE_DATA").value;
    ID = makeSprite(
        data["gfX"],
        data["gfY"]
    ).value;

    loadGraphic(ID, "../Images/gfDanceTitle.png", "../XML/gfDanceTitle.xml");
    Animations.addByIndices(ID, "danceRight", "gfDance", DANCE_RIGHT_INDICES, 24, false);
    Animations.addByIndices(ID, "danceLeft", "gfDance", DANCE_LEFT_INDICES, 24, false);
end

function OnBeat()
    danceLeft = not danceLeft;
    local anim = '';

    if danceLeft then
        anim = 'danceRight';
    else
        anim = 'danceLeft';
    end

    Raw.call("flixel.FlxSprite", "animation.play", ID, anim);
end

function OnDestroy()
    removeSprite(ID);
end
