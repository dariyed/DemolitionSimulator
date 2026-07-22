--[[
    DestructionRequest — Issue #3's deliberately crude "is this destruction request legal"
    check. Pure Luau, no Instances, so it's Tier-1 testable with Lune.

    There is no load path graph yet (that's Epic 2) — this issue only needs to prove the
    client -> server -> physics round trip works, and that the SERVER (not the client)
    decides whether a request is legal. So for now there is exactly one legal target: a
    single leaf part in BuildingSpec.TestBuilding that nothing else is welded to
    ("ColumnBackRight" — check BuildingSpec.luau: no other part declares `weldTo =
    "ColumnBackRight"`). That matters because breaking one weld only detaches whatever is
    directly hanging off it; picking a leaf means exactly one part falls, with nothing
    depending on it, rather than pulling its dependents down too (which would be simulating
    Epic 2's job before it exists).
]]

export type Request = {
    partId: string,
}

local DestructionRequest = {}

DestructionRequest.TEST_TARGET_ID = "ColumnBackRight"

-- Returns (true, nil) if `request` is well-formed AND names the one legal test target;
-- (false, "reason") otherwise. The server must call this before doing anything to a part —
-- never trust a client's request at face value.
function DestructionRequest.validate(request: unknown): (boolean, string?)
    if type(request) ~= "table" then
        return false, "request must be a table"
    end

    local partId = (request :: Request).partId
    if type(partId) ~= "string" or partId == "" then
        return false, "request.partId must be a non-empty string"
    end

    if partId ~= DestructionRequest.TEST_TARGET_ID then
        return false, string.format("illegal target: %q is not a legal destruction target", partId)
    end

    return true, nil
end

return DestructionRequest
