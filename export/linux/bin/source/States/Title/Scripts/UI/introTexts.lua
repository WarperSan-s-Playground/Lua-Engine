FlxGroup = require("source.objects.flixel.FlxGroup");
Alphabet = require("source.objects.Alphabet");
local TEXT_GROUP = FlxGroup:new();

function CreateText(texts, offset)
    offset = tonumber(offset) or 0;

    for i, value in ipairs(texts) do
        AddMoreText(value, offset, i - 1);
    end
end

function AddMoreText(text, offset, pos)
    offset = tonumber(offset) or 0;
    pos = tonumber(pos) or #TEXT_GROUP:getMembers();

    offset = (pos * 60) + 200 + offset;

    local newText = Alphabet:new(
        0,
        offset,
        text,
        true
    );
    newText:call("screenCenter", 0x01);

    TEXT_GROUP:add(newText, true);
end

function DeleteText()
    local members = TEXT_GROUP:getMembers();
    for i = #members, 1, -1 do
        local value = members[i];
        value:destroy();
        TEXT_GROUP:remove(value);
    end
end

function OnSickBeat(beat)
    if beat == 2 then
        CreateText({ 'Lua Engine by' }, 40);
    elseif beat == 4 then
        AddMoreText("WarperSan", 40);
    elseif beat == 5 then
        DeleteText();
    elseif beat == 6 then
        CreateText({ 'Not associated', 'with' }, -40);
    elseif beat == 8 then
        AddMoreText("newgrounds", -40);
    elseif beat == 9 then
        DeleteText();
    elseif beat == 10 then
        -- createCoolText([curWacky[0]]);
        CreateText({ "I WUV " }, 0);
    elseif beat == 12 then
        -- addMoreText(curWacky[1]);
        AddMoreText("PANCAKES");
    elseif beat == 13 then
        DeleteText();
    elseif beat == 14 then
        AddMoreText("Friday");
    elseif beat == 15 then
        AddMoreText("Night");
    elseif beat == 16 then
        AddMoreText("Funkin");
    end
end

function OnDestroy()
    TEXT_GROUP:destroy();
    TEXT_GROUP = nil;
end
