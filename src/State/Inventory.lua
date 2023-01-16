--[[
TheNexusAvenger

Simple state manager for the tools the player has access to.
--]]
--!strict

local Inventory = {}
Inventory.__index = Inventory

export type Inventory = {
    new: (Containers: {Instance}?) -> (Inventory),

    Tools: {BackpackItem},
    ToolsChanged: RBXScriptSignal,
    AddContainer: (self: Inventory, Container: Instance) -> (),
    Destroy: (self: Inventory) -> (),
}

--[[
Creates the inventory.
--]]
function Inventory.new(Containers: {Instance}?): Inventory
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
    return (self :: any) :: Inventory
end

--[[
Adds a tool.
--]]
function Inventory:AddTool(Tool: BackpackItem): ()
    if not Tool:IsA("BackpackItem") then return end

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
function Inventory:RemoveTool(Tool: BackpackItem): ()
    if not Tool:IsA("BackpackItem") then return end

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
function Inventory:AddContainer(Container: Instance): ()
    table.insert(self.Containers, Container)
    for _, Tool in Container:GetChildren() do
        self:AddTool(Tool :: BackpackItem)
    end
    table.insert(self.Events, Container.ChildAdded:Connect(function(Tool)
        self:AddTool(Tool :: BackpackItem)
    end))
    table.insert(self.Events, Container.ChildRemoved:Connect(function(Tool)
        self:RemoveTool(Tool :: BackpackItem)
    end))
end

--[[
Destroys the inventory.
--]]
function Inventory:Destroy(): ()
    for _, Event in self.Events do
        Event:Disconnect()
    end
    self.Events = {}
    self.Tools = {}
    self.Containers = {}
    self.ToolsChangedEvent:Destroy()
end



return (Inventory :: any) :: Inventory