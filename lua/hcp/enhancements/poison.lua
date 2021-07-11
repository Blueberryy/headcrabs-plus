function HCP.CalcPoisonBites(time)
    return math.max(math.ceil(((time or 0) - CurTime()) / HCP.GetConvarInt("poisonbites_healtime")), 0)
end

function HCP.CalcPoisonBitesTime(bites)
    return CurTime() + HCP.GetConvarInt("poisonbites_healtime") * bites
end

hook.Add("EntityTakeDamage", "HCP_PoisonBites", function(ent, dmg)
    local attacker = dmg:GetAttacker()
    if HCP.GetConvarInt("poisonbites") == 0 or dmg:IsDamageType(DMG_SLASH) then return end
    if not HCP.CheckTakeOver(ent, nil, attacker) or attacker:GetClass() ~= "npc_headcrab_black" and attacker:GetClass() ~= "npc_headcrab_poison"  then return end

    local bites = HCP.CalcPoisonBites(ent.HCP_PoisonBites) + 1
    if bites >= HCP.GetConvarInt("poisonbites") then
        dmg:SetDamage(999)
        ent.HCP_PoisonBites = nil
        attacker.HCP_DMGLock = CurTime() + 0.1
        return
    end

    ent.HCP_PoisonBites = HCP.CalcPoisonBitesTime(bites)
end)