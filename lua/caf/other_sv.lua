local meta = FindMetaTable("Entity")

function meta:WaterLevel2()
	local waterlevel = self:WaterLevel()

	if self:GetPhysicsObject():IsValid() and self:GetPhysicsObject():IsMoveable() then
		--Msg("Normal WaterLEvel\n")
		--this doesn't look like it works when ent is welded to world, or not moveable
		return waterlevel
	end
	--Msg("Special WaterLEvel\n") --Broken in Gmod SVN!!!
	if waterlevel ~= 0 then return waterlevel end
	local pos = self:GetPos()
	local tr = util.TraceLine({
		start = pos,
		endpos = pos,
		filter = {self},
		mask = 16432 -- MASK_WATER
	})
	if tr.Hit then return 3 end
	return 0
end

player_manager.AddValidModel("MedicMarine", "models/player/samzanemesis/MarineMedic.mdl")
player_manager.AddValidModel("SpecialMarine", "models/player/samzanemesis/MarineSpecial.mdl")
player_manager.AddValidModel("OfficerMarine", "models/player/samzanemesis/MarineOfficer.mdl")
player_manager.AddValidModel("TechMarine", "models/player/samzanemesis/MarineTech.mdl")
util.PrecacheModel("models/player/samzanemesis/MarineMedic.mdl")
util.PrecacheModel("models/player/samzanemesis/MarineSpecial.mdl")
util.PrecacheModel("models/player/samzanemesis/MarineOfficer.mdl")
util.PrecacheModel("models/player/samzanemesis/MarineTech.mdl")