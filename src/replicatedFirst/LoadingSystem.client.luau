-- // Services
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TweenService = game:GetService("TweenService")

-- // Player
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- // gui
local LoadingScreen = script.Parent:WaitForChild("LoadingScreen")

-- // const
local LOADING_TIPS = {
    "Tip: Use your sack to store items",
    "Don't forget to like the game and join the group!",
    "Follow @RoFishyOfficial on Twitter for special codes!",
    "Tip: Loot islands along the way!",
}

-- // remove screen
ReplicatedFirst:RemoveDefaultLoadingScreen()

-- // main
LoadingScreen.Parent = PlayerGui

local connection = task.spawn(function()
    while task.wait(1) do
        local Title = LoadingScreen.Background.Bottom.Loading
        Title.Text = Title.Text .. "."
        
        if Title.Text == "LOADING...." then
            Title.Text = "LOADING"
        end
    end
end)
local loadingTips = task.spawn(function()
    while task.wait(3) do
        local Tip = LoadingScreen.Background.Bottom.Tip
        Tip.Text = LOADING_TIPS[math.random(#LOADING_TIPS)]
    end
end)


task.wait(7)
repeat 
    task.wait() 
until game:IsLoaded()

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
task.cancel(loadingTips)
LoadingScreen:Destroy()