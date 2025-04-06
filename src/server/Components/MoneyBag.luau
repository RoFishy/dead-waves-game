-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Component = require(Packages.Component)
local Janitor = require(Packages.Janitor)

-- // Component
local MoneyBag = Component.new({
    Tag = "MoneyBag",
    Ancestors = {workspace}
})

function MoneyBag:Construct()
    self._janitor = Janitor.new()
end

function MoneyBag:Start()
    local Config = self.Instance:FindFirstChild("Config")
    assert(Config, "Moneybag configuration not found.")
    local Price = Config.Price

    local ProximityPrompt = Instance.new("ProximityPrompt")
    ProximityPrompt.Parent = self.Instance
    ProximityPrompt.HoldDuration = 1.5
    ProximityPrompt.ActionText = `${Price.Value}`
    ProximityPrompt.ObjectText = "Collect"
    ProximityPrompt.RequiresLineOfSight = false

    self._janitor:Add(ProximityPrompt.Triggered:Connect(function(player) 
        local leaderstats = player.leaderstats
        local Cash = leaderstats.Cash
        Cash.Value += Price.Value
        self.Instance:Destroy()
    end))
end

function MoneyBag:Stop()
    self._janitor:Cleanup()
end

return MoneyBag