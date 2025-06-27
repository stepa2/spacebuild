--[[ Serverside Custom Addon file Base ]]
--
--require("sb_space")
player_manager.AddValidModel("MedicMarine", "models/player/samzanemesis/MarineMedic.mdl")
player_manager.AddValidModel("SpecialMarine", "models/player/samzanemesis/MarineSpecial.mdl")
player_manager.AddValidModel("OfficerMarine", "models/player/samzanemesis/MarineOfficer.mdl")
player_manager.AddValidModel("TechMarine", "models/player/samzanemesis/MarineTech.mdl")
util.PrecacheModel("models/player/samzanemesis/MarineMedic.mdl")
util.PrecacheModel("models/player/samzanemesis/MarineSpecial.mdl")
util.PrecacheModel("models/player/samzanemesis/MarineOfficer.mdl")
util.PrecacheModel("models/player/samzanemesis/MarineTech.mdl")

local SB = {}
--local NextUpdateTime
local SB_InSpace = false
--SetGlobalInt("InSpace", 0)

SB.Override_PressureDamage = 0
SB.PlayerOverride = 0

CreateConVar("SB_NoClip", "1")
CreateConVar("SB_PlanetNoClipOnly", "1")
CreateConVar("SB_AdminSpaceNoclip", "1")
CreateConVar("SB_SuperAdminSpaceNoclip", "1")

--Think + Environments


local MapEntities = {"base_sb_planet1", "base_sb_planet2", "base_sb_star1", "base_sb_star2", "nature_dev_tree", "sb_environment", "base_cube_environment"}

local function PhysgunPickup(ply, ent)
	local notallowed = MapEntities
	if table.HasValue(notallowed, ent:GetClass()) then return false end
end

hook.Add("PhysgunPickup", "SB_PhysgunPickup_Check", PhysgunPickup)
--Don't remove environment on cleanup
local originalCleanUpMap = game.CleanUpMap

function game.CleanUpMap(dontSendToClients, ExtraFilters)
	if ExtraFilters then
		table.Add(ExtraFilters, MapEntities)
	else
		ExtraFilters = MapEntities
	end

	originalCleanUpMap(dontSendToClients, ExtraFilters)
end

local function PlayerNoClip(ply, on)
	if SB_InSpace and not ply.EnableSpaceNoclip and ply.environment and ply.environment:IsSpace() then
		return false
	end
end


--End Local Stuff
--[[
	The AutoStart functions
	Optional
	Get's called before/replacing __Construct on CAF Startup
	Return true = AutoStart (Addon got enabled)
	Return nil or false = addon didn't get enabled
]]
function SB.__AutoStart()
	SB.Register_Sun()
	SB.Register_Environments()
end

--[[
	The Constructor for this Custom Addon Class
	Required
	Return True if succesfully able to start up this addon
	Return false, the reason of why it wasn't able to start
]]
function SB.__Construct()
	if SB_InSpace then
		hook.Add("PlayerNoClip", "SB_PlayerNoClip_Check", PlayerNoClip)
		timer.Create("SBEnvironmentCheck", 1, 0, SB.PerformEnvironmentCheck)
		ResetGravity()

		return true
	end

	return false, "Not on a Spacebuild Map!"
end

CAF.LibSB = SB


concommand.Add("sb_toggle_space_noclip", function (ply, cmd, args)
	if not IsValid(ply) then
		return
	end
	if not ply:IsAdmin() then
		ply:ChatPrint("You cannot use this command")
		return
	end
	ply.EnableSpaceNoclip = not ply.EnableSpaceNoclip
	if ply.EnableSpaceNoclip then
		ply:ChatPrint("Space noclip now enabled!")
	else
		ply:ChatPrint("Space noclip now disabled!")
	end
end)




function SB.AddOverride_PressureDamage()
	SB.Override_PressureDamage = SB.Override_PressureDamage + 1
end