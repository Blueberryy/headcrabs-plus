include("hcp/convars.lua")
include("hcp/enhancements/modifiers.lua")

local function HCP_AddOption(panel, convar, name)
	if convar[3] == "bool" then
		local box = panel:CheckBox(name or "#hcp.cv." .. convar[1], "hcp_" .. convar[1])
		if convar[5] then convar[5](panel) end
		return box
	elseif convar[3] == "range" then
		local ns = panel:NumSlider(name or "#hcp.cv." .. convar[1], "hcp_" .. convar[1], convar[4][1], convar[4][2], 0)
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
	instant_kill:SetName("Instant Kill Options")
	for k, v in pairs(HCP.Convars["instantkill"]) do
		HCP_AddOption(instant_kill, v)
	end
	CPanel:AddItem(instant_kill)

	-- Other Options
	local other = vgui.Create("DForm", CPanel)
	other:SetName("Other Options")
	for k, v in pairs(HCP.Convars["other"]) do
		HCP_AddOption(other, v)
	end

	CPanel:AddItem(other)

	-- Modifier Options
	local modifiers = vgui.Create("DForm", CPanel)
	modifiers:SetName("Modifiers")

	for k, v in pairs(HCP.Convars["modifiers"]) do
		HCP_AddOption(modifiers, v)
	end

	modifiers:Help("")
	local health_label = modifiers:Help("Health Modifiers")
	health_label:DockMargin(0, 0, 8, 8)
	for k, v in pairs(HCP.Convars["health_modifiers"]) do
		local name = list.Get("NPC")["npc_" .. v[1]:sub(#"health_" + 1)]
		HCP_AddOption(modifiers, v, name and name.Name or "npc_" .. v[1]:sub(#"health_" + 1))
	end

	modifiers:Help("")
	local dmg_label = modifiers:Help("Damage Modifiers")
	dmg_label:DockMargin(0, 0, 8, 8)
	for k, v in pairs(HCP.Convars["dmg_modifiers"]) do
		local name = list.Get("NPC")["npc_" .. v[1]:sub(#"dmg_" + 1)]
		HCP_AddOption(modifiers, v, name and name.Name or "npc_" .. v[1]:sub(#"dmg_" + 1))
	end

	modifiers:Button("#hcp.help.reset_modifiers", "hcp_reset_modifiers")
	modifiers:Help("")

	CPanel:AddItem(modifiers)

end

hook.Add("PopulateToolMenu", "HCP_PopulateSettings", function()
	spawnmenu.AddToolMenuOption("Utilities", "Headcrabs Plus", "HCP_Settings", "#Settings", "", "", HCP_Menu)
end)