﻿AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
DEFINE_BASECLASS("base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self.energy = 0
	self.damaged = 0
	self.vent = false

	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName

		self.Inputs = Wire_CreateInputs(self, {"Vent"})

		self.Outputs = Wire_CreateOutputs(self, {"Energy", "Max Energy"})
	else
		self.Inputs = {
			{
				Name = "Vent"
			}
		}
	end
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
	end
end

function ENT:Repair()
	BaseClass.Repair(self)
	self:SetColor(Color(255, 255, 255, 255))
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct(self, true)
	end
end

function ENT:Leak()
	local energy = self:GetResourceAmount("energy")
	local zapme

	if CAF.GetAddon("Life Support") then
		zapme = CAF.GetAddon("Life Support").ZapMe
	end

	if energy == 0 then
		return
	end
	local waterlevel = 0

	if CAF then
		waterlevel = self:WaterLevel2()
	else
		waterlevel = self:WaterLevel()
	end

	if waterlevel > 0 then
		if zapme then
			zapme(self:GetPos(), 1)
		end

		local tmp = ents.FindInSphere(self:GetPos(), 600) --Better check in next version

		for _, ply in ipairs(tmp) do
			if ply:IsPlayer() and ply:WaterLevel() > 0 then
				if zapme then
					zapme(ply:GetPos(), 1)
				end

				ply:TakeDamage(energy / 100, 0)
			end
		end

		self:ConsumeResource("energy", energy)
	else
		if math.random(1, 10) < 2 then
			if zapme then
				zapme(self:GetPos(), 1)
			end

			local dec = math.random(200, 2000)
			self:ConsumeResource("energy", dec)
		end
	end
end

function ENT:Think()
	if self.damaged == 1 or self.vent then
		self:Leak()
	end

	BaseClass.Think(self)

	return true
end

function ENT:UpdateWireOutput()
	self:DoUpdateWireOutput("Energy", "energy")
end