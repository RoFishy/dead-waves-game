-- // Start
local StartTime = os.clock()

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- // Utils
local Utils = ReplicatedStorage.Modules.Utils
local Loader = require(Utils.Loader)

-- // Folders
local Services = ServerScriptService.Services
local Components = ServerScriptService.Components

print("-------[SERVER]-------")

print("-- // Services")
Loader.Init(Services:GetChildren())
Loader.Start()

print("-- // Components")
for _, Module in Components:GetChildren() do
    if not Module:IsA("ModuleScript") then continue end
    require(Module)
    print(`{Module.Name} Initialized`)
end

local EndTime = os.clock() - StartTime
print(("Server loading complete, took %.2f seconds"):format(EndTime))