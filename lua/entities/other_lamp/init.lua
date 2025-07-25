﻿AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
util.PrecacheSound("Buttons.snd17")
include("shared.lua")
DEFINE_BASECLASS("base_rd3_entity")
local Energy_Increment = 4

function ENT:Initialize()
	BaseClass.Initialize(self)
	self.Active = 0
	self.damaged = 0
	self.flashlight = nil

	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName

		self.Inputs = Wire_CreateInputs(self, {"On"})

		self.Outputs = Wire_CreateOutputs(self, {"On"})
	else
		self.Inputs = {
			{
				Name = "On"
			}
		}
	end
end

function ENT:TurnOn()
	if self.Active == 0 then
		self:EmitSound("Buttons.snd17")
		self.Active = 1
		self:SetOOO(1)

		if WireAddon ~= nil then
			Wire_TriggerOutput(self, "On", 1)
		end
	end
end

function ENT:TurnOff(warn)
	if self.Active == 1 then
		if not warn then
			self:EmitSound("Buttons.snd17")
		end

		self.Active = 0
		self:SetOOO(0)

		if WireAddon ~= nil then
			Wire_TriggerOutput(self, "On", 0)
		end
	end
end

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		if value == 0 then
			self:TurnOff()
		elseif value == 1 then
			self:TurnOn()
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
	if CAF and CAF.LibLS then
		CAF.LibLS.Destruct(self, true)
	end
end

function ENT:Think()
	BaseClass.Think(self)

	if self.Active == 1 then
		if self:GetResourceAmount("energy") < Energy_Increment then
			self:EmitSound("common/warning.wav")
			self:TurnOff(true)
		else
			self:ConsumeResource("energy", Energy_Increment)
		end
	end

	if self.Active == 1 and not self.flashlight then
		--self:SetOn(true)
		self.flashlight = ents.Create("env_projectedtexture")
		self.flashlight:SetParent(self)
		-- The local positions are the offsets from parent..
		self.flashlight:SetLocalPos(Vector(0, 0, 0))
		self.flashlight:SetLocalAngles(Angle(90, 90, 90))
		-- Looks like only one flashlight can have shadows enabled!
		self.flashlight:SetKeyValue("enableshadows", 1)
		self.flashlight:SetKeyValue("farz", 2048)
		self.flashlight:SetKeyValue("nearz", 8)
		--the size of the light
		self.flashlight:SetKeyValue("lightfov", 50)
		-- Color.. white is default
		self.flashlight:SetKeyValue("lightcolor", "255 255 255")
		self.flashlight:Spawn()
		self.flashlight:Input("SpotlightTexture", NULL, NULL, "effects/flashlight001")
	elseif self.Active == 0 and self.flashlight then
		SafeRemoveEntity(self.flashlight)
		self.flashlight = nil
	end

	return true
end