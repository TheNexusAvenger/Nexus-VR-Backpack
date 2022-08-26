--[[
TheNexusAvenger

Tests for the ToolGrid class.
--]]

local ServerScriptService = game:GetService("ServerScriptService")
local ToolGrid = require(ServerScriptService:WaitForChild("MainModule"):WaitForChild("NexusVRBackpack"):WaitForChild("UI"):WaitForChild("ToolGrid"))

return function()
     --Create the test tool grid and mock icon.
     local TestToolGrid = nil
     beforeEach(function()
        TestToolGrid = ToolGrid.new()
        TestToolGrid.CreateToolIcon = function(_, X, Y)
            return {
                Position = Vector2.new(X, Y),
                RelativePositionX = (X * (math.sqrt(3) / 2)) + 0.5,
                RelativePositionY = (Y * 0.75) + 0.5,
                Focused = false,
                SetFocused = function(self, Focused)
                    self.Focused = Focused
                end,
                SetTool = function(self, Tool)
                    self.Tool = Tool
                end,
                Destroy = function() end,
            }
        end
     end)
     afterEach(function()
        TestToolGrid:Destroy()
        TestToolGrid = nil
     end)

     --Run the tests.
     describe("A new tool grid of radius 1", function()
        it("should create a grid correctly.", function()
            TestToolGrid:SetRadius(1)

            expect(#TestToolGrid.IconGroups).to.equal(1)
            expect(#TestToolGrid.IconGroups[1]).to.equal(6)
            expect(TestToolGrid.IconGroups[1][1].Position).to.equal(Vector2.new(-0.5, -1))
            expect(TestToolGrid.IconGroups[1][2].Position).to.equal(Vector2.new(0.5, -1))
            expect(TestToolGrid.IconGroups[1][3].Position).to.equal(Vector2.new(1, 0))
            expect(TestToolGrid.IconGroups[1][4].Position).to.equal(Vector2.new(0.5, 1))
            expect(TestToolGrid.IconGroups[1][5].Position).to.equal(Vector2.new(-0.5, 1))
            expect(TestToolGrid.IconGroups[1][6].Position).to.equal(Vector2.new(-1, 0))
        end)

        it("should be created from no tools.", function()
            TestToolGrid:SetTools({})

            expect(#TestToolGrid.IconGroups).to.equal(1)
            expect(#TestToolGrid.IconGroups[1]).to.equal(6)
        end)

        it("should be created from enough tools.", function()
            TestToolGrid:SetTools({"MockTool", "MockTool", "MockTool", "MockTool"})

            expect(#TestToolGrid.IconGroups).to.equal(1)
            expect(#TestToolGrid.IconGroups[1]).to.equal(6)
        end)

        it("should be created from exactly enough tools.", function()
            TestToolGrid:SetTools({"MockTool", "MockTool", "MockTool", "MockTool", "MockTool", "MockTool"})

            expect(#TestToolGrid.IconGroups).to.equal(1)
            expect(#TestToolGrid.IconGroups[1]).to.equal(6)
        end)

        it("should scale up with too many tools.", function()
            TestToolGrid:SetTools({"MockTool", "MockTool", "MockTool", "MockTool", "MockTool", "MockTool"})
            expect(#TestToolGrid.IconGroups).to.equal(1)

            TestToolGrid:SetTools({"MockTool", "MockTool", "MockTool", "MockTool", "MockTool", "MockTool", "MockTool"})
            expect(#TestToolGrid.IconGroups).to.equal(2)
            expect(#TestToolGrid.IconGroups[1]).to.equal(6)
            expect(#TestToolGrid.IconGroups[2]).to.equal(12)
        end)

        it("should update the correct focused icon.", function()
            TestToolGrid:SetTools({"MockTool1", "MockTool2", "MockTool3", "MockTool4", "MockTool5", "MockTool6"})

            TestToolGrid:UpdateFocusedIcon(-0.2, -0.2)
            expect(TestToolGrid.FocusedIcon.Tool).to.equal("MockTool1")
            expect(TestToolGrid.IconGroups[1][1].Focused).to.equal(true)
            expect(TestToolGrid.IconGroups[1][2].Focused).to.equal(false)
            expect(TestToolGrid.IconGroups[1][3].Focused).to.equal(false)
            expect(TestToolGrid.IconGroups[1][4].Focused).to.equal(false)
            expect(TestToolGrid.IconGroups[1][5].Focused).to.equal(false)
            expect(TestToolGrid.IconGroups[1][6].Focused).to.equal(false)

            TestToolGrid:UpdateFocusedIcon(1, -0.2)
            expect(TestToolGrid.FocusedIcon.Tool).to.equal("MockTool2")
            expect(TestToolGrid.IconGroups[1][1].Focused).to.equal(false)
            expect(TestToolGrid.IconGroups[1][2].Focused).to.equal(true)
            expect(TestToolGrid.IconGroups[1][3].Focused).to.equal(false)
            expect(TestToolGrid.IconGroups[1][4].Focused).to.equal(false)
            expect(TestToolGrid.IconGroups[1][5].Focused).to.equal(false)
            expect(TestToolGrid.IconGroups[1][6].Focused).to.equal(false)

            TestToolGrid:UpdateFocusedIcon(0.4, 0.4)
            expect(TestToolGrid.FocusedIcon).to.equal(nil)
            expect(TestToolGrid.IconGroups[1][1].Focused).to.equal(false)
            expect(TestToolGrid.IconGroups[1][2].Focused).to.equal(false)
            expect(TestToolGrid.IconGroups[1][3].Focused).to.equal(false)
            expect(TestToolGrid.IconGroups[1][4].Focused).to.equal(false)
            expect(TestToolGrid.IconGroups[1][5].Focused).to.equal(false)
            expect(TestToolGrid.IconGroups[1][6].Focused).to.equal(false)
        end)
     end)

     describe("A new tool grid of radius 2", function()
        it("should create a grid correctly.", function()
            TestToolGrid:SetRadius(2)

            expect(#TestToolGrid.IconGroups).to.equal(2)
            expect(#TestToolGrid.IconGroups[1]).to.equal(6)
            expect(#TestToolGrid.IconGroups[2]).to.equal(12)
            expect(TestToolGrid.IconGroups[1][1].Position).to.equal(Vector2.new(-0.5, -1))
            expect(TestToolGrid.IconGroups[1][2].Position).to.equal(Vector2.new(0.5, -1))
            expect(TestToolGrid.IconGroups[1][3].Position).to.equal(Vector2.new(1, 0))
            expect(TestToolGrid.IconGroups[1][4].Position).to.equal(Vector2.new(0.5, 1))
            expect(TestToolGrid.IconGroups[1][5].Position).to.equal(Vector2.new(-0.5, 1))
            expect(TestToolGrid.IconGroups[1][6].Position).to.equal(Vector2.new(-1, 0))
            expect(TestToolGrid.IconGroups[2][1].Position).to.equal(Vector2.new(-1, -2))
            expect(TestToolGrid.IconGroups[2][2].Position).to.equal(Vector2.new(0, -2))
            expect(TestToolGrid.IconGroups[2][3].Position).to.equal(Vector2.new(1, -2))
            expect(TestToolGrid.IconGroups[2][4].Position).to.equal(Vector2.new(1.5, -1))
            expect(TestToolGrid.IconGroups[2][5].Position).to.equal(Vector2.new(2, 0))
            expect(TestToolGrid.IconGroups[2][6].Position).to.equal(Vector2.new(1.5, 1))
            expect(TestToolGrid.IconGroups[2][7].Position).to.equal(Vector2.new(1, 2))
            expect(TestToolGrid.IconGroups[2][8].Position).to.equal(Vector2.new(0, 2))
            expect(TestToolGrid.IconGroups[2][9].Position).to.equal(Vector2.new(-1, 2))
            expect(TestToolGrid.IconGroups[2][10].Position).to.equal(Vector2.new(-1.5, 1))
            expect(TestToolGrid.IconGroups[2][11].Position).to.equal(Vector2.new(-2, 0))
            expect(TestToolGrid.IconGroups[2][12].Position).to.equal(Vector2.new(-1.5, -1))
        end)

        it("should scale up with too many tools.", function()
            TestToolGrid:SetRadius(2)
            local MockTools = {}
            for _ = 1, 19 do
                table.insert(MockTools, "MockTool")
            end
            TestToolGrid:SetTools(MockTools)

            expect(#TestToolGrid.IconGroups).to.equal(3)
            expect(#TestToolGrid.IconGroups[1]).to.equal(6)
            expect(#TestToolGrid.IconGroups[2]).to.equal(12)
            expect(#TestToolGrid.IconGroups[3]).to.equal(18)
        end)

        it("should scale down with not enough tools.", function()
            TestToolGrid:SetRadius(2)
            TestToolGrid:SetTools({"MockTool1", "MockTool2", "MockTool3", "MockTool4", "MockTool5", "MockTool6"})

            expect(#TestToolGrid.IconGroups).to.equal(1)
            expect(#TestToolGrid.IconGroups[1]).to.equal(6)
        end)
    end)
end