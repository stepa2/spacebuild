local RD = {}

--[[
	The Constructor for this Custom Addon Class
]]
function RD.__Construct()
	return true, "No Implementation yet"
end

--[[
	Get the Version of this Custom Addon Class
]]
function RD.GetVersion()
	return 3.05, "Beta"
end

CAF.RegisterAddon("Life Support Entities", RD, "2")