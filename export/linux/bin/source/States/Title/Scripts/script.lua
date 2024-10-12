require("source.backend.Conductor");
require("source.backend.MusicalState");

-- Types
FlxSprite = require("source.objects.flixel.FlxSprite");
FlxGroup = require("source.objects.flixel.FlxGroup");
Alphabet = require("source.objects.Alphabet");

-- Load first
local loadMSG = fromJSON("../gfDanceTitle.json");
local data = loadMSG.value;
setShared("TITLE_DATA", data);

local CREDIT_GROUP = FlxGroup:new();
local TEXT_GROUP = FlxGroup:new();

function OnCreate()
    -- Add children
    addScript("gfTitle.lua", false);
    addScript("logoTitle.lua", false);
    addScript("titleEnter.lua", false);

    CreateBlackScreen();
    CreateNewGroundsLogo();

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
        CreateText({ 'Psych Engine by' }, 40);
    elseif sickBeats == 4 then
        AddMoreText("Shadow Mario", 40);
        AddMoreText("Riveren", 40);
    elseif sickBeats == 5 then
        DeleteText();
    elseif sickBeats == 6 then
        CreateText({ 'Not associated', 'with' }, -40);
    elseif sickBeats == 8 then
        AddMoreText("newgrounds", -40);
        SetNGLogoVisibility(true);
    elseif sickBeats == 9 then
        DeleteText();
        SetNGLogoVisibility(false);
    elseif sickBeats == 10 then
        -- createCoolText([curWacky[0]]);
        CreateText({ "WACKY " }, 0);
    elseif sickBeats == 12 then
        -- addMoreText(curWacky[1]);
        AddMoreText("WACKY 2");
    elseif sickBeats == 13 then
        DeleteText();
    elseif sickBeats == 14 then
        AddMoreText("Friday");
    elseif sickBeats == 15 then
        AddMoreText("Night");
    elseif sickBeats == 16 then
        AddMoreText("Funkin")
    elseif sickBeats == 17 then
        SkipIntro();
    end
end

function SkipIntro()
    DestroyNGLogo();

    -- Remove credit group
    CREDIT_GROUP:destroy();
    CREDIT_GROUP = nil;

    -- Remove text group
    TEXT_GROUP:destroy();
    TEXT_GROUP = nil;

    -- Flash
    Raw.call("flixel.FlxG", "camera.flash", nil, 0xFFFFFF, 4);
end

-- Black Screen
function CreateBlackScreen()
    local blackScreen = FlxSprite:new();

    blackScreen:makeGraphic(
        Raw.get("flixel.FlxG", "width", nil),
        Raw.get("flixel.FlxG", "height", nil),
        Color.BLACK
    );

    -- Add to group
    CREDIT_GROUP:add(blackScreen);
end

-- NewGrounds Logo
local newGroundsLogo;
function CreateNewGroundsLogo()
    local logo = FlxSprite:new(
        nil,
        Raw.get("flixel.FlxG", "height", nil) * 0.52
    );

    logo:loadGraphic("^/../Images/newgrounds_logo.png");
    logo:set("visible", false);
    logo:call("setGraphicSize", logo.width * 0.8);
    logo:call("updateHitbox");
    logo:call("screenCenter", 0x01);

    newGroundsLogo = logo;
end

function SetNGLogoVisibility(visible)
    newGroundsLogo:set("visible", visible == true);
end

function DestroyNGLogo()
    newGroundsLogo:destroy();
    newGroundsLogo = nil;
end

-- Intro Texts
function CreateText(texts, offset)
    offset = tonumber(offset) or 0;

    for i, value in ipairs(texts) do
        AddMoreText(value, offset, i);
    end
end

function AddMoreText(text, offset, pos)
    offset = tonumber(offset) or 0;
    pos = tonumber(pos) or (#TEXT_GROUP:getMembers() + 1);

    offset = (pos * 60) + 200 + offset;

    local newText = Alphabet:new(
        0,
        offset,
        text,
        true
    );
    newText:call("screenCenter", 0x01);

    CREDIT_GROUP:add(newText, true);
    TEXT_GROUP:add(newText, true);
end

function DeleteText()
    local members = TEXT_GROUP:getMembers();
    for i = #members, 1, -1 do
        local value = members[i];
        value:destroy();
        CREDIT_GROUP:remove(value);
        TEXT_GROUP:remove(value);
    end
end
