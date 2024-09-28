

local colorUtils = {};

function HEX2ARGB(hex)
    local a = math.floor(hex / 0x1000000) % 0x100
    local r = math.floor(hex / 0x10000) % 0x100
    local g = math.floor(hex / 0x100) % 0x100
    local b = hex % 0x100

    return {
        a = a,
        r = r,
        g = g,
        b = b,
    };
end

-- Interpolates between two HEX colors in the ARGB format
function colorUtils.interpolate(startColor, endColor, time)
    local color1 = HEX2ARGB(startColor);
    local color2 = HEX2ARGB(endColor);

    -- Clamp t between 0 and 1
    time = math.max(0, math.min(1, time));

    -- Interpolate each channel (A, R, G, B)
    local a = math.floor(color1.a + (color2.a - color1.a) * time);
    local r = math.floor(color1.r + (color2.r - color1.r) * time);
    local g = math.floor(color1.g + (color2.g - color1.g) * time);
    local b = math.floor(color1.b + (color2.b - color1.b) * time);

    return 0x1000000 * a + 0x10000 * r + 0x100 * g + b;
end

return colorUtils;