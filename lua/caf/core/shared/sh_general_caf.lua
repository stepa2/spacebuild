local CAF = CAF
local Addons = CAF.Addons
local addonlevel = CAF.addonlevel

function CAF.begintime()
	return os.clock()
end

function CAF.endtime(begintime)
	return CAF.begintime() - begintime
end

CAF.version = 0.5
--COLOR Settings
CAF.colors = {}
CAF.colors.red = Color(230, 0, 0, 230)
CAF.colors.green = Color(0, 230, 0, 230)
CAF.colors.white = Color(255, 255, 255, 255)

--END COLOR Settings
-- CAF Custom Status Saving
if not sql.TableExists("CAF_Custom_Vars") then
	sql.Query("CREATE TABLE IF NOT EXISTS CAF_Custom_Vars ( varname VARCHAR(255) , varvalue VARCHAR(255));")
end

local vars = {}

local function InsertVar(name, value)
	if not name or not value then return false, "Problem with the Parameters" end
	name = sql.SQLStr(name)
	value = sql.SQLStr(value)
	sql.Query("INSERT INTO CAF_Custom_Vars(varname, varvalue) VALUES(" .. name .. ", " .. value .. ");")
end

function CAF.SaveVar(name, value)
	if not name or not value then return false, "Problem with the Parameters" end
	CAF.LoadVar(name, value)
	name = sql.SQLStr(name)
	value = sql.SQLStr(value)
	sql.Query("UPDATE CAF_Custom_Vars SET varvalue=" .. value .. " WHERE varname=" .. name .. ";")
	vars[name] = value
end

function CAF.LoadVar(name, defaultvalue)
	if not defaultvalue then
		defaultvalue = "0"
	end

	if not name then return false, "Problem with the Parameters" end
	if vars[name] then return vars[name] end
	local data = sql.Query("SELECT * FROM CAF_Custom_Vars WHERE varname = '" .. name .. "';")

	if not data then
		print(sql.LastError())
		InsertVar(name, defaultvalue)
	else
		defaultvalue = string.TrimRight(data[1]["varvalue"])
	end

	Msg("-" .. tostring(defaultvalue) .. "-\n")
	vars[name] = defaultvalue

	return defaultvalue
end

--[[
	Returns the reference to the Custom Addon, nil if not existant
]]
function CAF.GetAddon(AddonName)
	if not AddonName then return nil, "No AddonName given" end

	return Addons[AddonName]
end

--[[
	Registers an addon with the game name into the table
	Overwrites if 2 addons use the same name
]]
function CAF.RegisterAddon(AddonName, AddonClass, level)
	if not AddonName then return nil, "No AddonName given" end
	if not AddonClass then return nil, "No AddonClass given" end

	if not level then
		level = 5
	end

	level = tonumber(level)

	if level < 1 then
		level = 1
	elseif level > 5 then
		level = 5
	end

	Addons[AddonName] = AddonClass
	table.insert(addonlevel[level], AddonName)

	return true
end

function CAF.GetLangVar(name)
	return CAF.LANGUAGE[name] or name
end