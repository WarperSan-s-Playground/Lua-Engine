require("source.utils.Raw");
require("source.utils.Animations");

importFile("DataBuiltIn");
importFile("SpriteBuiltIn");

local ID = -1;

function OnCreate()
    local data = getShared("TITLE_DATA").value;
    ID = makeSprite(
        data["titleX"],
        data["titleY"]
    ).value;

    loadGraphic(ID, "../Images/logoBumpin.png", "../XML/logoBumpin.xml");
    Animations.addByPrefix(ID, "bump", "logo bumpin", 24, false);
end

function OnBeat()
    Raw.call("flixel.FlxSprite", "animation.play", ID, "bump", true);
end

function OnDestroy()
    removeSprite(ID);
end
