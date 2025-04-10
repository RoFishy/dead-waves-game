-- // Start
local StartTime = os.clock()

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Utils
local Utils = ReplicatedStorage:WaitForChild("Modules").Utils
local Loader = require(Utils.Loader)

-- // Folders
local Controllers = script.Parent:WaitForChild("Controllers")

print("-----[CONTROLLERS]----")
Loader.Init(Controllers:GetChildren())
Loader.Start()

local DeltaTime = os.clock() - StartTime
print(("Client loading complete, took %.2f seconds"):format(DeltaTime))
warn("What do you think you're doing here...? Get back to the game blud...")
warn("I'm serious... get back to the game like a good boy.")
warn("Anyway, if you're still here, please report and bugs/errors to our Discord server.")
warn("Thanks! ~RoFishy")