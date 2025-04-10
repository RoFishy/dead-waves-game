-- // Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

-- // Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

local Camera = workspace.CurrentCamera

-- // const
local MAX_RETRIES = 5

local function CoreCall(method, ...)
    local result = {}
    for _ = 1, MAX_RETRIES do
        result = {pcall(StarterGui[method], StarterGui, ...)}
        if result[1] then
            break
        end
        RunService.Stepped:Wait()
    end
    return unpack(result)
end

-- // Controller
local CameraController = {}

function CameraController.Init()
    LocalPlayer.CameraMaxZoomDistance = 0.5
    Camera.FieldOfView = 100
    Character.Humanoid.CameraOffset = Vector3.new(0, 0, -.8)
    Mouse.Icon = "rbxasset://11232270592"
    CoreCall('SetCore', 'ResetButtonCallback', false)
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