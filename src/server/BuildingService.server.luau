--[[
    BuildingService — builds BuildingSpec.TestBuilding into real Workspace Instances at server
    start, connected with real WeldConstraints, so the test building is reproducible from
    source instead of being a one-off hand-placed Studio model (Issue #2).

    File name ends in ".server.luau", which is what tells Rojo to make this a Script (runs
    automatically on the server) instead of a ModuleScript (which only runs when required).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local BuildingSpec = require(ReplicatedStorage.Shared.Structural.BuildingSpec)

local building = BuildingSpec.TestBuilding
local ok, err = BuildingSpec.validate(building)
if not ok then
    error("BuildingService: refusing to build an invalid BuildingSpec: " .. tostring(err))
end

local baseplate = Workspace:FindFirstChild("Baseplate")
assert(baseplate, "BuildingService requires a Baseplate in Workspace to anchor the building to")

local buildingFolder = Instance.new("Folder")
buildingFolder.Name = building.name
buildingFolder.Parent = Workspace

-- First pass: create and position every part before welding anything. This order matters:
-- WeldConstraint locks in whatever the relative offset between its two parts happens to be
-- at the moment the constraint is created, so a part has to already be in its final position
-- before we weld it — welding first and moving it after would leave the weld holding the
-- wrong offset.
local instancesById: { [string]: BasePart } = {}

for _, partSpec in building.parts do
    local instance = Instance.new(partSpec.shape) :: BasePart
    instance.Name = partSpec.id
    instance.Size = Vector3.new(partSpec.size[1], partSpec.size[2], partSpec.size[3])
    instance.Position =
        Vector3.new(partSpec.position[1], partSpec.position[2], partSpec.position[3])
    instance.Anchored = false
    if partSpec.color then
        instance.Color = Color3.new(partSpec.color[1], partSpec.color[2], partSpec.color[3])
    end
    instance.Parent = buildingFolder
    instancesById[partSpec.id] = instance
end

-- Second pass: every part now sits in its correct final position, so it's safe to weld.
-- A part with no `weldTo` welds straight to the (Anchored) Baseplate; everything else welds
-- to the part it names. Because every part traces back to the Baseplate one weld at a time,
-- the whole structure is held up the same way a real building's load eventually reaches the
-- ground — Epic 2 turns that same `weldTo` chain into the real load path graph.
for _, partSpec in building.parts do
    local instance = instancesById[partSpec.id]
    local anchorPart = if partSpec.weldTo then instancesById[partSpec.weldTo] else baseplate

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = instance
    weld.Part1 = anchorPart
    weld.Parent = instance
end
