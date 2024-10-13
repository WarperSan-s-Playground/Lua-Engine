local newGroundsLogo;

function OnCreate()
    -- Types
    local FlxSprite = require("source.objects.flixel.FlxSprite");

    -- Create sprite
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

function OnSickBeat(beat)
    if beat == 8 then
        newGroundsLogo:set("visible", true);
    elseif beat == 9 then
        newGroundsLogo:set("visible", false);
    end
end

function OnDestroy()
    newGroundsLogo:destroy();
    newGroundsLogo = nil;
end
