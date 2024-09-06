GF_ID = -1;

function CreateGF()
    local gf = makeSprite();

    if gf.isError then
        trace("Failed to create a sprite: " .. gf.message);
        return;
    end

    local c = loadGraphic(gf.value, "../Images/gfDanceTitle.png", "../XML/gfDanceTitle.xml");

    if c.isError then
        trace("Failed to load the graphic: " .. c.message);
        return;
    end

    local idle = addAnimationByPrefix(gf.value, "gfDanceTitle", "gfDance", 24, true);

    if idle.isError then
        trace("Failed to load the animation: " .. idle.message);
        return;
    end

    GF_ID = gf.value;
end

function RemoveGF()
    removeSprite(GF_ID);
end

CreateGF();
--RemoveGF();
trace(p);