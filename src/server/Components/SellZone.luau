-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Component = require(Packages.Component)
local Janitor = require(Packages.Janitor)

-- // Objects
local Objects = ReplicatedStorage.Objects
local MoneyBag = Objects.MoneyBag

-- // Utils
local Utils = script.Parent.Parent.Utils
local SoundUtils = require(Utils.SoundUtils)

-- // Private Functions
local function SellItem(self, item)
    local Price = item.Config.Price.Value
    local MoneyBagClone = MoneyBag:Clone()

    SoundUtils.PlaySound(item.PrimaryPart.CFrame, "Sell")

    MoneyBagClone.Config.Price.Value = Price
    MoneyBagClone.Parent = workspace
    MoneyBagClone:PivotTo(self.Instance.MoneyZone.CFrame)

    item:Destroy()
end

-- // Component
local SellZone = Component.new({
    Tag = "SellZone",
    Ancestors = {workspace}
})

function SellZone:Construct()
    self._janitor = Janitor.new()
end

function SellZone:Start()
    self._janitor:Add(self.Instance.SellZone.Touched:Connect(function(item)
        if item and item.Parent then
            if item.Parent:FindFirstChild("Config") then
                if item.Parent.Config:FindFirstChild("Price") then
                    SellItem(self, item.Parent)
                end
            elseif item.Parent.Parent:FindFirstChild("Config") then
                if item.Parent.Parent.Config:FindFirstChild("Price") then
                    SellItem(self, item.Parent.Parent)
                end
            end
        end
    end))
end

function SellZone:Stop()
    self._janitor:Cleanup()
end

return SellZone