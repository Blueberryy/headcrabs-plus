AddCSLuaFile("hcp/convars.lua")
AddCSLuaFile("hcp/enhancements/modifiers.lua")
include("hcp/convars.lua")
include("hcp/enhancements/modifiers.lua")
include("hcp/enhancements/sabrean.lua")
include("hcp/enhancements/poison.lua")

local DEATH_DISSOLVE, DEATH_NODROP = 1, 2

HCP.ZombineModels = {
	["models/combine_soldier_prisonguard.mdl"] = 2, -- Number indicates Sabrean Skin, true means no replacement
	["models/player/combine_soldier_prisonguard.mdl"] = 2,

	["models/player/combine_soldier_prisonguard_original.mdl"] = 2,
	["models/player/combine_super_soldier.mdl"] = 3,
	["models/combine_super_soldier.mdl"] = 3,
	["models/player/combine_elite_original.mdl"] = 3,

	["models/player/combine_soldier.mdl"] = {[0] = 4, [1] = 1},
	["models/player/combine_soldier_original.mdl"] = {[0] = 4, [1] = 1},
	["models/combine_soldier.mdl"] = {[0] = 4, [1] = 1},
	["models/bloocobalt/combine/combine_04.mdl"] = {[0] = 4, [1] = 1},

	--Combine Units +PLUS+
	["models/nohelm_soldier.mdl"] = 4,
	["models/anim_mod/combine_soldier.mdl"] = 4,
	["models/anim_mod/combine_soldier_prisonguard.mdl"] = 2,
	["models/anim_mod/combine_super_soldier.mdl"] = 3,
	["models/csniper.mdl"] = true,
	["models/heg.mdl"] = true,
	["models/missing_soldier.mdl"] = true,
	["models/missing_soldier_prisonguard.mdl"] = true,
	["models/missing_super_soldier.mdl"] = true,
	["models/combine_burner_eliter.mdl"] = true,
	["models/player/zombie_soldier.mdl"] = true,
}

HCP.Headcrabs = {
	["npc_headcrab"] = "npc_zombie",
	["npc_headcrab_fast"] = "npc_fastzombie",
	["npc_headcrab_black"] = "npc_poisonzombie",
	["npc_headcrab_poison"] = "npc_poisonzombie",
}

HCP.Zombies = {
	["npc_zombie"] = true,
	["npc_fastzombie"] = true,
	["npc_poisonzombie"] = true,
	["npc_zombine"] = true,
}

HCP.InstantKill = {
	["npc_headcrab"] = true,
	["npc_headcrab_fast"] = true,
}

-- Determines if a Headcrab can take over an Entity (returns Bool)
function HCP.CheckTakeOver(entity, cosmetic, attacker)
	if attacker and (not IsValid(attacker) or not HCP.GetZombieClass(attacker:GetClass())) then return false end
	if not IsValid(entity) or not HCP.CheckHeadBone(cosmetic or entity) then return false end
	if entity:IsPlayer() and HCP.GetConvarBool("takeover_players") then return true end
	if entity:IsNPC() and HCP.GetConvarBool("takeover_npcs") then return true end
	return false
end

-- Determines if the entity has a valid Head Bone (returns Bool)
function HCP.CheckHeadBone(entity)
	return entity.HCP_Ignore or entity:LookupBone("ValveBiped.Bip01_Head1") ~= nil
end

-- Finds the zombie class for the given class and entity (returns String)
-- If no entity is provided, the function will not do a Zombine Check
function HCP.GetZombieClass(headcrab_class, entity)
	local class = HCP.Headcrabs[headcrab_class]
	if HCP.GetConvarBool("enable_infection") and HCP.Zombies[headcrab_class] then
		class = headcrab_class ~= "npc_zombine" and headcrab_class or "npc_zombie"
	end

	if IsValid(entity) and class == "npc_zombie" and HCP.GetConvarBool("enable_zombines") and HCP.ZombineModels[entity:GetModel()] then
		if entity:IsPlayer() and HCP.GetConvarBool("enable_player_zombines") then
			return "npc_zombine"
		elseif not entity:IsPlayer() then
			return "npc_zombine"
		end
	end
	return class or false
