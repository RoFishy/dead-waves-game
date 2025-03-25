-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // remotes
local Remotes = ReplicatedStorage.Remotes
local Items = Remotes.Items

local HandleItem = Items.HandleItem
local GetNetworkOwner = Items.GetNetworkOwner

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
end

return ItemHandler