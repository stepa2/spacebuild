﻿AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
DEFINE_BASECLASS("base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self.damaged = 0
	self.vent = false

	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName

		self.Inputs = Wire_CreateInputs(self, {"Vent"})

		self.Outputs = Wire_CreateOutputs(self, {"Heavy Water", "Max Heavy Water"})
	else
		self.Inputs = {
			{
				Name = "Vent"
			}
		}
	end

	self.caf.custom.masschangeoverride = true
end

function ENT:TriggerInput(iname, value)
	if iname == "Vent" then
		if value ~= 1 then
			self.vent = false
		else
			self.vent = true
		end
	end
end

function ENT:Damage()
	if self.damaged == 0 then
		self.damaged = 1
		self:EmitSound("PhysicsCannister.ThrusterLoop") --Change to a new Liquid Vent/Escaping Sound
	end
end

function ENT:Repair()
	BaseClass.Repair(self)
	self:SetColor(Color(255, 255, 255, 255))
	self:StopSound("PhysicsCannister.ThrusterLoop") --Change to a new air Vent/Escaping Sound
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.LibLS then
		CAF.LibLS.Destruct(self, true)
	end
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)
	self:StopSound("PhysicsCannister.ThrusterLoop") --Change to a new Liquid Vent/Escaping Sound
end

function ENT:Leak()
	local coolant = self:GetResourceAmount("heavy water")

	if coolant >= 100 then
		self:ConsumeResource("heavy water", 100)
	else
		self:ConsumeResource("heavy water", coolant)
		self:StopSound("PhysicsCannister.ThrusterLoop") --Change to a new Liquid Vent/Escaping Sound
	end
end

function ENT:UpdateMass()
	-- Heavy water really isn't THAT much heavier - its just Deutrium instead of hydrogen, so you have two extra neutrons.  The original value was a tiny bit too much IMHO.  Halved.
	local mul = 0.15
	local div = math.Round(self:GetNetworkCapacity("heavy water") / self.MAXRESOURCE)
	local mass = self.mass + ((self:GetResourceAmount("heavy water") * mul) / div) -- self.mass = default mass + need a good multiplier
	local phys = self:GetPhysicsObject()

	if phys:IsValid() and phys:GetMass() ~= mass then
		phys:SetMass(mass)
		phys:Wake()
	end
end

function ENT:Think()
	if self.damaged == 1 or self.vent then
		self:Leak()
	end

	self:UpdateMass()

	BaseClass.Think(self)

	return true
end

function ENT:UpdateWireOutput()
	self:DoUpdateWireOutput("Heavy Water", "heavy water")
end