-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // remotes
local Remotes = ReplicatedStorage.Remotes
local Items = Remotes.Items

local HandleItem = Items.HandleItem
local GetNetworkOwner = Items.GetNetworkOwner
local WeldItem = Items.WeldItem

-- // objects
local Raft = workspace.Raft
local CollisionBase = Raft.CollisionBase

-- // ItemHandler
local ItemHandler = {}

function ItemHandler:Start()
    HandleItem.OnServerEvent:Connect(function(Player : Player, Item : Model, Velocity : Vector3?)
        if Item.PrimaryPart:GetNetworkOwner() ~= nil then -- undo the part equipping shit (un equip it)
            Item.PrimaryPart:SetNetworkOwner(nil)
            if Velocity then
                Item.PrimaryPart.AssemblyLinearVelocity = Velocity
            end
        else -- equip item bcz nobody else has it
            Item.PrimaryPart:SetNetworkOwner(Player)
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
                for _, Part : Part in item:GetDescendants() do
                    if not Part:IsA("BasePart") then
                        continue
                    end
                    Part.CollisionGroup = "Default"
                end
            else 
                if CollisionBase:FindFirstChild(item.Name) then
                    CollisionBase:FindFirstChild(item.Name):Destroy()
                end
            end
        end
    end)
end

return ItemHandler