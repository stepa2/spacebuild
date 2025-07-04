﻿local RD = {}
--local ent_table = {};

local rd_cache = cache.create(1, false) --Store data for 1 second
--[[

]]
--local functions

RD_OverLay_Distance = CreateClientConVar("rd_overlay_distance", "512", false, false)
RD_OverLay_Mode = CreateClientConVar("rd_overlay_mode", "-1", false, false)

local REQUEST_ENT = 1
local REQUEST_NET = 2

----------NetTable functions

local function ClearNets()
	rd_cache:clear()
end

net.Receive("RD_ClearNets", ClearNets)

local function ReadBool()
	return net.ReadBit() == 1
end

local function ReadShort()
	return net.ReadInt(16)
end

local function ReadLong()
	return net.ReadInt(32)
end

local function ReadResource()
	local id = net.ReadUInt(8)
	if id == 0 then
		return net.ReadString()
	end
	return RD.GetResourceNameByID(id)
end

local dev = GetConVar("developer")

local function AddEntityToCache(nrofbytes)
	if dev:GetBool() then
		print("RD_Entity_Data #", nrofbytes, " bytes received")
	end

	local data = {}
	data.entid = ReadShort() --Key
	local up_to_date = ReadBool()

	if up_to_date then
		rd_cache:update("entity_" .. tostring(data.entid))
	end

	data.network = ReadShort() --network key
	data.resources = {}
	local nr_of_resources = ReadShort()

	if nr_of_resources > 0 then
		--print("nr_of_sources", nr_of_resources)
		local resource
		local maxvalue
		local value
		local temperature

		for i = 1, nr_of_resources do
			--print(i)
			resource = ReadResource()
			maxvalue = ReadLong()
			value = ReadLong()
			temperature = net.ReadFloat()

			if not resource then
				continue
			end

			data.resources[resource] = {
				value = value,
				maxvalue = maxvalue,
				temperature = temperature
			}
		end
	end

	rd_cache:add("entity_" .. tostring(data.entid), data)
end

net.Receive("RD_Entity_Data", AddEntityToCache)

local function AddNetworkToCache(nrofbytes)
	if dev:GetBool() then
		print("RD_Network_Data #", nrofbytes, " bytes received")
	end

	local data = {}
	data.netid = ReadShort() --network key
	local up_to_date = ReadBool()

	if up_to_date then
		rd_cache:update("network_" .. tostring(data.netid))
		return
	end

	data.resources = {}
	local nr_of_resources = ReadShort()

	if nr_of_resources > 0 then
		--print("nr_of_sources", nr_of_resources)
		local resource
		local maxvalue
		local value
		local temperature

		for _ = 1, nr_of_resources do
			--print(i)
			resource = ReadResource()
			maxvalue = ReadLong()
			value = ReadLong()
			temperature = net.ReadFloat()

			data.resources[resource] = {
				value = value,
				maxvalue = maxvalue,
				temperature = temperature,
			}
		end
	end

	data.cons = {}
	local nr_of_cons = ReadShort()

	if nr_of_cons > 0 then
		--print("nr_of_cons", nr_of_cons)
		for i = 1, nr_of_cons do
			--print(i)
			local con = ReadShort()
			table.insert(data.cons, con)
		end
	end

	rd_cache:add("network_" .. tostring(data.netid), data)
end

net.Receive("RD_Network_Data", AddNetworkToCache)

CAF.LibRD = RD

function RD.GetNetResourceAmount(netid, resource)
	if not resource then return 0, "No resource given" end
	local data = RD.GetNetTable(netid)
	if not data then return 0, "Not a valid network" end
	if not data.resources or not data.resources[resource] then return 0, "No resources available" end
	return data.resources[resource].value
end

function RD.GetResourceAmount(ent, resource)
	if not IsValid(ent) then return 0, "Not a valid entity" end
	if not resource then return 0, "No resource given" end
	local data = RD.GetEntityTable(ent)
	if not data.resources or not data.resources[resource] then return 0, "No resources available" end
	return data.resources[resource].value
end

--[[function RD.GetUnitCapacity(ent, resource)
	if not IsValid( ent ) then return 0, "Not a valid entity" end
	if not resource then return 0, "No resource given" end
	local amount = 0
	if ent_table[ent:EntIndex( )] then
		local index = ent_table[ent:EntIndex( )];
		if index.resources[resource] then
			amount = index.resources[resource].maxvalue
		end
	end
	return amount
end]]
function RD.GetNetNetworkCapacity(netid, resource)
	if not resource then return 0, "No resource given" end
	local data = RD.GetNetTable(netid)
	if not data then return 0, "Not a valid network" end
	if not data.resources or not data.resources[resource] then return 0, "No resources available" end
	return data.resources[resource].maxvalue
end

function RD.GetNetworkCapacity(ent, resource)
	if not IsValid(ent) then return 0, "Not a valid entity" end
	if not resource then return 0, "No resource given" end
	local data = RD.GetEntityTable(ent)
	if not data then return 0, "Not a valid network" end
	if not data.resources or not data.resources[resource] then return 0, "No resources available" end
	return data.resources[resource].maxvalue
end

local requests = {}
local ttl = 0.2 --Wait 0.2 second before doing a new request

function RD.GetEntityTable(ent)
	if not IsValid(ent) then
		return {}
	end

	local entid = ent:EntIndex()
	local id = "entity_" .. tostring(entid)
	local data, needs_update = rd_cache:get(id)

	if not data or needs_update and not requests[id] or requests[id] < CurTime() then
		--Do (new) request
		requests[id] = CurTime() + ttl
		net.Start("RD_Network_Data")
			net.WriteUInt(REQUEST_ENT, 8)
			net.WriteUInt(entid, 32)
		net.SendToServer()
	end
	--PrintTable(data)

	return data or {}
end

function RD.GetNetTable(netid)
	if not netid then
		return {}
	end

	local id = "network_" .. tostring(netid)
	local data, needs_update = rd_cache:get(id)

	if not data or needs_update and not requests[id] or requests[id] < CurTime() then
		--Do (new) request
		requests[id] = CurTime() + ttl
		net.Start("RD_Network_Data")
			net.WriteUInt(REQUEST_NET, 8)
			net.WriteUInt(netid, 32)
			net.WriteBool(needs_update)
		net.SendToServer()
	end

	return data or {}
end

--TODO UPDATE TO HERE

function RD.PrintDebug(ent)
	if ent then
		if ent.IsNode then
			PrintTable(RD.GetNetTable(ent.netid))
		else -- --
			local enttable = RD.GetEntityTable(ent)
			PrintTable(enttable)
		end
	end
end