﻿TOOL.Mode = "rd3_dev_link_valve"
TOOL.Category = "Resource Distribution"
TOOL.Name = "#Valve Link Tool"
TOOL.Command = nil
TOOL.ConfigName = ''
TOOL.Tab = "Custom Addon Framework"


if CLIENT then
	language.Add("tool.rd3_dev_link_valve.name", "Valve Link Tool")
	language.Add("tool.rd3_dev_link_valve.desc", "Links a resource node to a 1 or 2 way Valve.")
	language.Add("tool.rd3_dev_link_valve.0", "Left Click: Link Resource Node 1 to the valve.  Right Click: Link Resource Node2 to the Valve.  Reload: Unlink Device from All.")
	language.Add("tool.rd3_dev_link_valve.1", "Click on the next device (Valve/Resource node)")
	language.Add("tool.rd3_dev_link_valve.2", "Right-Click on the next device (Valve/Resource node)")
	language.Add("rd3_dev_link_valve_addlength", "Add Length:")
	language.Add("rd3_dev_link_valve_width", "Width:")
	language.Add("rd3_dev_link_valve_material", "Material:")
	language.Add("rd3_dev_link_valve_colour", "Color:")
end

TOOL.ClientConVar["material"] = "cable/cable2"
TOOL.ClientConVar["width"] = "2"
TOOL.ClientConVar["color_r"] = "255"
TOOL.ClientConVar["color_g"] = "255"
TOOL.ClientConVar["color_b"] = "255"
TOOL.ClientConVar["color_a"] = "255"

function TOOL:LeftClick(trace)
	--if not valid or player, exit
	if trace.Entity:IsValid() and trace.Entity:IsPlayer() then return end
	--if client exit
	if CLIENT then return true end
	-- If there's no physics object then we can't constraint it!
	if not util.IsValidPhysicsObject(trace.Entity, trace.PhysicsBone) then return false end
	--how many objects stored
	local iNum = self:NumObjects() + 1
	--save clicked postion
	self:SetObject(iNum, trace.Entity, trace.HitPos, trace.Entity:GetPhysicsObjectNum(trace.PhysicsBone), trace.PhysicsBone, trace.HitNormal)

	local rd = CAF.LibRD

	--first clicked object
	if iNum == 1 then
		--remove from any LS system since we are changing its link
		rd.Unlink(self:GetEnt(1))

		if self:GetEnt(1).IsNode then
			rd.Beam_clear(self:GetEnt(1))
		end

		--save beam settings
		rd.Beam_settings(self:GetEnt(1), self:GetClientInfo("material"), self:GetClientInfo("width"), Color(self:GetClientInfo("color_r"), self:GetClientInfo("color_g"), self:GetClientInfo("color_b"), self:GetClientInfo("color_a")))
	end

	if iNum == 2 and self:GetEnt(2).IsNode then
		rd.Beam_clear(self:GetEnt(2))
	end

	--add beam point
	rd.Beam_add(self:GetEnt(1), trace.Entity, trace.Entity:WorldToLocal(trace.HitPos + trace.HitNormal))

	--if finishing, run StartTouch on Resource Node to do link
	if iNum > 1 then
		local Ent1 = self:GetEnt(1) --get first ent
		local Ent2 = self:GetEnt(iNum) --get last ent

		if Ent1.IsNode and Ent2.IsValve and not Ent2.IsEntityValve then
			if Ent1:GetPos():Distance(Ent2:GetPos()) <= Ent1.range then
				Ent2:SetNode1(Ent1)
			else
				CAF.NotifyOwner(self, "The Resource Node and Valve are too far apart!")
			end
		elseif Ent2.IsNode and Ent1.IsValve and not Ent1.IsEntityValve then
			if Ent2:GetPos():Distance(Ent1:GetPos()) <= Ent2.range then
				Ent1:SetNode1(Ent2)
			else
				CAF.NotifyOwner(self, "The Resource Node and Valve are too far apart!")
			end
		else
			CAF.NotifyOwner(self, "Invalid Combination!")
			--clear beam points
			rd.Beam_clear(self:GetEnt(1))
			self:ClearObjects() --clear objects
			--failure

			return
		end

		--if first ent is the node, transfer beam info to last ent
		if Ent1.IsNode then
			rd.Beam_switch(self:GetEnt(1), self:GetEnt(iNum))
		end

		self:ClearObjects() --clear objects
	else
		self:SetStage(iNum)
	end
	--success!

	return true
end

