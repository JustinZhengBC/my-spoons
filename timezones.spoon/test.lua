local timezones = require("init")

local function assertEqual(actual, expected, testName)
    assert(actual == expected, string.format("%s expected:\n%s\nBut got:\n%s", testName, expected, actual))
end

local function testPos(input, expected)
    local actual = timezones:convert(input, "PST", "EST", 3)
    assertEqual(actual, expected, "testPos")
end

testPos(
    "This input has no times in it: 11.",
    "This input has no times in it: 11."
)
testPos(
    "This input has an invalid hour in it: 13pm.",
    "This input has an invalid hour in it: 13pm."
)
testPos(
    "This input has an invalid minute in it: 11:61am.",
    "This input has an invalid minute in it: 11:61am."
)
testPos(
    "This input has an invalid marker in it: 4:38cm.",
    "This input has an invalid marker in it: 4:38cm."
)
testPos(
    "I'm free between 11AM and 1PM, so maybe 12PM?",
    "I'm free between 11AM PST (2PM EST) and 1PM PST (4PM EST), so maybe 12PM PST (3PM EST)?"
)
testPos(
    "Should we meet at 8:30am, 9 AM, or 9:15 A.M.?",
    "Should we meet at 8:30am PST (11:30am EST), 9 AM PST (12 PM EST), or 9:15 A.M. PST (12:15 P.M. EST)?"
)

local function testNeg(input, expected)
    local actual = timezones:convert(input, "EST", "PST", -3)
    assertEqual(actual, expected, "testNeg")
end

testNeg(
    "I'm free between 11AM and 1PM, so maybe 12PM?",
    "I'm free between 11AM EST (8AM PST) and 1PM EST (10AM PST), so maybe 12PM EST (9AM PST)?"
)
testNeg(
    "Should we meet at 2:30pm, 3 PM, or 3:15 P.M.?",
    "Should we meet at 2:30pm EST (11:30am PST), 3 PM EST (12 PM PST), or 3:15 P.M. EST (12:15 P.M. PST)?"
)

local function testPosLarge(input, expected)
    local actual = timezones:convert(input, "PST", "HKT", 16)
    assertEqual(actual, expected, "testPosLarge")
end

testPosLarge(
    "I'm free between 11AM and 1PM, so maybe 12PM?",
    "I'm free between 11AM PST (3PM HKT) and 1PM PST (5PM HKT), so maybe 12PM PST (4PM HKT)?"
)

local function testNegLarge(input, expected)
    local actual = timezones:convert(input, "HKT", "PST", -16)
    assertEqual(actual, expected, "testNegLarge")
end

testNegLarge(
    "I'm free between 11AM and 1PM, so maybe 12PM?",
    "I'm free between 11AM HKT (7AM PST) and 1PM HKT (9AM PST), so maybe 12PM HKT (8AM PST)?"
)
