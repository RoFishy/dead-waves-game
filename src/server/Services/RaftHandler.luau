-- // Services
local RunService = game:GetService("RunService")

-- // Objects
local Raft = workspace:WaitForChild("Raft")
local CollisionBase = Raft.CollisionBase
local MotorSound = CollisionBase.Motor

-- // Variables
local MaxSpeed = Raft.VehicleSeat.MaxSpeed

-- // constants
local WHEEL_RADIUS = 9.1 / 2

local SOUND_MIN_SPEED = 0.6
local SOUND_MAX_SPEED = 1.5

-- // RaftHandler
local RaftHandler = {}

function RaftHandler:Start()
    local connection
    connection = RunService.Heartbeat:Connect(function(_)
        if not Raft then
            connection:Disconnect()
        end
        MaxSpeed = Raft.VehicleSeat.MaxSpeed
        local SOUND_MAX_VELOCITY = MaxSpeed * WHEEL_RADIUS
        local Speed = math.abs(CollisionBase.CFrame.LookVector:Dot(CollisionBase.AssemblyLinearVelocity))

        MotorSound.PlaybackSpeed = SOUND_MAX_SPEED + (SOUND_MAX_SPEED - SOUND_MIN_SPEED) * math.min(Speed / SOUND_MAX_VELOCITY, 1)
    end)
end

return RaftHandler