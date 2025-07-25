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

		self.Outputs = Wire_CreateOutputs(self, {"Storage", "Max Storage"})
	else
		self.Inputs = {
			{
				Name = "Vent"
			}
		}
	end

	self.caf.custom.masschangeoverride = true
	self.caf.custom.resource = "oxygen"
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

function ENT:OnRemove()
	BaseClass.OnRemove(self)
	local air = self:GetResourceAmount(self.caf.custom.resource)

	if self.environment then
		if self.caf.custom.resource == "oxygen" then
			self.environment:Convert(-1, 0, air)
		elseif self.caf.custom.resource == "carbon dioxide" then
			self.environment:Convert(-1, 1, air)
		elseif self.caf.custom.resource == "hydrogen" then
			self.environment:Convert(-1, 3, air)
		elseif self.caf.custom.resource == "nitrogen" then
			self.environment:Convert(-1, 2, air)
		end
	end

	self:StopSound("PhysicsCannister.ThrusterLoop")
end

function ENT:Damage()
	if self.damaged == 0 then
		self.damaged = 1
		self:EmitSound("PhysicsCannister.ThrusterLoop")
	end
end

function ENT:Repair()
	BaseClass.Repair(self)
	self:SetColor(Color(255, 255, 255, 255))
	self:StopSound("PhysicsCannister.ThrusterLoop")
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.LibLS then
		CAF.LibLS.Destruct(self, true)
	end
end

function ENT:Leak()
	local air = self:GetResourceAmount(self.caf.custom.resource)
	local mul = air / self.MAXRESOURCE
	local am = math.Round(mul * 1000)

	if air >= am then
		self:ConsumeResource(self.caf.custom.resource, am)

		if self.environment then
			if self.caf.custom.resource == "oxygen" then
				self.environment:Convert(-1, 0, am)
			elseif self.caf.custom.resource == "carbon dioxide" then
				self.environment:Convert(-1, 1, am)
			elseif self.caf.custom.resource == "hydrogen" then
				self.environment:Convert(-1, 3, am)
			elseif self.caf.custom.resource == "nitrogen" then
				self.environment:Convert(-1, 2, am)
			end
		end
	else
		self:ConsumeResource(self.caf.custom.resource, air)

		if self.environment then
			if self.caf.custom.resource == "oxygen" then
				self.environment:Convert(-1, 0, air)
			elseif self.caf.custom.resource == "carbon dioxide" then
				self.environment:Convert(-1, 1, air)
			elseif self.caf.custom.resource == "hydrogen" then
				self.environment:Convert(-1, 3, air)
			elseif self.caf.custom.resource == "nitrogen" then
				self.environment:Convert(-1, 2, air)
			end
		end

		self:StopSound("PhysicsCannister.ThrusterLoop")
	end
end

function ENT:UpdateMass()
	local mul = 0.02

	if self.caf.custom.resource == "oxygen" then
		mul = 0.02
	elseif self.caf.custom.resource == "carbon dioxide" then
		mul = 0.02
	elseif self.caf.custom.resource == "hydrogen" then
		mul = 0.02
	elseif self.caf.custom.resource == "nitrogen" then
		mul = 0.02
	end

	local div = math.Round(self:GetNetworkCapacity(self.caf.custom.resource) / self.MAXRESOURCE)
	local mass = self.mass + ((self:GetResourceAmount(self.caf.custom.resource) * mul) / div) -- self.mass = default mass + need a good multiplier
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
	self:DoUpdateWireOutput("Storage", self.caf.custom.resource)
end