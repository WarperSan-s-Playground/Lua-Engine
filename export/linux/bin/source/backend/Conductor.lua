require("source/utils/Raw");

--[[ Conductor ]]
Conductor = {};

local BPM_KEY = "backend.Conductor.BPM";
local CROCHET_KEY = "backend.Conductor.CROCHET";
local STEP_CROCHET_KEY = "backend.Conductor.STEP_CROCHET";
local BPM_CHANGE_MAP_KEY = "backend.Conductor.BpmChangeMap";
setGlobal(BPM_CHANGE_MAP_KEY, {}, true);

function Conductor.getBPMFromSeconds(time)
    local lastChange = {
        stepTime = 0,
        songTime = 0,
        bpm = getGlobal(BPM_KEY).value or 0,
        stepCrochet = getGlobal(STEP_CROCHET_KEY).value or 0,
    };

    time = tonumber(time);

    -- Check if NaN
    if (time == nil) then
        trace("Tried to get the BPM without giving a time.");
        return lastChange;
    end

    local bpmChangeMap = getGlobal(BPM_CHANGE_MAP_KEY).value or {};

    -- Fetch the last change
    for index, value in ipairs(bpmChangeMap) do
        if (time >= value.songTime) then
            lastChange = value;
        end
    end

    return lastChange;
end

function Conductor.setBPM(bpm)
    bpm = tonumber(bpm);

    -- If bpm not valid, don't change
    if (bpm == nil) then
        trace("Tried to set the BPM to '" .. (bpm or "null") .. "'.");
        return;
    end

    local crochet = 60 / bpm * 1000;
    local stepCrochet = crochet / 4;

    setGlobal(BPM_KEY, bpm, true);
    setGlobal(CROCHET_KEY, crochet, true);
    setGlobal(STEP_CROCHET_KEY, stepCrochet, true);
end

function Conductor.setSongPosition(songPosition)
    songPosition = tonumber(songPosition);

    -- If songPosition not valid, don't change
    if (songPosition == nil) then
        trace("Tried to set the song position to '" .. (songPosition or "null") .. "'.");
        return;
    end

    setGlobal("backend.Conductor.SONG_POSITION", songPosition, true);
end

Conductor.setBPM(100);

-- class Conductor{
-- 	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

-- 	public static function mapBPMChanges(song:SwagSong) {
-- 		bpmChangeMap = [];

-- 		var curBPM:Float = song.bpm;
-- 		var totalSteps:Int = 0;
-- 		var totalPos:Float = 0;
-- 		for (i in 0...song.notes.length) {
-- 			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM) {
-- 				curBPM = song.notes[i].bpm;
-- 				var event:BPMChangeEvent = {
-- 					stepTime: totalSteps,
-- 					songTime: totalPos,
-- 					bpm: curBPM
-- 				};
-- 				bpmChangeMap.push(event);
-- 			}

-- 			var deltaSteps:Int = song.notes[i].lengthInSteps;
-- 			totalSteps += deltaSteps;
-- 			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
-- 		}
-- 		trace("new BPM map BUDDY " + bpmChangeMap);
-- 	}
-- }
