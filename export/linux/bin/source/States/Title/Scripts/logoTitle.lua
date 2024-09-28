local data = getShared("TITLE_DATA").value;
local msg = makeSprite(
    data["titleX"],
    data["titleY"]
);

loadGraphic(msg.value, "../Images/logoBumpin.png", "../XML/logoBumpin.xml");
addAnimationByPrefix(msg.value, "bump", "logo bumpin", 24, true);
