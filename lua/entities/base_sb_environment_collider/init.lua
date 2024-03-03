AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local SB = CAF.GetAddon("Spacebuild")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetNoDraw(true)
	self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
	self:AddEFlags(EFL_SERVER_ONLY)
	self:SetMoveType(MOVETYPE_NONE)
	self.TouchTable = {}
end

function ENT:UpdateTransmitState()
	return TRANSMIT_NEVER
end

function ENT:ResetTouchTable()
	for ent, _ in pairs(self.TouchTable) do
		self:EndTouch(ent)
	end
	self.TouchTable = {}
end

function ENT:SetEnvironment(env)
	self:SetPos(env:GetPos())
	self:SetAngles(env:GetAngles())
	self:SetParent(env)
	self.sbenv = env
	env:SBEnvPhysics(self)

	local phys = self:GetPhysicsObject()
	phys:EnableMotion(false)
	phys:EnableGravity(false)
	phys:EnableDrag(false)
	phys:Wake()

	self:SetTrigger(true)
end

function ENT:OnRemove()
	for ent, _ in pairs(self.TouchTable) do
		self:EndTouch(ent)
	end
	self.TouchTable = {}
end

function ENT:StartTouch(ent)
	if ent.SkipSBChecks or not self.sbenv then
		return
	end

	if not ent.SBInEnvironments then
		ent.SBInEnvironments = {}
	end

	self.TouchTable[ent] = true
	ent.SBInEnvironments[self.sbenv] = true
	SB.PerformEnvironmentCheckOnEnt(ent)
end

function ENT:EndTouch(ent)
	if ent.SkipSBChecks or not self.sbenv then
		return
	end

	if not ent.SBInEnvironments then
		ent.SBInEnvironments = {}
	end

	self.TouchTable[ent] = nil
	ent.SBInEnvironments[self.sbenv] = nil
	SB.PerformEnvironmentCheckOnEnt(ent)
end
