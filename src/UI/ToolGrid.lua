--[[
TheNexusAvenger

Hexagon grid for showing tools.
--]]
--!strict

local ToolIcon = require(script.Parent:WaitForChild("ToolIcon"))

local ToolGrid = {}
ToolGrid.__index = ToolGrid

export type ToolGrid = {
    new: () -> (ToolGrid),

    AdornFrame: Frame,
    IconGroups: {{any}},
    SetTools: (self: ToolGrid, Tools: {BackpackItem}) -> (),
    UpdateFocusedIcon: (self: ToolGrid, RelativePositionX: number, RelativePositionY: number) -> (),
    Destroy: (self: ToolGrid) -> (),
}



--[[
Creates the tool grid.
--]]
function ToolGrid.new(): ToolGrid
    --Create the object.
    local self = {
        IconGroups = {}
    }
    setmetatable(self, ToolGrid)

    --Create the adorn frame.
    local AdornFrame = Instance.new("Frame")
    AdornFrame.BackgroundTransparency = 1
    AdornFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    AdornFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.AdornFrame = AdornFrame

    --Return the object.
    return (self :: any) :: ToolGrid
end

--[[
Creates a ToolIcon.
--]]
function ToolGrid:CreateToolIcon(RelativePositionX: number, RelativePositionY: number)
    return ToolIcon.new(self.AdornFrame, RelativePositionX, RelativePositionY)
end

--[[
Sets the radius of the grid.
--]]
function ToolGrid:SetRadius(Radius: number): ()
    Radius = math.max(1, Radius)
    if Radius == #self.IconGroups then return end

    --Create the grids that don't exist.
    for i = #self.IconGroups + 1, Radius do
        --Create the top row.
        local NewGroup = {}
        for j = 1, i + 1 do
            table.insert(NewGroup, self:CreateToolIcon((-(i + 1) / 2) + j - 0.5, -i))
        end

        --Create the sides.
        local LeftSideIcons = {}
        local CurrentRowSize = i + 1
        for j = 2, (2 * i) do
            if j <= i + 1 then
                CurrentRowSize += 1
            else
                CurrentRowSize += -1
            end
            table.insert(LeftSideIcons, self:CreateToolIcon((-(CurrentRowSize) / 2) + 1 - 0.5, -i + j - 1))
            table.insert(NewGroup, self:CreateToolIcon((-(CurrentRowSize) / 2) + CurrentRowSize - 0.5, -i + j - 1))
        end

        --Create the bottom row and store the left side icons.
        for j = i + 1, 1, -1 do
            table.insert(NewGroup, self:CreateToolIcon((-(i + 1) / 2) + j - 0.5, i))
        end
        for j = #LeftSideIcons, 1, -1 do
            table.insert(NewGroup, LeftSideIcons[j])
        end

        --Store the group.
        table.insert(self.IconGroups, NewGroup)
    end

    --Remove the extra rows.
    for i = #self.IconGroups, Radius + 1, -1 do
        local Group = self.IconGroups[i]
        table.remove(self.IconGroups, i)
        for _, Icon in Group do
            Icon:Destroy()
        end
    end
end

--[[
Sets the tools for the grid to show.
--]]
function ToolGrid:SetTools(Tools: {BackpackItem}): ()
    --Update the radius.
    local MinimumRadius = 1
    local OpenSlots = 6
    while #Tools > OpenSlots do
        MinimumRadius += 1
        OpenSlots += (6 * MinimumRadius)
    end
    self:SetRadius(MinimumRadius)

    --Assign the tools.
    local CurrentToolId = 1
    for _, IconGroup in self.IconGroups do
        for _, Icon in IconGroup do
            Icon:SetTool(Tools[CurrentToolId])
            CurrentToolId += 1
        end
    end
end

--[[
Updates the icon that is focused.
--]]
function ToolGrid:UpdateFocusedIcon(RelativePositionX: number, RelativePositionY: number): ()
    --Determine the new focused icon.
    local NewFocusedIcon = nil
    local DistanceToFocusedIcon = 0.5
    for _, IconGroup in self.IconGroups do
        for _, Icon in IconGroup do
            local DistanceTo = (((RelativePositionX - Icon.RelativePositionX) ^ 2) + ((RelativePositionY - Icon.RelativePositionY) ^ 2)) ^ 0.5
            if DistanceTo < DistanceToFocusedIcon then
                NewFocusedIcon = Icon
                DistanceToFocusedIcon = DistanceTo
            end
        end
    end

    --Update the focused icon.
    if NewFocusedIcon ~= self.FocusedIcon then
        if self.FocusedIcon then
            self.FocusedIcon:SetFocused(false)
        end
        if NewFocusedIcon then
            NewFocusedIcon:SetFocused(true)
        end
        self.FocusedIcon = NewFocusedIcon
    end
end

--[[
Destroys the tool grid.
--]]
function ToolGrid:Destroy()
    self.AdornFrame:Destroy()
    for _, IconGroup in self.IconGroups do
        for _, Icon in IconGroup do
            Icon:Destroy()
        end
    end
    self.IconGroups = {}
end



return (ToolGrid :: any) :: ToolGrid