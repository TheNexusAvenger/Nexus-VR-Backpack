--[[
TheNexusAvenger

Simple state manager for the tools the player has access to.
--]]

local Inventory = {}
Inventory.__index = Inventory



--[[
Creates the inventory.
--]]
function Inventory.new(Containers: {Instance}?)
    --Create the object.
    local self = {
        Containers = {},
        Tools = {},
        Events = {},
    }
    setmetatable(self, Inventory)

    --Add the event.
    self.ToolsChangedEvent = Instance.new("BindableEvent")
    self.ToolsChanged = self.ToolsChangedEvent.Event

    --Add the containers.
    if Containers then
        for _, Container in Containers do
            self:AddContainer(Container)
        end
    end

    --Return the object.
    return self
end

--[[
Adds a tool.
--]]
function Inventory:AddTool(Tool: Tool): nil
    if not Tool:IsA("Tool") and not Tool:IsA("HopperBin") then return end

    --Return if the tool is already stored.
    for i, OtherTool in self.Tools do
        if Tool == OtherTool then
            return
        end
    end

    --Add the tool.
    table.insert(self.Tools, Tool)
    self.ToolsChangedEvent:Fire()
end

--[[
Adds a tool.
--]]
function Inventory:RemoveTool(Tool: Tool): nil
    if not Tool:IsA("Tool") and not Tool:IsA("HopperBin") then return end

    --Return if the tool is in one of the containers.
    for _, Container in self.Containers do
        if Tool.Parent == Container then
            return
        end
    end

    --Determine the index and remove the tool.
    local ToolIndex = nil
    for i, OtherTool in self.Tools do
        if Tool == OtherTool then
            ToolIndex = i
            break
        end
    end
    if not ToolIndex then return end
    table.remove(self.Tools, ToolIndex)
    self.ToolsChangedEvent:Fire()
end

--[[
Adds a container to monitor.
--]]
function Inventory:AddContainer(Container: Instance): nil
    table.insert(self.Containers, Container)
    for _, Tool in Container:GetChildren() do
        self:AddTool(Tool)
    end
    table.insert(self.Events, Container.ChildAdded:Connect(function(Tool)
        self:AddTool(Tool)
    end))
    table.insert(self.Events, Container.ChildRemoved:Connect(function(Tool)
        self:RemoveTool(Tool)
    end))
end

--[[
Destroys the inventory.
--]]
function Inventory:Destroy(): nil
    for _, Event in self.Events do
        Event:Disconnect()
    end
    self.Events = {}
    self.Tools = {}
    self.Containers = {}
    self.ToolsChangedEvent:Destroy()
end



return Inventory