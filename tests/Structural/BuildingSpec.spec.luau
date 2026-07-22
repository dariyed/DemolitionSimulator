local BuildingSpec = require("../../src/shared/Structural/BuildingSpec")

return {
    ["the seeded TestBuilding is valid"] = function()
        local ok, err = BuildingSpec.validate(BuildingSpec.TestBuilding)
        assert(ok, "expected TestBuilding to be valid, got error: " .. tostring(err))
    end,

    ["rejects a building with a duplicate part id"] = function()
        local building = {
            name = "Duplicate",
            parts = {
                { id = "A", shape = "Part", size = { 1, 1, 1 }, position = { 0, 0, 0 } },
                { id = "A", shape = "Part", size = { 1, 1, 1 }, position = { 1, 0, 0 } },
            },
        }
        local ok = BuildingSpec.validate(building)
        assert(not ok, "expected duplicate ids to be rejected")
    end,

    ["rejects a part missing a required field"] = function()
        local building = {
            name = "MissingSize",
            parts = {
                { id = "A", shape = "Part", position = { 0, 0, 0 } },
            },
        }
        local ok = BuildingSpec.validate(building)
        assert(not ok, "expected a part with no size to be rejected")
    end,

    ["rejects an invalid shape"] = function()
        local building = {
            name = "BadShape",
            parts = {
                { id = "A", shape = "SphereThing", size = { 1, 1, 1 }, position = { 0, 0, 0 } },
            },
        }
        local ok = BuildingSpec.validate(building)
        assert(not ok, "expected an unrecognized shape to be rejected")
    end,

    ["rejects weldTo referencing an unknown id"] = function()
        local building = {
            name = "GhostWeld",
            parts = {
                {
                    id = "A",
                    shape = "Part",
                    size = { 1, 1, 1 },
                    position = { 0, 0, 0 },
                    weldTo = "DoesNotExist",
                },
            },
        }
        local ok = BuildingSpec.validate(building)
        assert(not ok, "expected weldTo referencing a non-existent id to be rejected")
    end,

    ["rejects a part welded to itself"] = function()
        local building = {
            name = "SelfWeld",
            parts = {
                {
                    id = "A",
                    shape = "Part",
                    size = { 1, 1, 1 },
                    position = { 0, 0, 0 },
                    weldTo = "A",
                },
            },
        }
        local ok = BuildingSpec.validate(building)
        assert(not ok, "expected a part welded to itself to be rejected")
    end,

    ["accepts a part with no weldTo (welds directly to the ground)"] = function()
        local building = {
            name = "GroundOnly",
            parts = {
                { id = "A", shape = "Part", size = { 1, 1, 1 }, position = { 0, 0, 0 } },
            },
        }
        local ok, err = BuildingSpec.validate(building)
        assert(ok, "expected a part with no weldTo to be valid, got error: " .. tostring(err))
    end,
}
