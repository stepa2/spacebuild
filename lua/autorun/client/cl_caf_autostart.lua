local gmod_version_required = 145

if VERSION < gmod_version_required then
	error("SB CORE: Your gmod is out of date: found version ", VERSION, "required ", gmod_version_required)
end

local net = net
--Variable Declarations
CAF = {}



local function ErrorOffStuff(String)
	Msg("----------------------------------------------------------------------\n")
	Msg("-----------Custom Addon Management Framework Error----------\n")
	Msg("----------------------------------------------------------------------\n")
	Msg(tostring(String) .. "\n")
end

include("caf/core/shared/sh_general_caf.lua")

hook.Add("InitPostEntity", "CAF_Start", function()
	CAF.LibRD.__Construct()
	CAF.LibSB.__AutoStart()
	-- TODO: CAF.LibSB.__Construct()

	CAF.LibLS.__Construct()
end)

stp.IncludeFile("caf/core/popup_sh.lua")

--CAF = CAF
--Include clientside files
--Core
local coreFiles = file.Find("caf/core/client/*.lua", "LUA")

for k, File in ipairs(coreFiles) do
	local ErrorCheck, PCallError = pcall(include, "caf/core/client/" .. File)

	if not ErrorCheck then
		ErrorOffStuff(PCallError)
	end
end

local languageFiles = file.Find("caf/languagevars/*.lua", "LUA")

for k, File in ipairs(languageFiles) do
	local ErrorCheck, PCallError = pcall(include, "caf/languagevars/" .. File)

	if not ErrorCheck then
		ErrorOffStuff(PCallError)
	end
end

--Addons
local addonFiles = file.Find("caf/addons/client/*.lua", "LUA")

for k, File in ipairs(addonFiles) do
	local ErrorCheck, PCallError = pcall(include, "caf/addons/client/" .. File)

	if not ErrorCheck then
		ErrorOffStuff(PCallError)
	end
end


stp.IncludeFile("caf/core/player_full_load_sh.lua")