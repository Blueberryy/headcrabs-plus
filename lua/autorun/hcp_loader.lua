HCP = HCP or {}
HCP.Version = "4.0"

if SERVER then
	AddCSLuaFile("hcp/cl_init.lua")
	include("hcp/sv_init.lua")
else
	include("hcp/cl_init.lua")
end

function HCP.GetSabreanEnabled()
	return HCP.GetConvarBool("enable_sabrean") and HCP.GetSabreanInstalled()
end

function HCP.GetSabreanInstalled()
	return ConVarExists("poisonheadcrabzombineskins_prison")
end