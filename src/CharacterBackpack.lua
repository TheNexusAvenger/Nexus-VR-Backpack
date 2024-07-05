--[[
TheNexusAvenger

Backpack associated with a character.
--]]
--!strict

local PROCESSED_KEYCODES_WHITELIST = {
    [Enum.KeyCode.ButtonL3] = true, --Left thumbstick.
    [Enum.KeyCode.ButtonR3] = true, --Right thumbstick.
}

local VRService = game:GetService("VRService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Backpack3D = require(script.Parent:WaitForChild("UI"):WaitForChild("Backpack3D"))

local CharacterBackpack = {}
CharacterBackpack.__index = CharacterBackpack

export type CharacterBackpack = {
    new: (Character: Model) -> (CharacterBackpack),

    Enabled: boolean,
    SetKeyCode: (self: CharacterBackpack, KeyCode: Enum.KeyCode) -> (),
    SetUserCFrame: (self: CharacterBackpack, UserCFrame: Enum.UserCFrame) -> (),
    Open: (self: CharacterBackpack) -> (),
    Close: (self: CharacterBackpack) -> (),
    Destroy: (self: CharacterBackpack) -> (),
}



--[[
Creates the character backpack.
--]]
function CharacterBackpack.new(Character: Model): CharacterBackpack
    --Create the object.
    local self = {
        Enabled = true,
        Player = Players:GetPlayerFromCharacter(Character),
        KeyCode = Enum.KeyCode.ButtonR3,
        UserCFrame = Enum.UserCFrame.RightHand,
        Events = {},
    }
    setmetatable(self, CharacterBackpack)

    --Wait for the Humanoid.
    self.Humanoid = Character:FindFirstChildOfClass("Humanoid")
    while not self.Humanoid do
        Character.ChildAdded:Wait()
        self.Humanoid = Character:FindFirstChildOfClass("Humanoid")
    end

    --Create the backpack.
    self.Backpack = Backpack3D.new(self.Player:WaitForChild("PlayerGui"), {Character, self.Player:WaitForChild("Backpack")})

    --Connect the interact events.
    table.insert(self.Events, UserInputService.InputBegan:Connect(function(Input, Processed)
        if Input.KeyCode ~= self.KeyCode then return end
        if Processed and not PROCESSED_KEYCODES_WHITELIST[Input.KeyCode] then return end
        if #self.Backpack.Inventory.Tools == 0 then return end
        self:Open()
    end))
    table.insert(self.Events, UserInputService.InputEnded:Connect(function(Input)
        if Input.KeyCode ~= self.KeyCode then return end
        self:Close()
    end))

    --Connect the destroy events.
    table.insert(self.Events, (self :: any).Humanoid.Died:Connect(function()
        self:Destroy()
    end))
    table.insert(self.Events, self.Player.CharacterAdded:Connect(function()
        self:Destroy()
    end))
    table.insert(self.Events, self.Player.CharacterRemoving:Connect(function()
        self:Destroy()
    end))

    --Set the default KeyCode.
    --This will open up the backpack if it is already pressed.
    self:SetKeyCode(Enum.KeyCode.ButtonR3)

    --Return the object.
    return (self :: any) :: CharacterBackpack
end

--[[
Returns the CFrame to open the backpack at.
--]]
function CharacterBackpack:GetBackpackCFrame(): CFrame
    return (Workspace.CurrentCamera:GetRenderCFrame() * UserInputService:GetUserCFrame(Enum.UserCFrame.Head):Inverse() * UserInputService:GetUserCFrame(self.UserCFrame))
end

--[[
Returns the position the hand is at.
--]]
function CharacterBackpack:GetHandPosition(): Vector3
    return self:GetBackpackCFrame().Position
end

--[[
Sets the key to use for opening and closing the backpack.
--]]
function CharacterBackpack:SetKeyCode(KeyCode: Enum.KeyCode): ()
    self.KeyCode = KeyCode
    if UserInputService:IsKeyDown(KeyCode) then
        self:Open()
    end
end

--[[
Sets the input to open the menu at.
--]]
function CharacterBackpack:SetUserCFrame(UserCFrame: Enum.UserCFrame): ()
    self.UserCFrame = UserCFrame
end

--[[
Opens the backpack.
--]]
function CharacterBackpack:Open(): ()
    --Open the backpack.
    if not self.Enabled then return end
    if self.Backpack.Opened then return end
    self.Backpack:Open()
    local NexusVRCharacterModelControllerApi = (self :: any).NexusVRCharacterModelControllerApi
    if NexusVRCharacterModelControllerApi then
        NexusVRCharacterModelControllerApi:DisableControllerInput(self.UserCFrame)
    end

    --Update the position and focus until it is closed.
    local OriginOffset = (Workspace.CurrentCamera:GetRenderCFrame() * VRService:GetUserCFrame(Enum.UserCFrame.Head):Inverse()):Inverse() * self:GetBackpackCFrame()
    self.UpdateFocusEvent = RunService.RenderStepped:Connect(function()
        self.Backpack:MoveTo(Workspace.CurrentCamera:GetRenderCFrame() * VRService:GetUserCFrame(Enum.UserCFrame.Head):Inverse() * OriginOffset)
        self.Backpack:UpdateFocusedToolWorldSpace(self:GetHandPosition())
    end)
end

--[[
Closes the backpack.
--]]
function CharacterBackpack:Close(): ()
    if not self.Backpack.Opened then return end

    --Update the tool.
    if self.UpdateFocusEvent then
        self.UpdateFocusEvent:Disconnect()
        self.UpdateFocusEvent = nil
    end
    local SelectedTool = self.Backpack:GetFocusedTool()
    if SelectedTool then
        (self.Humanoid :: Humanoid):EquipTool(SelectedTool :: Tool)
    else
        (self.Humanoid :: Humanoid):UnequipTools()
    end

    --Close the backpack.
    self.Backpack:Close()
    local NexusVRCharacterModelControllerApi = (self :: any).NexusVRCharacterModelControllerApi
    if NexusVRCharacterModelControllerApi then
        NexusVRCharacterModelControllerApi:EnableControllerInput(self.UserCFrame)
    end
end

--[[
Destroys the backpack.
--]]
function CharacterBackpack:Destroy(): ()
    --Disconnect the events.
    if self.UpdateFocusEvent then
        self.UpdateFocusEvent:Disconnect()
        self.UpdateFocusEvent = nil
    end
    for _, Event in self.Events do
        Event:Disconnect()
    end
    self.Events = {}

    --Close and clear the backpack.
    if self.Backpack.Opened then
        self.Backpack:Close()
        task.delay(0.1, function()
            self.Backpack:Destroy()
        end)
    else
        self.Backpack:Destroy()
    end
end


return (CharacterBackpack :: any) :: CharacterBackpack