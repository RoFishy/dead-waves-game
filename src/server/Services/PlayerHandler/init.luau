-- // Roblox Services
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Services
local TerrainHandler = require(script.Parent.TerrainHandler)

-- // Objects
local Objects = ReplicatedStorage.Objects
local BackpackObject = Objects.Backpack

-- // Data
local PlayerBackpacks = {}

-- // Vars
local BackpackColors = {
    BrickColor.new("Brown"),
    BrickColor.new("Curry"),
    BrickColor.new("Crimson"),
    BrickColor.new("Dark Royal blue"),
    BrickColor.new("Tr. Green"),
    BrickColor.new("Silver")
}

-- // Local Functions
local function SpawnPlayer(Character : Model)
    local Spawns = TerrainHandler:GetSpawns()
    local RandomSpawn = Spawns[tostring(math.random(1, #Spawns:GetChildren()))]
    Character:PivotTo(RandomSpawn.CFrame)
end

local function RegisterPlayerCollisions(Character : Model)
    for _, Part in Character:GetChildren() do
        if Part:IsA("BasePart") then
            Part.CollisionGroup = "Player"
        end
    end
end

local PlayerHandler = {}

function PlayerHandler.Init()
    PhysicsService:RegisterCollisionGroup("Player")
    PhysicsService:RegisterCollisionGroup("Item")
    PhysicsService:CollisionGroupSetCollidable("Item", "Player", false)
end

function PlayerHandler:Start()
    Players.PlayerAdded:Connect(function(Player : Player)
        Player.DevEnableMouseLock = false

        -- leaderstats
        local leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = Player

        local Cash = Instance.new("IntValue")
        Cash.Name = "Cash"
        Cash.Parent = leaderstats
        Cash.Value = 20

        PlayerBackpacks[Player] = {}

        local BackpackFolder = Instance.new("Folder")
        BackpackFolder.Parent = ReplicatedStorage.Backpacks
        BackpackFolder.Name = Player.Name

        Player.CharacterAdded:Connect(function(Character : Model)
            SpawnPlayer(Character)
            RegisterPlayerCollisions(Character)

            local RandomColor = BackpackColors[math.random(1, #BackpackColors)]

            local Backpack = BackpackObject:Clone()
            Backpack.Parent = Character
            Backpack.CFrame = (Character.Torso.CFrame * CFrame.Angles(math.rad(180), 0, 0))
            Backpack.Position -= -(Backpack.CFrame.LookVector * 0.4)
            Backpack.Position -= Vector3.new(0, 0.15, 0)
            Backpack.BrickColor = RandomColor

            table.remove(BackpackColors, table.find(BackpackColors, RandomColor))

            local WeldConstraint = Instance.new("WeldConstraint")
            WeldConstraint.Parent = Character.Torso
            WeldConstraint.Part0 = Character.Torso
            WeldConstraint.Part1 = Backpack
        end)
    end)
    Players.PlayerRemoving:Connect(function(Player : Player) 
        PlayerBackpacks[Player] = nil
    end)
end

function PlayerHandler:GetBackpack(Player : Player)
    return PlayerBackpacks[Player]
end

return PlayerHandler