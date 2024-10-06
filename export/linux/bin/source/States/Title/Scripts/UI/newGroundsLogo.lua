require("source.utils.Raw");

importFile("SpriteBuiltIn");

local ID = -1;

function OnCreate()
    ID = makeSprite(
        0,
        Raw.get("flixel.FlxG", "height", nil) * 0.52
    ).value;

    loadGraphic(ID, "^/../Images/newgrounds_logo.png");
    Raw.set("flixel.FlxSprite", "visible", ID, false);
    Raw.call(
        "flixel.FlxSprite",
        "setGraphicSize",
        ID,
        tonumber(Raw.get("flixel.FlxSprite", "width", ID)) * 0.8
    );
    Raw.call("flixel.FlxSprite", "updateHitbox", ID);
    Raw.call("flixel.FlxSprite", "screenCenter", ID, 0x01);

    return ID;
end

function OnDestroy()
    removeSprite(ID);
end