end

-- Finds the Sabrean skin table for a model name (returns Table)
function HCP.GetSabreanSkin(model)
	model = string.Explode("/", model)
	model = model[table.Count(model) - 1] .. "/" .. model[table.Count(model)]
	return HCP.SabreanModels[model] or HCP.SabreanModels[string.Explode("/", model)[2]] or false
end

-- Setups Sabrean's Model or Bonemerge that matches a target (returns Bool or Entity)
function HCP.SetupBonemerge(zclass, entity, target, nobonemerge)
	-- Find the model and skin that should be used if Sabrean's is enabled
	local model, skin
	if HCP.GetSabreanEnabled() then
		local skintable = HCP.GetSabreanSkin(entity:GetModel())
		local zombineskin = HCP.ZombineModels[entity:GetModel()]

		-- Support for shotgunner skins
		if istable(zombineskin) then
			zombineskin = zombineskin[entity:GetSkin()] or true
		end

		if zclass == "npc_zombie" or zclass == "npc_fastzombie" then
			if (not skintable or not skintable[1]) and isnumber(zombineskin) then
				model = "models/zombie/zombie_soldier.mdl"
				skin = zombineskin
			elseif skintable then
				model = "models/zombie/classic.mdl"
				skin = skintable[1]
			end
		elseif skintable and zclass == "npc_poisonzombie" then
			model = "models/zombie/poison.mdl"
			skin = skintable[2]
		elseif isnumber(zombineskin) and zclass == "npc_zombine" then
			model = "models/zombie/zombie_soldier.mdl"
			skin = zombineskin
		end
	end

	-- Don't use bonemerge if the found model and zombie model are the same
	if target:GetModel() == model then
		target:SetSkin(skin)
		return true
	end

	if not nobonemerge then
		local bonemerge = HCP.CreateBonemerge(target, model or entity:GetModel(), skin or entity:GetSkin())
		if entity.GetPlayerColor then bonemerge:SetPlayerColor(entity:GetPlayerColor()) end
		for k, v in pairs(entity:GetBodyGroups()) do
			bonemerge:SetBodygroup(v.id, entity:GetBodygroup(v.id))
		end

		return bonemerge
	end

	return false
end

-- Copies a Bonemerge from one entity to another (returns Entity)
function HCP.CopyBonemerge(bonemerge, target)
	local newmerge = HCP.CreateBonemerge(target, bonemerge:GetModel(), bonemerge:GetSkin())
	for k, v in pairs(bonemerge:GetBodyGroups()) do
		newmerge:SetBodygroup(v.id, bonemerge:GetBodygroup(v.id))
	end
	return newmerge
end

-- Creates a Bonemerge entity on a parent (returns Entity)
function HCP.CreateBonemerge(entity, model, skin, noscaling)
	if not IsValid(entity) then return end

	local bonemerge = ents.Create("hcp_bonemerge")
	bonemerge:SetParent(entity)
	bonemerge:SetModel(model)
	bonemerge:SetSkin(skin or 1)
	bonemerge:SetShouldScale(not noscaling)
	bonemerge:Spawn()
	entity.HCP_Bonemerge = bonemerge
	entity:DeleteOnRemove(bonemerge)

	return bonemerge
end

