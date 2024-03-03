local gmod_version_required = 145

if VERSION < gmod_version_required then
	error("CAF: Your gmod is out of date: found version ", VERSION, "required ", gmod_version_required)
end

local net = net

-- Variable Declarations
CAF = {}

local function ErrorOffStuff(String)
	Msg("----------------------------------------------------------------------\n")
	Msg("-----------Custom Addon Management Framework Error----------\n")
	Msg("----------------------------------------------------------------------\n")
	Msg(tostring(String) .. "\n")
end

AddCSLuaFile("autorun/client/cl_caf_autostart.lua")
include("caf/core/shared/sh_general_caf.lua")


--function Declarations

--Local functions

hook.Add("InitPostEntity", "CAF_Start", function()
	CAF.LibRD.__Construct()
	CAF.LibSB.__Construct()

	CAF.LibLS.__Construct()
end)

--[[
	The following code sends the clientside and shared files to the client and includes CAF core code
]]
--Send Client and Shared files to the client and Include the ServerAddons

stp.IncludeFile("caf/core/popup_sh.lua")

--Core files

for k, File in ipairs(file.Find("caf/core/server/*.lua", "LUA")) do
	local ErrorCheck, PCallError = pcall(include, "caf/core/server/" .. File)

	if not ErrorCheck then
		ErrorOffStuff(PCallError)
	end
end

for k, File in ipairs(file.Find("CAF/Core/client/*.lua", "LUA")) do
	local ErrorCheck, PCallError = pcall(AddCSLuaFile, "caf/core/client/" .. File)

	if not ErrorCheck then
		ErrorOffStuff(PCallError)
	end
end

for k, File in ipairs(file.Find("CAF/Core/shared/*.lua", "LUA")) do
	local ErrorCheck, PCallError = pcall(AddCSLuaFile, "caf/core/shared/" .. File)

	if not ErrorCheck then
		ErrorOffStuff(PCallError)
	end
end

for k, File in ipairs(file.Find("caf/languagevars/*.lua", "LUA")) do
	local ErrorCheck, PCallError = pcall(AddCSLuaFile, "caf/languagevars/" .. File)

	if not ErrorCheck then
		ErrorOffStuff(PCallError)
	end

	local ErrorCheck2, PCallError2 = pcall(include, "caf/languagevars/" .. File)

	if not ErrorCheck2 then
		ErrorOffStuff(PCallError2)
	end
end

--Main Addon
for k, File in ipairs(file.Find("caf/addons/server/*.lua", "LUA")) do
	local ErrorCheck, PCallError = pcall(include, "caf/addons/server/" .. File)

	if not ErrorCheck then
		ErrorOffStuff(PCallError)
	end
end

for k, File in ipairs(file.Find("caf/addons/client/*.lua", "LUA")) do
	local ErrorCheck, PCallError = pcall(AddCSLuaFile, "caf/addons/client/" .. File)

	if not ErrorCheck then
		ErrorOffStuff(PCallError)
	end
end

for k, File in ipairs(file.Find("caf/addons/shared/*.lua", "LUA")) do
	local ErrorCheck, PCallError = pcall(AddCSLuaFile, "caf/addons/shared/" .. File)

	if not ErrorCheck then
		ErrorOffStuff(PCallError)
	end
end


stp.IncludeFile("caf/core/player_full_load_sh.lua")