﻿TOOL.Mode = "rd3_dev_link_adv"
TOOL.Category = "Resource Distribution"
TOOL.Name = "#Advanced Link Tool"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.Tab = "Custom Addon Framework"


if CLIENT then
	language.Add("tool.rd3_dev_link_adv.name", "Advanced Link Tool")
	language.Add("tool.rd3_dev_link_adv.desc", "Links Resource-Carrying Devices together to a Resource Node, including Vehicle Pods. Waypoints can be set using this stool!!")
	language.Add("tool.rd3_dev_link_adv.0", "Left Click: Link Devices.  Right Click: Place link point.  Reload: Unlink Device from All.")
	language.Add("tool.rd3_dev_link_adv.1", "Click on another Resource-Carrying Device(or Vehicle Pod)")
	language.Add("tool.rd3_dev_link_adv.2", "Right-Click on another Resource-Carrying Device(or the same one to unlink ALL)")
	language.Add("rd3_dev_link_adv_addlength", "Add Length:")
	language.Add("rd3_dev_link_adv_width", "Width:")
	language.Add("rd3_dev_link_adv_material", "Material:")
	language.Add("rd3_dev_link_adv_colour", "Color:")
end

TOOL.ClientConVar["material"] = "cable/cable"
TOOL.ClientConVar["width"] = "2"
TOOL.ClientConVar["color_r"] = "255"
TOOL.ClientConVar["color_g"] = "255"
TOOL.ClientConVar["color_b"] = "255"
TOOL.ClientConVar["color_a"] = "255"

function TOOL:LeftClick(tr)
	--if not valid or player, exit
	if tr.Entity:IsValid() and tr.Entity:IsPlayer() then return end
	--if client exit
	if CLIENT then return true end
	-- If there's no physics object then we can't constraint it!
	if not util.IsValidPhysicsObject(tr.Entity, tr.PhysicsBone) then return false end
	--how many objects stored
	local iNum = self:NumObjects() + 1
	--save clicked postion
	self:SetObject(iNum, tr.Entity, tr.HitPos, tr.Entity:GetPhysicsObjectNum(tr.PhysicsBone), tr.PhysicsBone, tr.HitNormal)

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
	rd.Beam_add(self:GetEnt(1), tr.Entity, tr.Entity:WorldToLocal(tr.HitPos + tr.HitNormal))

	--if finishing, run StartTouch on Resource Node to do link
	if iNum > 1 then
		local Ent1 = self:GetEnt(1) --get first ent
		local Ent2 = self:GetEnt(iNum) --get last ent
		local length = (self:GetPos(1) - self:GetPos(iNum)):Length()

		if Ent1.IsNode and Ent2.IsNode then
			if length <= Ent1.range or length <= Ent2.range then
				rd.LinkNodes(Ent1.netid, Ent2.netid)
			else
				CAF.NotifyOwner(self, "These 2 Nodes are too far apart!")
				--clear beam points
				rd.Beam_clear(self:GetEnt(1))
				self:ClearObjects() --clear objects
				--failure

				return
			end
		elseif Ent1.IsNode and table.Count(rd.GetEntityTable(Ent2)) > 0 then
			if length <= Ent1.range then
				rd.Link(Ent2, Ent1.netid)
			else
				CAF.NotifyOwner(self, "The Entity and the Node are too far apart!")
				--clear beam points
				rd.Beam_clear(self:GetEnt(1))
				self:ClearObjects() --clear objects
				--failure

				return
			end
		elseif Ent2.IsNode and table.Count(rd.GetEntityTable(Ent1)) > 0 then
			if length <= Ent2.range then
				rd.Link(Ent1, Ent2.netid)
			else
				CAF.NotifyOwner(self, "The Entity and the Node are too far apart!")
				--clear beam points
				rd.Beam_clear(self:GetEnt(1))
				self:ClearObjects() --clear objects
				--failure

				return
			end
		elseif Ent1.IsNode and Ent2.IsPump then
			if length <= Ent1.range then
				Ent2:SetNetwork(Ent1.netid)
				Ent2.node = Ent1
			else
				CAF.NotifyOwner(self, "The Pump and the Node are too far apart!")
				--clear beam points
				rd.Beam_clear(self:GetEnt(1))
				self:ClearObjects() --clear objects
				--failure

				return
			end
		elseif Ent2.IsNode and Ent1.IsPump then
			-- pump has no range
			if length <= Ent2.range then
				Ent1:SetNetwork(Ent2.netid)
				Ent1.node = Ent2
			else
				CAF.NotifyOwner(self, "The Pump and the Node are too far apart!")
				--clear beam points
				rd.Beam_clear(self:GetEnt(1))
				self:ClearObjects() --clear objects
				--failure

				return
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
	else
		self:SetStage(iNum)
	end

	--clear objects on 2nd click
	if iNum > 1 then
		self:ClearObjects()
	end
	--success!

	return true
end

function TOOL:RightClick(tr)
	--if not valid, exit
	if not tr.Entity or not tr.Entity:IsValid() or tr.Entity:IsPlayer() or tr.Entity:IsWorld() then return false end
	--if client exit
	if CLIENT then return true end
	-- If there's no physics object then we can't constraint it!
	if not util.IsValidPhysicsObject(tr.Entity, tr.PhysicsBone) then return false end
	--how many objects stored
	local iNum = self:NumObjects() + 1
	--save clicked postion
	self:SetObject(iNum, tr.Entity, tr.HitPos, tr.Entity:GetPhysicsObjectNum(tr.PhysicsBone), tr.PhysicsBone, tr.HitNormal)
	--add beam point
	CAF.LibRD.Beam_add(self:GetEnt(1), tr.Entity, tr.Entity:WorldToLocal(tr.HitPos + tr.HitNormal))
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

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Text = "#tool.rd3_dev_link_adv.name",
		Description = "#tool.rd3_dev_link_adv.desc"
	})

	CPanel:AddControl("Slider", {
		Label = "#rd3_dev_link_adv_width",
		Type = "Float",
		Min = ".1",
		Max = "20",
		Command = "rd3_dev_link_adv_width"
	})

	CPanel:AddControl("MatSelect", {
		Height = "1",
		Label = "#rd3_dev_link_adv_material",
		ItemWidth = 24,
		ItemHeight = 64,
		ConVar = "rd3_dev_link_adv_material",
		Options = list.Get("BeamMaterials")
	})

	CPanel:AddControl("Color", {
		Label = "#rd3_dev_link_adv_colour",
		Red = "rd3_dev_link_adv_color_r",
		Green = "rd3_dev_link_adv_color_g",
		Blue = "rd3_dev_link_adv_color_b",
		ShowAlpha = "1",
		ShowHSV = "1",
		ShowRGB = "1",
		Multiplier = "255"
	})
end