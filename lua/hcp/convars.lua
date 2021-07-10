-- See resource\localization\en\hcp.properties for the default language file
-- which includes the help text for all Convars, Menus, and Tools

HCP.Convars = {}

-- Creates a Console Variable and returns it.
function HCP.CreateConvar(category, name, def, type, typedata, panel)
	HCP.Convars[category] = HCP.Convars[category] or {}
	table.insert(HCP.Convars[category], {name, def, type, typedata, panel})
	return CreateConVar("hcp_" .. name, def, FCVAR_ARCHIVE)
end

function HCP.GetConvarBool(name)
	if not GetConVar("hcp_" .. name) then return false end
	return GetConVar("hcp_" .. name):GetBool()
end

function HCP.GetConvarInt(name)
	if not GetConVar("hcp_" .. name) then return false end
	return GetConVar("hcp_" .. name):GetInt()
end

-- Take Over Convars
HCP.CreateConvar("Take Over Options", "takeover_npcs", 1, "bool")
HCP.CreateConvar("Take Over Options", "takeover_players", 1, "bool")
HCP.CreateConvar("Take Over Options", "remove_attacker", 1, "bool")
HCP.CreateConvar("Take Over Options", "enable_zombines", 0, "bool", nil, function(p)
	if not IsMounted("episodic") then
		p:Help("#hcp.help.needs_episodic"):SetTextColor(Color(255, 0, 0))
	end
end)
HCP.CreateConvar("Take Over Options", "enable_player_zombines", 1, "bool")
HCP.CreateConvar("Take Over Options", "enable_bonemerge", 1, "bool")
HCP.CreateConvar("Take Over Options", "enable_bonemerge_ragdolls", 1, "bool")

-- Instant kill Convars
HCP.CreateConvar("Instant-Kill Options", "instantkill_enable", 0, "bool")
HCP.CreateConvar("Instant-Kill Options", "instantkill_behind", 0, "bool")
HCP.CreateConvar("Instant-Kill Options", "instantkill_chance", 0, "range", {1, 100})

-- Other Convars
HCP.CreateConvar("Other", "enable_undolist", 1, "bool")
HCP.CreateConvar("Other", "enable_infection", 0, "bool")
HCP.CreateConvar("Other", "enable_burrowing", 1, "bool")
HCP.CreateConvar("Other", "enable_sabrean", 1, "bool", nil, function(p)
	if not HCP.GetSabreanInstalled() then
		local sabrean = p:Button("#hcp.help.download_sabrean")
		sabrean.DoClick = function() gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=206166550") end
	end
end)

