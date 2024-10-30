--Main module and API for Nexus VR Backpack.
--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterBackpack = require(script:WaitForChild("CharacterBackpack"))

local NexusVRBackpack = {}
NexusVRBackpack.Enabled = true

export type NexusVRBackpack = {
    CurrentBackpack: CharacterBackpack.CharacterBackpack?,
    OverrideKeyCode: Enum.KeyCode?,
    OverrideUserCFrame: Enum.UserCFrame?,
} & typeof(NexusVRBackpack)



--[[
Creates a backpack for the current character.
--]]
function NexusVRBackpack.CreateBackpack(self: NexusVRBackpack): ()
    --Clear the existing backpack.
    if self.CurrentBackpack then
        self.CurrentBackpack:Destroy()
        self.CurrentBackpack = nil
    end

    --Create the new backpack.
    if not Players.LocalPlayer.Character then return end
    local NewBackpack = CharacterBackpack.new(Players.LocalPlayer.Character)
    NewBackpack.Enabled = self.Enabled
    if self.OverrideKeyCode then
        NewBackpack:SetKeyCode(self.OverrideKeyCode)
    end
    if self.OverrideUserCFrame then
        NewBackpack:SetUserCFrame(self.OverrideUserCFrame)
    end
    self.CurrentBackpack = NewBackpack
end

--[[
Loads Nexus VR Backpack.
--]]
function NexusVRBackpack.Load(self: NexusVRBackpack): ()
    --Set up the backpacks.
    Players.LocalPlayer.CharacterAdded:Connect(function()
        self:CreateBackpack()
    end)
    self:CreateBackpack()

    --Load the Nexus VR Character Model API.
    task.spawn(function()
        --Get the Nexus VR Character Model API.
        local NexusVRCharacterModel = require(ReplicatedStorage:WaitForChild("NexusVRCharacterModel", 10 ^ 99))
        if not NexusVRCharacterModel.Api then
            warn("Nexus VR Character Model is loaded by no API is found. This was added in V.2.4.0. Inputs on the right controller won't be disabled when interacting with the backpack.")
            return
        end
        (CharacterBackpack :: any).NexusVRCharacterModelControllerApi = NexusVRCharacterModel.Api:WaitFor("Controller")

        --Add the Nexus VR Backpack API.
        NexusVRCharacterModel.Api:Register("Backpack", {
            GetBackpackEnabled = function(_): boolean
                return self:GetBackpackEnabled()
            end,
            SetBackpackEnabled = function(_, Enabled: boolean): ()
                self:SetBackpackEnabled(Enabled)
            end,
            SetKeyCode = function(_, KeyCode: Enum.KeyCode): ()
                self:SetKeyCode(KeyCode)
            end,
            SetUserCFrame = function(_, UserCFrame: Enum.UserCFrame): ()
                self:SetUserCFrame(UserCFrame)
            end,
        })
    end)
end

--[[
Returns if the backpack is enabled or disabled.
--]]
function NexusVRBackpack.GetBackpackEnabled(self: NexusVRBackpack): boolean
    return self.Enabled
end

--[[
Sets the backpack as enabled or disabled.
--]]
function NexusVRBackpack.SetBackpackEnabled(self: NexusVRBackpack, Enabled: boolean): ()
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
function NexusVRBackpack.SetKeyCode(self: NexusVRBackpack, KeyCode: Enum.KeyCode): ()
    self.OverrideKeyCode = KeyCode
    if self.CurrentBackpack then
        self.CurrentBackpack:SetKeyCode(KeyCode or Enum.KeyCode.ButtonR3)
    end
end

--[[
Sets the input to open the menu at.
--]]
function NexusVRBackpack.SetUserCFrame(self: NexusVRBackpack, UserCFrame: Enum.UserCFrame): ()
    self.OverrideUserCFrame = UserCFrame
    if self.CurrentBackpack then
        self.CurrentBackpack:SetUserCFrame(UserCFrame or Enum.UserCFrame.RightHand)
    end
end



return NexusVRBackpack