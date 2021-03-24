﻿AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetNWInt("overlaymode", 1)
	self:SetNWInt("OOO", 0)
	self.Active = 0
	self.connected = {}
	self.connected.node1 = nil
	self.connected.node2 = nil

	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName

		self.Inputs = Wire_CreateInputs(self, {"Open"})

		self.Outputs = Wire_CreateOutputs(self, {"Open"})
	else
		self.Inputs = {
			{
				Name = "Open"
			}
		}
	end
end

function ENT:GetNode1()
	return self.connected.node1
end

function ENT:GetNode2()
	return self.connected.node2
end

function ENT:SetNode1(node1)
	if self.connected.node1 and self.Active == 1 then
		local rd = CAF.GetAddon("Resource Distribution")

		rd.UnlinkNodes(self.connected.node1.netid, self.connected.node2.netid)

		if node1 then
			rd.LinkNodes(node1.netid, self.connected.node2.netid)
		else
			self:TurnOff()
		end
	end

	self.connected.node1 = node1

	if node1 then
		self:SetNWInt("netid1", node1.netid)
	else
		self:SetNWInt("netid1", 0)
	end
end

function ENT:SetNode2(node2)
	if self.connected.node2 and self.Active == 1 then
		local rd = CAF.GetAddon("Resource Distribution")

		r.UnlinkNodes(self.connected.node1.netid, self.connected.node2.netid)

		if node1 then
			rd.LinkNodes(self.connected.node1.netid, node2.netid)
		else
			self:TurnOff()
		end
	end

	self.connected.node2 = node2

	if node2 then
		self:SetNWInt("netid2", node2.netid)
	else
		self:SetNWInt("netid2", 0)
	end
end

function ENT:TurnOn()
	if self.Active == 0 and self.connected.node1 and self.connected.node2 then
		CAF.GetAddon("Resource Distribution").linkNodes(self.connected.node1.netid, self.connected.node2.netid)
		self.Active = 1
		self:SetOOO(1)

		if WireAddon ~= nil then
			Wire_TriggerOutput(self, "Open", self.Active)
		end
	end
end

function ENT:TurnOff()
	if self.Active == 1 and self.connected.node1 and self.connected.node2 then
		CAF.GetAddon("Resource Distribution").UnlinkNodes(self.connected.node1.netid, self.connected.node2.netid)
		self.Active = 0
		self:SetOOO(0)

		if WireAddon ~= nil then
			Wire_TriggerOutput(self, "Open", self.Active)
		end
	end
end

function ENT:TriggerInput(iname, value)
	if iname == "Open" then
		if value == 0 then
			self:TurnOff()
		elseif value == 1 then
			self:TurnOn()
		end
	end
end

--use this to set self.active
--put a self:TurnOn and self:TurnOff() in your ent
--give value as nil to toggle
--override to do overdrive
--AcceptInput (use action) calls this function with value = nil
function ENT:SetActive(value, caller)
	if ((not (value == nil) and value ~= 0) or (value == nil)) and self.Active == 0 then
		if self.TurnOn then
			self:TurnOn(nil, caller)
		end
	elseif ((not (value == nil) and value == 0) or (value == nil)) and self.Active == 1 then
		if self.TurnOff then
			self:TurnOff(nil, caller)
		end
	end
end

function ENT:SetOOO(value)
	self:SetNWInt("OOO", value)
end

function ENT:Repair()
	self:SetHealth(self:GetMaxHealth())
end

function ENT:AcceptInput(name, activator, caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		self:SetActive(nil, caller)
	end
end

--should make the damage go to the shield if the shield is installed(CDS)
function ENT:OnTakeDamage(DmgInfo)
	if self.Shield then
		self.Shield:ShieldDamage(DmgInfo:GetDamage())
		CDS_ShieldImpact(self:GetPos())

		return
	end

	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").DamageLS(self, DmgInfo:GetDamage())
	end
end

function ENT:Think()
	-- Check if all ents are still valid!
	if self.connected.node1 and not IsValid(self.connected.node1) then
		self:TurnOff()
		self.connected.node1 = nil
		self:SetNWInt("netid1", 0)
	end

	if self.connected.node2 and not IsValid(self.connected.node2) then
		self:TurnOff()
		self.connected.node2 = nil
		self:SetNWInt("netid2", 0)
	end

	-- Check if they are still in range!
	if self.connected.node1 and self:GetPos():Distance(self.connected.node1:GetPos()) > self.connected.node1.range then
		self:TurnOff()
		self.connected.node1 = nil
		self:SetNWInt("netid1", 0)
	end

	if self.connected.node2 and self:GetPos():Distance(self.connected.node2:GetPos()) > self.connected.node2.range then
		self:TurnOff()
		self.connected.node2 = nil
		self:SetNWInt("netid2", 0)
	end

	self:NextThink(CurTime() + 1)

	return true
end

function ENT:OnRemove()
	self:TurnOff()

	if WireAddon ~= nil then
		Wire_Remove(self)
	end
end

function ENT:OnRestore()
	if WireAddon ~= nil then
		Wire_Restored(self)
	end
end

function ENT:PreEntityCopy()
	local RD = CAF.GetAddon("Resource Distribution")
	RD.BuildDupeInfo(self)

	if WireAddon ~= nil then
		local DupeInfo = WireLib.BuildDupeInfo(self)

		if DupeInfo then
			duplicator.StoreEntityModifier(self, "WireDupeInfo", DupeInfo)
		end
	end
end

function ENT:PostEntityPaste(Player, Ent, CreatedEntities)
	local RD = CAF.GetAddon("Resource Distribution")
	RD.ApplyDupeInfo(Ent, CreatedEntities)

	if WireAddon ~= nil and Ent.EntityMods and Ent.EntityMods.WireDupeInfo then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end