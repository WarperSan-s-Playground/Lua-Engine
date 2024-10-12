require("source.utils.Color");
require("source.utils.Raw");

FlxSprite = require("source.objects.flixel.FlxSprite");

importFile("DataBuiltIn");

local sprite;
local timer = 0;

function OnCreate()
    local data = getShared("TITLE_DATA").value;

    sprite = FlxSprite:new(
        tonumber(data["startX"]),
        tonumber(data["startY"])
    );

    sprite:loadGraphic("../Images/titleEnter.png", "../XML/titleEnter.xml");
    sprite:addByPrefix("idle", "ENTER IDLE", 24, true);
    sprite:addByPrefix("press", "ENTER PRESSED", 24, true);
end

function OnUpdate(elapsed)
    UpdateTimer(elapsed);
end

-- Updates the title timer
function UpdateTimer(elapsed)
    -- Limit between [0; 1]
    if (elapsed > 1) then
        elapsed = 1;
    elseif (elapsed < 0) then
        elapsed = 0;
    end

    -- Increase timer
    timer = timer + elapsed;

    if (timer > 2) then
        timer = timer - 2;
    end

    UpdateTitle(timer);
end

-- Updates the color and alpha of the title
function UpdateTitle(value)
    if (value >= 1) then
        value = 2 - value;
    end

    -- Ease the value
    value = Raw.call("flixel.tweens.FlxEase", "quadInOut", nil, value);

    -- Set values
    sprite.alpha = nil;
    sprite.alpha = Raw.call("flixel.math.FlxMath", "lerp", nil, 1, 0.64, value);

    sprite.color = nil;
    sprite.color = Color.interpolate(0xFF33FFFF, 0xFF3333CC, value);
    sprite:submit();
end
