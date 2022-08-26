--[[
TheNexusAvenger

Tests for the Inventory class.
--]]

local ServerScriptService = game:GetService("ServerScriptService")
local Inventory = require(ServerScriptService:WaitForChild("MainModule"):WaitForChild("NexusVRBackpack"):WaitForChild("State"):WaitForChild("Inventory"))

return function()
    --Create the test inventory.
    local ToolsChangedEventCalls = 0
    local TestInventory = nil
    local TestTools = {}
    beforeEach(function()
        TestInventory = Inventory.new()
        TestInventory.ToolsChanged:Connect(function()
            ToolsChangedEventCalls += 1
        end)
        for _ = 1, 3 do
            table.insert(TestTools, Instance.new("Tool"))
        end
    end)
    afterEach(function()
        TestInventory:Destroy()
        TestInventory = nil
        for _, Tool in TestTools do
            Tool:Destroy()
        end
        TestTools = {}
        ToolsChangedEventCalls = 0
    end)

    --Run the tests.
    describe("A single container", function()
        it("should store existing tools.", function()
            local TestModel = Instance.new("Model")
            TestTools[1].Parent = TestModel
            TestTools[2].Parent = TestModel
            TestInventory:AddContainer(TestModel)

            expect(#TestInventory.Tools).to.equal(2)
            expect(TestInventory.Tools[1]).to.equal(TestTools[1])
            expect(TestInventory.Tools[2]).to.equal(TestTools[2])
        end)

        it("should accept new tools.", function()
            local TestModel = Instance.new("Model")
            TestTools[1].Parent = TestModel
            TestTools[2].Parent = TestModel
            TestInventory:AddContainer(TestModel)
            TestTools[3].Parent = TestModel
            task.wait()

            expect(ToolsChangedEventCalls).to.equal(3)
            expect(#TestInventory.Tools).to.equal(3)
            expect(TestInventory.Tools[1]).to.equal(TestTools[1])
            expect(TestInventory.Tools[2]).to.equal(TestTools[2])
            expect(TestInventory.Tools[3]).to.equal(TestTools[3])
        end)

        it("should remove tools.", function()
            local TestModel = Instance.new("Model")
            TestTools[1].Parent = TestModel
            TestTools[2].Parent = TestModel
            TestInventory:AddContainer(TestModel)
            TestTools[1].Parent = nil
            task.wait()

            expect(ToolsChangedEventCalls).to.equal(3)
            expect(#TestInventory.Tools).to.equal(1)
            expect(TestInventory.Tools[1]).to.equal(TestTools[2])
        end)
    end)

    describe("Multiple containers", function()
        it("should store tools from all in order.", function()
            local TestModel1 = Instance.new("Model")
            TestTools[1].Parent = TestModel1
            TestTools[3].Parent = TestModel1
            TestInventory:AddContainer(TestModel1)
            local TestModel2 = Instance.new("Model")
            TestTools[2].Parent = TestModel2
            TestInventory:AddContainer(TestModel2)

            expect(ToolsChangedEventCalls).to.equal(3)
            expect(#TestInventory.Tools).to.equal(3)
            expect(TestInventory.Tools[1]).to.equal(TestTools[1])
            expect(TestInventory.Tools[2]).to.equal(TestTools[3])
            expect(TestInventory.Tools[3]).to.equal(TestTools[2])
        end)

        it("should keep tools when moving containers without changing the order.", function()
            local TestModel1 = Instance.new("Model")
            TestTools[1].Parent = TestModel1
            TestTools[3].Parent = TestModel1
            TestInventory:AddContainer(TestModel1)
            local TestModel2 = Instance.new("Model")
            TestTools[2].Parent = TestModel2
            TestInventory:AddContainer(TestModel2)
            task.wait()
            TestTools[3].Parent = TestModel2

            expect(ToolsChangedEventCalls).to.equal(3)
            expect(#TestInventory.Tools).to.equal(3)
            expect(TestInventory.Tools[1]).to.equal(TestTools[1])
            expect(TestInventory.Tools[2]).to.equal(TestTools[3])
            expect(TestInventory.Tools[3]).to.equal(TestTools[2])
        end)

        it("should remove and re-add tools if they exit all containers and re-enter.", function()
            local TestModel1 = Instance.new("Model")
            TestTools[1].Parent = TestModel1
            TestTools[3].Parent = TestModel1
            TestInventory:AddContainer(TestModel1)
            local TestModel2 = Instance.new("Model")
            TestTools[2].Parent = TestModel2
            TestInventory:AddContainer(TestModel2)
            task.wait()
            TestTools[3].Parent = nil
            task.wait()
            TestTools[3].Parent = TestModel1

            expect(ToolsChangedEventCalls).to.equal(5)
            expect(#TestInventory.Tools).to.equal(3)
            expect(TestInventory.Tools[1]).to.equal(TestTools[1])
            expect(TestInventory.Tools[2]).to.equal(TestTools[2])
            expect(TestInventory.Tools[3]).to.equal(TestTools[3])
        end)
    end)

    describe("Containers passed in the constructor", function()
        it("should store tools from all in order.", function()
            local TestModel1 = Instance.new("Model")
            TestTools[1].Parent = TestModel1
            TestTools[3].Parent = TestModel1
            local TestModel2 = Instance.new("Model")
            TestTools[2].Parent = TestModel2
            local NewInventory = Inventory.new({TestModel1, TestModel2})

            expect(#NewInventory.Tools).to.equal(3)
            expect(NewInventory.Tools[1]).to.equal(TestTools[1])
            expect(NewInventory.Tools[2]).to.equal(TestTools[3])
            expect(NewInventory.Tools[3]).to.equal(TestTools[2])
            NewInventory:Destroy()
        end)
    end)
end