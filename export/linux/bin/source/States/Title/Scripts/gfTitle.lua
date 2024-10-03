-- importFile("DataBuiltIn");
-- importFile("SpriteBuiltIn");
-- importFile("AnimationBuiltIn");
require("source/utils/Raw");

local data = getShared("TITLE_DATA").value;
local ID = makeSprite(
    data["gfX"],
    data["gfY"]
).value;
local danceLeft = false;

loadGraphic(ID, "../Images/gfDanceTitle.png", "../XML/gfDanceTitle.xml");
addAnimationByIndices(ID, "danceRight", "gfDance", { 30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }, 24, false);
addAnimationByIndices(ID, "danceLeft", "gfDance", { 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29 }, 24,
    false);

function OnBeat()
    danceLeft = not danceLeft;
    local anim = '';

    if danceLeft then
        anim = 'danceRight';
    else
        anim = 'danceLeft';
    end

    Raw.call("flixel.FlxSprite{" .. ID .. "}", "animation.play", anim);
end
