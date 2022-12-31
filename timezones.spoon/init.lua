--- === Timezones ===
---
--- Automatically add timezone conversion to clipboard text
--- Does not handle dates!

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Timezones"
obj.version = "1.0"
obj.author = "Justin Zheng <justinzhengbc@gmail.com>"
obj.homepage = "https://github.com/justinzhengbc/hammerspoon-utils"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function findTime(text, pos)
    local i1, j1, h1, s1, ampm1     = string.find(text, "(%d%d?)(%s?)([AaPp][.]?[Mm][.]?)", pos)
    local i2, j2, h2, m2, s2, ampm2 = string.find(text, "(%d%d?):(%d%d)(%s?)([AaPp][.]?[Mm][.]?)", pos)
    if i1 and (not i2 or i1 < i2) then
        return i1, j1, h1, nil, s1, ampm1
    elseif i2 then
        return i2, j2, h2, m2, s2, ampm2
    end
    return nil
end

local function formatTime(h, m, s, ampm, tz, isTarget)
    local formattedTime
    if m then
        formattedTime = string.format("%d:%d%s%s %s", h, m, s, ampm, tz)
    else
        formattedTime = string.format("%d%s%s %s", h, s, ampm, tz)
    end
    if isTarget then
        return string.format(" (%s)", formattedTime)
    else
        return formattedTime
    end
end

local amPmSwitch = {
    A = "P",
    a = "p",
    P = "A",
    p = "a"
}

local function switchAmPm(ampm)
    return amPmSwitch[string.sub(ampm, 1, 1)] .. string.sub(ampm, 2)
end

--- Timezones:convert(text, source, target, offset)
--- Method
--- Does timezone conversion over text
---
--- Parameters:
---  * text - Text containing times to be converted
---  * source - Original timezone code
---  * target - New timezone code
---  * offset - The number of hours to add, may be negative
---
--- Returns:
---  * New text with original and converted times
function obj:convert(text, source, target, offset)
    if text then
        local pos = 1;
        local newText = {}
        while 1 do
            local i, j, h, m, s, ampm = findTime(text, pos)
            if not i then
                table.insert(newText, string.sub(text, pos))
                break
            end
            h = tonumber(h)
            m = tonumber(m)
            if h == 0 or h > 12 or (m and (m == 0 or m > 59)) then
                table.insert(newText, string.sub(text, pos, j))
                pos = assert(j) + 1
            else
                if h == 12 then
                    h = 0
                end
                local h2 = h + offset
                local ampm2 = ampm
                if ((math.floor(h2 / 12) % 2) ~ (math.floor(math.abs(offset) / 12) % 2)) > 0 then
                    ampm2 = switchAmPm(ampm)
                end
                h2 = h2 % 12
                if h == 0 then
                    h = 12
                end
                if h2 == 0 then
                    h2 = 12
                end
                table.insert(newText, string.sub(text, pos, i - 1))
                pos = assert(j) + 1
                table.insert(newText, formatTime(h, m, s, ampm, source, false))
                table.insert(newText, formatTime(h2, m, s, ampm2, target, true))
            end
        end
        return table.concat(newText)
    end
    return nil
end

function obj:_convertClipboardAndPaste(source, target, offset)
    local newText = self:convert(hs.pasteboard.readString(), source, target, tonumber(offset))
    if newText then
        hs.pasteboard.setContents(newText)
        hs.eventtap.keyStroke({ "cmd" }, "v")
    end
end

--- Timezones:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for Timezones
---
--- Parameters:
---  * mapping - A table containing hotkeys for functions named XXXToYYYByZ
---    * XXX and YYY are time zone codes
---    * Z is the number of hours to add, and may be negative
function obj:bindHotKeys(mapping)
    for functionName, hotkey in pairs(mapping) do
        local source, target, offset = string.match(functionName, "^([%u%l]+)To([%u%l]+)By([+-]?%d+)$")
        hs.hotkey.bindSpec(hotkey,
            function() self:_convertClipboardAndPaste(source, target, tonumber(offset)) end)
    end
end

return obj
