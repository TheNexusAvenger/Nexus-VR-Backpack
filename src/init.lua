--[[
TheNexusAvenger

Main module and API for Nexus VR Backpack.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local CharacterBackpack = require(script:WaitForChild("CharacterBackpack"))

local NexusVRBackpack = {}



--[[
Creates a backpack for the current character.
--]]
function NexusVRBackpack:CreateBackpack()
    --Clear the existing backpack.
    if self.CurrentBackpack then
        self.CurrentBackpack:Destroy()
        self.CurrentBackpack = nil
    end

    --Create the new backpack.
    if not Players.LocalPlayer.Character then return end
    self.CurrentBackpack = CharacterBackpack.new(Players.LocalPlayer.Character)
    if self.OverrideKeyCode then
        self.CurrentBackpack:SetKeyCode(self.OverrideKeyCode)
    end
    if self.OverrideUserCFrame then
        self.CurrentBackpack:SetUserCFrame(self.OverrideUserCFrame)
    end
end

--[[
Loads Nexus VR Backpack.
--]]
function NexusVRBackpack:Load()
    --Disable the default backpack.
    --Done in a loop in case the game tries to enable the default backpack.
    task.spawn(function()
        while true do
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
            task.wait(0.1)
        end
    end)

    --Set up the backpacks.
    Players.LocalPlayer.CharacterAdded:Connect(function()
        self:CreateBackpack()
    end)
    self:CreateBackpack()

    --Load the Nexus VR Character Model API.
    task.spawn(function()
        local NexusVRCharacterModel = require(ReplicatedStorage:WaitForChild("NexusVRCharacterModel", 10 ^ 99))
        if not NexusVRCharacterModel.Api then
            warn("Nexus VR Character Model is loaded by no API is found. This was added in V.2.4.0. Inputs on the right controller won't be disabled when interacting with the backpack.")
            return
        end
        CharacterBackpack.NexusVRCharacterModelControllerApi = NexusVRCharacterModel.Api:WaitFor("Controller")
    end)
end

--[[
Sets the key to use for opening and closing the backpack.
--]]
function NexusVRBackpack:SetKeyCode(KeyCode: Enum.KeyCode): nil
    self.OverrideKeyCode = KeyCode
    if self.CurrentBackpack then
        self.CurrentBackpack:SetKeyCode(KeyCode or Enum.KeyCode.ButtonR3)
    end
end

--[[
Sets the input to open the menu at.
--]]
function NexusVRBackpack:SetUserCFrame(UserCFrame: Enum.UserCFrame): nil
    self.OverrideUserCFrame = UserCFrame
    if self.CurrentBackpack then
        self.CurrentBackpack:SetUserCFrame(UserCFrame or Enum.UserCFrame.RightHand)
    end
end



return NexusVRBackpack