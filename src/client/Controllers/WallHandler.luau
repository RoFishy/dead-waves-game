-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService =game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- // Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local DistanceFade = require(Modules.DistanceFade)

-- // Objects
local GeneratedChunks = workspace:WaitForChild("GeneratedChunks")

-- // Settings
local Settings = {
    ["DistanceOuter"] = 80,
    ["DistanceInner"] = 50,
    ["EffectRadius"] = 32, 
	["EffectRadiusMin"] = 8, 
    ["EdgeDistanceCalculations"] = true,
	["Texture"] = "rbxassetid://18852900044",
	["TextureTransparency"] = .25,
	["BackgroundTransparency"] = 0.95,
	["TextureColor"] = Color3.fromRGB(115, 248, 255),
	["BackgroundColor"] = Color3.fromRGB(0, 153, 255),
	["TextureSize"] = Vector2.new(12, 11),
	["TextureOffset"] = Vector2.new(0, .5),
	["Brightness"] = 3,
}

local baseOffsetsX = {
	["1"] = -3,
	["2"] = -2,
	["3"] = -1,
	["4"] = 0,
	["5"] = 1,
	["6"] = 2,
	["7"] = 3
}

-- // Wall Handler
local WallHandler = {}

function WallHandler.Init()
    WallHandler.Fade = DistanceFade.new()
    WallHandler.Fade:UpdateSettings(Settings)
    WallHandler.Parts = {}
end

function WallHandler:Start()
    for _, Chunk in GeneratedChunks:GetChildren() do
        for _, Part in Chunk:WaitForChild("Barriers"):GetChildren() do
            table.insert(self.Parts, Part)
            self.Fade:AddFace(Part, Enum.NormalId.Front)
            self.Fade:AddFace(Part, Enum.NormalId.Back)
        end
    end

    GeneratedChunks.DescendantAdded:Connect(function(descendant)
        if descendant.Parent.Name == "Barriers" then
            table.insert(self.Parts, descendant)
            self.Fade:AddFace(descendant, Enum.NormalId.Front)
            self.Fade:AddFace(descendant, Enum.NormalId.Back)
        end
    end)

    local TweenValue = Instance.new("Vector3Value")
    TweenValue.Parent = script

    TweenService:Create(TweenValue, TweenInfo.new(6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false), { Value = Vector3.new(-6, 5.5) }):Play()

    RunService.Heartbeat:Connect(function(_)

        for _, v in self.Parts do
            local offsetX = baseOffsetsX[v.Name]
            local offsetY = TweenValue.Value.Y
            local newOffset = offsetX
            if offsetX then
                newOffset = -offsetX
            end
            self.Fade:UpdateFaceSettings(v, Enum.NormalId.Front, {["TextureOffset"] = Vector2.new(offsetX, offsetY)})
            self.Fade:UpdateFaceSettings(v, Enum.NormalId.Back, {["TextureOffset"] = Vector2.new(newOffset, offsetY)})
        end

        self.Fade:Step()
    end)
end

return WallHandler