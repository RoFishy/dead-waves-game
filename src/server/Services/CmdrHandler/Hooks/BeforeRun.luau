local Owners = {
    "xRo_Fishy",
    "Monkey_MakersYt"
}

return function (registry)
    registry:RegisterHook("BeforeRun", function(context)
        if not table.find(Owners, context.Executor.Name) then
            return "You are not allowed to use this command."
        end
    end)
end