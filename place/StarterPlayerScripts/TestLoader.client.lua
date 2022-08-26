--[[
TheNexusAvenger

Loads Nexus VR Backpack on the client for testing.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")



--Load Nexus VR Backpack.
local NexusVRBackpack = require(ReplicatedStorage:WaitForChild("NexusVRBackpack"))
if UserInputService.VREnabled then
    --TODO: Load for Nexus VR Character Model
else
    --TODO: Use backpack code when implemented.
    --Create the Tool Grid and ScreenGui.
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local ToolGrid = require(game.ReplicatedStorage.NexusVRBackpack.UI.ToolGrid).new()
    ToolGrid.AdornFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    ToolGrid.AdornFrame.Parent = ScreenGui
    ToolGrid.AdornFrame.Size = UDim2.new(0.2, 0, 0.2, 0)
    ToolGrid.AdornFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY

    local Inventory = require(game.ReplicatedStorage.NexusVRBackpack.State.Inventory).new()
    while not Players.LocalPlayer.Character do task.wait() end
    Inventory:AddContainer(Players.LocalPlayer.Character)
    Inventory:AddContainer(Players.LocalPlayer:WaitForChild("Backpack"))
    Inventory.ToolsChanged:Connect(function()
        ToolGrid:SetTools(Inventory.Tools)
    end)
    ToolGrid:SetTools(Inventory.Tools)

    --Update the input.
    while true do
        local MouseLocation = UserInputService:GetMouseLocation() - game:GetService("GuiService"):GetGuiInset()
        local RelativeX = ((MouseLocation.X - ToolGrid.AdornFrame.AbsolutePosition.X) / ToolGrid.AdornFrame.AbsoluteSize.X)
        local RelativeY = ((MouseLocation.Y - ToolGrid.AdornFrame.AbsolutePosition.Y) / ToolGrid.AdornFrame.AbsoluteSize.Y)
        ToolGrid:UpdateFocusedIcon(RelativeX, RelativeY)
        task.wait()
    end
end