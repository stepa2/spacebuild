local gmod_version_required = 145

if VERSION < gmod_version_required then
	error("CAF: Your gmod is out of date: found version ", VERSION, "required ", gmod_version_required)
end

local net = net

local net_pools = {"CAF_Addon_Construct", "CAF_Start_true", "CAF_Start_false", "CAF_Addon_POPUP"}

for _, v in pairs(net_pools) do
	util.AddNetworkString(v)
end

-- Variable Declarations
CAF = {}
CAF.StartingUp = false
local DEBUG = true
CAF.DEBUG = DEBUG
local Addons = {}
CAF.Addons = Addons

local addonlevel = {}
CAF.addonlevel = addonlevel
addonlevel[1] = {}
addonlevel[2] = {}
addonlevel[3] = {}
addonlevel[4] = {}
addonlevel[5] = {}

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

local function OnAddonConstruct(name)
	if not name then return end
	net.Start("CAF_Addon_Construct")
	net.WriteString(name)
	net.Broadcast()
end

--[[
	Start
		This function loads all the Custom Addons on Startup
]]
function CAF.Start()
	Msg("Starting CAF Addons\n")
	CAF.StartingUp = true
	net.Start("CAF_Start_true")
	net.Broadcast()

	for level, tab in pairs(addonlevel) do
		print("Loading Level " .. tostring(level) .. " Addons\n")

		for k, v in pairs(tab) do
			if not Addons[v] then
				continue
			end
			print("-->", "Loading addon " .. tostring(v) .. "\n")

			local state = Addons[v].DEFAULTSTATUS

			if Addons[v].__AutoStart then
				local ok2, err = pcall(Addons[v].__AutoStart, state)

				if not ok2 then
					print("CAF_AutoStart", "Couldn't call AutoStart for " .. v .. ": " .. err .. "\n")
				else
					OnAddonConstruct(v)
					print("-->", "Auto Started Addon: " .. v .. "\n")
				end
			else
				local ok2, err = pcall(Addons[v].__Construct)

				if not ok2 then
					print("CAF_Construct", "Couldn't call constructor for " .. v .. ": " .. err .. "\n")
				else
					OnAddonConstruct(v)
					print("-->", "Loaded addon: " .. v .. "\n")
				end
			end
		end
	end
	CAF.StartingUp = false
	net.Start("CAF_Start_false")
	net.Broadcast()
end

hook.Add("InitPostEntity", "CAF_Start", CAF.Start)

--[[
	This function will update the Client with all active addons
]]
function CAF.PlayerSpawn(ply)
	for k, v in pairs(Addons) do
		net.Start("CAF_Addon_Construct")
		net.WriteString(k)
		net.Send(ply)
	end
end

hook.Add("PlayerFullLoad", "CAF_In_Spawn", CAF.PlayerSpawn)

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
