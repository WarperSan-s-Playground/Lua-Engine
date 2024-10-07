require("source.utils.Raw");

importFile("DataBuiltIn");

Sprite = require("source.objects.Sprite");

local sprite;

function OnCreate()
    local data = getShared("TITLE_DATA").value;

    sprite = Sprite:new(
        data["titleX"],
        data["titleY"]
    );

    sprite:loadGraphic("../Images/logoBumpin.png", "../XML/logoBumpin.xml");
    sprite:addByPrefix("bump", "logo bumpin", 24, false);
end

function OnBeat()
    print("BEAT LOGO");
    sprite:playAnimation("bump", true);
end

function OnDestroy()
    sprite:destroy();
end
