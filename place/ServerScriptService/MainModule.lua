--[[
TheNexusAvenger

Loader for Nexus VR Backpack.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")



--Copy NexusVRBackpack to ReplicatedStorage if it doesn't exist already.
--Client setup is up to Nexus VR Character Model or the game creator.
if ReplicatedStorage:FindFirstChild("NexusVRBackpack") then return end
script:WaitForChild("NexusVRBackpack").Parent = ReplicatedStorage

--Return true so that there are no errors.
return true