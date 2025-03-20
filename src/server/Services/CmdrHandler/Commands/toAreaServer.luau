local TeleportAreas = workspace.TeleportAreas

return function (_, players, area)
    if not TeleportAreas:FindFirstChild(string.lower(area[1])) then
        return "Invalid area"
    end
    for _, player in players do
        player.Character:PivotTo(TeleportAreas:FindFirstChild(string.lower(area[1])).CFrame)
    end
    return "Teleported player(s)"
end