require("source.utils.Raw");

importFile("DataBuiltIn");

FlxSprite = require("source.objects.flixel.FlxSprite");

local sprite;

function OnCreate()
    local data = getShared("TITLE_DATA").value;

    sprite = FlxSprite:new(
        data["titleX"],
        data["titleY"]
    );

    sprite:loadGraphic("../Images/logoBumpin.png", "../XML/logoBumpin.xml");
    sprite:addByPrefix("bump", "logo bumpin", 24, false);
end

function OnBeat()
    sprite:playAnimation("bump", true);
end

function OnDestroy()
    sprite:destroy();
end