function TOOL:RightClick(trace)
	--if not valid or player, exit
	if trace.Entity:IsValid() and trace.Entity:IsPlayer() then return end
	--if client exit
	if CLIENT then return true end
	-- If there's no physics object then we can't constraint it!
	if not util.IsValidPhysicsObject(trace.Entity, trace.PhysicsBone) then return false end
	--how many objects stored
	local iNum = self:NumObjects() + 1
	--save clicked postion
	self:SetObject(iNum, trace.Entity, trace.HitPos, trace.Entity:GetPhysicsObjectNum(trace.PhysicsBone), trace.PhysicsBone, trace.HitNormal)

	local rd = CAF.LibRD

	--first clicked object
	if iNum == 1 then
		--remove from any LS system since we are changing its link
		rd.Unlink(self:GetEnt(1))

		if self:GetEnt(1).IsNode then
			rd.Beam_clear(self:GetEnt(1))
		end

		--save beam settings
		rd.Beam_settings(self:GetEnt(1), self:GetClientInfo("material"), self:GetClientInfo("width"), Color(self:GetClientInfo("color_r"), self:GetClientInfo("color_g"), self:GetClientInfo("color_b"), self:GetClientInfo("color_a")))
	end

	if iNum == 2 and self:GetEnt(2).IsNode then
		rd.Beam_clear(self:GetEnt(2))
	end

	--add beam point
	rd.Beam_add(self:GetEnt(1), trace.Entity, trace.Entity:WorldToLocal(trace.HitPos + trace.HitNormal))

	--if finishing, run StartTouch on Resource Node to do link
	if iNum > 1 then
		local Ent1 = self:GetEnt(1) --get first ent
		local Ent2 = self:GetEnt(iNum) --get last ent

		if Ent1.IsNode and Ent2.IsValve and not Ent2.IsEntityValve then
			if Ent1:GetPos():Distance(Ent2:GetPos()) <= Ent1.range then
				Ent2:SetNode2(Ent1)
			else
				CAF.NotifyOwner(self, "The Resource Node and Valve are too far apart!")
			end
		elseif Ent2.IsNode and Ent1.IsValve and not Ent1.IsEntityValve then
			if Ent2:GetPos():Distance(Ent1:GetPos()) <= Ent2.range then
				Ent1:SetNode2(Ent2)
			else
				CAF.NotifyOwner(self, "The Resource Node and Valve are too far apart!")
			end
		else
			CAF.NotifyOwner(self, "Invalid Combination!")
			--clear beam points
			rd.Beam_clear(self:GetEnt(1))
			self:ClearObjects() --clear objects
			--failure

			return
		end

		--if first ent is the node, transfer beam info to last ent
		if Ent1.IsNode then
			rd.Beam_switch(self:GetEnt(1), self:GetEnt(iNum))
		end

		self:ClearObjects() --clear objects
	else
		self:SetStage(iNum)
	end
	--success!

	return true
end

function TOOL:Reload(trace)
	--if not valid or player, exit
	if trace.Entity:IsValid() and trace.Entity:IsPlayer() then return end
	--if client exit
	if CLIENT then return true end

	local rd = CAF.LibRD


	if trace.Entity.IsNode then
		rd.UnlinkAllFromNode(trace.Entity.netid)
	elseif trace.Entity.IsValve then
		if trace.Entity.IsEntityValve then
			trace.Entity:SetRDEntity(nil)
			trace.Entity:SetNode(nil)
		else
			trace.Entity:SetNode1(nil)
			trace.Entity:SetNode2(nil)
		end

		rd.Beam_clear(trace.Entity)
	elseif trace.Entity.IsPump then
		trace.Entity.node = nil
		trace.Entity:SetNetwork(0)
		rd.Beam_clear(trace.Entity)
	else
		rd.Unlink(trace.Entity)
	end

	self:ClearObjects() --clear objects

	return true
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", {
		Text = "#tool.rd3_dev_link_valve.name",
		Description = "#tool.rd3_dev_link_valve.desc"
	})

	panel:AddControl("Slider", {
		Label = "#rd3_dev_link_valve_width",
		Type = "Float",
		Min = ".1",
		Max = "20",
		Command = "rd3_dev_link_valve_width"
	})

	panel:AddControl("MatSelect", {
		Height = "1",
		Label = "#rd3_dev_link_valve_material",
		ItemWidth = 24,
		ItemHeight = 64,
		ConVar = "rd3_dev_link_valve_material",
		Options = list.Get("BeamMaterials")
	})

	panel:AddControl("Color", {
		Label = "#rd3_dev_link_valve_colour",
		Red = "rd3_dev_link_valve_color_r",
		Green = "rd3_dev_link_valve_color_g",
		Blue = "rd3_dev_link_valve_color_b",
		ShowAlpha = "1",
		ShowHSV = "1",
		ShowRGB = "1",
		Multiplier = "255"
	})
end