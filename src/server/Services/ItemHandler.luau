-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Modules
local Modules = ReplicatedStorage.Modules
local Utils = Modules.Utils
local Loader = require(Utils.Loader)

-- // Handlers
local PlayerHandler = Loader.Get("PlayerHandler")

-- // remotes
local Remotes = ReplicatedStorage.Remotes
local Items = Remotes.Items

local HandleItem = Items.HandleItem
local GetNetworkOwner = Items.GetNetworkOwner
local WeldItem = Items.WeldItem
local StoreItem = Items.StoreItem
local UnstoreItem = Items.UnstoreItem

-- // Constants
local MAX_ITEMS = 10

-- // objects
local Raft = workspace.Raft
local CollisionBase = Raft.CollisionBase

-- // ItemHandler
local ItemHandler = {}

function ItemHandler:Start()
    HandleItem.OnServerEvent:Connect(function(Player : Player, Item : Model, Velocity : Vector3?)
        if Item and Item.PrimaryPart then
            if Item.PrimaryPart:GetNetworkOwner() ~= nil then -- undo the part equipping shit (un equip it)
                Item.PrimaryPart:SetNetworkOwner(nil)
                if Velocity then
                    Item.PrimaryPart.AssemblyLinearVelocity = Velocity
                end
            else -- equip item bcz nobody else has it
                Item.PrimaryPart:SetNetworkOwner(Player)
            end
        end
    end)
    GetNetworkOwner.OnServerInvoke = function(_, Part : BasePart)
        return Part:GetNetworkOwner()
    end
    WeldItem.OnServerEvent:Connect(function(_, item, weld : boolean?)
        if item then
            if weld then
                local weldConstraint : WeldConstraint = Instance.new("WeldConstraint")
                weldConstraint.Parent = CollisionBase
                weldConstraint.Part0 = CollisionBase
                weldConstraint.Part1 = item.PrimaryPart
                weldConstraint.Name = item.Name
                item.PrimaryPart:SetNetworkOwner(nil)
            else
                if CollisionBase:FindFirstChild(item.Name) then
                    CollisionBase:FindFirstChild(item.Name):Destroy()
                end
            end
        end
    end)
    StoreItem.OnServerEvent:Connect(function(player, item)
        local Backpack = PlayerHandler:GetBackpack(player)
        local BackpackFolder = ReplicatedStorage.Backpacks[player.Name]
        if #Backpack >= MAX_ITEMS then return end -- how the fuck they got more idk tbh
        item.PrimaryPart:SetNetworkOwner(nil)
        table.insert(Backpack, item.Name)

        item.Parent = BackpackFolder
    end)
    UnstoreItem.OnServerEvent:Connect(function(player)
        local Backpack = PlayerHandler:GetBackpack(player)
        local BackpackFolder = ReplicatedStorage.Backpacks[player.Name]
        if #Backpack == 0 then return end
        local ItemName = Backpack[#Backpack]
        table.remove(Backpack, table.find(Backpack, Backpack[#Backpack]))
        
        local Item : Model = BackpackFolder:FindFirstChild(ItemName)
        if Item then
            Item.Parent = workspace
            Item:MoveTo(player.Character.PrimaryPart.CFrame.LookVector * 6 + player.Character.PrimaryPart.CFrame.Position)
        end
    end)

end

return ItemHandler