-- Creates a bonemerged death ragdoll matching the Entity's Bonemerge (returns Entity)
function HCP.CreateDeathRagdoll(entity)
	local deathragdoll = ents.Create("prop_ragdoll")
	deathragdoll:SetModel(entity:GetModel())
	deathragdoll:SetPos(entity:GetPos())
	deathragdoll:SetAngles(entity:GetAngles())
	deathragdoll:Spawn()
	deathragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	deathragdoll:Fire("FadeAndRemove", "", 120)

	HCP.CopyBonemerge(entity.HCP_Bonemerge, deathragdoll)

	-- Move all the bones to match the NPC
	for i = 0, deathragdoll:GetPhysicsObjectCount() do
		local physobj = deathragdoll:GetPhysicsObjectNum(i)
		if IsValid(physobj) then
			local pos, ang = entity:GetBonePosition(entity:TranslatePhysBoneToBone(i))
			physobj:SetPos(pos)
			physobj:SetAngles(ang)
			physobj:EnableMotion(true)
		end
	end

	-- Don't show the headcrab on the ragdoll if one was dropped
	if entity.HCP_Death == DEATH_NODROP then
		deathragdoll:SetBodygroup(1,1)
	else
		deathragdoll.HCP_Bonemerge:SetShouldScale(false)
	end

	entity:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	entity.HCP_Bonemerge:Remove()
	SafeRemoveEntityDelayed(entity, 0.2)

	return deathragdoll
end

-- Creates a bonemerged zombie matching the Entity (returns Entity)
function HCP.CreateZombie(zclass, entity, nobonemerge)
	local zombie = ents.Create(zclass)
	zombie:SetPos(entity:GetPos())
	zombie:SetAngles(entity:GetAngles())
	zombie:Spawn()
	zombie:Activate()
	zombie:SetNoDraw(false)
	zombie.IsHeadcrabPlus = true

	if zclass == "npc_poisonzombie" then
		for k,v in pairs(zombie:GetBodyGroups()) do
			if v.id == 1 then continue end
			zombie:SetBodygroup(v.id, 0)
		end
		zombie:SetKeyValue("crabcount", 0)
	end

	HCP.SetupBonemerge(zclass, IsValid(entity.HCP_Bonemerge) and entity.HCP_Bonemerge or entity, zombie, nobonemerge)

	return zombie
end

function HCP.HandleTakeover(attacker, entity, cosmetic)
	if not IsValid(attacker) or not HCP.CheckTakeOver(entity, cosmetic) then return end

	local zclass = HCP.GetZombieClass(attacker:GetClass(), cosmetic or entity)
	if not zclass then return end

	local zombie = HCP.CreateZombie(zclass, cosmetic or entity, not HCP.GetConvarBool("enable_bonemerge"))

	if HCP.GetConvarBool("remove_attacker") and not HCP.Zombies[attacker:GetClass()] then
		attacker:Remove()
	else
		attacker.HCP_DMGLock = nil
	end

	if IsValid(attacker.HCP_Owner) then
		local owner = attacker.HCP_Owner

		if owner:GetInfoNum("hcp_enable_undolist", 1) == 1 then
			undo.Create("Zombified_Headcrab")
				undo.AddEntity(zombie)
				undo.SetPlayer(owner)
			undo.Finish()
		end
		owner:AddCleanup("npcs", zombie)
		owner:AddCount("npcs", zombie)
	end

	if entity:IsNPC() then
		entity:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
		SafeRemoveEntityDelayed(entity, 0.2)
	elseif entity:IsPlayer() then
		entity.HCP_RemoveRagdoll = true
	end

	return zombie
end

hook.Add("PlayerSpawnedNPC", "headCrabsPlus_OwnerTracker", function(ply, ent)
	if not IsValid(ply) or not IsValid(ent) then return end
	ent.HCP_Owner = ply
end)

