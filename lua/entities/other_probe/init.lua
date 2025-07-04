﻿AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
util.PrecacheSound("Buttons.snd17")
include("shared.lua")
DEFINE_BASECLASS("base_rd3_entity")
local Energy_Increment = 4
local BeepCount = 3

function ENT:Initialize()
	BaseClass.Initialize(self)
	self.Active = 0
	self.damaged = 0

	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName

		self.Inputs = Wire_CreateInputs(self, {"On"})

		self.Outputs = Wire_CreateOutputs(self, {"O2 Level", "CO2 Level", "Nitrogen Level", "Hydrogen Level", "Empty Air Level", "Pressure", "Temperature", "Gravity", "On"})
	else
		self.Inputs = {
			{
				Name = "On"
			}
		}
	end
	--self:ShowOutput()
end

function ENT:TurnOn()
	self:EmitSound("Buttons.snd17")
	self.Active = 1
	self:SetOOO(1)
	self:Sense()
	self:ShowOutput()

	if WireAddon ~= nil then
		Wire_TriggerOutput(self, "On", 1)
	end
end

function ENT:TurnOff(warn)
	if not warn then
		self:EmitSound("Buttons.snd17")
	end

	self.Active = 0
	self:SetOOO(0)
	self:ShowOutput()

	if WireAddon ~= nil then
		Wire_TriggerOutput(self, "On", 0)
		Wire_TriggerOutput(self, "O2 Level", 0)
		Wire_TriggerOutput(self, "CO2 Level", 0)
		Wire_TriggerOutput(self, "Nitrogen Level", 0)
		Wire_TriggerOutput(self, "Hydrogen Level", 0)
		Wire_TriggerOutput(self, "Empty Air Level", 0)
		Wire_TriggerOutput(self, "Pressure", 0)
		Wire_TriggerOutput(self, "Temperature", 0)
		Wire_TriggerOutput(self, "Gravity", 0)
	end
end

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		self:SetActive(value)
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
	if CAF and CAF.LibLS then
		CAF.LibLS.Destruct(self, true)
	end
end

function ENT:Sense()
	if self:GetResourceAmount("energy") <= 0 then
		self:EmitSound("common/warning.wav")
		self:TurnOff(true)

		return
	else
		if BeepCount > 0 then
			BeepCount = BeepCount - 1
		else
			self:EmitSound("Buttons.snd17")
			BeepCount = 20 --30 was a little long, 3 times a minute is ok
		end
	end

	if WireAddon ~= nil and self.environment then
		Wire_TriggerOutput(self, "O2 Level", self.environment:GetO2Percentage())
		Wire_TriggerOutput(self, "CO2 Level", self.environment:GetCO2Percentage())
		Wire_TriggerOutput(self, "Nitrogen Level", self.environment:GetNPercentage())
		Wire_TriggerOutput(self, "Hydrogen Level", self.environment:GetHPercentage())
		Wire_TriggerOutput(self, "Empty Air Level", self.environment:GetEmptyAirPercentage())
		Wire_TriggerOutput(self, "Pressure", self.environment:GetPressure())
		Wire_TriggerOutput(self, "Temperature", self.environment:GetTemperature(self))
		Wire_TriggerOutput(self, "Gravity", self.environment:GetSBGravity())
	end

	self:ConsumeResource("energy", Energy_Increment)
end

function ENT:ShowOutput()
	self:SetNWInt(1, self.environment:GetO2Percentage() or 0)
	self:SetNWInt(2, self.environment:GetCO2Percentage() or 0)
	self:SetNWInt(3, self.environment:GetNPercentage() or 0)
	self:SetNWInt(4, self.environment:GetHPercentage() or 0)
	self:SetNWInt(5, self.environment:GetPressure() or 0)
	self:SetNWInt(6, self.environment:GetTemperature(self) or 0)
	self:SetNWInt(7, self.environment:GetSBGravity() or 0)
	self:SetNWString(8, self.environment:GetEnvironmentName() or "")
	self:SetNWInt(9, self.environment:GetEmptyAirPercentage() or 0)
end

function ENT:Think()
	BaseClass.Think(self)

	if self.Active == 1 then
		self:Sense()
		self:ShowOutput()
	end

	return true
end