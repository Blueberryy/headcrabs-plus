include("hcp/convars.lua")
include("hcp/enhancements/modifiers.lua")

local function HCP_AddOption(panel, convar, name)
	if convar[3] == "bool" then
		local box = panel:CheckBox(name or "#hcp.cv." .. convar[1], "hcp_" .. convar[1])
		if convar[5] then convar[5](panel, box) end
		return box
	elseif convar[3] == "range" then
		local ns = panel:NumSlider(name or "#hcp.cv." .. convar[1], "hcp_" .. convar[1], convar[4][1], convar[4][2], 0)
		if convar[5] then convar[5](panel, ns) end
		return ns
	end
end

local function HCP_Menu(CPanel)
	CPanel:ClearControls()

	-- Take Over Options
	for k, v in pairs(HCP.Convars["takeover"]) do
		HCP_AddOption(CPanel, v)
	end

	-- Instant-Kill Options
	local instant_kill = vgui.Create("DForm", CPanel)
	instant_kill:SetName("#hcp.ui.instantkill")
	for k, v in pairs(HCP.Convars["instantkill"]) do
		HCP_AddOption(instant_kill, v)
	end
	CPanel:AddItem(instant_kill)

	-- Other Options
	local other = vgui.Create("DForm", CPanel)
	other:SetName("#hcp.ui.other")
	for k, v in pairs(HCP.Convars["other"]) do
		HCP_AddOption(other, v)
	end

	CPanel:AddItem(other)
end

local function HCP_Modifiers(CPanel)
	for k, v in pairs(HCP.Convars["modifiers"]) do
		HCP_AddOption(CPanel, v)
	end

	local health = vgui.Create("DForm", CPanel)
	health:SetName("#hcp.ui.health_modifiers")
	for k, v in pairs(HCP.Convars["health_modifiers"]) do
		local name = list.Get("NPC")["npc_" .. v[1]:sub(#"health_" + 1)]
		HCP_AddOption(health, v, name and name.Name or "npc_" .. v[1]:sub(#"health_" + 1))
	end
	CPanel:AddItem(health)

	local dmg = vgui.Create("DForm", CPanel)
	dmg:SetName("#hcp.ui.dmg_modifiers")
	for k, v in pairs(HCP.Convars["dmg_modifiers"]) do
		local name = list.Get("NPC")["npc_" .. v[1]:sub(#"dmg_" + 1)]
		HCP_AddOption(dmg, v, name and name.Name or "npc_" .. v[1]:sub(#"dmg_" + 1))
	end
	CPanel:AddItem(dmg)

	CPanel:Button("#hcp.ui.reset_modifiers", "hcp_reset_modifiers")
	CPanel:Help("")
end

hook.Add("PopulateToolMenu", "HCP_PopulateSettings", function()
	spawnmenu.AddToolMenuOption("Utilities", "Headcrabs Plus", "HCP_Settings", "#Settings", "", "", HCP_Menu)
	spawnmenu.AddToolMenuOption("Utilities", "Headcrabs Plus", "HCP_Modifiers", "#hcp.ui.modifiers", "", "", HCP_Modifiers)
end)