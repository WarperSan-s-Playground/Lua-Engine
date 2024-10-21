require("source.utils.Raw");

local sprite;

function OnCreate()
    local FlxSprite = require("source.objects.flixel.FlxSprite");
    local data = getShared("TITLE_DATA").value;

    sprite = FlxSprite:new(
        tonumber(data["titleX"]),
        tonumber(data["titleY"])
    );

    sprite:loadGraphic("^/../Images/logoBumpin.png", "^/../XML/logoBumpin.xml");
    sprite:addByPrefix("bump", "logo bumpin", 24, false);
end

function OnBeat()
    sprite:playAnimation("bump", true);
end

function OnDestroy()
    sprite:destroy();
    sprite = nil;
end
