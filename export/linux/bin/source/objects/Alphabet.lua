require("source.utils.Raw");

FlxGroup = require("source.objects.flixel.FlxGroup");
Alphabet = setmetatable({}, FlxGroup);
Alphabet.__index = Alphabet;

function Alphabet:new(x, y, text, bold)
    local alphabet = FlxGroup.new(self, x, y);

    -- Create
    alphabet.startX = alphabet.x;
    alphabet.startY = alphabet.y;
    alphabet.bold = bold == true;
    alphabet._letters = {};
    ClearLetters(alphabet);
    alphabet:setText(text);

    return alphabet;
end

function Alphabet:setText(text)
    text = tostring(text):gsub('\\n', '\n');
    ClearLetters(self);
    CreateLetters(self, text);
end

function ClearLetters(alphabet)
    for key, value in pairs(alphabet._letters) do
        value:destroy();
    end

    alphabet._letters = {};
    alphabet._rows = 0;
end

function CreateLetters(alphabet, newText)
    local consecutiveSpaces = 0;
    local xPos = 0;
    local rowData = {};
    local rows = 0;
    local bold = alphabet.bold;
    local X_LIMIT = tonumber(Raw.get("flixel.FlxG", "width", nil)) * 0.65;
    local letters = {};

    for i = 1, #newText do
        -- Get character
        local c = newText:sub(i, i);

        -- Move to next line
        if (c == '\n') then
            xPos = 0;
            rows = rows + 1;

            goto next_letter;
        end

        local isSpace = (c == ' ') or (bold and c == '_');

        if (isSpace) then
            consecutiveSpaces = consecutiveSpaces + 1;
        end

        local isValidCharacter = true; -- AlphaCharacter.allLetters.exists(character.toLowerCase())

        -- If not a valid character, skip
        if (not isValidCharacter) then
            goto next_letter;
        end

        -- If the character is a bold space, skip
        if (bold and isSpace) then
            goto next_letter;
        end

        if (consecutiveSpaces > 0) then
            xPos = xPos + 28 * consecutiveSpaces;
            rowData[rows] = xPos;

            if (not bold and xPos > X_LIMIT) then
                xPos = 0;
                rows = rows + 1;
            end
        end

        consecutiveSpaces = 0;

        local letter = FlxSprite:new();
        letter:loadGraphic("~/source/States/Title/Images/gfDanceTitle.png", "~/source/States/Title/XML/gfDanceTitle.xml");

        -- var letter:AlphaCharacter = cast recycle(AlphaCharacter, true);
        -- letter.scale.x = scaleX;
        -- letter.scale.y = scaleY;
        letter.rowWidth = 0;

        -- letter.setupAlphaCharacter(xPos, rows * Y_PER_ROW * scale.y, character, bold);
        -- @:privateAccess letter.parent = this;

        letter.row = rows;
        local offset = 0;

        if (not bold) then
            offset = 2;
        end

        xPos = xPos + letter.width;-- + (letter.letterOffset[0] + offset);
        rowData[rows] = xPos;

        letters[#letters + 1] = letter;

        ::next_letter::
    end

    for key, letter in pairs(letters) do
        letter.rowWidth = rowData[letter.row];
    end


    if (#letters > 0) then
        rows = rows + 1;
    end

    alphabet._rows = rows;
end

return Alphabet;
