-- importFile("DataBuiltIn");
-- importFile("SpriteBuiltIn");
-- importFile("AnimationBuiltIn");

local data = getShared("TITLE_DATA").value;
local msg = makeSprite(
    data["gfX"],
    data["gfY"]
);

loadGraphic(msg.value, "../Images/gfDanceTitle.png", "../XML/gfDanceTitle.xml");
addAnimationByPrefix(msg.value, "gfDanceTitle", "gfDance", 24, true);
