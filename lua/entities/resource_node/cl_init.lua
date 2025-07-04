﻿include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

local RD = CAF.LibRD

surface.CreateFont("ConflictText", {
	font = "Verdana",
	size = 60,
	weight = 600
})

surface.CreateFont("Flavour", {
	font = "Verdana",
	size = 40,
	weight = 600
})

function ENT:Draw(bDontDrawModel)
	self:DoNormalDraw()
	--draw beams by MadDog
	RD.Beam_Render(self)

	if Wire_Render then
		Wire_Render(self)
	end
end

function ENT:DrawTranslucent(bDontDrawModel)
	if bDontDrawModel then return end
	self:Draw()
end

function ENT:DoNormalDraw(bDontDrawModel)
	local mode = self:GetNWInt("overlaymode")

	-- Don't enable it if disabled by default!
	if RD_OverLay_Mode and mode ~= 0 and RD_OverLay_Mode.GetInt then
		local nr = math.Round(RD_OverLay_Mode:GetInt())

		if nr >= 0 and nr <= 3 then
			mode = nr
		end
	end

	local rd_overlay_dist = 512

	if RD_OverLay_Distance and RD_OverLay_Distance.GetInt then
		local nr = RD_OverLay_Distance:GetInt()

		if nr >= 256 then
			rd_overlay_dist = nr
		end
	end

	local mdl = self:GetModel()


	if not bDontDrawModel then
		self:DrawModel()
	end
	if not ((EyePos():Distance(self:GetPos()) < rd_overlay_dist and mode ~= 0) and ((mode ~= 1 and not string.find(mdl, "s_small_res")) or LocalPlayer():GetEyeTrace().Entity == self)) then
		return
	end

	local netid = self:GetNWInt("netid")
	local nettable = RD.GetNetTable(netid)
	local range = self:GetNWInt("range")
	local playername = self:GetPlayerName()
	local nodename = self:GetNWString("rd_node_name")

	if playername == "" then
		playername = "World"
	end

	-- 0 = no overlay
	-- 1 = default overlaytext
	-- 2 = new overlaytext
	if not mode or mode == 1 or string.find(mdl, "s_small_res") then
		local OverlayText = ""
		OverlayText = OverlayText .. "Network " .. netid .. "\n"

		if nodename ~= "" then
			OverlayText = OverlayText .. "Networkname " .. nodename .. "\n"
		end

		OverlayText = OverlayText .. "Owner: " .. playername .. "\n"
		OverlayText = OverlayText .. "Range: " .. range .. "\n"

		if table.Count(nettable) <= 0 then
			OverlayText = OverlayText .. "Loading network data...\n"
		else
			local cons = nettable.cons

			if table.Count(cons) > 0 then
				OverlayText = OverlayText .. "Connected to networks: "

				for k, v in pairs(cons) do
					OverlayText = OverlayText .. tostring(v) .. " "
				end

				OverlayText = OverlayText .. "\n"
			end

			local resources = nettable.resources

			if table.Count(resources) > 0 then
				for k, v in pairs(resources) do
					OverlayText = OverlayText .. RD.GetProperResourceName(k) .. ": " .. v.value .. "/" .. v.maxvalue .. "\n"
				end
			else
				OverlayText = OverlayText .. "No Resources Connected\n"
			end
		end

		AddWorldTip(self:EntIndex(), OverlayText, 0.5, self:GetPos(), self)
		return
	end
	local TempY = 0
	local mul_up = 10
	local mul_ri = -16.5
	local mul_fr = -12.5

	if string.find(mdl, "small_res") then
		mul_up = 5.2
	elseif string.find(mdl, "medium_res") then
		mul_up = 10.2
	elseif string.find(mdl, "large_res") then
		mul_up = 15.2
	end

	--local pos = self:GetPos() + (self:GetForward() ) + (self:GetUp() * 40 ) + (self:GetRight())
	local pos = self:GetPos() + (self:GetUp() * mul_up) + (self:GetRight() * mul_ri) + (self:GetForward() * mul_fr)
	--[[local angle =  (LocalPlayer():GetPos() - trace.HitPos):Angle()
	angle.r = angle.r  + 90
	angle.y = angle.y + 90
	angle.p = 0]]
	local angle = self:GetAngles()
	local textStartPos = -375
	cam.Start3D2D(pos, angle, 0.05)
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(textStartPos, 0, 1250, 675)
	surface.SetDrawColor(155, 155, 155, 255)
	surface.DrawRect(textStartPos, 0, -5, 675)
	surface.DrawRect(textStartPos, 0, 1250, -5)
	surface.DrawRect(textStartPos, 675, 1250, -5)
	surface.DrawRect(textStartPos + 1250, 0, 5, 675)
	TempY = TempY + 10
	surface.SetFont("ConflictText")
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(textStartPos + 15, TempY)
	surface.DrawText("Network " .. netid)
	TempY = TempY + 70
	local extra = 70

	if mode == 3 then
		extra = 50
	end

	surface.SetFont("Flavour")
	surface.SetTextColor(200, 200, 255, 255)
	surface.SetTextPos(textStartPos + 15, TempY)
	surface.DrawText("Owner: " .. playername)
	TempY = TempY + extra

	if nodename ~= "" then
		surface.SetTextPos(textStartPos + 15, TempY)
		surface.DrawText("Nodename: " .. nodename)
		TempY = TempY + extra
	end

	surface.SetTextPos(textStartPos + 15, TempY)
	surface.DrawText("Range: " .. range)
	TempY = TempY + extra

	if table.Count(nettable) <= 0 then
		surface.SetTextPos(textStartPos + 15, TempY)
		surface.DrawText("Loading data...")
		TempY = TempY + extra
	else
		-- Print the used resources
		local stringUsage = ""
		local cons = nettable.cons

		if table.Count(cons) > 0 then

			for k, v in pairs(cons) do
				stringUsage = stringUsage .. tostring(v) .. " "
			end

			surface.SetTextPos(textStartPos + 15, TempY)
			surface.DrawText("Connected to networks: " .. stringUsage)
			TempY = TempY + extra
		end

		stringUsage = ""
		local resources = nettable.resources

		if table.Count(resources) > 0 then
			local i = 0
			surface.SetTextPos(textStartPos + 15, TempY)
			surface.DrawText("Resources: ")
			TempY = TempY + extra

			for k, v in pairs(resources) do
				if mode == 3 then
					surface.SetTextColor(200, 200, 255, 255)
					local amt = v.value / v.maxvalue
					surface.SetTextPos(textStartPos + 15, TempY)
					surface.DrawText("   " .. RD.GetProperResourceName(k))
					surface.DrawOutlinedRect(-20, TempY - 5, -2 * textStartPos + 20, 40)
					surface.DrawRect(-20, TempY - 5, ((-2 * textStartPos) + 20) * amt, 40)
					TempY = TempY + 50
					local value, h = surface.GetTextSize(tostring(v.value))

					if amt < 0.5 then
						surface.SetTextPos(-2 * textStartPos * amt - 5, TempY - 15 - h)
						surface.DrawText(v.value)
					else
						surface.SetTextColor(0, 0, 0, 255)
						surface.SetTextPos(-2 * textStartPos * amt - 15 - value, TempY - 15 - h)
						surface.DrawText(v.value)
					end
				else
					stringUsage = stringUsage .. "[" .. RD.GetProperResourceName(k) .. ": " .. v.value .. "/" .. v.maxvalue .. "] "
					i = i + 1

					if i == 3 then
						surface.SetTextPos(textStartPos + 15, TempY)
						surface.DrawText("   " .. stringUsage)
						TempY = TempY + 70
						stringUsage = ""
						i = 0
					end
				end
			end

			if mode ~= 3 then
				surface.SetTextPos(textStartPos + 15, TempY)
				surface.DrawText("   " .. stringUsage)
				TempY = TempY + 70
			end
		else
			surface.SetTextColor(200, 200, 255, 255)
			surface.SetTextPos(textStartPos + 15, TempY)
			surface.DrawText("No resources connected")
			TempY = TempY + 70
		end
	end

	--Stop rendering
	cam.End3D2D()
end

if Wire_UpdateRenderBounds then
	function ENT:Think()
		Wire_UpdateRenderBounds(self)
		self:NextThink(CurTime() + 3)
	end
end