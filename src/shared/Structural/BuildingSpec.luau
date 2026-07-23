--[[
    BuildingSpec — a pure data description of a building's geometry.

    "Pure" means this module only returns and validates plain Luau tables — it never touches
    Workspace or creates a single Instance. That's what makes it fast to unit-test with Lune
    (see tests/Structural/BuildingSpec.spec.luau) instead of only being testable by opening
    Roblox Studio. server/BuildingService.server.luau is the thin layer that reads this data
    and actually builds real parts from it.

    Each part optionally declares `weldTo`, the id of another part it's welded to. A part with
    no `weldTo` is understood to weld directly to the ground (the Baseplate) — so every part
    in a valid building has a path back to the ground, one weld at a time. Epic 2 (Structural
    Engineering System) will build the real load path / dependency graph on top of this same
    `weldTo` relationship; this issue only needs the geometry to exist and be buildable.
]]

export type PartSpec = {
    id: string,
    shape: "Part" | "WedgePart",
    size: { number }, -- {x, y, z} in studs
    position: { number }, -- {x, y, z}, world position of the part's center
    color: { number }?, -- optional {r, g, b}, each 0-1
    weldTo: string?, -- id of the part this welds to; nil = welds directly to the Baseplate
}

export type Building = {
    name: string,
    parts: { PartSpec },
}

local BuildingSpec = {}

-- Checks that a Building table is well-formed: every part has the required fields, no two
-- parts share an id, and every `weldTo` points at a real part (never itself, never a ghost
-- id). Returns (true, nil) if valid, or (false, "reason") if not — callers should always
-- check `ok` before touching the building, so a malformed spec is caught immediately instead
-- of failing confusingly later when BuildingService tries to build Instances from it.
function BuildingSpec.validate(building: Building): (boolean, string?)
    if type(building) ~= "table" then
        return false, "building must be a table"
    end
    if type(building.name) ~= "string" or building.name == "" then
        return false, "building.name must be a non-empty string"
    end
    if type(building.parts) ~= "table" or #building.parts == 0 then
        return false, "building.parts must be a non-empty array"
    end

    -- First pass: check each part in isolation, and record every id we've seen so the
    -- second pass can check `weldTo` references against a complete set.
    local seenIds = {}
    for index, part in building.parts do
        if type(part.id) ~= "string" or part.id == "" then
            return false, string.format("parts[%d].id must be a non-empty string", index)
        end
        if seenIds[part.id] then
            return false, string.format("duplicate part id: %q", part.id)
        end
        seenIds[part.id] = true

        if part.shape ~= "Part" and part.shape ~= "WedgePart" then
            return false,
                string.format(
                    "parts[%d] (%s) has invalid shape: %s",
                    index,
                    part.id,
                    tostring(part.shape)
                )
        end
        if type(part.size) ~= "table" or #part.size ~= 3 then
            return false,
                string.format("parts[%d] (%s).size must be a {x, y, z} array", index, part.id)
        end
        if type(part.position) ~= "table" or #part.position ~= 3 then
            return false,
                string.format("parts[%d] (%s).position must be a {x, y, z} array", index, part.id)
        end
    end

    -- Second pass: now that seenIds is complete, check weldTo references. This has to be a
    -- separate pass because a part earlier in the array might legally weld to a part later
    -- in the array — order in the list doesn't imply build order.
    for index, part in building.parts do
        if part.weldTo ~= nil then
            if part.weldTo == part.id then
                return false,
                    string.format("parts[%d] (%s).weldTo cannot reference itself", index, part.id)
            end
            if not seenIds[part.weldTo] then
                return false,
                    string.format(
                        "parts[%d] (%s).weldTo references unknown id: %q",
                        index,
                        part.id,
                        part.weldTo
                    )
            end
        end
    end

    return true, nil
end

-- The seeded test building for Epic 1: four corner columns holding up two roof beams and one
-- wall panel. Deliberately simple — its only job is to prove the pipeline (spec → validated
-- data → real welded Instances) end to end. Epic 2 replaces "everything welds in a straight
-- line back to whichever part it names" with a real load path graph.
BuildingSpec.TestBuilding = {
    name = "TestBuilding",
    parts = {
        { id = "ColumnFrontLeft", shape = "Part", size = { 2, 10, 2 }, position = { -8, 5, -8 } },
        { id = "ColumnFrontRight", shape = "Part", size = { 2, 10, 2 }, position = { 8, 5, -8 } },
        { id = "ColumnBackLeft", shape = "Part", size = { 2, 10, 2 }, position = { -8, 5, 8 } },
        { id = "ColumnBackRight", shape = "Part", size = { 2, 10, 2 }, position = { 8, 5, 8 } },
        {
            id = "BeamFront",
            shape = "Part",
            size = { 18, 1, 2 },
            position = { 0, 10.5, -8 },
            weldTo = "ColumnFrontLeft",
        },
        {
            id = "BeamBack",
            shape = "Part",
            size = { 18, 1, 2 },
            position = { 0, 10.5, 8 },
            weldTo = "ColumnBackLeft",
        },
        {
            id = "WallLeft",
            shape = "Part",
            size = { 2, 10, 16 },
            position = { -8, 5, 0 },
            weldTo = "ColumnFrontLeft",
        },
        -- A small marker welded to the side of a column, sticking out into open air with
        -- nothing else touching it (unlike the beams, which rest on two columns each, or the
        -- columns, which sit flush with the ground). It exists only so Issue #3's crude
        -- destruction test has one part that's truly held up by nothing but its own weld —
        -- not a "real" structural element.
        {
            id = "TestMarker",
            shape = "Part",
            size = { 1, 1, 1 },
            position = { 8, 8, -6.5 },
            weldTo = "ColumnFrontRight",
        },
    },
} :: Building

return BuildingSpec
