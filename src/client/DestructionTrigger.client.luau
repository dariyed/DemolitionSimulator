--[[
    DestructionTrigger — Issue #3's crude manual-test trigger. Press F to ask the server to
    destroy the one designated test part (DestructionRequest.TEST_TARGET_ID).

    This script only ever asks — it has no say in whether anything actually happens.
    DestructionService on the server is the one that validates the request and decides
    whether the part actually fails. If you (or anyone) modified this script to request a
    different part, the server would still reject it: the legal target lives in
    DestructionRequest, not here.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local DestructionRequest = require(ReplicatedStorage.Shared.Destruction.DestructionRequest)

-- WaitForChild, not FindFirstChild: DestructionService creates these at server start, but
-- this client script can start running before that finishes, so it has to wait rather than
-- assume the Remotes folder already exists.
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local destructionRequested = remotesFolder:WaitForChild("DestructionRequested") :: RemoteEvent

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
    -- gameProcessedEvent is true when the input was already consumed by something else (a
    -- text box, a menu) — skip it so this doesn't fire while, say, typing in chat.
    if gameProcessedEvent then
        return
    end
    if input.KeyCode == Enum.KeyCode.F then
        destructionRequested:FireServer({ partId = DestructionRequest.TEST_TARGET_ID })
    end
end)
