local gmod_version_required = 145

if VERSION < gmod_version_required then
	error("CAF: Your gmod is out of date: found version ", VERSION, "required ", gmod_version_required)
end

local net = net

local net_pools = {"CAF_Addon_POPUP"}

for _, v in pairs(net_pools) do
	util.AddNetworkString(v)
end

-- Variable Declarations
CAF = {}
local DEBUG = true
CAF.DEBUG = DEBUG

function CAF.AllowSpawn(type, sub_type, class, model)
	local res = hook.Call("CAFTOOLAllowEntitySpawn", type, sub_type, class, model)
	if res ~= nil then
		return res
	end
	return true
end


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

--msg, location, color, displaytime
function CAF.POPUP(ply, msg, location, color, displaytime)
	if msg then
		location = location or "top"
		color = color or CAF.colors.white
		displaytime = displaytime or 1
		net.Start("CAF_Addon_POPUP")
		net.WriteString(msg)
		net.WriteString(location)
		net.WriteUInt(color.r, 8)
		net.WriteUInt(color.g, 8)
		net.WriteUInt(color.b, 8)
		net.WriteUInt(color.a, 8)
		net.WriteUInt(displaytime, 16)
		net.Send(ply)
	end
end

CAF = CAF

--[[
	The following code sends the clientside and shared files to the client and includes CAF core code
]]
--Send Client and Shared files to the client and Include the ServerAddons

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

net.Receive("CAF_PlayerFullLoad", function(_, ply)
	if ply.PlayerFullLoaded then
		return
	end
	ply.PlayerFullLoaded = true
	hook.Run("PlayerFullLoad", ply)
end)
util.AddNetworkString("CAF_PlayerFullLoad")
