require("source.utils.Raw");

Sprite = require("source.objects.Sprite");

importFile("SpriteBuiltIn");

local sprite;

function OnCreate()
    sprite = Sprite:new(
        0,
        Raw.get("flixel.FlxG", "height", nil) * 0.52
    );

    sprite:loadGraphic("^/../Images/newgrounds_logo.png");
    Raw.set("flixel.FlxSprite", "visible", sprite.ID, false);
    Raw.call(
        "flixel.FlxSprite",
        "setGraphicSize",
        sprite.ID,
        tonumber(Raw.get("flixel.FlxSprite", "width", sprite.ID)) * 0.8
    );
    Raw.call("flixel.FlxSprite", "updateHitbox", sprite.ID);
    Raw.call("flixel.FlxSprite", "screenCenter", sprite.ID, 0x01);

    return sprite.ID;
end

function OnDestroy()
    sprite:destroy();
end
