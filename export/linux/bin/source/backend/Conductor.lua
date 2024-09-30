--[[ Conductor ]]
Conductor = {};
local BPM_CHANGE_MAP_KEY = "backend.Conductor.BpmChangeMap";
setGlobal(BPM_CHANGE_MAP_KEY, {}, true);

function Conductor:getBPMFromSeconds(time)
    local lastChange = {
        stepTime = 0,
        songTime = 0,
        bpm = 0,
        stepCrochet = 0,
    };

    -- Check if NaN
    if (type(time) ~= "number") then
        trace("Tried to get the BPM without giving a time.");
        return lastChange;
    end

    time = time or 0;

    -- local bpmChangeMap = getGlobal(BPM_CHANGE_MAP_KEY).value or {};

    -- -- Fetch the last change
    -- for index, value in ipairs(bpmChangeMap) do
    --     if (time >= value.songTime) then
    --         lastChange = value;
    --     end
    -- end

    return lastChange;
end

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
