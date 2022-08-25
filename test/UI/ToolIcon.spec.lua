--[[
TheNexusAvenger

Tests for the ToolIcon class.
--]]

local ServerScriptService = game:GetService("ServerScriptService")
local ToolIcon = require(ServerScriptService:WaitForChild("MainModule"):WaitForChild("NexusVRBackpack"):WaitForChild("UI"):WaitForChild("ToolIcon"))

return function()
    --Create the test tool icon and mock services.
    local TestToolIcon = nil
    beforeEach(function()
        TestToolIcon = ToolIcon.new(nil, 0, 0)
        TestToolIcon.Players = {
            LocalPlayer = {
                Character = Instance.new("Model"),
            },
        }
        TestToolIcon.TweenService = {
            Create = function(self, Ins, _, Properties)
                self.LastProperties = Properties
                for Name, Value in Properties do
                    Ins[Name] = Value
                end
                return {
                    Play = function() end
                }
            end,
            shouldHaveSet = function(Color, Size, Transparency)
                expect(TestToolIcon.TweenService.LastProperties.ImageColor3).to.equal(Color)
                expect(TestToolIcon.TweenService.LastProperties.Size).to.equal(Size)
                expect(TestToolIcon.TweenService.LastProperties.ImageTransparency).to.be.near(Transparency)
            end
        }
    end)
    afterEach(function()
        TestToolIcon:Destroy()
        TestToolIcon = nil
    end)

    --Run the tests.
    describe("ToolIcon with no tool", function()
        it("should have default properties", function()
            expect(TestToolIcon.Background.ImageTransparency).to.be.near(0.8)
            expect(TestToolIcon.Background.ImageColor3).to.equal(Color3.new(0.1, 0.1, 0.1))
            expect(TestToolIcon.Background.Size).to.equal(UDim2.new(0.9, 0, 0.9, 0))
        end)

        it("should not change when focused", function()
            TestToolIcon:SetFocused(true)
            expect(TestToolIcon.Background.ImageTransparency).to.be.near(0.8)
            expect(TestToolIcon.Background.ImageColor3).to.equal(Color3.new(0.1, 0.1, 0.1))
            expect(TestToolIcon.Background.Size).to.equal(UDim2.new(0.9, 0, 0.9, 0))
            TestToolIcon.TweenService.shouldHaveSet(Color3.new(0.1, 0.1, 0.1), UDim2.new(0.9, 0, 0.9, 0), 0.8)
        end)

        it("should not change when unfocused", function()
            TestToolIcon:SetFocused(true)
            TestToolIcon:SetFocused(false)
            expect(TestToolIcon.Background.ImageTransparency).to.be.near(0.8)
            expect(TestToolIcon.Background.ImageColor3).to.equal(Color3.new(0.1, 0.1, 0.1))
            expect(TestToolIcon.Background.Size).to.equal(UDim2.new(0.9, 0, 0.9, 0))
            TestToolIcon.TweenService.shouldHaveSet(Color3.new(0.1, 0.1, 0.1), UDim2.new(0.9, 0, 0.9, 0), 0.8)
        end)
    end)

    describe("ToolIcon with a tool with no icon", function()
        it("should show the tool name", function()
            local Tool = Instance.new("Tool")
            Tool.Name = "TestName"
            TestToolIcon:SetTool(Tool)

            expect(TestToolIcon.Background.ImageTransparency).to.be.near(0.5)
            expect(TestToolIcon.Background.ImageColor3).to.equal(Color3.new(0.1, 0.1, 0.1))
            expect(TestToolIcon.Background.Size).to.equal(UDim2.new(0.9, 0, 0.9, 0))
            expect(TestToolIcon.ToolText.Text).to.equal("TestName")
            expect(TestToolIcon.ToolText.Visible).to.equal(true)
            expect(TestToolIcon.ToolImage.Visible).to.equal(false)
            TestToolIcon.TweenService.shouldHaveSet(Color3.new(0.1, 0.1, 0.1), UDim2.new(0.9, 0, 0.9, 0), 0.5)
        end)

        it("should change when focused", function()
            local Tool = Instance.new("Tool")
            Tool.Name = "TestName"
            TestToolIcon:SetTool(Tool)

            TestToolIcon:SetFocused(true)
            expect(TestToolIcon.Background.ImageTransparency).to.be.near(0.5)
            expect(TestToolIcon.Background.ImageColor3).to.equal(Color3.new(0.2, 0.2, 0.2))
            expect(TestToolIcon.Background.Size).to.equal(UDim2.new(1.1, 0, 1.1, 0))
            TestToolIcon.TweenService.shouldHaveSet(Color3.new(0.2, 0.2, 0.2), UDim2.new(1.1, 0, 1.1, 0), 0.5)
        end)

        it("should become green when equipped", function()
            local Tool = Instance.new("Tool")
            Tool.Name = "TestName"
            TestToolIcon:SetTool(Tool)
            Tool.Parent = TestToolIcon.Players.LocalPlayer.Character
            task.wait()

            expect(TestToolIcon.Background.ImageTransparency).to.be.near(0.5)
            expect(TestToolIcon.Background.ImageColor3).to.equal(Color3.new(0, 0.7, 0))
            expect(TestToolIcon.Background.Size).to.equal(UDim2.new(0.9, 0, 0.9, 0))
            TestToolIcon.TweenService.shouldHaveSet(Color3.new(0, 0.7, 0), UDim2.new(0.9, 0, 0.9, 0), 0.5)

            TestToolIcon:SetFocused(true)
            expect(TestToolIcon.Background.ImageTransparency).to.be.near(0.5)
            expect(TestToolIcon.Background.ImageColor3).to.equal(Color3.new(0.2, 1, 0.2))
            expect(TestToolIcon.Background.Size).to.equal(UDim2.new(1.1, 0, 1.1, 0))
            TestToolIcon.TweenService.shouldHaveSet(Color3.new(0.2, 1, 0.2), UDim2.new(1.1, 0, 1.1, 0), 0.5)
        end)

        it("should reset when unequipped", function()
            local Tool = Instance.new("Tool")
            Tool.Name = "TestName"
            Tool.Parent = TestToolIcon.Players.LocalPlayer.Character
            TestToolIcon:SetTool(Tool)
            Tool.Parent = nil
            task.wait()

            expect(TestToolIcon.Background.ImageTransparency).to.be.near(0.5)
            expect(TestToolIcon.Background.ImageColor3).to.equal(Color3.new(0.1, 0.1, 0.1))
            expect(TestToolIcon.Background.Size).to.equal(UDim2.new(0.9, 0, 0.9, 0))
            TestToolIcon.TweenService.shouldHaveSet(Color3.new(0.1, 0.1, 0.1), UDim2.new(0.9, 0, 0.9, 0), 0.5)
        end)

        it("should update the tool name", function()
            local Tool = Instance.new("Tool")
            Tool.Name = "TestName"
            TestToolIcon:SetTool(Tool)
            expect(TestToolIcon.ToolText.Text).to.equal("TestName")

            Tool.Name = "NewName"
            task.wait()
            expect(TestToolIcon.ToolText.Text).to.equal("NewName")
        end)

        it("should change to an image", function()
            local Tool = Instance.new("Tool")
            Tool.Name = "TestName"
            TestToolIcon:SetTool(Tool)
            expect(TestToolIcon.ToolText.Text).to.equal("TestName")

            Tool.TextureId = "TestIcon"
            task.wait()
            expect(TestToolIcon.ToolImage.Image).to.equal("TestIcon")
            expect(TestToolIcon.ToolText.Visible).to.equal(false)
            expect(TestToolIcon.ToolImage.Visible).to.equal(true)
        end)

        it("should change tools", function()
            local Tool = Instance.new("Tool")
            Tool.Name = "TestName"
            TestToolIcon:SetTool(Tool)
            local NewTool = Instance.new("Tool")
            NewTool.Name = "NewName"
            TestToolIcon:SetTool(NewTool)

            expect(TestToolIcon.ToolText.Text).to.equal("NewName")
            expect(TestToolIcon.ToolText.Visible).to.equal(true)
            expect(TestToolIcon.ToolImage.Visible).to.equal(false)
        end)
    end)

    describe("ToolIcon with a tool with an icon", function()
        it("should show the tool icon", function()
            local Tool = Instance.new("Tool")
            Tool.Name = "TestName"
            Tool.TextureId = "TestIcon"
            TestToolIcon:SetTool(Tool)

            expect(TestToolIcon.Background.ImageTransparency).to.be.near(0.5)
            expect(TestToolIcon.Background.ImageColor3).to.equal(Color3.new(0.1, 0.1, 0.1))
            expect(TestToolIcon.Background.Size).to.equal(UDim2.new(0.9, 0, 0.9, 0))
            expect(TestToolIcon.ToolImage.Image).to.equal("TestIcon")
            expect(TestToolIcon.ToolText.Visible).to.equal(false)
            expect(TestToolIcon.ToolImage.Visible).to.equal(true)
            TestToolIcon.TweenService.shouldHaveSet(Color3.new(0.1, 0.1, 0.1), UDim2.new(0.9, 0, 0.9, 0), 0.5)
        end)

        it("should change to text", function()
            local Tool = Instance.new("Tool")
            Tool.Name = "TestName"
            Tool.TextureId = "TestIcon"
            TestToolIcon:SetTool(Tool)
            Tool.TextureId = ""
            task.wait()

            expect(TestToolIcon.Background.ImageTransparency).to.be.near(0.5)
            expect(TestToolIcon.Background.ImageColor3).to.equal(Color3.new(0.1, 0.1, 0.1))
            expect(TestToolIcon.Background.Size).to.equal(UDim2.new(0.9, 0, 0.9, 0))
            expect(TestToolIcon.ToolText.Text).to.equal("TestName")
            expect(TestToolIcon.ToolText.Visible).to.equal(true)
            expect(TestToolIcon.ToolImage.Visible).to.equal(false)
            TestToolIcon.TweenService.shouldHaveSet(Color3.new(0.1, 0.1, 0.1), UDim2.new(0.9, 0, 0.9, 0), 0.5)
        end)
    end)
end