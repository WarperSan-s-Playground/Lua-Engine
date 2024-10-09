require("source.backend.Conductor");
require("source.backend.MusicalState");

-- Types
FlxGroup = require("source.objects.flixel.FlxGroup");

-- Load first
local loadMSG = fromJSON("../gfDanceTitle.json");
local data = loadMSG.value;
setShared("TITLE_DATA", data);

local CREDIT_GROUP = FlxGroup:new();
local NG_ID = -1;

function OnCreate()
    -- Add children
    addScript("gfTitle.lua", false);
    addScript("logoTitle.lua", false);
    addScript("titleEnter.lua", false);

    CreateBlackScreen();
    NG_ID = addScript("UI/newGroundsLogo.lua", false).value;

    -- -- Set Music
    playMusic("../Music/freakyMenu.ogg", true, 0);
    Conductor.setBPM(data.bpm);
end

function OnDestroy()
    closeScript("gfTitle.lua");
    closeScript("logoTitle.lua");
    closeScript("titleEnter.lua");
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
        Raw.set("flixel.FlxSprite", "visible", NG_ID, true);
    elseif sickBeats == 9 then
        -- deleteCoolText();
        Raw.set("flixel.FlxSprite", "visible", NG_ID, false);
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
        SkipIntro();
    end
end

function SkipIntro()
    closeScript("UI/newGroundsLogo.lua");

    -- Remove credit group
    CREDIT_GROUP:destroy();
    CREDIT_GROUP = nil;

    -- Flash
    Raw.call("flixel.FlxG", "camera.flash", nil, 0xFFFFFF, 4);
end

-- Black Screen
function CreateBlackScreen()
    local blackScreenMSG = addScript("UI/blackScreen.lua", false);
    closeScript("UI/blackScreen.lua");

    -- If error occurred, skip
    if (blackScreenMSG.isError) then
        return;
    end

    -- Add to group
    CREDIT_GROUP:add(blackScreenMSG.value);
end
