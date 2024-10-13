require("source.backend.Conductor");
require("source.backend.MusicalState");

-- Types
FlxGroup = require("source.objects.flixel.FlxGroup");

-- Load first
local loadMSG = fromJSON("../gfDanceTitle.json");
local data = loadMSG.value;
setShared("TITLE_DATA", data);

local CREDIT_GROUP = FlxGroup:new();

function OnCreate()
    -- Add children
    addScript("UI/gfTitle.lua", false);
    addScript("UI/logoTitle.lua", false);
    addScript("UI/titleEnter.lua", false);

    CreateBlackScreen();

    addScript("UI/newGroundsLogo.lua", false);
    addScript("UI/introTexts.lua", false);

    -- -- Set Music
    playMusic("../Music/freakyMenu.ogg", true, 0);
    Conductor.setBPM(data.bpm);
end

local sickBeats = 0;
function OnBeat()
    sickBeats = sickBeats + 1;
    callMethod("OnSickBeat", { sickBeats });
end

function OnSickBeat(beat)
    if beat == 1 then
        playMusic("../Music/freakyMenu.ogg", true, 0);
        Raw.call("flixel.FlxG", "sound.music.fadeIn", nil, 4, 0, 0.7);
    elseif beat == 17 then
        callMethod("SkipIntro");
    end
end

function SkipIntro()
    -- Remove credit group
    CREDIT_GROUP:destroy();
    CREDIT_GROUP = nil;

    closeScript("UI/introTexts.lua");
    closeScript("UI/newGroundsLogo.lua");

    -- Flash
    Raw.call("flixel.FlxG", "camera.flash", nil, 0xFFFFFF, 4);
end

-- Black Screen
function CreateBlackScreen()
    local FlxSprite = require("source.objects.flixel.FlxSprite");
    local blackScreen = FlxSprite:new();

    blackScreen:makeGraphic(
        Raw.get("flixel.FlxG", "width", nil),
        Raw.get("flixel.FlxG", "height", nil),
        Color.BLACK
    );

    -- Add to group
    CREDIT_GROUP:add(blackScreen);
end
