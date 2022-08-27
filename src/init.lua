--[[
TheNexusAvenger

Main module and API for Nexus VR Backpack.
--]]

local Players = game:GetService("Players")
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
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

    --Set up the backpacks.
    Players.LocalPlayer.CharacterAdded:Connect(function()
        self:CreateBackpack()
    end)
    self:CreateBackpack()
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