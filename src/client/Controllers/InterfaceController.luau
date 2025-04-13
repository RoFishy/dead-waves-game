-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // GUI
local HUD = PlayerGui:WaitForChild("HUD")

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local InterfaceRemotes = Remotes.Interface

local CashEffectRemote = InterfaceRemotes.CashEffect

-- // Objects
local Objects = ReplicatedStorage:WaitForChild("Objects")
local MoneyIcon = Objects:WaitForChild("MoneyIcon")

-- // Controller
local InterfaceController = {}

function InterfaceController:Start()
    CashEffectRemote.OnClientEvent:Connect(function()
        self:CashEffect()
    end)
end

function InterfaceController:CashEffect()
    for _ = 1, 25 do
        local Clone = MoneyIcon:Clone()
        Clone.Parent = HUD

        local size = math.random(1, 1) / 10
        Clone.Size = UDim2.fromScale(size, size)

        TweenService:Create(Clone, TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),{Position = UDim2.new(math.random(20, 80)/100, 0, math.random(10,90)/100, 0)}):Play()
        TweenService:Create(Clone, TweenInfo.new(.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Rotation = math.random(-90, 90)}):Play()
        TweenService:Create(Clone, TweenInfo.new(1.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
        TweenService:Create(Clone, TweenInfo.new(.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = Clone.Size + UDim2.fromScale(.1, .1)}):Play()
        --task.wait(.025)
        Debris:AddItem(Clone, 1)
    end
end

return InterfaceController