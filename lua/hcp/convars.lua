-- See resource\localization\en\hcp.properties for the default language file
-- which includes the help text for all Convars, Menus, and Tools

HCP.Convars = {}

-- Creates a Console Variable and returns it.
function HCP.CreateConvar(category, name, def, type, typedata, panel)
	HCP.Convars[category] = HCP.Convars[category] or {}
	table.insert(HCP.Convars[category], {name, def, type, typedata, panel})
	return CreateConVar("hcp_" .. name, def, FCVAR_ARCHIVE)
end

function HCP.CreateClientConvar(category, name, def, type, typedata, panel)
	HCP.Convars[category] = HCP.Convars[category] or {}
	table.insert(HCP.Convars[category], {name, def, type, typedata, panel})

	if CLIENT then
		return CreateConVar("hcp_" .. name, def, bit.bor(FCVAR_ARCHIVE, FCVAR_USERINFO))
	end
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
HCP.CreateConvar("takeover", "takeover_npcs", 1, "bool")
HCP.CreateConvar("takeover", "takeover_players", 1, "bool")
HCP.CreateConvar("takeover", "remove_attacker", 1, "bool")
HCP.CreateConvar("takeover", "enable_zombines", 0, "bool", nil, function(p)
	if not IsMounted("episodic") then
		p:Help("#hcp.help.needs_episodic"):SetTextColor(Color(255, 0, 0))
	end
end)
HCP.CreateConvar("takeover", "enable_player_zombines", 1, "bool")
HCP.CreateConvar("takeover", "enable_bonemerge", 1, "bool")
HCP.CreateConvar("takeover", "enable_bonemerge_ragdolls", 1, "bool")

-- Instant Kill Convars
HCP.CreateConvar("instantkill", "instantkill_enable", 0, "bool")
HCP.CreateConvar("instantkill", "instantkill_behind", 0, "bool")
HCP.CreateConvar("instantkill", "instantkill_chance", 0, "range", {1, 100})

-- Scripted Sequences Convars
HCP.CreateConvar("scripted", "takeover_animation", 0, "bool")
HCP.CreateConvar("scripted", "enable_burrowing", 0, "bool")
HCP.CreateConvar("scripted", "burrowing_range", 0, "range", {1, 500})
HCP.CreateConvar("scripted", "enable_sleeping", 0, "bool")
HCP.CreateConvar("scripted", "sleeping_range", 0, "range", {1, 500})
HCP.CreateConvar("scripted", "sleeping_time", 0, "range", {1, 500})

-- Poison Headcrab Convars
HCP.CreateConvar("poison", "poison_bites", 3, "range", {0, 5})
HCP.CreateConvar("poison", "poison_healtime", 5, "range", {1, 30})
HCP.CreateConvar("poison", "poison_return", 3, "bool", nil, function(p, box) box:SetEnabled(false) end)

-- Other Convars
HCP.CreateClientConvar("other", "enable_undolist", 1, "bool")
HCP.CreateConvar("other", "enable_infection", 0, "bool")
HCP.CreateConvar("other", "enable_sabrean", 1, "bool", nil, function(p)
	if not HCP.GetSabreanInstalled() then
		p:Button("#hcp.help.download_sabrean").DoClick = function() gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=206166550") end
	end
end)

-- Modifier Convars
HCP.CreateConvar("modifiers", "modifiers_enable", 1, "bool")
HCP.CreateConvar("modifiers", "modifiers_override", 1, "bool")

