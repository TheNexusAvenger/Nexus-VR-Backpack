--[[
TheNexusAvenger

Loads Nexus VR Backpack on the client for testing.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")



--Load Nexus VR Backpack.
local NexusVRBackpack = require(ReplicatedStorage:WaitForChild("NexusVRBackpack"))
if UserInputService.VREnabled then
    --TODO: Load for Nexus VR Character Model
else
    --TODO: Load non-VR tester
end