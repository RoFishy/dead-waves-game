-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- // Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ZonePlus = require(Packages.ZonePlus)

-- // Chunks
local ChunksFolder = ReplicatedStorage.Chunks -- the actual chunks ifykwim
local GeneratedChunks = workspace.GeneratedChunks

local Spawns = workspace.Spawns -- this is the stuff like islands and shit
local SpawnParts = ReplicatedStorage.SpawnParts

-- // Utils
local TerrainUtils = require(script.Parent.TerrainUtils)

-- // Module
local ChunkUtil = {}

function ChunkUtil:GenerateChunk(PreviousChunk : Model?, LoadMaterials : boolean, RenderEnter : (RandomChunk : Model) -> (), RenderLeave : (RandomChunk : Model) -> ()) -- new chunks only
    local RandomChunk
    if not PreviousChunk then
        RandomChunk = ReplicatedStorage.Lobby.Lobby
    else
        RandomChunk = ChunksFolder[tostring(math.random(1, #ChunksFolder:GetChildren()))]:Clone() -- choose a random chunk
    end
    RandomChunk.Parent = GeneratedChunks

    -- place this shit before actually filling in the terrain
    if PreviousChunk then
        RandomChunk:PivotTo(PreviousChunk.Exit.CFrame)
    end

    -- fill in the terrain properties
    if LoadMaterials == true then
        TerrainUtils.fillPart(RandomChunk.Sand, Enum.Material.Sand)
        TerrainUtils.fillPart(RandomChunk.Water, Enum.Material.Water)
    end

    -- // set these to not transparent
    RandomChunk.Water.Transparency = 1
    RandomChunk.Sand.Transparency = 1

    -- island spawns
    if RandomChunk:FindFirstChild("Spawns") then
        for _, Spawn in RandomChunk.Spawns:GetChildren() do
            local nothing = math.random(1, 10)
            if nothing < 2 then
                Spawn.Transparency = 1
                continue
            end
            Spawn.Transparency = 1
            local RandomSpawn = Spawns[tostring(math.random(1, #Spawns:GetChildren()))]:Clone()
            local SpawnPartsModel = SpawnParts:FindFirstChild(RandomSpawn.Name):Clone()


            local CopiedRegion = TerrainUtils.copyReg(RandomSpawn)
            TerrainUtils.pasteReg(CopiedRegion, Spawn)

            RandomSpawn:PivotTo(Spawn.CFrame)

            if SpawnPartsModel then
                SpawnPartsModel:PivotTo(RandomSpawn.SpawnParts.CFrame)
                SpawnPartsModel.Parent = Spawn
            end

            -- save spawns old  name for caching
            local Name = Instance.new("StringValue")
            Name.Name = "Name"
            Name.Parent = Spawn
            Name.Value = RandomSpawn.Name

            -- unique name for caching purposes
            Spawn.Name = HttpService:GenerateGUID(false)
        end
    end
    -- lobby spawns
    if RandomChunk:FindFirstChild("LobbySpawn") then
        local LobbyPaste = RandomChunk.LobbySpawn
        local LobbySpawn = workspace.LobbySpawn

        local CopiedLobby = TerrainUtils.copyReg(LobbySpawn)
        TerrainUtils.pasteReg(CopiedLobby, LobbyPaste)

        LobbyPaste.Transparency = 1

        local LobbySpawnPart = RandomChunk.SpawnParts
        local LobbyParts = ReplicatedStorage.Lobby.LobbyParts:Clone()
        LobbyParts:PivotTo(LobbySpawnPart.CFrame)
        LobbyParts.Parent = RandomChunk
    end
    -- safeplace ONLY (gonna procrastinate it for later ig)


    -- generate a random name for the chunk that can be referred to later; has to be unique
    local RandomName = HttpService:GenerateGUID(false)
    RandomChunk.Name = RandomName

    -- now we need to check whenever people enter or leave the render area, this is the fuckign annoying part
    -- edit: it was not as annoying as i thought
    ChunkUtil[RandomName] = {}
    ChunkUtil[RandomName]["Players"] = {}

    local RenderZone = ZonePlus.new(RandomChunk.RenderZone)
    RenderZone.playerEntered:Connect(function(Player)
        if #ChunkUtil[RandomName]["Players"] == 0 then
            RenderEnter(RandomChunk)
        end
        table.insert(ChunkUtil[RandomName]["Players"], Player.Name)
    end)
    RenderZone.playerExited:Connect(function(Player)
        table.remove(ChunkUtil[RandomName]["Players"], table.find(ChunkUtil[RandomName]["Players"], Player.Name))
        if #ChunkUtil[RandomName]["Players"] == 0 then
            RenderLeave(RandomChunk)
        end
    end)

    return RandomChunk
end

return ChunkUtil