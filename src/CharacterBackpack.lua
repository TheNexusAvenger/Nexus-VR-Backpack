--[[
TheNexusAvenger

Backpack associated with a character.
--]]

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Backpack3D = require(script.Parent:WaitForChild("UI"):WaitForChild("Backpack3D"))

local CharacterBackpack = {}
CharacterBackpack.__index = CharacterBackpack



--[[
Creates the character backpack.
--]]
function CharacterBackpack.new(Character: Model)
    --Create the object.
    local self = {
        Player = Players:GetPlayerFromCharacter(Character),
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
        if Processed then return end
        if Input.KeyCode ~= self.KeyCode then return end
        self:Open()
    end))
    table.insert(self.Events, UserInputService.InputEnded:Connect(function(Input)
        if Input.KeyCode ~= self.KeyCode then return end
        self:Close()
    end))

    --Connect the destroy events.
    table.insert(self.Events, self.Humanoid.Died:Connect(function()
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
    return self
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
function CharacterBackpack:SetKeyCode(KeyCode: Enum.KeyCode): nil
    self.KeyCode = KeyCode
    if UserInputService:IsKeyDown(KeyCode) then
        self:Open()
    end
end

--[[
Sets the input to open the menu at.
--]]
function CharacterBackpack:SetUserCFrame(UserCFrame: Enum.UserCFrame): nil
    self.UserCFrame = UserCFrame
end

--[[
Opens the backpack.
--]]
function CharacterBackpack:Open(): nil
    --Open the backpack.
    if self.Backpack.Opened then return end
    self.Backpack:MoveTo(self:GetBackpackCFrame())
    self.Backpack:Open()

    --Update the focus until it is closed.
    self.UpdateFocusEvent = RunService.RenderStepped:Connect(function()
        self.Backpack:UpdateFocusedToolWorldSpace(self:GetHandPosition())
    end)
end

--[[
Closes the backpack.
--]]
function CharacterBackpack:Close(): nil
    if not self.Backpack.Opened then return end

    --Update the tool.
    if self.UpdateFocusEvent then
        self.UpdateFocusEvent:Disconnect()
        self.UpdateFocusEvent = nil
    end
    local SelectedTool = self.Backpack:GetFocusedTool()
    if SelectedTool then
        self.Humanoid:EquipTool(SelectedTool)
    else
        self.Humanoid:UnequipTools()
    end

    --Close the backpack.
    self.Backpack:Close()
end

--[[
Destroys the backpack/
--]]
function CharacterBackpack:Destroy()
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


return CharacterBackpack