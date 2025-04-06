-- // Services
local Players = game:GetService("Players")

-- // Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

local Camera = workspace.CurrentCamera

-- // Controller
local CameraController = {}

function CameraController.Init()
    LocalPlayer.CameraMaxZoomDistance = 0.5
    Camera.FieldOfView = 100
    Character.Humanoid.CameraOffset = Vector3.new(0, 0, -.8)
    Mouse.Icon = "rbxasset://11232270592"
end

function CameraController:Start()
    for _, child in Character:GetChildren() do
        if child:IsA("BasePart") and child.Name ~= "Head" then
            child:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
                child.LocalTransparencyModifier = child.Transparency
            end)

            child.LocalTransparencyModifier = child.Transparency
        end
    end

    Camera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
        if Camera.CameraSubject:IsA("VehicleSeat") then
            Camera.CameraSubject = Character.Humanoid
        end
    end)
end

return CameraController