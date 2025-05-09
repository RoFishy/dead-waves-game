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

local Items = ReplicatedStorage.Items

-- // Utils
local TerrainUtils = require(script.Parent.TerrainUtils)

-- // Module
local ChunkUtil = {}

function ChunkUtil:GenerateChunk(PreviousChunk : Model?, LoadMaterials : boolean, RenderEnter : (RandomChunk : Model) -> (), RenderLeave : (RandomChunk : Model) -> ()) -- new chunks only
    local RandomChunk
    if not PreviousChunk then
        RandomChunk = ReplicatedStorage.Lobby.Lobby:Clone()
    else
        local RandomNumber = math.random(1, 10)
        if RandomNumber < 2 then
            RandomNumber = 2
        else
            RandomNumber = math.random(1, #ChunksFolder:GetChildren())
        end
        RandomChunk = ChunksFolder[tostring(RandomNumber)]:Clone() -- choose a random chunk
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
            Spawn.Transparency = 1
            local RandomSpawn = Spawns[tostring(math.random(1, #Spawns:GetChildren()))]:Clone()
            local SpawnPartsModel = SpawnParts:FindFirstChild(RandomSpawn.Name):Clone()


            local CopiedRegion = TerrainUtils.copyReg(RandomSpawn)
            TerrainUtils.pasteReg(CopiedRegion, Spawn)

            RandomSpawn:PivotTo(Spawn.CFrame)

            if SpawnPartsModel then
                SpawnPartsModel:PivotTo(RandomSpawn.SpawnParts.CFrame - Vector3.new(0, 2, 0))
                SpawnPartsModel.Parent = Spawn
            end

            -- save spawns old  name for caching
            local Name = Instance.new("StringValue")
            Name.Name = "Name"
            Name.Parent = Spawn
            Name.Value = RandomSpawn.Name

            -- unique name for caching purposes
            Spawn.Name = HttpService:GenerateGUID(false)

            -- item spawns
            if SpawnPartsModel:FindFirstChild("ItemSpawns") then
                for _, ItemSpawn in SpawnPartsModel.ItemSpawns:GetChildren() do
                    local ItemFolder = Items:FindFirstChild(ItemSpawn.Name)

                    assert(ItemFolder, "Item folder not found")
                    local Config = ItemSpawn.Config
                    if Config.Region.Value == true then
                        local MaxSpawns = Config.MaxSpawns.Value
                        local ItemsFolder = Instance.new("Folder")
                        ItemsFolder.Name = "Items"
                        ItemsFolder.Parent = SpawnPartsModel
                        
                        local RandomPosition = (ItemSpawn.CFrame * CFrame.new(
                            (math.random() - 0.5) * ItemSpawn.Size.X, -- x
                            (math.random() - 0.5) * ItemSpawn.Size.Y, -- y
                            (math.random() - 0.5) * ItemSpawn.Size.Z -- z
                        )).Position

                        print((RandomPosition - ItemSpawn.Position).magnitude)
                        
                        for _ = 1, MaxSpawns do
                            local ItemsTable = ItemFolder:GetChildren()
                            local RandomItem = ItemsTable[math.random(1, #ItemsTable)]:Clone()
                            if RandomItem:IsA("Model") then
                                if not RandomItem.PrimaryPart then continue end
                                for _, Part in RandomItem:GetChildren() do
                                    if not Part:IsA("BasePart") then continue end
                                    Part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                end
                                RandomItem.PrimaryPart.Position = ItemSpawn.Position
                            else
                                RandomItem.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                RandomItem.Position = ItemSpawn.Position
                            end
                            RandomItem.Parent = workspace
                        end
                    else
                        -- TODO: add regular item spawning outside of regions
                    end
                end
            end
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