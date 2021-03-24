﻿AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
util.PrecacheSound("ambient.steam01")
--Extra Resources Added by DataSchmuck for the McBuild's Community
include("shared.lua")
DEFINE_BASECLASS("base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self.damaged = 0
	self.venten = false
	self.ventoxy = false
	self.ventco2 = false
	self.venthyd = false
	self.ventnit = false
	self.ventwat = false
	self.venthwwat = false
	self.ventamount = 1000

	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName

		self.Inputs = Wire_CreateInputs(self, {"Vent Amount", "Expel Energy", "Vent Oxygen", "Vent Co2", "Vent Hydrogen", "Vent Nitrogen", "Leak Water", "Leak Heavy Water"})

		self.Outputs = Wire_CreateOutputs(self, {"Energy", "Oxygen", "Co2", "Hydrogen", "Nitrogen", "Water", "Hvy Water", "Max Energy", "Max Oxygen", "Max Co2", "Max Hydrogen", "Max Nitrogen", "Max Water", "Max Hvy Water"})
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
	if iname == "Expel Energy" then
		if value ~= 1 then
			self.venten = false
		else
			self.venten = true
		end
	elseif iname == "Vent Oxygen" then
		if value ~= 1 then
			self.ventoxy = false
		else
			self.ventoxy = true
		end
	elseif iname == "Vent Co2" then
		if value ~= 1 then
			self.ventco2 = false
		else
			self.ventco2 = true
		end
	elseif iname == "Vent Hydrogen" then
		if value ~= 1 then
			self.venthyd = false
		else
			self.venthyd = true
		end
	elseif iname == "Vent Nitrogen" then
		if value ~= 1 then
			self.ventnit = false
		else
			self.ventnit = true
		end
	elseif iname == "Leak Water" then
		if value ~= 1 then
			self.ventwat = false
		else
			self.ventwat = true
		end
	elseif iname == "Leak Heavy Water" then
		if value ~= 1 then
			self.venthwwat = false
		else
			self.venthwat = true
		end
	elseif iname == "Vent Amount" then
		if value ~= 0 then
			self.ventamount = math.abs(value)
		else
			self.ventamount = 1000
		end
	end
end

function ENT:Damage()
	if self.damaged == 0 then
		self.damaged = 1
		self:EmitSound("PhysicsCannister.ThrusterLoop")
		self:EmitSound("ambient.steam01")
	end
end

function ENT:Repair()
	BaseClass.Repair(self)
	self:SetColor(Color(255, 255, 255, 255))
	self.damaged = 0
	self:StopSound("PhysicsCannister.ThrusterLoop")
	self:StopSound("ambient.steam01")
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct(self, true)
	end
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)
	local air = self:GetResourceAmount("oxygen")
	local co2 = self:GetResourceAmount("carbon dioxide")
	local hydrogen = self:GetResourceAmount("hydrogen")
	local nitrogen = self:GetResourceAmount("nitrogen")

	if self.environment then
		self.environment:Convert(-1, 0, air)
		self.environment:Convert(-1, 1, co2)
		self.environment:Convert(-1, 3, hydrogen)
		self.environment:Convert(-1, 2, nitrogen)
	end

	self:StopSound("PhysicsCannister.ThrusterLoop")
	self:StopSound("ambient.steam01")
end

function ENT:LeakHvyWater()
	local heavywater = self:GetResourceAmount("heavy water")

	if heavywater >= self.ventamount then
		self:ConsumeResource("heavy water", self.ventamount)
	else
		self:ConsumeResource("heavy water", heavywater)
		self:StopSound("PhysicsCannister.ThrusterLoop") --Change to a new Liquid Vent/Escaping Sound
	end
end

function ENT:VentCo2()
	local co2 = self:GetResourceAmount("carbon dioxide")

	if co2 >= self.ventamount then
		self:ConsumeResource("carbon dioxide", self.ventamount)

		if self.environment then
			self.environment:Convert(-1, 1, self.ventamount)
		end
	else
		self:ConsumeResource("carbon dioxide", co2)

		if self.environment then
			self.environment:Convert(-1, 1, co2)
		end

		self:StopSound("PhysicsCannister.ThrusterLoop") --Change to a new co2 Vent/Escaping Sound
	end
end

function ENT:VentO2()
	local air = self:GetResourceAmount("oxygen")

	if air > 0 then
		if air >= self.ventamount then
			self:ConsumeResource("oxygen", self.ventamount)

			if self.environment then
				self.environment:Convert(-1, 0, self.ventamount)
			end
		else
			self:ConsumeResource("oxygen", air)

			if self.environment then
				self.environment:Convert(-1, 0, air)
			end

			self:StopSound("PhysicsCannister.ThrusterLoop")
		end
	end
