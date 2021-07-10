HCP.Modifiers = {
	-- Convar, Default Damage, Default Health
	["npc_headcrab"] = {5, 10},
	["npc_headcrab_fast"] = {5, 10},
	["npc_headcrab_black"] = {false, 35},
	["npc_headcrab_poison"] = "npc_headcrab_black",
	["npc_zombie"] = {10, 70},
	["npc_poisonzombie"] = {10, 175},
	["npc_fastzombie"] = {5, 50},
	["npc_zombine"] = {10, 100},
}

for k, v in pairs(HCP.Modifiers) do
	if isstring(v) then continue end

	local name = k:sub(#"npc_" + 1)
	if v[1] then
		HCP.CreateConvar("dmg_modifiers", "dmg_" .. name, v[1], "range", {0, 100})
	end
	HCP.CreateConvar("health_modifiers", "health_" .. name, v[2], "range", {1, 300})
end

-- Calculates the modified health value (returns Integer)
function HCP.GetModifiedHealth(entity)
	local mdtbl, copy_class = HCP.Modifiers[entity:GetClass()]
	if isstring(mdtbl) then -- Allow for multiple classes to share the same convars
		copy_class = mdtbl
		mdtbl = HCP.Modifiers[copy_class]
	end
	if not mdtbl or not mdtbl[2] then return false end

	if HCP.GetConvarBool("modifiers_override") then return HCP.GetConvarInt("health_" .. (copy_class or entity:GetClass()):sub(#"npc_" + 1)) end
	return HCP.GetConvarInt("health_" .. (copy_class or entity:GetClass()):sub(#"npc_" + 1)) - mdtbl[2]
end

-- Calculates the modified damage value (returns Integer)
function HCP.GetModifiedDamage(entity, dmg)
	if dmg:GetDamageType() == DMG_BLAST then return end -- Don't change grenade blasts

	local mdtbl, copy_class = HCP.Modifiers[entity:GetClass()]
	if isstring(mdtbl) then -- Allow for multiple classes to share the same convars
		copy_class = mdtbl
		mdtbl = HCP.Modifiers[copy_class]
	end
	if not mdtbl or not mdtbl[1] then return false end

	if HCP.GetConvarBool("modifiers_override") then return HCP.GetConvarInt("dmg_" .. (copy_class or entity:GetClass()):sub(#"npc_" + 1)) end
	return dmg:GetDamage() + HCP.GetConvarInt("dmg_" .. (copy_class or entity:GetClass()):sub(#"npc_" + 1)) - mdtbl[1]
end

if SERVER then
	hook.Add("EntityTakeDamage", "HCP_Modifiers", function(target, dmg)
		if not IsValid(dmg:GetAttacker()) or not HCP.GetConvarBool("modifiers_enable") then return end

		local newdmg = HCP.GetModifiedDamage(dmg:GetAttacker(), dmg)
		if not newdmg or (dmg:GetAttacker().HCP_DMGLock and dmg:GetAttacker().HCP_DMGLock + 0.1 > CurTime()) then return end

		dmg:SetDamage(newdmg)
	end)

	hook.Add("OnEntityCreated", "HCP_Modifiers", function(ent)
		if not HCP.GetConvarBool("modifiers_enable") or not IsValid(ent) or not ent:IsNPC() then return end

		timer.Simple(0.2, function()
			if not IsValid(ent) then return end
			local health = HCP.GetModifiedHealth(ent)
			if not health then return end

			ent:SetHealth(health)
		end)
	end)

	concommand.Add("hcp_reset_modifiers", function(ply)
		if IsValid(ply) and not ply:IsAdmin() then return end
		for k, v in pairs(HCP.Modifiers) do
			if not istable(v) then continue end
			if v[1] then
				RunConsoleCommand("hcp_dmg_" .. k:sub(#"npc_" + 1), tostring(v[1]))
			end

			if v[2] then
				RunConsoleCommand("hcp_health_" .. k:sub(#"npc_" + 1), tostring(v[2]))
			end
		end
	end)
end

