--[[
TheNexusAvenger

Main module and API for Nexus VR Backpack.
--]]
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local CharacterBackpack = require(script:WaitForChild("CharacterBackpack"))

local NexusVRBackpack = {}
NexusVRBackpack.Enabled = true



--[[
Creates a backpack for the current character.
--]]
function NexusVRBackpack:CreateBackpack()
    --Clear the existing backpack.
    if self.CurrentBackpack then
        self.CurrentBackpack:Destroy()
        self.CurrentBackpack = nil :: any
    end

    --Create the new backpack.
    if not Players.LocalPlayer.Character then return end
    self.CurrentBackpack = CharacterBackpack.new(Players.LocalPlayer.Character)
    self.CurrentBackpack.Enabled = self.Enabled
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
            if StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) then
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
            end
            task.wait()
        end
    end)

    --Set up the backpacks.
    Players.LocalPlayer.CharacterAdded:Connect(function()
        self:CreateBackpack()
    end)
    self:CreateBackpack()

    --Load the Nexus VR Character Model API.
    task.spawn(function()
        --Get the Nexus VR Character Model API.
        local NexusVRCharacterModel = require(ReplicatedStorage:WaitForChild("NexusVRCharacterModel", 10 ^ 99)) :: any
        if not NexusVRCharacterModel.Api then
            warn("Nexus VR Character Model is loaded by no API is found. This was added in V.2.4.0. Inputs on the right controller won't be disabled when interacting with the backpack.")
            return
        end
        (CharacterBackpack :: any).NexusVRCharacterModelControllerApi = NexusVRCharacterModel.Api:WaitFor("Controller")

        --Add the Nexus VR Backpack API.
        NexusVRCharacterModel.Api:Register("Backpack", {
            SetKeyCode = function(_, KeyCode: Enum.KeyCode): ()
                self:SetKeyCode(KeyCode)
            end,
            SetUserCFrame = function(_, UserCFrame: Enum.KeyCode): ()
                self:SetUserCFrame(UserCFrame)
            end,
        })
    end)
end

--[[
Returns if the backpack is enabled or disabled.
--]]
function NexusVRBackpack:GetBackpackEnabled(): boolean
    return self.Enabled
end

--[[
Sets the backpack as enabled or disabled.
--]]
function NexusVRBackpack:SetBackpackEnabled(Enabled: boolean): ()
    self.Enabled = (Enabled ~= false)
    if self.CurrentBackpack then
        self.CurrentBackpack.Enabled = self.Enabled
        if not self.Enabled then
            self.CurrentBackpack:Close()
        end
    end
end

--[[
Sets the key to use for opening and closing the backpack.
--]]
function NexusVRBackpack:SetKeyCode(KeyCode: Enum.KeyCode): ()
    self.OverrideKeyCode = KeyCode
    if self.CurrentBackpack then
        self.CurrentBackpack:SetKeyCode(KeyCode or Enum.KeyCode.ButtonR3)
    end
end

--[[
Sets the input to open the menu at.
--]]
function NexusVRBackpack:SetUserCFrame(UserCFrame: Enum.UserCFrame): ()
    self.OverrideUserCFrame = UserCFrame
    if self.CurrentBackpack then
        self.CurrentBackpack:SetUserCFrame(UserCFrame or Enum.UserCFrame.RightHand)
    end
end



return NexusVRBackpack