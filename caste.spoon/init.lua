--- === Caste ===
---
--- Simultaneous cut and paste

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "Caste"
obj.version = "1.0"
obj.author = "Justin Zheng <justinzhengbc@gmail.com>"
obj.homepage = "https://github.com/justinzhengbc/hammerspoon-utils"
obj.license = "MIT - https://opensource.org/licenses/MIT"

local function caste()
    local existing = hs.pasteboard.readString()
    if existing then
        -- hs.uielement:selectedText() does not always work
        hs.eventtap.keyStroke({ "cmd" }, "c")
        local target = hs.pasteboard.readString()
        hs.pasteboard.setContents(existing)
        -- clear current selection, required for applications like Excel
        hs.eventtap.keyStroke({}, "escape")
        hs.eventtap.keyStroke({ "cmd" }, "v")
        if target then
            hs.pasteboard.setContents(target)
        end
    end
end

--- Caste:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for Caste
---
--- Parameters:
---  * mapping - A table containing a hotkey for 'caste'
function obj:bindHotKeys(mapping)
    assert(mapping['caste'], "Mapping must define 'caste'")
    hs.spoons.bindHotkeysToSpec({ caste = caste }, mapping)
end

return obj
