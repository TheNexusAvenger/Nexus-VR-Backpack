--[[
TheNexusAvenger

Loader for Nexus VR Backpack.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")



return function()
    --Copy NexusVRBackpack to ReplicatedStorage if it doesn't exist already.
    --Client setup is up to Nexus VR Character Model or the game creator.
    if ReplicatedStorage:FindFirstChild("NexusVRBackpack") then return end
    script:WaitForChild("NexusVRBackpack").Parent = ReplicatedStorage
end