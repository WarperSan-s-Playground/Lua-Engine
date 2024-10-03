require("source/backend/Conductor");

-- Load first
local loadMSG = fromJSON("../gfDanceTitle.json");
local data = loadMSG.value;
setShared("TITLE_DATA", data);

function OnCreate()
    -- Add children
    addScript("gfTitle.lua");
    addScript("logoTitle.lua");
    addScript("titleEnter.lua");

    -- Set Music
    playMusic("../Music/freakyMenu.ogg");
    Conductor.setBPM(data.bpm);
    callMethod("OnBeat");
end

function OnDestroy()
    closeScript("gfTitle.lua");
    closeScript("logoTitle.lua");
    closeScript("titleEnter.lua");
end

require("source/backend/Conductor");

function OnUpdate(elapsed)
    UpdateMusic();
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
        if (curStep % 4 == 0) then
            trace("BEAT HIT");
            callMethod("OnBeat");
        end
    end
end

function UpdateStep()
    local songPosition = Raw.get("flixel.FlxG", "sound.music.time");
    local lastChange = Conductor.getBPMFromSeconds(songPosition);

    local shit = (songPosition - lastChange.songTime) / lastChange.stepCrochet;
    curStep = lastChange.stepTime + math.floor(shit);
end

function UpdateBeat()
    curBeat = math.floor(curStep / 4);
end
