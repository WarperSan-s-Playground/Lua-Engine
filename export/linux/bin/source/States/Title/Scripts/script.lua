-- Load first
local loadMSG = fromJSON("../gfDanceTitle.json");
setShared("TITLE_DATA", loadMSG.value);

function OnCreate()
    -- Add children
    addScript("gfTitle.lua");
    closeScript("gfTitle.lua");

    addScript("logoTitle.lua");
    closeScript("logoTitle.lua");

    addScript("titleEnter.lua");

    playMusic("../Music/freakyMenu.ogg");
end

function OnDestroy()
    closeScript("titleEnter.lua");
end
