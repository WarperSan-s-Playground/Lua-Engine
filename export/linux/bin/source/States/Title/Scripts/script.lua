-- Load first
local loadMSG = fromJSON("../gfDanceTitle.json");
setGlobal("TITLE_DATA", loadMSG.value);

-- Add children
addScript("gfTitle.lua");
addScript("logoTitle.lua");
closeScript("logoTitle.lua");
