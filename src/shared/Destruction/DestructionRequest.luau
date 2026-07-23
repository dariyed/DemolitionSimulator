--[[
    DestructionRequest — Issue #3's deliberately crude "is this destruction request legal"
    check. Pure Luau, no Instances, so it's Tier-1 testable with Lune.

    There is no load path graph yet (that's Epic 2) — this issue only needs to prove the
    client -> server -> physics round trip works, and that the SERVER (not the client)
    decides whether a request is legal. So for now there is exactly one legal target:
    "BeamBack", a leaf part in BuildingSpec.TestBuilding that nothing else is welded to (check
    BuildingSpec.luau: no other part declares `weldTo = "BeamBack"`). Breaking one weld only
    detaches whatever is directly hanging off it, so picking a leaf means exactly one part
    falls, with nothing depending on it — pulling dependents down too would be simulating
    Epic 2's job before it exists.

    BeamBack specifically (not one of the columns): a column's bottom already sits flush with
    the ground (Baseplate), so breaking its weld leaves it with nowhere to fall — it just goes
    loose in place, which looked like nothing happened during manual testing. BeamBack sits
    ~10 studs up, resting only on its weld to ColumnBackLeft, so breaking that weld gives it
    real distance to actually fall and hit the ground.
]]

export type Request = {
    partId: string,
}

local DestructionRequest = {}

DestructionRequest.TEST_TARGET_ID = "BeamBack"

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
