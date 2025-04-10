-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Spawns
local SpawnParts = ReplicatedStorage.SpawnParts

-- // Utils
local TerrainUtil = require(script.TerrainUtils)
local ChunkUtil = require(script.Chunk)

-- // TerrainHandler
local TerrainHandler = {}

function TerrainHandler.Init()
    TerrainHandler.Cache = {}
    TerrainHandler.Spawns = nil
end

function TerrainHandler:Start()
    -- setup the lobby chunk first ig
    local StartTime = os.clock()
    local CurrentChunk = ChunkUtil:GenerateChunk(nil, true, function(RandomChunk)
        TerrainHandler:LoadChunk(RandomChunk)
    end, function(RandomChunk)
        TerrainHandler:UnloadChunk(RandomChunk)
    end)
    self:UnloadChunk(CurrentChunk)
    self:LoadChunk(CurrentChunk)
    self.Spawns = CurrentChunk.LobbyParts.Spawns

    for _ = 1, 50 do
        CurrentChunk = ChunkUtil:GenerateChunk(CurrentChunk, false, function(RandomChunk)
            TerrainHandler:LoadChunk(RandomChunk)
        end, function(RandomChunk)
            TerrainHandler:UnloadChunk(RandomChunk)
        end)
        self:UnloadChunk(CurrentChunk)
    end
    local DeltaTime = os.clock() - StartTime
    print(("Chunk loading complete, took %.2f seconds"):format(DeltaTime))
end

function TerrainHandler:LoadChunk(Chunk : Model) -- for chunks that have already been generated (not loading new chunks)
    TerrainUtil.fillPart(Chunk.Water, Enum.Material.Water)
    TerrainUtil.fillPart(Chunk.Sand, Enum.Material.Sand)
    --print(Chunk.Name)
    --print(self.Cache)
    --print(self.Cache[Chunk.Name])
    if self.Cache[Chunk.Name] then
        local Terrain = self.Cache[Chunk.Name]["TerrainArea"]
        TerrainUtil.pasteReg(Terrain, Chunk.TerrainArea)
    else 
        self.Cache[Chunk.Name] = {}
        if Chunk:FindFirstChild("Spawns") then 
            for _, spawn in Chunk.Spawns:GetChildren() do
                local Name = spawn:FindFirstChildOfClass("StringValue").Value
                -- cache the spawnParts (if there are any)
                if spawn:FindFirstChild("NonTerrain") then -- if its just yk a part and shit
                    continue
                end
                self.Cache[Chunk.Name][spawn.Name] = {}
                --self.Cache[Chunk.Name][spawn.Name]["Terrain"] = TerrainUtil.copyReg(spawn) -- save each spawn for later
                self.Cache[Chunk.Name][spawn.Name]["Name"] = Name
            end
        end
    end

    if Chunk:FindFirstChild("Spawns") then 
        for _, spawn in Chunk.Spawns:GetChildren() do
            if spawn:FindFirstChild("NonTerrain") then -- if its just yk a part and shit
                continue
            end
            --local CopiedRegion = self.Cache[Chunk.Name][spawn.Name]["Terrain"]
            --TerrainUtil.pasteReg(CopiedRegion, spawn)

            -- now find the parts and un-cache them
            if SpawnParts:FindFirstChild(self.Cache[Chunk.Name][spawn.Name]["Name"]) then
                local Clone = SpawnParts:FindFirstChild(self.Cache[Chunk.Name][spawn.Name]["Name"]):Clone()
                Clone.Parent = spawn
                Clone:PivotTo(spawn.CFrame - Vector3.new(0, 2, 0))
            end
        end
    end
    if Chunk:FindFirstChild("LobbySpawn") then
        local LobbySpawnPart = Chunk.SpawnParts
        local LobbyParts = ReplicatedStorage.Lobby.LobbyParts:Clone()
        LobbyParts:PivotTo(LobbySpawnPart.CFrame)
        LobbyParts.Parent = Chunk
    end
end

function TerrainHandler:GetSpawns()
    return self.Spawns
end

function TerrainHandler:UnloadChunk(Chunk : Model)
    -- delete the basic terrain areas
    self.Cache[Chunk.Name] = {} -- init the cache
    self.Cache[Chunk.Name]["TerrainArea"] = TerrainUtil.copyReg(Chunk.TerrainArea)
    
    if Chunk:FindFirstChild("LobbyParts") then
        Chunk:WaitForChild("LobbyParts"):Destroy()
    end
    if Chunk:FindFirstChild("Spawns") then
        for _, spawn in Chunk.Spawns:GetChildren() do
            local Name = ""
            -- cache the spawnParts (if there are any)
            if spawn:FindFirstChildOfClass("Model") then
                Name = spawn:WaitForChild("Name").Value
                spawn:FindFirstChildOfClass("Model"):Destroy()
            end
            if spawn:FindFirstChild("NonTerrain") then -- if its just yk a part and shit
                continue
            end
            self.Cache[Chunk.Name][spawn.Name] = {}
            --self.Cache[Chunk.Name][spawn.Name]["Terrain"] = TerrainUtil.copyReg(spawn) -- save each spawn for later
            self.Cache[Chunk.Name][spawn.Name]["Name"] = Name
            TerrainUtil.deleteReg(spawn)
        end
    end
    TerrainUtil.deleteReg(Chunk.TerrainArea)
end

return TerrainHandler