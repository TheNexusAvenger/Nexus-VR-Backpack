--[[
TheNexusAvenger

Loads Nexus VR Backpack on the server for testing.
--]]

local TOTAL_TEST_TOOLS = 9

local ServerScriptService = game:GetService("ServerScriptService")
local StarterPack = game:GetService("StarterPack")
local HttpService = game:GetService("HttpService")



--Create the test tools.
for i = 1, TOTAL_TEST_TOOLS do
    local TestTool = Instance.new("Tool")
    TestTool.Name = HttpService:GenerateGUID()
    if math.random() > 0.5 then
        TestTool.TextureId = "http://www.roblox.com/asset/?id=94746192"
    end
    TestTool.Parent = StarterPack

    local TestHandle = Instance.new("Part")
    TestHandle.BrickColor = BrickColor.random()
    TestHandle.Size = Vector3.new(1, 1, 1)
    TestHandle.Name = "Handle"
    TestHandle.CanCollide = false
    TestHandle.Parent = TestTool
end

--Load Nexus VR Backpack.
require(ServerScriptService:WaitForChild("MainModule"))()