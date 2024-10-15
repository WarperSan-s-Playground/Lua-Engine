local LOGO_PATH = "^/../Images/newgrounds_logo.png";
local logo;

function OnCreate()
    -- Types
    local FlxSprite = require("source.objects.flixel.FlxSprite");

    -- Create sprite
    logo = FlxSprite:new(
        nil,
        Raw.get("flixel.FlxG", "height", nil) * 0.52
    );

    logo:loadGraphic(LOGO_PATH);
    logo:set("visible", false);
    logo:call("setGraphicSize", logo.width * 0.8);
    logo:call("updateHitbox");
    logo:call("screenCenter", 0x01);
end

function OnSickBeat(beat)
    if beat == 8 then
        logo:set("visible", true);
    elseif beat == 9 then
        logo:set("visible", false);
    end
end

function OnDestroy()
    logo:destroy();
    releaseResource(LOGO_PATH);
end
