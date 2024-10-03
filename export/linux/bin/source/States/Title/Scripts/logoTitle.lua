require("source/utils/Raw");

local data = getShared("TITLE_DATA").value;
local ID = makeSprite(
    data["titleX"],
    data["titleY"]
).value;

loadGraphic(ID, "../Images/logoBumpin.png", "../XML/logoBumpin.xml");
addAnimationByPrefix(ID, "bump", "logo bumpin", 24, false);

function OnBeat()
    Raw.call("flixel.FlxSprite{" .. ID .. "}", "animation.play", "bump", true);
end