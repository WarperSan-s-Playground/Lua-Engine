-- Load first
local loadMSG = fromJSON("../gfDanceTitle.json");
setShared("TITLE_DATA", loadMSG.value);

-- Add children
addScript("gfTitle.lua");
addScript("logoTitle.lua");

closeScript("gfTitle.lua");
closeScript("logoTitle.lua");

trace(getAllScripts().value);
