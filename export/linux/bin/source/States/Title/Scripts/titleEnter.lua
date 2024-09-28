package.path = package.path .. ";./source/utils/?.lua"
local colorUtils = require("Colors");
local rawUtils = require("Raw");

local data = getShared("TITLE_DATA").value;

function OnCreate()
    LoadTitleEnter();
end

local PRESSED_ENTER = false;

function OnUpdate(elapsed)
    UpdateTimer(elapsed);
end

--[[ TIMER ]]
local timer = 0;

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

--[[ TITLE ENTER ]]
local ID = -1;
local ALPHAS = { 1, 0.64 };
local COLORS = { 0x33FFFF, 0x3333CC };

-- Loads the title graphic and animations
function LoadTitleEnter()
    ID = makeSprite(
        data["startX"],
        data["startY"]
    ).value;

    loadGraphic(ID, "../Images/titleEnter.png", "../XML/titleEnter.xml");
    addAnimationByPrefix(ID, "idle", "ENTER IDLE", 24, true);
    addAnimationByPrefix(ID, "press", "ENTER PRESSED", 24, true);
end

-- Updates the color and alpha of the title
function UpdateTitle(value)
    if (value >= 1) then
        value = 2 - value;
    end

    -- Ease the value
    value = rawUtils.call("flixel.tweens.FlxEase", "quadInOut", value);

    -- Set alpha
    local alpha = rawUtils.call("flixel.math.FlxMath", "lerp", ALPHAS[1], ALPHAS[2], value);
    rawUtils.set('flixel.FlxSprite', 'alpha', ID, alpha);

    -- Set color
    local color = colorUtils.interpolate(COLORS[1], COLORS[2], value);
    rawUtils.set('flixel.FlxSprite', 'color', ID, color);
end
