--[[
    DestructionRequest — Issue #3's deliberately crude "is this destruction request legal"
    check. Pure Luau, no Instances, so it's Tier-1 testable with Lune.

    There is no load path graph yet (that's Epic 2) — this issue only needs to prove the
    client -> server -> physics round trip works, and that the SERVER (not the client)
    decides whether a request is legal. So for now there is exactly one legal target:
    "TestMarker", a small non-structural part in BuildingSpec.TestBuilding added specifically
    for this test. It's held up by nothing but its own weld, unlike everything else in the
    building: the columns sit flush with the ground (breaking their weld leaves them with
    nowhere to fall), and the beams rest on TWO columns each by physical contact, not just the
    one they're welded to (breaking one weld still leaves them resting on the other column).
    TestMarker sticks out from the side of a column into open air, touching nothing else, so
    it actually falls the instant its one weld breaks.

    This whole trigger — including TestMarker itself — is throwaway scaffolding. Epic 4 adds
    the real tools (explosive charge, wrecking ball) that operate on real structural elements
    through the Epic 2 load path graph; this issue only needs to prove the plumbing works.
]]

export type Request = {
    partId: string,
}

local DestructionRequest = {}

DestructionRequest.TEST_TARGET_ID = "TestMarker"

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