-- Mark an enemy for the correct death behavior
hook.Add("EntityTakeDamage", "HCP_MarkDeath", function(target, dmginfo)
	if not target:IsNPC() or not IsValid(target.HCP_Bonemerge) or dmginfo:GetDamage() < target:Health() then return end

	if dmginfo:IsDamageType(DMG_DISSOLVE) then
		target.HCP_Death = DEATH_DISSOLVE
		return
	end

	if target:GetClass() == "npc_poisonzombie" and target:GetKeyValues()["crabcount"] == 0  then
		for k,v in pairs(target:GetBodyGroups()) do
			target:SetBodygroup(v.id, 0)
		end
		return
	end

	-- Stop them from splitting in half from saws / explosions
	if dmginfo:GetDamage() >= target:GetMaxHealth( ) / 2 and bit.band(dmginfo:GetDamageType(), bit.bor(DMG_BLAST, DMG_CRUSH, DMG_SLASH)) ~= 0 then
		dmginfo:SetDamageType(DMG_GENERIC)
	end

	local damageThreshold = dmginfo:GetDamage() / target:GetMaxHealth()
	local HC_BONE
	if target:GetClass() == "npc_zombie" or target:GetClass() == "npc_zombine" then
		HC_BONE = 13
	elseif target:GetClass() == "npc_fastzombie" then
		HC_BONE = 10
	else
		return
	end

	-- Determine if the attack hit the head bone
	if dmginfo:IsBulletDamage() and damageThreshold < 0.25 then
		if not target:GetHitBoxBone(HC_BONE, 0) then return end

		local bounds = {target:GetHitBoxBounds(HC_BONE, 0)}
		local world, worldang = target:GetBonePosition(target:GetHitBoxBone(HC_BONE, 0))

		OrderVectors(bounds[1], bounds[2])
		bounds[1]:Add(Vector(-1,-1,-1))
		bounds[2]:Add(Vector(1,1,1))

		local dmgpos = WorldToLocal(dmginfo:GetDamagePosition(), target:GetAngles(), world, worldang)
		if dmgpos:WithinAABox(bounds[1], bounds[2]) then
			target.HCP_Death = DEATH_NODROP
		end
	elseif not dmginfo:IsBulletDamage() then
		target.HCP_Death = DEATH_NODROP
	end
end)

hook.Add("OnNPCKilled", "HCP_NPCDeath", function(npc, inflictor, attacker)
	-- Handle Death Ragdolls
	if IsValid(npc.HCP_Bonemerge) then
		if not HCP.GetConvarBool("enable_bonemerge_ragdolls") then
			npc.HCP_Bonemerge:Remove()
		end

		if npc.HCP_Death == DEATH_DISSOLVE then
			npc:SetModel(npc.HCP_Bonemerge:GetModel())
			npc.HCP_Bonemerge:Remove()
			return
		end

		if HCP.GetConvarBool("enable_bonemerge_ragdolls") then
			HCP.CreateDeathRagdoll(npc)
		end
		return
	end

	if not isentity(attacker) then attacker = inflictor end -- bad mods that use hook.Run incorrectly
	HCP.HandleTakeover(attacker, npc)
end)

hook.Add("DoPlayerDeath", "HCP_PlayerDeath", function(ply, attacker, dmg)
	if pk_pills and pk_pills.getMappedEnt(ply) then
		local pill = pk_pills.getMappedEnt(ply)
		ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS) -- Zombie will be invisible if it spawns in the player's collision, should reset on spawn
		HCP.HandleTakeover(attacker, ply, pill:GetPuppet())
		pill:Remove()
		return
	end

	HCP.HandleTakeover(attacker, ply)
end)

-- Remove Player's Ragdoll after Zombification
hook.Add("PostPlayerDeath", "HCP_RemoveRagdoll", function(ply)
	ply.HCP_PoisonBites = nil

	if not ply.HCP_RemoveRagdoll then return end
	ply.HCP_RemoveRagdoll = nil

	if IsValid(ply:GetRagdollEntity()) then
		ply:GetRagdollEntity():Remove()
	end
end)

-- Instant Kill Chance
hook.Add("EntityTakeDamage", "HCP_InstantKill", function(ent, dmg)
	local attacker = dmg:GetAttacker()
	if not HCP.CheckTakeOver(ent, nil, attacker) or not HCP.InstantKill[attacker:GetClass()] then return end

	if HCP.GetConvarBool("instantkill_enable") and math.Rand(0, 100) < HCP.GetConvarInt("instantkill_chance") then
		dmg:SetDamage(999)
		attacker.HCP_DMGLock = CurTime()
	end

	if HCP.GetConvarBool("instantkill_behind") then
		local angle = (ent:GetPos() - attacker:GetPos()):Angle() - ent:EyeAngles()
		angle:Normalize()
		if angle.y < 60 and angle.y > -60 then
			dmg:SetDamage(999)
			attacker.HCP_DMGLock = CurTime() + 0.1
		end
	end
end)

