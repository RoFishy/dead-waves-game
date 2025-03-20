return {
    Name = "toArea";
    Aliases = {};
    Description = "Teleports a player to a dev area";
    Args = {
		{
			Type = "players";
			Name = "from";
			Description = "The players to teleport";
		},
        {
            Type = "strings";
            Name = "to";
            Description = "The area to teleport to";
        }
    }
}