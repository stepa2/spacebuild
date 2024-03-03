hook.Add("SetupMove", "SB_SetupMove_Gravity", function(ply)
    local gravity = ply:GetNWFloat("gravity")
    if gravity == 0 then
        gravity = 0.00001
    end
    ply:SetGravity(gravity)
end)

list.Set("PlayerOptionsModel", "MedicMarine", "models/player/samzanemesis/MarineMedic.mdl")
list.Set("PlayerOptionsModel", "SpecialMarine", "models/player/samzanemesis/MarineSpecial.mdl")
list.Set("PlayerOptionsModel", "OfficerMarine", "models/player/samzanemesis/MarineOfficer.mdl")
list.Set("PlayerOptionsModel", "TechMarine", "models/player/samzanemesis/MarineTech.mdl")