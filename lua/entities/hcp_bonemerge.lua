AddCSLuaFile()
ENT.Type = "anim"

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "ShouldScale")
	self:NetworkVar("Vector", 0, "PlayerColor")
end

function ENT:Initialize()
	if SERVER then
		self:AddEffects(bit.bor(EF_BONEMERGE))
	end

	if IsValid(self:GetParent()) then
		self:GetParent():SetSubMaterial(0, "models/effects/vol_light001")
		self:GetParent():SetSkin(100)
	end

	self:AddCallback("BuildBonePositions", self.BuildBonePositions)
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:OnRemove()
	if IsValid(self:GetParent()) then
		self:GetParent():SetSubMaterial(0, "")
	end
end

function ENT:BuildBonePositions(boneCount)
	if not self:GetShouldScale() or not IsValid(self:GetParent()) then return end

	local boneId = self:LookupBone("ValveBiped.Bip01_Head1")
	local matrix = self:GetBoneMatrix(boneId or -1)
	if not boneId or not matrix then return end

	if self:GetParent():GetClass() == "npc_poisonzombie" then
		matrix:Scale(Vector(0.8, 0.8, 0.8))
		matrix:Rotate(Angle(-90, 130, 0))
	else
		matrix:Scale(Vector(.01, .01, .01))
	end
	self:SetBoneMatrix(boneId, matrix)
end