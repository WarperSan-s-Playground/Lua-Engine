require("source.utils.Raw");
require("source.backend.Conductor");

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

function OnUpdate()
    UpdateMusic();
end