require("source.utils.Raw");

importFile("SpriteBuiltIn");

function OnCreate()
    local ID = makeSprite(0, 0).value;

    makeGraphic(
        ID,
        Raw.get("flixel.FlxG", "width", nil),
        Raw.get("flixel.FlxG", "height", nil),
        'BLACK'
    );
    return ID;
end
