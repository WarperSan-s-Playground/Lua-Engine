require("source.utils.Raw");

Sprite = require("source.objects.Sprite");

importFile("SpriteBuiltIn");

function OnCreate()
    local sprite = Sprite:new(0, 0);
    sprite:makeGraphic(
        Raw.get("flixel.FlxG", "width", nil),
        Raw.get("flixel.FlxG", "height", nil),
        "black"
    );
    return sprite.ID;
end
