TITLE_DATA = nil;

function LoadTitleData()
    local loadMSG = fromJSON("../gfDanceTitle.json");

    if loadMSG.isError then
        trace("Failed to load the data: " .. loadMSG.message);
        return;
    end

    TITLE_DATA = loadMSG.value;
    setGlobal("TITLE_DATA", TITLE_DATA);
end

function CreateLogo()
    local logoMSG = makeSprite(
        TITLE_DATA["titleX"],
        TITLE_DATA["titleY"]
    );

    if logoMSG.isError then
        trace("Failed to create a sprite: " .. logoMSG.message);
        return;
    end

    local graphicMSG = loadGraphic(logoMSG.value, "../Images/logoBumpin.png", "../XML/logoBumpin.xml");

    if graphicMSG.isError then
        trace("Failed to load the graphic: " .. graphicMSG.message);
        return;
    end

    local animMSG = addAnimationByPrefix(logoMSG.value, "bump", "logo bumpin", 24, true);

    if animMSG.isError then
        trace("Failed to load the animation: " .. animMSG.message);
        return;
    end
end

LoadTitleData();
addScript("./gfTitle.lua");
CreateLogo();
