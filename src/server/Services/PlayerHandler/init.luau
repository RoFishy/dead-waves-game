-- // Roblox Services
local Players = game:GetService("Players")

-- // Services
local TerrainHandler = require(script.Parent.TerrainHandler)

-- // Local Functions
local function SpawnPlayer(Character : Model)
    local Spawns = TerrainHandler:GetSpawns()
    local RandomSpawn = Spawns[tostring(math.random(1, #Spawns:GetChildren()))]
    Character:PivotTo(RandomSpawn.CFrame)
end

local PlayerHandler = {}

function PlayerHandler:Start()
    Players.PlayerAdded:Connect(function(Player : Player)
        Player.DevEnableMouseLock = false
        Player.CharacterAdded:Connect(function(Character : Model)
            SpawnPlayer(Character)
        end)
    end)
end

return PlayerHandler