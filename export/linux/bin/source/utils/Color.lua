Color = {
    TRANSPARENT = 0x00000000,
    WHITE = 0xFFFFFFFF,
    GRAY = 0xFF808080,
    BLACK = 0xFF000000,
    GREEN = 0xFF008000,
    LIME = 0xFF00FF00,
    YELLOW = 0xFFFFFF00,
    ORANGE = 0xFFFFA500,
    RED = 0xFFFF0000,
    PURPLE = 0xFF800080,
    BLUE = 0xFF0000FF,
    BROWN = 0xFF8B4513,
    PINK = 0xFFFFC0CB,
    MAGENTA = 0xFFFF00FF,
    CYAN = 0xFF00FFFF,
};

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

---Interpolates between two HEX colors
---@param startColor integer Start color in ARGB
---@param endColor integer End color in ARGB
---@param time number Percentage of lerp
---@return integer color Interpolated color
function Color.interpolate(startColor, endColor, time)
    local color1 = HEX2ARGB(startColor);
    local color2 = HEX2ARGB(endColor);

    -- Clamp t between 0 and 1
    time = math.max(0, math.min(1, time));

    -- Interpolate each channel (A, R, G, B)
    return Color.parseColor({
        a = math.floor(color1.a + (color2.a - color1.a) * time),
        r = math.floor(color1.r + (color2.r - color1.r) * time),
        g = math.floor(color1.g + (color2.g - color1.g) * time),
        b = math.floor(color1.b + (color2.b - color1.b) * time),
    });
end

---Parses the given color to it's HEX RGB format
---@param value string|number|table Color to parse
---@return integer color Formatted color
function Color.parseColor(value)
    local _type = type(value);
    local color;

    -- If already a number, skip
    if (_type == "number") then
        color = value;
        goto return_color;
    end

    if (_type == "string") then
        -- If the color starts with #, parse the hex value
        if (string.sub(value, 1, 1) == '#') then
            value = string.sub(value, 2, #value);
            color = tonumber(value, 16);
            goto return_color;
        end

        -- Find the value from the possible constant colors
        local capValue = string.upper(value);
        for name, field in pairs(Color) do
            if (type(field) == "number" and string.upper(name) == capValue) then
                color = field;
                goto return_color;
            end
        end
    end

    -- If table, try { R, G, B }
    if (_type == "table") then
        local a = tonumber(value['a']) or 0xFF;
        local r = tonumber(value['r']);
        local g = tonumber(value['g']);
        local b = tonumber(value['b']);

        -- If one missing, skip
        if (r == nil or g == nil or b == nil) then
            goto return_color;
        end

        color = 0x1000000 * a + 0x10000 * r + 0x100 * g + b;

        goto return_color;
    end

    ::return_color::

    -- Default if not found
    color = color or Color.WHITE;

    -- Only keep the good part
    color = math.floor(color);            -- Remove decimals
    color = math.min(color, Color.WHITE); -- Limit to max white
    color = math.max(color, Color.BLACK); -- Limit to min black

    -- To 32 bits
    if (color >= 2 ^ 31) then
        color = color - 2 ^ 32;
    end

    return color;
end
