-- // Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- // Player
local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera

-- // Objects
local Objects = ReplicatedStorage.Objects
local Highlight = Objects.HoverHighlight

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local ItemRemotes = Remotes.Items
local GetNetworkOwner : RemoteFunction = ItemRemotes.GetNetworkOwner
local HandleItem : RemoteEvent = ItemRemotes.HandleItem

-- // Constants
local RANGE = 12
local CARRY_DISTANCE = 9
local MAX_CARRY_DISTANCE = 20
local CARRY_SMOOTH = 0.16
local THROW_BOOST = 8
local RAY_PARAMS = RaycastParams.new()

-- // Ray Params
RAY_PARAMS.FilterType = Enum.RaycastFilterType.Exclude
RAY_PARAMS.FilterDescendantsInstances = {LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()}

-- // Variables
local TargetPos : Vector3 = nil
local CurrentTarget : Model = nil
local Carrying = false

-- // Local Functions
local function RegisterItemCollision(Item : Model, Group : string)
    for _, Part in Item:GetDescendants() do
        if Part:IsA("BasePart") then
            Part.CollisionGroup = Group
        end
    end
end

-- // Controller
local ItemController = {}

function ItemController:Start()
    RunService.RenderStepped:Connect(function() 
        local Raycast : RaycastResult = workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * RANGE, RAY_PARAMS)

        if Raycast then
            local Part = Raycast.Instance
            if Part and Part.Parent:IsA("Model") and Part.Parent:GetAttribute("Item") then
                if not Carrying and Part.Parent ~= CurrentTarget then
                    CurrentTarget = Part.Parent
                    Highlight.Parent = CurrentTarget
                end
            else
                if CurrentTarget ~= nil and not Carrying then
                    CurrentTarget = nil
                    Highlight.Parent = nil
                end
            end
        end
        -- if something happens to current target (ex: plr picks up)
        if CurrentTarget == nil and Carrying then
            Carrying = false
        end

        -- carry obj
        if Carrying and CurrentTarget ~= nil then
            TargetPos = Camera.CFrame.Position + (Camera.CFrame.LookVector * CARRY_DISTANCE)

            local CurrentCFrame = CurrentTarget.PrimaryPart.CFrame
            local NewCFrame = CurrentCFrame:Lerp(CFrame.new(TargetPos, TargetPos + Camera.CFrame.LookVector), CARRY_SMOOTH)

            CurrentTarget:PivotTo(NewCFrame)
            CurrentTarget.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

            if (Camera.CFrame.Position - CurrentTarget.PrimaryPart.CFrame.Position).Magnitude > MAX_CARRY_DISTANCE then
                self:DropItem(false)
                Highlight.Parent = nil
                CurrentTarget = nil
            end
        end

    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:PickupItem()
        end
    end)
    UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Carrying then
            self:DropItem(true)
        end
    end)
    UserInputService.TouchStarted:Connect(function(_, gameProcessedEvent)
        if gameProcessedEvent then return end
        self:PickupItem()
    end)
    UserInputService.TouchEnded:Connect(function(_, gameProcessedEvent)
        if gameProcessedEvent then return end
        if Carrying then
            self:DropItem(true)
        end
    end)
end

function ItemController:PickupItem()
    if CurrentTarget ~= nil then
        if GetNetworkOwner:InvokeServer(CurrentTarget.PrimaryPart) ~= nil then return end

        Carrying = true
        HandleItem:FireServer(CurrentTarget)
        RegisterItemCollision(CurrentTarget, "Item")
    end
end

function ItemController:DropItem(AddForce : boolean?)
    local Velocity = Vector3.new(0, 0, 0)
    if AddForce then
        Velocity = (TargetPos - CurrentTarget.PrimaryPart.Position) * THROW_BOOST
    end
    HandleItem:FireServer(CurrentTarget, Velocity)
    RegisterItemCollision(CurrentTarget, "Default")
    Carrying = false
end

return ItemController