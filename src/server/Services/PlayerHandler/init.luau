-- // Roblox Services
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

-- // Services
local TerrainHandler = require(script.Parent.TerrainHandler)

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
        leaderstats.Parent = Player

        local Cash = Instance.new("IntValue")
        Cash.Name = "Cash"
        Cash.Parent = leaderstats
        Cash.Value = 20

        Player.CharacterAdded:Connect(function(Character : Model)
            SpawnPlayer(Character)
            RegisterPlayerCollisions(Character)
        end)
    end)
end

return PlayerHandler