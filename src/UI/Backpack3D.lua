--[[
TheNexusAvenger

Class for the backpack in 3D space.
--]]
--!strict

local UI_PHYSICAL_SCALE = 0.5

local TweenService = game:GetService("TweenService")

local ToolGrid = require(script.Parent:WaitForChild("ToolGrid"))
local Inventory = require(script.Parent.Parent:WaitForChild("State"):WaitForChild("Inventory"))

local Backpack3D = {}
Backpack3D.__index = Backpack3D

export type Backpack3D = {
    new: (Parent: GuiObject, Containers: {Instance}) -> (Backpack3D),

    Opened: boolean,
    Inventory: Inventory.Inventory,
    GetFocusedTool: (self: Backpack3D) -> (BackpackItem?),
    UpdateFocusedToolWorldSpace: (self: Backpack3D, Position: Vector3) -> (),
    MoveTo: (self: Backpack3D, Location: CFrame) -> (),
    Open: (self: Backpack3D) -> (),
    Close: (self: Backpack3D) -> (),
    Destroy: (self: Backpack3D) -> (),
}



--[[
Creates the 3D backpack.
--]]
function Backpack3D.new(Parent: GuiObject, Containers: {Instance}): Backpack3D
    --Create the object.
    local self = {
        Opened = false,
    }
    setmetatable(self, Backpack3D)

    --Create the adornment.
    local SurfaceGui = Instance.new("SurfaceGui")
    SurfaceGui.Name = "NexusVRBackpack"
    SurfaceGui.AlwaysOnTop = true
    SurfaceGui.Enabled = false
    SurfaceGui.LightInfluence = 0
    SurfaceGui.Face = Enum.NormalId.Back
    SurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    SurfaceGui.PixelsPerStud = 250
    SurfaceGui.Parent = Parent
    self.SurfaceGui = SurfaceGui

    local Part = Instance.new("Part")
    Part.Transparency = 1
    Part.Size = Vector3.zero
    Part.Anchored = true
    Part.CanCollide = false
    Part.CanQuery = false
    Part.Parent = SurfaceGui
    SurfaceGui.Adornee = Part
    self.Part = Part

    local CenterFrame = Instance.new("Frame")
    CenterFrame.BackgroundTransparency = 1
    CenterFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    CenterFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    CenterFrame.Parent = SurfaceGui
    self.CenterFrame = CenterFrame

    local Cursor = Instance.new("Frame")
    Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
    Cursor.Size = UDim2.new(0.1, 0, 0.1, 0)
    Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
    Cursor.ZIndex = 10
    Cursor.Parent = CenterFrame
    self.Cursor = Cursor

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = Cursor

    --Create the tool grid.
    local BackpackToolGrid = ToolGrid.new()
    BackpackToolGrid.AdornFrame.Size = UDim2.new(0, 0, 0, 0)
    BackpackToolGrid.AdornFrame.Parent = CenterFrame
    self.ToolGrid = BackpackToolGrid

    --Create the inventory.
    local BackpackInventory = Inventory.new(Containers)
    self.Inventory = BackpackInventory
    BackpackInventory.ToolsChanged:Connect(function()
        self:UpdateInventory()
    end)
    self:UpdateInventory()

    --Return the object.
    return (self :: any) :: Backpack3D
end

--[[
Returns the focused tool, if any.
--]]
function Backpack3D:GetFocusedTool(): BackpackItem?
    return self.ToolGrid.FocusedIcon and self.ToolGrid.FocusedIcon.Tool
end

--[[
Updates the backpack when the tools change.
--]]
function Backpack3D:UpdateInventory(): ()
    --Update the tools.
    self.ToolGrid:SetTools(self.Inventory.Tools)

    --Update the size.
    local Diameter = (#self.ToolGrid.IconGroups * 2) + 1
    local DiameterScaled = Diameter * (math.sqrt(3) / 2)
    self.Part.Size = Vector3.new(DiameterScaled * UI_PHYSICAL_SCALE, DiameterScaled * UI_PHYSICAL_SCALE, 0)
    self.CenterFrame.Size = UDim2.new(1 / DiameterScaled, 0, 1 / DiameterScaled, 0)
end

--[[
Updates the focused tool in local space.
--]]
function Backpack3D:UpdateFocusedToolLocalSpace(RelativeX: number, RelativeY: number): ()
    if not self.Opened then return end
    local SurfaceGuiPositionX, SurfaceGuiPositionY = (self.SurfaceGui :: SurfaceGui).AbsoluteSize.X * RelativeX, (self.SurfaceGui :: SurfaceGui).AbsoluteSize.Y * RelativeY
    local GridX = (SurfaceGuiPositionX - self.CenterFrame.AbsolutePosition.X) / self.CenterFrame.AbsoluteSize.X
    local GridY = (SurfaceGuiPositionY - self.CenterFrame.AbsolutePosition.Y) / self.CenterFrame.AbsoluteSize.Y
    self.Cursor.Position = UDim2.new(GridX, 0, GridY, 0)
    self.ToolGrid:UpdateFocusedIcon(GridX, GridY)
end

--[[
Updates the focused tool in world space.
--]]
function Backpack3D:UpdateFocusedToolWorldSpace(Position: Vector3): ()
    local RelativeCFrame = (self.Part :: Part).CFrame:Inverse() * CFrame.new(Position)
    local Size = self.Part.Size
    self:UpdateFocusedToolLocalSpace((RelativeCFrame.X / Size.X) + 0.5, 0.5 - (RelativeCFrame.Y / Size.Y))
end

--[[
Moves the backpack to the specified CFrame.
--]]
function Backpack3D:MoveTo(Location: CFrame): ()
    self.Part.CFrame = Location
end

--[[
Opens the backpack.
--]]
function Backpack3D:Open(): ()
    if self.Opened then return end
    self.Opened = true
    self.SurfaceGui.Enabled = true
    TweenService:Create(self.ToolGrid.AdornFrame, TweenInfo.new(0.1), {
        Size = UDim2.new(1, 0, 1, 0)
    }):Play()
end

--[[
Closes the backpack.
--]]
function Backpack3D:Close(): ()
    if not self.Opened then return end
    self:UpdateFocusedToolLocalSpace(math.huge, math.huge)
    self.Opened = false
    TweenService:Create(self.ToolGrid.AdornFrame, TweenInfo.new(0.1), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.delay(0.1, function()
        if self.Opened then return end
        self.SurfaceGui.Enabled = false
    end)
end

--[[
Destroys the backpack.
--]]
function Backpack3D:Destroy(): ()
    self.SurfaceGui:Destroy()
    self.ToolGrid:Destroy()
    self.Inventory:Destroy()
end



return (Backpack3D :: any) :: Backpack3D