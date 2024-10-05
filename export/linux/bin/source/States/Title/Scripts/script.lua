require("source/backend/Conductor");

-- Load first
local loadMSG = fromJSON("../gfDanceTitle.json");
local data = loadMSG.value;
setShared("TITLE_DATA", data);

local NG_ID = -1;

function OnCreate()
    -- Add children
    addScript("gfTitle.lua", false);
    addScript("logoTitle.lua", false);
    addScript("titleEnter.lua");
    NG_ID = addScript("newGroundsLogo.lua", false).value;

    -- Set Music
    playMusic("../Music/freakyMenu.ogg", true, 0);
    Conductor.setBPM(data.bpm);
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

local sickBeats = 0;
function OnBeat()
    sickBeats = sickBeats + 1;

    if sickBeats == 1 then
        playMusic("../Music/freakyMenu.ogg", true, 0);
        Raw.call("flixel.FlxG", "sound.music.fadeIn", nil, 4, 0, 0.7);
    elseif sickBeats == 2 then
        -- createCoolText(['Psych Engine by'], 40);
    elseif sickBeats == 4 then
        -- addMoreText('Shadow Mario', 40);
        -- addMoreText('Riveren', 40);
    elseif sickBeats == 5 then
        -- deleteCoolText();
    elseif sickBeats == 6 then
        -- createCoolText(['Not associated', 'with'], -40);
    elseif sickBeats == 8 then
        -- addMoreText('newgrounds', -40);
        --Raw.set("flixel.FlxSprite", "visible", NG_ID, true);
    elseif sickBeats == 9 then
        -- deleteCoolText();
        --Raw.set("flixel.FlxSprite", "visible", NG_ID, false);
    elseif sickBeats == 10 then
        -- createCoolText([curWacky[0]]);
    elseif sickBeats == 12 then
        -- addMoreText(curWacky[1]);
    elseif sickBeats == 13 then
        -- deleteCoolText();
    elseif sickBeats == 14 then
        -- addMoreText('Friday');
    elseif sickBeats == 15 then
        -- addMoreText('Night');
    elseif sickBeats == 16 then
        -- addMoreText('Funkin');
    elseif sickBeats == 17 then
        -- skipIntro();
    end
end
