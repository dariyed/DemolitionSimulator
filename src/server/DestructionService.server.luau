--[[
    DestructionService — Issue #3's deliberately crude destruction trigger.

    A client fires a RemoteEvent asking to destroy a part. The SERVER — never the client —
    decides whether that's legal, by running the request through the pure
    DestructionRequest.validate. Only if it's legal does the server break the one
    WeldConstraint holding that part up, so it falls under real physics rather than being
    Destroy()'d or faked with an animation. This is the same server-authoritative pattern
    CLAUDE.md documents for HalfSwordGame's hit detection: the client can ask, but only the
    server can make it happen.

    There is no load path graph yet (Epic 2) — this script only proves the round trip works:
    client asks -> server validates -> a real weld breaks -> physics takes over.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local DestructionRequest = require(ReplicatedStorage.Shared.Destruction.DestructionRequest)

-- The RemoteEvent is created here, from a script, rather than hand-placed in Studio — the
-- same reasoning as BuildingService building the building from data: it's reproducible from
-- source, not a one-off manual step someone has to remember to redo after a fresh clone.
local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage

local destructionRequested = Instance.new("RemoteEvent")
destructionRequested.Name = "DestructionRequested"
destructionRequested.Parent = remotesFolder

-- Looks up a part by id inside the TestBuilding folder that BuildingService built. Returns
-- nil if the building (or the part) isn't there yet — the caller treats that as "reject",
-- same as any other invalid request, rather than erroring.
local function findTestBuildingPart(partId: string): BasePart?
    local building = Workspace:FindFirstChild("TestBuilding")
    if not building then
        return nil
    end
    local part = building:FindFirstChild(partId)
    return if part and part:IsA("BasePart") then part else nil
end

destructionRequested.OnServerEvent:Connect(function(player: Player, request: unknown)
    local ok, err = DestructionRequest.validate(request)
    if not ok then
        warn(
            string.format(
                "DestructionService: rejected request from %s: %s",
                player.Name,
                tostring(err)
            )
        )
        return
    end

    -- `validate` already confirmed request.partId is the one legal target, so this cast is
    -- safe: we only reach here after the type/shape check above passed.
    local partId = (request :: DestructionRequest.Request).partId
    local targetPart = findTestBuildingPart(partId)
    if not targetPart then
        warn(string.format("DestructionService: legal target %q not found in Workspace", partId))
        return
    end

    -- BuildingService parents each part's WeldConstraint to the part itself, so this finds
    -- the exact weld holding this part to whatever it's connected to. Destroying it (rather
    -- than, say, calling targetPart:Destroy()) is what makes this "fail like a real building"
    -- instead of "vanish" — the part is already Anchored = false, so once nothing welds it to
    -- the Baseplate anymore, gravity does the rest.
    local weld = targetPart:FindFirstChildOfClass("WeldConstraint")
    if weld then
        weld:Destroy()
    end
end)
