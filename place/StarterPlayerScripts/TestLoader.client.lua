--[[
TheNexusAvenger

Loads Nexus VR Backpack on the client for testing.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")



--Load Nexus VR Backpack.
local NexusVRBackpack = require(ReplicatedStorage:WaitForChild("NexusVRBackpack"))
if UserInputService.VREnabled then
    --TODO: Load for Nexus VR Character Model
else
    local Character = Players.LocalPlayer.Character
    while not Character do Character = Players.LocalPlayer.Character task.wait() end

    local Backpack = require(ReplicatedStorage.NexusVRBackpack.UI.Backpack3D).new(Workspace.CurrentCamera, {
        Character,
        Players.LocalPlayer:WaitForChild("Backpack"),
    })

    UserInputService.InputBegan:Connect(function(Input, Processed)
        if Processed or Input.KeyCode ~= Enum.KeyCode.Q then return end
        if Backpack.Opened then
            Backpack:Close()
        else
            Backpack:Open()
        end
    end)

    while true do
        local BackpackSize = Backpack.Part.Size
        local BackpackCFrame = Workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -4)
        local MouseLocation = UserInputService:GetMouseLocation() - game:GetService("GuiService"):GetGuiInset()
        local UpperLeftCorner = Workspace.CurrentCamera:WorldToScreenPoint((BackpackCFrame * CFrame.new(-BackpackSize.X / 2, BackpackSize.Y / 2, 0)).Position)
        local BottomRightCorner = Workspace.CurrentCamera:WorldToScreenPoint((BackpackCFrame * CFrame.new(BackpackSize.X / 2, -BackpackSize.Y / 2, 0)).Position)
        local RelativeX = (MouseLocation.X - UpperLeftCorner.X) / (BottomRightCorner.X - UpperLeftCorner.X)
        local RelativeY = (MouseLocation.Y - UpperLeftCorner.Y) / (BottomRightCorner.Y - UpperLeftCorner.Y)

        Backpack:MoveTo(BackpackCFrame)
        Backpack:UpdateFocusedToolWorldSpace((BackpackCFrame * CFrame.new(BackpackSize.X * (RelativeX - 0.5), BackpackSize.Y * (0.5 - RelativeY), 0)).Position)
        RunService.RenderStepped:Wait()
    end
end