--[[
TheNexusAvenger

Loads Nexus VR Backpack on the client for testing.
--]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local NexusVRBackpack = require(ReplicatedStorage:WaitForChild("NexusVRBackpack"))



--Prepare Nexus VR Backpack for non-VR testing.
if not UserInputService.VREnabled then
    --Modify the CharacterBackpack for non-VR testing.
    local CharacterBackpack = require(ReplicatedStorage:WaitForChild("NexusVRBackpack"):WaitForChild("CharacterBackpack"))
    local OriginalCharacterBackpackConstructor = CharacterBackpack.new
    CharacterBackpack.new = function(Character)
        --Create the backpack.
        local Backpack = OriginalCharacterBackpackConstructor(Character)

        --Continuously put it at the center of the view.
        table.insert(Backpack.Events, RunService.RenderStepped:Connect(function()
            Backpack.Backpack:MoveTo(Backpack:GetBackpackCFrame())
        end))

        --Return the backpack.
        return Backpack
    end

    CharacterBackpack.GetBackpackCFrame = function(self)
        return Workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -2)
    end

    CharacterBackpack.GetHandPosition = function(self)
        --The following is long because the API to test with is in world space.
        --Since the backpack is a SurfaceGui in 3D space, this is required to translate the mouse into 3D space relative to the backpack.
        local BackpackSize = self.Backpack.Part.Size
        local BackpackCFrame = Workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -2)
        local MouseLocation = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
        local UpperLeftCorner = Workspace.CurrentCamera:WorldToScreenPoint((BackpackCFrame * CFrame.new(-BackpackSize.X / 2, BackpackSize.Y / 2, 0)).Position)
        local BottomRightCorner = Workspace.CurrentCamera:WorldToScreenPoint((BackpackCFrame * CFrame.new(BackpackSize.X / 2, -BackpackSize.Y / 2, 0)).Position)
        local RelativeX = (MouseLocation.X - UpperLeftCorner.X) / (BottomRightCorner.X - UpperLeftCorner.X)
        local RelativeY = (MouseLocation.Y - UpperLeftCorner.Y) / (BottomRightCorner.Y - UpperLeftCorner.Y)
        return (BackpackCFrame * CFrame.new(BackpackSize.X * (RelativeX - 0.5), BackpackSize.Y * (0.5 - RelativeY), 0)).Position
    end

    --Set the non-VR keybind.
    NexusVRBackpack:SetKeyCode(Enum.KeyCode.Q)
end

--Load Nexus VR Backpack.
NexusVRBackpack:Load()