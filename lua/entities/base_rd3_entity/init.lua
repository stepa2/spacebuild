﻿AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

local EnergyToTemperature_Increment = 250

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetNWInt("overlaymode", 1)
	self:SetNWInt("OOO", 0)
	self.Active = 0
	self:SetTemperature(-1)
	self.caf = self.caf or {}
	self.caf.custom = self.caf.custom or {}
end

function ENT:GetThermalMass()
	if not self.ThermalMass then
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			self.ThermalMass = phys:GetMass()
		end
	end
	return self.ThermalMass or 1
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

AccessorFunc(ENT, "LSMULTIPLIER", "Multiplier", FORCE_NUMBER)

function ENT:GetMultiplier()
	return self.LSMULTIPLIER or 1
end

function ENT:NormalizeTemperatureTo(otherTemperature, increment)
	local selfTemperature = self:GetTemperature()
	if selfTemperature < 0 or math.abs(selfTemperature - otherTemperature) < 0.1 then
		self:SetTemperature(otherTemperature)
		return
	end
	self:SetTemperature(selfTemperature + ((otherTemperature - selfTemperature) * increment / self:GetThermalMass()))
end

function ENT:WarmUpWithEnergy(energy, dontconsume)
	if not dontconsume then
		energy = self:ConsumeResource("energy", energy)
	end
	self:SetTemperature(self:GetTemperature() + (energy * EnergyToTemperature_Increment / self:GetThermalMass()))
end

function ENT:SetTemperature(temp)
	self:SetNWFloat("Temperature", temp)
end

function ENT:Think()
	self:NextThink(CurTime() + 1)

	local envTemperature = -1
	if self.environment then
		if self.environment.GetTemperature then
			envTemperature = self.environment:GetTemperature(self)
		elseif self.environment.environment and self.environment.environment.GetTemperature then
			envTemperature = self.environment.environment:GetTemperature(self)
		end
	end

	if envTemperature < 0 then
		if self.UpdateWireOutput then
			self:UpdateWireOutput()
		end
		return true
	end

	self:NormalizeTemperatureTo(envTemperature, 0.1)

	if self.UpdateWireOutput then
		self:UpdateWireOutput()
	end

	return true
end

function ENT:Repair()
	self:SetHealth(self:GetMaxHealth())
end

function ENT:AcceptInput(name, activator, caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		if self.Inputs and caller.useaction and caller.useaction == true then
			local maxz = table.Count(self.Inputs)
			local last = false
			local num = 1

			for k, v in pairs(self.Inputs) do
				if num >= maxz then
					last = true
				end

				net.Start("RD_AddInputToMenu")
				net.WriteBool(last)
				net.WriteString(v.Name)
				net.WriteEntity(self)
				net.Send(caller)
				num = num + 1
			end
		else
			self:SetActive(nil, caller)
		end
	end
end

util.AddNetworkString("RD_AddInputToMenu")

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

function ENT:OnRemove()
	RD.Unlink(self)
	RD.RemoveRDEntity(self)

	if WireLib then
		WireLib.Remove(self)
	end

	if self.InputsBeingTriggered then
		for k, v in pairs(self.InputsBeingTriggered) do
			hook.Remove("Think", "ButtonHoldThinkNumber" .. v.hooknum)
		end
	end
end

--NEW Functions 
function ENT:RegisterNonStorageDevice()
	return RD.RegisterNonStorageDevice(self)
end

function ENT:AddResource(resource, maxamount, defaultvalue)
	return RD.AddResource(self, resource, maxamount, defaultvalue)
end

function ENT:ConsumeResource(resource, amount)
	return RD.ConsumeResource(self, resource, amount)
end

function ENT:SupplyResource(resource, amount, temperature)
	return RD.SupplyResource(self, resource, amount, temperature)
end

function ENT:Link(netid)
	return RD.Link(self, netid)
end

function ENT:Unlink()
	return RD.Unlink(self)
end

function ENT:GetResourceAmount(resource)
	return RD.GetResourceAmount(self, resource)
end

function ENT:GetResourceData(resource)
	return RD.GetResourceData(self, resource)
end

function ENT:GetUnitCapacity(resource)
	return RD.GetUnitCapacity(self, resource)
end

function ENT:GetNetworkCapacity(resource)
	return RD.GetNetworkCapacity(self, resource)
end

function ENT:GetEntityTable()
	return RD.GetEntityTable(self)
end

--END NEW Functions
function ENT:OnRestore()
	if WireLib then
		WireLib.Restored(self)
	end
end

function ENT:PreEntityCopy()
	RD.BuildDupeInfo(self)

	if WireLib then
		local DupeInfo = WireLib.BuildDupeInfo(self)

		if DupeInfo then
			duplicator.StoreEntityModifier(self, "WireDupeInfo", DupeInfo)
		end
	end
end

function ENT:PostEntityPaste(Player, Ent, CreatedEntities)
	RD.ApplyDupeInfo(Ent, CreatedEntities)

	if WireLib and Ent.EntityMods and Ent.EntityMods.WireDupeInfo then
		WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end

function ENT:DoUpdateWireOutput(outputName, resourceName)
	local amount, capacity = self:GetResourceData(resourceName)
	Wire_TriggerOutput(self, outputName, amount)
	Wire_TriggerOutput(self, "Max " .. outputName, capacity)
end
