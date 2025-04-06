-- // Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Utils
local Utils = ReplicatedStorage:WaitForChild("Modules").Utils
local ActionManager = require(Utils.ActionManager)

local Bindings = {}

-- // Player
local LocalPlayer = Players.LocalPlayer

local Camera = workspace.CurrentCamera

-- // Objects
local Objects = ReplicatedStorage.Objects
local Highlight : Highlight = Objects.HoverHighlight
local ItemGui : BillboardGui = Objects.ItemGui

local Raft : Model = workspace:WaitForChild("Raft")
local CollisionBase = Raft:WaitForChild("CollisionBase")

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local ItemRemotes = Remotes.Items
local GetNetworkOwner : RemoteFunction = ItemRemotes.GetNetworkOwner
local HandleItem : RemoteEvent = ItemRemotes.HandleItem
local WeldItem : RemoteEvent = ItemRemotes.WeldItem

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

local function ClearGui()
    for _, v in ItemGui:GetChildren() do
        if v.Name == "Detail" then
            v:Destroy()
        end
    end
end

-- // Controller
local ItemController = {}

function ItemController:Start()
    RunService.RenderStepped:Connect(function() 
        local Raycast : RaycastResult = workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * RANGE, RAY_PARAMS)

        if CurrentTarget then
            CurrentTarget.Destroying:Connect(function()
                CurrentTarget = nil
            end)
        end

        if Raycast then
            local Part = Raycast.Instance
            if Part and Part.Parent:IsA("Model") and Part.Parent:GetAttribute("Item") then
                if not Carrying and Part.Parent ~= CurrentTarget then
                    CurrentTarget = Part.Parent
                    Highlight.Parent = CurrentTarget
                    ItemGui.Parent = CurrentTarget.PrimaryPart

                    local ItemConfig = CurrentTarget:FindFirstChild("Config")
                    assert(ItemConfig, "Item has no config")

                    ItemGui.Title.Text = ItemConfig.Title.Value
                    for _, Config in ItemConfig.Details:GetChildren() do
                        if not Config:IsA("StringValue") then
                            continue
                        end
                        local Detail = ItemGui.DetailTemplate:Clone()
                        Detail.Parent = ItemGui
                        Detail.Text = Config.Value
                        Detail.Visible = true
                        Detail.Name = "Detail"
                    end

                    if not table.find(Bindings, "Drag") then
                        ActionManager.bindAction("Drag", function(action, inputState)
                            self:ActionHandler(action, inputState)
                        end, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonX, 1)
                        table.insert(Bindings, "Drag")
                    end
                    if CollisionBase:FindFirstChild(CurrentTarget.Name) then
                        self:UnbindAction("Weld")
                        self:UnbindAction("Drag")
                        if not table.find(Bindings, "Unweld") then
                            ActionManager.bindAction("Unweld", function(action, inputState)
                                self:ActionHandler(action, inputState)
                            end, Enum.KeyCode.Z, Enum.KeyCode.ButtonY, 2)
                            table.insert(Bindings, "Unweld")
                        end
                    end
                else
                    if CollisionBase:FindFirstChild(CurrentTarget.Name) then
                        self:UnbindAction("Weld")
                        self:UnbindAction("Drag")
                        if not table.find(Bindings, "Unweld") then
                            table.insert(Bindings, "Unweld")
                            ActionManager.bindAction("Unweld", function(action, inputState)
                                self:ActionHandler(action, inputState)
                            end, Enum.KeyCode.Z, Enum.KeyCode.ButtonY, 2)
                        end
                    end
                end
            else
                if CurrentTarget ~= nil and not Carrying then
                    CurrentTarget = nil
                    Highlight.Parent = nil
                    ItemGui.Parent = nil
                    ClearGui()
                    self:UnbindAction("Drag")
                    self:UnbindAction("Unweld")
                end
            end
            
        else
            if CurrentTarget ~= nil and not Carrying then
                CurrentTarget = nil
                Highlight.Parent = nil
                ItemGui.Parent = nil
                ClearGui()
                self:UnbindAction("Drag")
                self:UnbindAction("Weld")
                self:UnbindAction("Unweld")
            end
        end
        -- if something happens to current target (ex: plr picks up)
        if CurrentTarget == nil and Carrying then
            Carrying = false
            self:UnbindAction("Weld")
            self:UnbindAction("Unweld")
            self:UnbindAction("Drag")
        end

        -- carry obj

        if Carrying and CurrentTarget ~= nil then
            if CollisionBase:FindFirstChild(CurrentTarget.Name) then
                return
            end
            TargetPos = Camera.CFrame.Position + (Camera.CFrame.LookVector * CARRY_DISTANCE)

            local CurrentCFrame = CurrentTarget.PrimaryPart.CFrame
            local NewCFrame = CurrentCFrame:Lerp(CFrame.new(TargetPos, TargetPos + Camera.CFrame.LookVector), CARRY_SMOOTH)

            CurrentTarget:PivotTo(NewCFrame)
            CurrentTarget.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

            if (Camera.CFrame.Position - CurrentTarget.PrimaryPart.CFrame.Position).Magnitude > MAX_CARRY_DISTANCE then
                self:DropItem(false)
                Highlight.Parent = nil
                ItemGui.Parent = nil
                ClearGui()
                CurrentTarget = nil
            end

            -- // weldings
            local nearbyParts = workspace:GetPartBoundsInRadius(CurrentTarget.PrimaryPart.Position, 1.5)
            local ViableParts = {}
            for _, Part in nearbyParts do
                if Part:IsDescendantOf(Raft) then
                    if not table.find(Bindings, "Weld") then
                        ActionManager.bindAction("Weld", function(action, inputState)
                            self:ActionHandler(action, inputState)
                        end, Enum.KeyCode.Z, Enum.KeyCode.ButtonY, 2)
                        table.insert(Bindings, "Weld")
                    end
                    table.insert(ViableParts, Part.Name)
                end
            end
            if #ViableParts == 0 then
                self:UnbindAction("Weld")
            end
        end
    end)
end

function ItemController:UnbindAction(Name)
    ActionManager.unbindAction(Name)
    table.remove(Bindings, table.find(Bindings, Name))
end

function ItemController:ActionHandler(action, inputState)
    if inputState == Enum.UserInputState.Begin then
        if action == "Drag" then
            self:PickupItem()
        elseif action == "Weld" then
            RegisterItemCollision(CurrentTarget, "Default")
            WeldItem:FireServer(CurrentTarget, true)
            Carrying = false
            CurrentTarget = nil
            self:UnbindAction("Drag")
            table.remove(Bindings, table.find(Bindings, "Drag"))
        elseif action == "Unweld" then
            WeldItem:FireServer(CurrentTarget, false)
            self:UnbindAction("Unweld")
            table.remove(Bindings, table.find(Bindings, "Unweld"))
            ActionManager.bindAction("Weld", function(_action, _inputState)
                self:ActionHandler(_action, _inputState)
            end, Enum.KeyCode.Z, Enum.KeyCode.ButtonY, 2)
            ActionManager.bindAction("Drag", function(_action, _inputState) 
                self:ActionHandler(_action, _inputState)
            end, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonX, 1)
            table.insert(Bindings, "Weld")
            table.insert(Bindings, "Drag")
            Carrying = false
        end
    elseif inputState == Enum.UserInputState.End then
        if Carrying then
            self:DropItem(true)
        end
    end
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