-- Modify other addon's hooks to fix conflictions :)
hook.Add("InitPostEntity", "HCP_CompatHooks", function()
	local hooktable = hook.GetTable()

	-- Stop P.K. Pills hook from returning during player death
	if hooktable["DoPlayerDeath"]["pk_pill_death"] then
		local oldpk = hooktable["DoPlayerDeath"]["pk_pill_death"]
		hook.Add("DoPlayerDeath", "pk_pill_death", function(ply, attacker)
			if IsValid(pk_pills.getMappedEnt(ply)) and HCP.CheckTakeOver(ply, pk_pills.getMappedEnt(ply):GetPuppet(), attacker) then return end
			return oldpk(ply, attacker)
		end)
	end

	-- Stop Blood and Gore Overhaul 3 from gibbing zombies
	if hooktable["OnNPCKilled"]["BGORagdollsConvertNPC"] then
		local oldbgo = hooktable["OnNPCKilled"]["BGORagdollsConvertNPC"]
		hook.Add("OnNPCKilled", "OnNPCKilled", function(npc, attacker, inflictor)
			if npc.IsHeadcrabPlus and IsValid(npc.HCP_boneMerge) then return end
			return oldbgo(npc, attacker, inflictor)
		end)
	end
end)

-- Diagnostics for bug reports
-- I don't really care that its bad, its just for me!
local Hooks = {
	"InitPostEntity",
	"EntityTakeDamage",
	"DoPlayerDeath",
	"OnNPCKilled",
}
local functions = {}
local function ReadHookFile(info)
	local source = "lua/" .. string.gsub(info.source, "@(.*)lua/", "", 1)
	local data = file.Read(source, "GAME")
	if not data or data == "" then return end

	local str = ""
	local datatable = string.Split(data, "\n")
	for i = info.linedefined, info.lastlinedefined do
		if not datatable[i] then break end
		str = str .. datatable[i] .. "\n"
	end

	return str
end

local diagnostic
concommand.Add("hcp_diagnostic", function(ply)
	if IsValid(ply) and not ply:IsAdmin() then return end
	local report = IsValid(ply) and function(...) ply:ChatPrint(...) print(...) end or print

	if diagnostic then
		report(diagnostic)
		return
	end

	local str = "----List of Addons----"
	for k, v in pairs(engine.GetAddons()) do
		if not v.mounted then continue end
		str = str .. "\n" .. v.wsid .. ":\t" .. v.title
	end

	str = str .. "\n\n-----List of Hooks----"
	for k, v in pairs(Hooks) do
		str = str .. "\n" .. v .. ":"
		for a, b in SortedPairs(hook.GetTable()[v]) do
			str = str .. "\n\t" .. a
			functions[v .. "." .. a] = b
		end
	end

	str = str .. "\n\n-----Hook Definitions-----"
	for k, v in SortedPairs(functions) do
		local info = debug.getinfo(v)
		str = str .. "\n" .. k .. ": " .. info.source .. "\n" .. (ReadHookFile(info) or "unable to read") .. "\n"
	end

	HTTP({
		url = "https://hastebin.com/documents",
		method = "POST",
		body = str,
		failure = function(e) report("Diagnostic failed to post: " .. e) end,
		success = function(c, body, h)
			local data = util.JSONToTable(body)
			if not data or not data.key then
				report("Diagnostic failed to post: " .. c)
				return
			end

			diagnostic = "Your diagnostic report has been posted at:\n" .. "https://hastebin.com/" .. data.key .. "\nPaste this in your bug report on the forums!"
			report(diagnostic)
		end
	})
end)