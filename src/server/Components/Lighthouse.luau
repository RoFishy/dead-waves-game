-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- // Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Component = require(Packages.Component)
local Janitor = require(Packages.Janitor)

-- // Component
local Lighthouse = Component.new({
    Tag = "Lighthouse",
    Ancestors = {workspace},
})

function Lighthouse:Construct()
    self._janitor = Janitor.new()
end

function Lighthouse:Start()
    local Light = self.Instance.Light
    local SpinPart = self.Instance.SpinPart

    self._janitor:Add(task.spawn(function()
        while task.wait() do
            if Lighting:GetMinutesAfterMidnight() > 6 * 60 then
                Light.PointLight.Enabled = false
                Light.Transparency = 1
            else
                Light.Transparency = 0
                Light.PointLight.Enabled = true
                Light.CFrame = Light.CFrame * CFrame.fromEulerAnglesXYZ(0,0.005,0)
                SpinPart.CFrame = SpinPart.CFrame * CFrame.fromEulerAnglesXYZ(0,0.005,0)
            end
        end
    end))
end

function Lighthouse:Stop()
    self._janitor:Cleanup()
end

return Lighthouse