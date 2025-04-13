-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Audios
local Audios = ReplicatedStorage.Audios

local SoundUtils = {}

function SoundUtils.PlaySound(TargetCFrame, Sound : string, Type : "SoundEffects" | "RadioSongs" | "Ambience"?)
    Type = Type or "SoundEffects"
    local SoundFolder = Audios:FindFirstChild(Type)
    assert(SoundFolder, "Sound folder not found")

    Sound = SoundFolder:FindFirstChild(Sound)
    assert(Sound, "Sound not found")

    local Length = Sound.TimeLength

    local SoundPart = Instance.new("Part")
    SoundPart.Anchored = true
    SoundPart.Transparency = 1
    SoundPart.CanCollide = false
    SoundPart.CFrame = TargetCFrame
    SoundPart.Parent = workspace

    local Clone = Sound:Clone()
    Clone.Parent = SoundPart
    Clone:Play()
    task.delay(Length, function()
        SoundPart:Destroy()
    end)
end

return SoundUtils