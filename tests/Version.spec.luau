local Version = require("../src/shared/Version")

return {
    ["Version.current is a string"] = function()
        assert(type(Version.current) == "string", "expected string, got " .. type(Version.current))
    end,

    ["Version.current matches semver pattern"] = function()
        assert(
            Version.current:match("^%d+%.%d+%.%d+$") ~= nil,
            "expected semver x.y.z, got: " .. Version.current
        )
    end,
}
