-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Component = require(Packages.Component)
local Janitor = require(Packages.Janitor)

-- // Objects
local Objects = ReplicatedStorage.Objects
local MoneyBag = Objects.MoneyBag

-- // Component
local SellZone = Component.new({
    Tag = "SellZone",
    Ancestors = {workspace}
})

function SellZone:Construct()
    self._janitor = Janitor.new()
end

function SellZone:Start()
    local MoneyZone = self.Instance.MoneyZone
    self._janitor:Add(self.Instance.SellZone.Touched:Connect(function(item)
        if item and item.Parent then
            if item.Parent:FindFirstChild("Config") then
                if item.Parent.Config:FindFirstChild("Price") then
                    local Price = item.Parent.Config.Price.Value
                    local MoneyBagClone = MoneyBag:Clone()
    
                    MoneyBagClone.Config.Price.Value = Price
                    MoneyBagClone.Parent = workspace
                    MoneyBagClone:PivotTo(MoneyZone.CFrame)
    
                    item.Parent:Destroy()
                end
            end
        end
    end))
end

function SellZone:Stop()
    self._janitor:Cleanup()
end

return SellZone