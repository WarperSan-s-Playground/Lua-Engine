require("source/utils/Colors");
require("source/utils/Raw");
require("source/backend/Conductor");

local data = getShared("TITLE_DATA").value;

function OnCreate()
    LoadTitleEnter();
end

function OnUpdate(elapsed)
    UpdateTimer(elapsed);
    UpdateMusic();
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
    value = Raw.call("flixel.tweens.FlxEase", "quadInOut", value);

    -- Set alpha
    local alpha = Raw.call("flixel.math.FlxMath", "lerp", ALPHAS[1], ALPHAS[2], value);
    Raw.set('flixel.FlxSprite', 'alpha', ID, alpha);

    -- Set color
    local color = Colors.interpolate(COLORS[1], COLORS[2], value);
    Raw.set('flixel.FlxSprite', 'color', ID, color);
end

local curBeat = 0;
local curStep = 0;

function UpdateMusic()

    local oldStep = curStep;
    UpdateStep();
    UpdateBeat();

    -- If step didn't change, skip
    if (oldStep == curStep) then
        return;
    end

    if (curStep > 0) then
        trace("STEP HIT");
    end
end

function UpdateBeat()
    curBeat = math.floor(curStep / 4);
end

function UpdateStep()
    local songPosition = 0;
    local lastChange = Conductor:getBPMFromSeconds(songPosition);

    local shit = (songPosition - lastChange.songTime) / lastChange.stepCrochet;
    curStep = lastChange.stepTime + math.floor(shit);
end