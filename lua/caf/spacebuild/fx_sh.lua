if SERVER then
    util.AddNetworkString("AddStar")

    function CAF.LibSB.SendSunConfig(sun, ply)
        net.Start("AddStar")
        net.WriteEntity(sun)
        net.WriteVector(sun:GetPos())
        net.WriteString(sun:GetEnvironmentName())
        net.WriteFloat(sun.sbenvironment.size)
    
        if ply then
            net.Send(ply)
        else
            net.Broadcast()
        end
    end

    
	hook.Add("PlayerFullLoad", "SB.SendSunConfig", function(ply)
        for _, v in ipairs(CAF.LibSB:GetStars()) do
			if IsValid(v) then
				CAF.LibSB.SendSunConfig(v, ply)
			end
		end
    end)
else
    local stars = {}

    local function DrawSunEffects()
        -- no pixel shaders? no sun effects!
        if not render.SupportsPixelShaders_2_0() then return end
        local eyePos = EyePos()

        -- render each star.
        for ent, Sun in pairs(stars) do
            -- calculate brightness.
            local entpos = Sun.Position --Sun.ent:LocalToWorld( Vector(0,0,0) )
            local normVec = Vector(entpos - eyePos)
            normVec:Normalize()
            local dot = math.Clamp(EyeAngles():Forward():Dot(normVec), -1, 1)
            dot = math.abs(dot)
            --local dist = Vector( entpos - EyePos() ):Length();
            local dist = entpos:Distance(eyePos) / 1.5
            -- draw sunbeams.
            local sunpos = eyePos + normVec * (dist * 0.5)
            local scrpos = sunpos:ToScreen()

            if dist <= Sun.BeamRadius and dot > 0 then
                local frac = (1 - ((1 / Sun.BeamRadius) * dist)) * dot
                -- draw sun.
                --DrawSunbeams( darken, multiply, sunsize, sunx, suny )
                DrawSunbeams(0.95, frac, 0.255, scrpos.x / ScrW(), scrpos.y / ScrH())
            end

            -- can the sun see us?
            local tr = util.TraceLine({
                start = entpos,
                endpos = eyePos,
                filter = LocalPlayer(),
            })

            -- draw!
            if dist <= Sun.Radius and dot > 0 and tr.Fraction >= 1 then
                -- calculate brightness.
                local frac = (1 - ((1 / Sun.Radius) * dist)) * dot
                -- draw bloom.
                DrawBloom(0.428, 3 * frac, 15 * frac, 15 * frac, 5, 0, 1, 1, 1)
                -- draw colormod.
                DrawColorModify({
                    ["$pp_colour_addr"] = 0.35 * frac,
                    ["$pp_colour_addg"] = 0.15 * frac,
                    ["$pp_colour_addb"] = 0.05 * frac,
                    ["$pp_colour_brightness"] = 0.8 * frac,
                    ["$pp_colour_contrast"] = 1 + (0.15 * frac),
                    ["$pp_colour_colour"] = 1,
                    ["$pp_colour_mulr"] = 0,
                    ["$pp_colour_mulg"] = 0,
                    ["$pp_colour_mulb"] = 0,
                })
            end
        end
    end

    hook.Add("RenderScreenspaceEffects", "SB_VFX_Render", DrawSunEffects)

    -- receive sun information
    net.Receive("AddStar", function()
        local ent = net.ReadEntity()
        local position = net.ReadVector()
        local tmpname = net.ReadString()
        local radius = net.ReadFloat()

        stars[ent] = {
            name = tmpname,
            Position = position,
            Radius = radius, -- * 2
            BeamRadius = radius * 1.5, --*3
        }
    end)
end