end

function ENT:VentHydrogen()
	local hydrogen = self:GetResourceAmount("hydrogen")

	if hydrogen >= self.ventamount then
		self:ConsumeResource("hydrogen", self.ventamount)

		if self.environment then
			self.environment:Convert(-1, 3, self.ventamount)
		end
	else
		self:ConsumeResource("hydrogen", hydrogen)

		if self.environment then
			self.environment:Convert(-1, 3, hydrogen)
		end

		self:StopSound("PhysicsCannister.ThrusterLoop") --Change to a new air Vent/Escaping Sound
	end
end

function ENT:VentNitrogen()
	local nitrogen = self:GetResourceAmount("nitrogen")

	if nitrogen >= self.ventamount then
		self:ConsumeResource("nitrogen", self.ventamount)

		if self.environment then
			self.environment:Convert(-1, 2, self.ventamount)
		end
	else
		self:ConsumeResource("nitrogen", nitrogen)

		if self.environment then
			self.environment:Convert(-1, 2, nitrogen)
		end

		self:StopSound("PhysicsCannister.ThrusterLoop") --Change to a new air Vent/Escaping Sound
	end
end

function ENT:ExpEnergy()
	local energy = self:GetResourceAmount("energy")

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
		zapme(self:GetPos(), 1)
		local tmp = ents.FindInSphere(self:GetPos(), 600)

		for _, ply in ipairs(tmp) do
			--??? wont that be zaping any player in any water??? should do a dist check first and have damage based on dist
			if ply:IsPlayer() and ply:WaterLevel() > 0 then
				zapme(ply:GetPos(), 1)
				ply:TakeDamage(ply:WaterLevel() * energy / 100, 0)
			end
		end

		self.maxenergy = self:GetUnitCapacity("energy")

		--??? loose all energy on net when damaged and in water??? that sounds crazy to me
		if energy >= self.maxenergy then
			self:ConsumeResource("energy", self.maxenergy)
		else
			self:ConsumeResource("energy", energy)
		end
	else
		if energy >= self.ventamount then
			self:ConsumeResource("energy", self.ventamount)
		else
			self:ConsumeResource("energy", energy)
		end
	end
end

function ENT:LeakWater()
	local water = self:GetResourceAmount("water")

	if water == 0 then
		return
	end
	if water >= self.ventamount then
		self:ConsumeResource("water", self.ventamount)
	else
		self:ConsumeResource("water", water)
		self:StopSound("ambient.steam01")
	end
end

function ENT:UpdateMass()
	--[[local RD = CAF.GetAddon("Resource Distribution")
     local mul = 0.5
     local div = math.Round(RD.GetNetworkCapacity(self, "carbon dioxide")/self.MAXRESOURCE)
     local mass = self.mass + ((RD.GetResourceAmount(self, "carbon dioxide") * mul)/div) -- self.mass = default mass + need a good multiplier
     local phys = self:GetPhysicsObject()
     if phys:IsValid() then
         if phys:GetMass() ~= mass then
             phys:SetMass(mass)
             phys:Wake()
         end
     end]]
end

function ENT:Think()
	if self.damaged == 1 or self.venten then
		self:ExpEnergy()
	end

	if self.damaged == 1 or self.ventoxy then
		self:VentO2()
	end

	if self.damaged == 1 or self.ventnit then
		self:VentNitrogen()
	end

	if self.damaged == 1 or self.venthyd then
		self:VentHydrogen()
	end

	if self.damaged == 1 or self.ventco2 then
		self:VentCo2()
	end

	if self.damaged == 1 or self.ventwat then
		self:LeakWater()
	end

	if self.damaged == 1 or self.venthwat then
		self:LeakHvyWater()
	end

	self:UpdateMass()

	BaseClass.Think(self)

	return true
end

function ENT:UpdateWireOutput()
	self:DoUpdateWireOutput("Hydrogen", "hydrogen")
	self:DoUpdateWireOutput("Co2", "carbon dioxide")
	self:DoUpdateWireOutput("Nitrogen", "nitrogen")
	self:DoUpdateWireOutput("Hvy Water", "heavy water")
	self:DoUpdateWireOutput("Oxygen", "oxygen")
	self:DoUpdateWireOutput("Energy", "energy")
	self:DoUpdateWireOutput("Water", "water")
end
