-- // Services
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")

-- // Player
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- // gui
local LoadingScreen = script.Parent:WaitForChild("LoadingScreen")

-- // remove screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

-- // main
LoadingScreen.Parent = PlayerGui

local connection = task.spawn(function()
    while task.wait(1) do
        local Title = LoadingScreen.Background.Bottom.Loading
        Title.Text = Title.Text .. "."
        if Title.Text == "LoadingScreen..." then
            Title.Text = "LoadingScreen"
        end
    end
end)


task.wait(3)
if not game:IsLoaded() then
    game.Loaded:Wait()
end

for _, v in LoadingScreen:GetDescendants() do
    if v:IsA("Frame") then
        TweenService:Create(v, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    elseif v:IsA("ImageLabel") then
        TweenService:Create(v, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
    elseif v:IsA("TextLabel") then
        TweenService:Create(v, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    end
end
task.wait(.5)
task.cancel(connection)
LoadingScreen:Destroy()