local RD = CAF.LibRD

-- BEAMS BY MADDOG

list.Add("BeamMaterials", "cable/rope_icon")
list.Add("BeamMaterials", "cable/cable2")
list.Add("BeamMaterials", "cable/xbeam")
list.Add("BeamMaterials", "cable/redlaser")
list.Add("BeamMaterials", "cable/blue_elec")
list.Add("BeamMaterials", "cable/physbeam")
list.Add("BeamMaterials", "cable/hydra")

if SERVER then
    --Name: RD.Beam_settings
    --Desc: Sends beam info to the clientside.
    --Args:
    --	beamMaterial -  the material to use (defualt cable/cable2)
    --	beamSize - the size of the beam, design 2
    --	beamColor - the beam color (default: Color(255, 255, 255, 255)
    function RD.Beam_settings(ent, beamMaterial, beamSize, beamColor)
        --get beam color
        local beamR, beamG, beamB, beamA = beamColor.r or 255, beamColor.g or 255, beamColor.b or 255, beamColor.a or 255
        --send beam info to ent/clientside
        ent:SetNWString("BeamInfo", 
            (beamMaterial or "cable/cable2") .. ";" .. 
            tostring(beamSize or 2) .. ";" .. 
            tostring(beamR or 255) .. ";" .. 
            tostring(beamG or 255) .. ";" .. 
            tostring(beamB or 255) .. ";" .. 
            tostring(beamA or 255))
    end

    --Name: RD.Beam_add
    --Desc: Add a beam to a ent
    --Args:
    --	sEnt: The ent to save the beam to
    --	eEnt: The entity to base the vector off
    --	beamVec: The local vector (based on eEnt) to place the beam
    function RD.Beam_add(sEnt, eEnt, beamVec)
        --get how many beams there currently are
        local iBeam = (sEnt:GetNWInt("Beams") or 0) + 1
        --send beam data
        --clicked entity
        sEnt:SetNWEntity("BeamEnt" .. tostring(iBeam), eEnt)
        --clicked local vector
        sEnt:SetNWVector("Beam" .. tostring(iBeam), beamVec or Vector(0, 0, 0))
        --how many beams (points)
        sEnt:SetNWInt("Beams", iBeam)
    end

    --Name: RD.Beam_switch
    --Desc: Switches the beam settings from one ent to another.
    --Args:
    --	Ent1: The ent to get the current beams from
    --	Ent2: Where to send the beam settings to
    function RD.Beam_switch(Ent1, Ent2)
        --transfer beam data
        Ent2:SetNWString("BeamInfo", Ent1:GetNWString("BeamInfo"))

        --loop through all beams
        for i = 1, Ent1:GetNWInt("Beams") do
            --transfer beam data
            Ent2:SetNWVector("Beam" .. tostring(i), Ent1:GetNWVector("Beam" .. tostring(i)))
            Ent2:SetNWEntity("BeamEnt" .. tostring(i), Ent1:GetNWEntity("BeamEnt" .. tostring(i)))
        end

        --how many beam points
        Ent2:SetNWInt("Beams", Ent1:GetNWInt("Beams"))
        --set beams to zero
        Ent1:SetNWInt("Beams", 0)
    end

    --Name: RD.Beam_clear
    --Desc: Sets beams to zero to stop from them rendering
    --Args:
    --	ent - the ent to clean the beams from
    function RD.Beam_clear(ent)
        ent:SetNWInt("Beams", 0)
    end

    --Name: Rd.Beam_get_table
    --Desc: Used to return a table of beam info for adv dup support
    --Args:
    --	ent - the ent to get the beam info from
    function RD.Beam_dup_save(ent)
        --the table to return
        local beamTable = {}
        duplicator.ClearEntityModifier(ent, "RDBeamDupeInfo")
        --amount of beams to draw
        beamTable.Beams = ent:GetNWInt("Beams")

        --if we have beams, then create them
        if beamTable.Beams and beamTable.Beams ~= 0 then
            --store beam info
            beamTable.BeamInfo = ent:GetNWString("BeamInfo")

            --loop through all beams
            for i = 1, beamTable.Beams do
                --store beam vector
                beamTable["Beam" .. tostring(i)] = ent:GetNWVector("Beam" .. tostring(i))
                --store beam entity
                beamTable["BeamEnt" .. tostring(i)] = ent:GetNWEntity("BeamEnt" .. tostring(i)):EntIndex()
            end
        else
            --no beams to save
            return
        end

        --store beam table into duplicator
        duplicator.StoreEntityModifier(ent, "RDBeamDupeInfo", beamTable)
    end

    --Name: Rd.Beam_set_table
    --Desc: Sets beams from a table
    --Args:
    --	ent - the ent to get the beam info from
    function RD.Beam_dup_build(ent, CreatedEntities)
        --exit if no beam dup info
        if not ent.EntityMods or not ent.EntityMods.RDBeamDupeInfo then return end
        --get the beam info table
        local beamTable = ent.EntityMods.RDBeamDupeInfo
        --transfer beam data
        ent:SetNWString("BeamInfo", beamTable.BeamInfo)

        --loop through all beams
        for i = 1, beamTable.Beams do
            --transfer beam data
            ent:SetNWVector("Beam" .. tostring(i), beamTable["Beam" .. tostring(i)])
            ent:SetNWEntity("BeamEnt" .. tostring(i), CreatedEntities[beamTable["BeamEnt" .. tostring(i)]])
        end

        --how many beam points
        ent:SetNWInt("Beams", beamTable.Beams)
    end


else
    --holds the materials
    local beamMat = {}

    for _, mat in pairs(list.Get("BeamMaterials")) do
        beamMat[mat] = Material(mat)
    end

    local xbeam = Material("cable/xbeam")

    -- Desc: draws beams on ents
    function RD.Beam_Render(ent)
        --get the number of beams to use
        local intBeams = ent:GetNWInt("Beams")

        --if we have beams, then create them
        if intBeams and intBeams ~= 0 then
            --make some vars we are about to use
            local start, scroll = ent:GetNWVector("Beam1"), CurTime() * 0.5
            --get beam info and explode into a table
            local beamInfo = string.Explode(";", ent:GetNWString("BeamInfo"))
            --get beam info from table (1: beamMaterial 2: beamSize 3: beamR 4: beamG 5: beamB 6: beamAlpha)
            local beamMaterial, beamSize, color = (beamMat[beamInfo[1]] or xbeam), (beamInfo[2] or 2), Color(beamInfo[3] or 255, beamInfo[4] or 255, beamInfo[5] or 255, beamInfo[6] or 255)
            -- set material
            render.SetMaterial(beamMaterial)
            render.StartBeam(intBeams) --how many links (points) the beam has

            --loop through all beams
            for i = 1, intBeams do
                --get beam data
                local beam, subent = ent:GetNWVector("Beam" .. tostring(i)), ent:GetNWEntity("BeamEnt" .. tostring(i))

                --if no beam break for statement
                if not beam or not subent or not subent:IsValid() then
                    ent:SetNWInt("Beams", 0)
                    break
                end

                --get beam world vector
                local pos = subent:LocalToWorld(beam)
                --update scroll
                scroll = scroll - (pos - start):Length() / 10
                -- add point
                render.AddBeam(pos, beamSize, scroll, color)
                --reset start postion
                start = pos
            end

            --beam done
            render.EndBeam()
        end
    end

end