--[[
TheNexusAvenger

Class for a tool icon.
--]]

local ToolIcon = {}
ToolIcon.__index = ToolIcon



--[[
Creates the tool icon.
--]]
function ToolIcon.new(Parent: GuiObject, PositionX: number, PositionY: number)
    --Create the object.
    local self = {
        Focused = false,
        Players = game:GetService("Players"), --Stored to be replaced in unit tests.
        TweenService = game:GetService("TweenService"), --Stored to be replaced in unit tests.
        RelativePositionX = (PositionX * (math.sqrt(3) / 2)) + 0.5,
        RelativePositionY = (PositionY * 0.75) + 0.5,
    }
    setmetatable(self, ToolIcon)

    --Create the frames.
    local Background = Instance.new("ImageLabel")
    Background.BackgroundTransparency = 1
    Background.AnchorPoint = Vector2.new(0.5, 0.5)
    Background.Size = UDim2.new(0.9, 0, 0.9, 0)
    Background.Position = UDim2.new(self.RelativePositionX, 0, self.RelativePositionY, 0)
    Background.Image = "http://www.roblox.com/asset/?id=10708006436"
    Background.Name = self.RelativePositionX..","..self.RelativePositionY
    Background.ImageColor3 = Color3.new(0.1, 0.1, 0.1)
    Background.ImageTransparency = 0.8
    Background.Parent = Parent
    self.Background = Background

    local ToolText = Instance.new("TextLabel")
    ToolText.BackgroundTransparency = 1
    ToolText.AnchorPoint = Vector2.new(0.5, 0.5)
    ToolText.Position = UDim2.new(0.5, 0, 0.5, 0)
    ToolText.Size = UDim2.new(0.625, 0, 0.625, 0)
    ToolText.Font = Enum.Font.SourceSans
    ToolText.TextColor3 = Color3.new(1, 1, 1)
    ToolText.Text = ""
    ToolText.TextSize = (Background.AbsoluteSize.Y * 0.625) / 4
    ToolText.TextWrapped = true
    ToolText.Visible = false
    ToolText.Parent = Background
    self.ToolText = ToolText
    Background:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        ToolText.TextSize = (Background.AbsoluteSize.Y * 0.625) / 4
    end)

    local ToolImage = Instance.new("ImageLabel")
    ToolImage.BackgroundTransparency = 1
    ToolImage.AnchorPoint = Vector2.new(0.5, 0.5)
    ToolImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    ToolImage.Size = UDim2.new(0.625, 0, 0.625, 0)
    ToolImage.Visible = false
    ToolImage.Parent = Background
    self.ToolImage = ToolImage

    --Return the object.
    return self
end

--[[
Updates the color of the icon.
--]]
function ToolIcon:UpdateColor(): nil
    --Update the text and icon.
    if self.Tool then
        if self.Tool.TextureId == "" then
            self.ToolText.Visible = true
            self.ToolImage.Visible = false
            self.ToolText.Text = self.Tool.Name
        else
            self.ToolText.Visible = false
            self.ToolImage.Visible = true
            self.ToolImage.Image = self.Tool.TextureId
        end
    else
        self.ToolText.Visible = false
        self.ToolImage.Visible = false
    end

    --Determine the color, transparency, and size.
    local Color = Color3.new(0.1, 0.1, 0.1)
    local Transparency = (self.Tool and 0.5 or 0.8)
    local Size = ((self.Tool and self.Focused and UDim2.new(1.05, 0, 1.05, 0)) or UDim2.new(0.9, 0, 0.9, 0))
    if self.Tool then
        if self.Players.LocalPlayer.Character and self.Players.LocalPlayer.Character == self.Tool.Parent then
            if self.Focused then
                Color = Color3.new(0.2, 1, 0.2)
            else
                Color = Color3.new(0, 0.7, 0)
            end
        else
            if self.Focused then
                Color = Color3.new(0.2, 0.2, 0.2)
            end
        end
    end

    --Set the properties.
    self.TweenService:Create(self.Background, TweenInfo.new(0.1), {
        Size = Size,
        ImageColor3 = Color,
        ImageTransparency = Transparency,
    }):Play()
end

--[[
Sets the tool for the icon.
--]]
function ToolIcon:SetTool(Tool: Tool): nil
    if Tool == self.Tool then return end

    --Disconnect the tool events.
    self.Tool = Tool
    if self.ToolEvents then
        for _, Event in self.ToolEvents do
            Event:Disconnect()
        end
        self.ToolEvents = nil
    end
    self:UpdateColor()
    if not Tool then return end

    --Connect the tool events.
    self.ToolEvents = {}
    table.insert(self.ToolEvents, Tool.Changed:Connect(function(PropertyName)
        if PropertyName ~= "Name" and PropertyName ~= "TextureId" and PropertyName ~= "Parent" then return end
        self:UpdateColor()
    end))
end

--[[
Sets the icon as focused.
--]]
function ToolIcon:SetFocused(Focused: boolean): nil
    self.Focused = Focused
    self:UpdateColor()
end

--[[
Destroys the tool icon.
--]]
function ToolIcon:Destroy()
    self.Background:Destroy()
    if self.ToolEvents then
        for _, Event in self.ToolEvents do
            Event:Disconnect()
        end
        self.ToolEvents = nil
    end
end



return ToolIcon