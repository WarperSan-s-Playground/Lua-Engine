package.path = package.path .. ";./source/utils/?.lua"
local colorUtils = require("Colors");

local data = getShared("TITLE_DATA").value;
local msg = makeSprite(
    data["startX"],
    data["startY"]
);

function OnCreate()
    LoadTitleEnter();
end

local PRESSED_ENTER = false;

function OnUpdate(elapsed)
    UpdateTimer(elapsed);
end

--[[ TIMER ]]
local timer = 0;

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

function LoadTitleEnter()
    loadGraphic(msg.value, "../Images/titleEnter.png", "../XML/titleEnter.xml");
    addAnimationByPrefix(msg.value, "idle", "ENTER IDLE", 24, true);

    ID = msg.value;
end

function UpdateTitle(value)
    if (value >= 1) then
        value = 2 - value;
    end

    -- Ease the value
    value = callRaw("flixel.tweens.FlxEase:quadInOut", { value }).value;

    -- Set values
    local alpha = callRaw("flixel.math.FlxMath:lerp", { ALPHAS[1], ALPHAS[2], value }).value;
    setRaw('flixel.FlxSprite{' .. ID .. '}:alpha', alpha);

    local color = colorUtils.interpolate(COLORS[1], COLORS[2], value);
    setRaw('flixel.FlxSprite{' .. ID .. '}:color', color);
end