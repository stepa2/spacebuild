local RD = {}
local nettable = {}
local ent_table = {}
local resourcenames = {}
local resources = {}
local rd_cache = cache.create(1, true) --Store data for 1 second

--Local functions/variables
--Precache some sounds for snapping
for i = 1, 3 do
	util.PrecacheSound("physics/metal/metal_computer_impact_bullet" .. i .. ".wav")
end

util.PrecacheSound("physics/metal/metal_box_impact_soft2.wav")
local nextnetid = 1

local function WriteBool(bool)
	net.WriteBit(bool)
end

local function WriteShort(short)
	return net.WriteInt(short, 16)
end

local function WriteLong(long)
	return net.WriteInt(long, 32)
end

local function WriteResource(name)
	local id = RD.GetResourceID(name) or 0
	net.WriteUInt(id, 8)
	if id == 0 then
		net.WriteString(name)
	end
end

util.AddNetworkString("RD_Entity_Data")

local function sendEntityData(ply, entid, rddata)
	net.Start("RD_Entity_Data")
	WriteShort(entid) --send key to update
	WriteBool(false) --Update
	WriteShort(rddata.network) --send network used in entity
	WriteShort(table.Count(rddata.resources)) --How many resources are going to be send?

	for l, w in pairs(rddata.resources) do
		WriteResource(l)
		WriteLong(w.maxvalue)
		WriteLong(w.value)
		net.WriteFloat(w.temperature)
	end

	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

util.AddNetworkString("RD_Network_Data")

local function sendNetworkData(ply, netid, rddata)
	net.Start("RD_Network_Data")
	WriteShort(netid) --send key to update
	WriteBool(false) --Up to date
	WriteShort(table.Count(rddata.resources)) --How many resources are going to be send?

	for l, w in pairs(rddata.resources) do
		WriteResource(l)
		WriteLong(w.maxvalue)
		WriteLong(w.value)
		net.WriteFloat(w.temperature)
	end

	local nr_of_cons = #rddata.cons
	WriteShort(nr_of_cons) --How many connections are going to be send?

	if nr_of_cons > 0 then
		for l, w in pairs(rddata.cons) do
			WriteShort(w)
		end
	end

	if ply then
		net.Send(ply)
		--net.Broadcast()
	else
		net.Broadcast()
	end
end

--[[
function RD.GetEntityTable(ent)
	local entid = ent:EntIndex( )
	return ent_table[entid] or {}
end

function RD.GetNetTable(netid)
	return nettable[netid] or {}
end

]]

local REQUEST_ENT = 1
local REQUEST_NET = 2

local function requestEntityData(ply, id)
	local data = rd_cache:get("entity_" .. id)
	local tmpdata
	if not data then
		tmpdata = ent_table[id]

		if not tmpdata then
			return
		end

		data = {}
		data.network = tmpdata.network
		data.resources = {}
		local OverlaySettings = list.Get("LSEntOverlayText")[tmpdata.ent:GetClass()]
		local storage = true

		if OverlaySettings then
			local num = OverlaySettings.num or 0
			local resnames = OverlaySettings.resnames
			local genresnames = OverlaySettings.genresnames

			if num ~= -1 then
				storage = false

				if resnames then
					for _, k in pairs(resnames) do
						local value, maxvalue, temperature = RD.GetResourceData(tmpdata.ent, k)
						data.resources[k] = {
							value = value,
							temperature = temperature,
							maxvalue = maxvalue
						}
					end
				end

				if genresnames then
					for _, k in pairs(genresnames) do
						local value, maxvalue, temperature = RD.GetResourceData(tmpdata.ent, k)
						data.resources[k] = {
							value = value,
							temperature = temperature,
							maxvalue = maxvalue
						}
					end
				end
			end
		end

		if storage then
			for k, v in pairs(tmpdata.resources) do
				local value, maxvalue, temperature = RD.GetResourceData(tmpdata.ent, k)
				data.resources[k] = {
					value = value,
					temperature = temperature,
					maxvalue = maxvalue
				}
			end
		end

		rd_cache:add("entity_" .. id, data)
	end

	sendEntityData(ply, id, data)
end

local function requestNetwork(ply, id)
	local data = rd_cache:get("network_" .. id)
	local tmpdata
	if not data then
		tmpdata = nettable[id]

		if not tmpdata then
			return
		end

		data = {}
		data.resources = {}

		for k, v in pairs(tmpdata.resources) do
			local value, maxvalue, temperature = RD.GetNetResourceData(id, k)
			data.resources[k] = {
				value = value,
				temperature = temperature,
				maxvalue = maxvalue
			}
		end

		data.cons = {}

		for k, v in pairs(tmpdata.cons) do
			table.insert(data.cons, v)
		end

		rd_cache:add("network_" .. id, data)
	end

	sendNetworkData(ply, id, data)
end

local function RequestResourceData(_, ply)
	local typ = net.ReadUInt(8)
	local id = net.ReadUInt(32)

	if typ == REQUEST_ENT then
		requestEntityData(ply, id)
	elseif typ == REQUEST_NET then
		requestNetwork(ply, id)
	else
		ply:ChatPrint("RD BUG: INVALID TYPE")
	end
end
net.Receive("RD_Network_Data", RequestResourceData)

--End local functions
--[[
	The Constructor for this Custom Addon Class
]]
function RD.__Construct()
	nextnetid = 1
	nettable = {}
	ent_table = {}

	return true
end

CAF.LibRD = RD

local ResourceEnergyContents = {
	water = 0.1
}

function RD.GetResourceEnergyContent(res, amount, delta)
	return ResourceEnergyContents[res] * amount * delta
end

function RD.GetResourceAmountFromEnergy(res, energy, delta)
	return energy / (ResourceEnergyContents[res] * delta)
end

--[[
	RemoveRDEntity( entity)
		Call this when you want to remove the registered RD entity from the RD3 syncing (happens in the base_rd_entity/init.lua: OnRemove Function, if you override this function, don't forget to add this call!!)

]]
function RD.RemoveRDEntity(ent)
	if not ent or not IsValid(ent) then return end

	if ent.IsNode then
		--RemoveNetWork(ent.netid)
		--nettable[ent.netid].clear = true
		nettable[ent.netid] = nil
	elseif ent_table[ent:EntIndex()] then
		--RemoveEnt(ent:EntIndex())
		--ent_table[ent:EntIndex()].clear = true
		ent_table[ent:EntIndex()] = nil
	end
end

--[[
	RegisterNonStorageDevice( entity)
	
		Used to register non-storage Device ( devices that have a max of 0 for all resources)
		Add the to-display resources to the "list.Set( "LSEntOverlayText" , "generator_energy_fusion", {HasOOO = true, num = 2, resnames = {"nitrogen","heavy water"}} )" call specific for your Sent

]]
function RD.RegisterNonStorageDevice(ent)
	if not IsValid(ent) then return false, "Not a valid entity" end

	if not ent_table[ent:EntIndex()] then
		ent_table[ent:EntIndex()] = {}
		local index = ent_table[ent:EntIndex()]
		index.resources = {}
		index.network = 0
		index.clear = false
		index.haschanged = false
		index.new = true
		index.ent = ent
	elseif ent_table[ent:EntIndex()].ent ~= ent then
		ent_table[ent:EntIndex()] = {}
		local index = ent_table[ent:EntIndex()]
		index.resources = {}
		index.network = 0
		index.clear = false
		index.haschanged = false
		index.new = true
		index.ent = ent
	end
end

--[[
	AddResource(entity, resource, maximum amount, default value)
		
		Add a resource to the Entity, you can use this for any amount, but it's recomended to only call this if your entity can store resources (max amount > 0 )
			Even if it requires multiple resources, registering the ones that can store resources is enough.
			
			Note: If your device doesn't store anything just use RegisterNonStorageDevice instead of this, it's more optimized for it
]]
function RD.AddResource(ent, resource, maxamount, defaultvalue)
	if not IsValid(ent) then return false, "Not a valid entity" end
	if not resource then return false, "No resource given" end

	local temperatureFn = ent.GetTemperature
	local temperature = temperatureFn and temperatureFn(ent) or 0

	if not defaultvalue then
		defaultvalue = 0
	end

	if not maxamount then
		maxamount = 0
	end

	if not table.HasValue(resources, resource) then
		table.insert(resources, resource)
	end

	if ent_table[ent:EntIndex()] and ent_table[ent:EntIndex()].ent == ent then
		local index = ent_table[ent:EntIndex()]

		if index.resources[resource] then
			if index.network ~= 0 then
				nettable[index.network].resources[resource].maxvalue = nettable[index.network].resources[resource].maxvalue - index.resources[resource].maxvalue

				if nettable[index.network].resources[resource].value > nettable[index.network].resources[resource].maxvalue then
					nettable[index.network].resources[resource].value = nettable[index.network].resources[resource].maxvalue
				end
			end
		else
			index.resources[resource] = {}
		end

		index.resources[resource].maxvalue = maxamount
		index.resources[resource].value = defaultvalue
		index.resources[resource].haschanged = true
		index.resources[resource].temperature = temperature

		if index.network ~= 0 then
			nettable[index.network].resources[resource].maxvalue = nettable[index.network].resources[resource].maxvalue + maxamount
			nettable[index.network].resources[resource].value = nettable[index.network].resources[resource].value + defaultvalue

			if nettable[index.network].resources[resource].value > nettable[index.network].resources[resource].maxvalue then
				nettable[index.network].resources[resource].value = nettable[index.network].resources[resource].maxvalue
				nettable[index.network].resources[resource].haschanged = true
			end
		end

		index.haschanged = true
	else
		ent_table[ent:EntIndex()] = {}
		local index = ent_table[ent:EntIndex()]
		index.resources = {}
		index.resources[resource] = {}
		index.resources[resource].maxvalue = maxamount
		index.resources[resource].value = defaultvalue
		index.resources[resource].temperature = temperature
		index.network = 0
		index.clear = false
		index.haschanged = false
		index.new = true
		index.ent = ent
	end

	return true
end

--[[
	AddNetResource(Netid, resource, maximum amount, default value)
		
		Add a resource to the network with the specified Netid, you can use this for any amount, but it's recomended to only call this if your entity can store resources (max amount > 0 )
			Even if it requires multiple resources, registering the ones that can store resources is enough.
			
			Note: If your device doesn't store anything just use RegisterNonStorageDevice instead of this, it's more optimized for it
]]
function RD.AddNetResource(netid, resource, maxamount, defaultvalue)
	if not netid or not nettable[netid] then return false, "Not a valid Network ID" end
	if not resource then return false, "No resource given" end

	if not defaultvalue then
		defaultvalue = 0
	end

	if not maxamount then
		maxamount = 0
	end

	if maxamount < defaultvalue then
		defaultvalue = maxamount
	end

	if not table.HasValue(resources, resource) then
		table.insert(resources, resource)
	end

	local index = nettable[netid]

	if not index.resources[resource] then
		index.resources[resource] = {}
		index.resources[resource].temperature = 0
		index.resources[resource].maxvalue = maxamount
		index.resources[resource].value = defaultvalue
		index.resources[resource].haschanged = true
		index.haschanged = true
	else
		index.resources[resource].maxvalue = index.resources[resource].maxvalue + maxamount
		index.resources[resource].value = index.resources[resource].value + defaultvalue

		if index.resources[resource].value > index.resources[resource].maxvalue then
			index.resources[resource].value = index.resources[resource].maxvalue
		end

		index.resources[resource].haschanged = true
		index.haschanged = true
	end

	return true
end

local function tryGetNetResTable(network, resource)
	local singleNetTable = nettable[network]
	if not singleNetTable then
		return
	end
	local netResourceTable = singleNetTable.resources
	if not netResourceTable then
		return
	end
	return netResourceTable[resource], singleNetTable
end

local function calcNewTemp(curValue, curTemp, addValue, addTemp)
	local totalValue = curValue + addValue
	if totalValue == 0 then
		return curTemp
	end
	return (curTemp * (curValue / totalValue)) + (addTemp * (addValue / totalValue))
end

--[[
	ConsumeNetResource( netid, resource, amount)
	
		Only use this if you got a special sent (like the Resource Pumps) which don't have direct netinfo stored
		
		This means not Registered using RegisterNonStorageDevice() or Addresource(), one you used those you definetly don't need to use this one (except for special cases)
		
		Returns the actual amount consumed!!

]]
function RD.ConsumeNetResource(netid, resource, amount)
	if not nettable[netid] then return 0, "Not a valid network" end
	if not resource then return 0, "No resource given" end
	if not amount then return 0, "No amount given" end
	local origamount = amount
	local consumed = 0
	local index = {}
	index.network = netid

	local netResourceTable, singleNetTable = tryGetNetResTable(index.network, resource)
	if netResourceTable and singleNetTable and netResourceTable.maxvalue > 0 then
		if netResourceTable.value >= amount then
			netResourceTable.value = netResourceTable.value - amount
			netResourceTable.haschanged = true
			singleNetTable.haschanged = true
		elseif nettable[index.network].resources[resource].value > 0 then
			amount = netResourceTable.value
			netResourceTable.value = 0
			netResourceTable.haschanged = true
			singleNetTable.haschanged = true
		else
			amount = 0
		end

		consumed = amount
	end

	if consumed ~= origamount and table.Count(nettable[index.network].cons) > 0 then
		for k, v in pairs(RD.GetConnectedNets(index.network)) do
			if v == index.network then
				continue
			end

			amount = origamount - consumed
			local otherNetResourceTable, otherNetTable = tryGetNetResTable(v, resource)
			if otherNetTable and otherNetResourceTable and otherNetResourceTable.maxvalue > 0 then
				if otherNetResourceTable.value >= amount then
					otherNetResourceTable.value = otherNetResourceTable.value - amount
					otherNetResourceTable.haschanged = true
					otherNetTable.haschanged = true
				elseif otherNetResourceTable.value > 0 then
					amount = otherNetResourceTable.value
					otherNetResourceTable.value = 0
					otherNetResourceTable.haschanged = true
					otherNetTable.haschanged = true
				else
					amount = 0
				end

				consumed = consumed + amount
				if consumed >= origamount then break end
			end
		end
	end

	return consumed
end

--[[
	ConsumeResource(entity, resource , amount)
	
		Use this to consume resource (if you call this from inside the entity use self where the entity needs to be)
		
		It will return the amount of resources actually consumed!!
]]
function RD.ConsumeResource(ent, resource, amount)
	if not IsValid(ent) then return 0, "Not a valid entity" end
	if not resource then return 0, "No resource given" end
	if not amount then return 0, "No amount given" end

	local index = ent_table[ent:EntIndex()]
	if not index then
		return 0
	end

	if index.network == 0 and index.resources[resource] and index.resources[resource].maxvalue > 0 then
		if index.resources[resource].value >= amount then
			index.resources[resource].value = index.resources[resource].value - amount
			index.resources[resource].haschanged = true
			index.haschanged = true
		elseif index.resources[resource].value > 0 then
			amount = index.resources[resource].value
			index.resources[resource].value = 0
			index.resources[resource].haschanged = true
			index.haschanged = true
		end

		return amount
	end

	return RD.ConsumeNetResource(index.network, resource, amount)
end

--[[
	SupplyNetResource(netid, resource, amount, temperature)
	
		Only use this if you got a special sent (like the Resource Pumps) which don't have direct netinfo stored
		
		This means not Registered using RegisterNonStorageDevice() or Addresource(), one you used those you definetly don't need to use this one (except for special cases)
	
		Returns the amount of resources it couldn't supply to the network (lack of storage fe)
	
]]
function RD.SupplyNetResource(netid, resource, amount, temperature)
	if not amount then return 0, "No amount given" end
	if not nettable[netid] then return amount, "Not a valid network" end
	if not resource then return amount, "No resource given" end
	if not temperature then return amount, "No temperature given" end
	local index = {}
	local left = amount
	index.network = netid

	local netResourceTable, singleNetTable = tryGetNetResTable(index.network, resource)
	if netResourceTable then
		if netResourceTable.maxvalue > netResourceTable.value + left then
			netResourceTable.temperature = calcNewTemp(netResourceTable.value, netResourceTable.temperature, left, temperature)
			netResourceTable.value = netResourceTable.value + left
			left = 0
			singleNetTable.haschanged = true
			netResourceTable.haschanged = true
		elseif netResourceTable.maxvalue > netResourceTable.value then
			local amountTransferred = netResourceTable.maxvalue - netResourceTable.value
			left = left - amountTransferred
			netResourceTable.temperature = calcNewTemp(netResourceTable.value, netResourceTable.temperature, amountTransferred, temperature)
			netResourceTable.value = netResourceTable.maxvalue
			singleNetTable.haschanged = true
			netResourceTable.haschanged = true
		end
	end

	if left == 0 or table.Count(singleNetTable.cons) == 0 then
		return left
	end
	for k, v in pairs(RD.GetConnectedNets(index.network)) do
		if v == index then
			continue
		end

		local otherNetResourceTable, otherNetTable = tryGetNetResTable(v, resource)
		if otherNetResourceTable then
			if otherNetResourceTable.maxvalue > otherNetResourceTable.value + left then
				otherNetResourceTable.temperature = calcNewTemp(otherNetResourceTable.value, otherNetResourceTable.temperature, left, temperature)
				otherNetResourceTable.value = otherNetResourceTable.value + left
				left = 0
				otherNetTable.haschanged = true
				otherNetResourceTable.haschanged = true
			elseif otherNetResourceTable.maxvalue > otherNetResourceTable.value then
				local amountTransferred = otherNetResourceTable.maxvalue - otherNetResourceTable.value
				left = left - amountTransferred
				otherNetResourceTable.temperature = calcNewTemp(otherNetResourceTable.value, otherNetResourceTable.temperature, amountTransferred, temperature)
				otherNetResourceTable.value = otherNetResourceTable.maxvalue
				otherNetTable.haschanged = true
				otherNetResourceTable.haschanged = true
			end

			if left <= 0 then break end
		end
	end

	return left
end

--[[
	SupplyResource(entity, resource, amount)
		
		Supplies the network connected to the specific Entity (mostly self) the specific amount of resources
		
		Returns the amount of resources it couldn't store

]]
function RD.SupplyResource(ent, resource, amount, temperature)
	if not amount then return 0, "No amount given" end
	if not IsValid(ent) then return amount, "Not a valid entity" end
	if not resource then return amount, "No resource given" end
	local left = amount

	if not temperature then
		local temperatureFn = ent.GetTemperature
		temperature = temperatureFn and temperatureFn(ent) or 0
	end

	if ent_table[ent:EntIndex()] then
		local index = ent_table[ent:EntIndex()]

		if index.network == 0 then
			local indexResources = index.resources[resource]
			if indexResources then
				if indexResources.maxvalue > indexResources.value + left then
					indexResources.temperature = calcNewTemp(indexResources.value, indexResources.temperature, left, temperature)
					indexResources.value = indexResources.value + left
					index.haschanged = true
					indexResources.haschanged = true
					left = 0
				elseif indexResources.maxvalue > indexResources.value then
					local amountTransferred = indexResources.maxvalue - indexResources.value
					left = left - amountTransferred
					indexResources.temperature = calcNewTemp(indexResources.value, indexResources.temperature, amountTransferred, temperature)
					indexResources.value = indexResources.maxvalue
					indexResources.haschanged = true
					index.haschanged = true
				end
			end
		else
			left = RD.SupplyNetResource(index.network, resource, amount, temperature)
		end
	end

	return left
end

--[[
	Link(entity, netid)
	
		This function connects the specific (valid) entity to the specific (valid) network
		
		This is called by the Link tool(s)

]]
function RD.Link(ent, netid)
	RD.Unlink(ent) --Just to be sure

	if not ent_table[ent:EntIndex()] or not nettable[netid] then
		return
	end
	local index = ent_table[ent:EntIndex()]
	local netindex = nettable[netid]

	for k, v in pairs(index.resources) do
		local resindex = netindex.resources[k]

		if not resindex then
			netindex.resources[k] = {}
			resindex = netindex.resources[k]
			resindex.maxvalue = 0
			resindex.value = 0
			resindex.temperature = 0
		end

		if index.resources[k].maxvalue > 0 then
			resindex.maxvalue = resindex.maxvalue + index.resources[k].maxvalue
			resindex.temperature = calcNewTemp(resindex.value, resindex.temperature, index.resources[k].value, index.resources[k].temperature)
			resindex.value = resindex.value + index.resources[k].value
		end

		resindex.haschanged = true
	end

	table.insert(netindex.entities, ent)
	index.network = netid
	index.haschanged = true
	netindex.haschanged = true
end

--[[
	Unlink(entity)
	
		This function unlinks the device from it's network
		
		This is called by the Link tool(s)

]]
function RD.Unlink(ent)
	if not ent_table[ent:EntIndex()] then
		return
	end
	local index = ent_table[ent:EntIndex()]

	if index.network ~= 0 then
		if nettable[index.network] then
			for k, v in pairs(index.resources) do
				if index.resources[k].maxvalue > 0 then
					local resindex = nettable[index.network].resources[k]
					local percent = resindex.value / resindex.maxvalue
					index.resources[k].value = index.resources[k].maxvalue * percent
					resindex.maxvalue = resindex.maxvalue - index.resources[k].maxvalue
					resindex.value = resindex.value - index.resources[k].value
					index.resources[k].haschanged = true
					resindex.haschanged = true
				end
			end

			index.haschanged = true
			nettable[index.network].haschanged = true

			for k, v in pairs(nettable[index.network].entities) do
				if v == ent then
					table.remove(nettable[index.network].entities, k)
					--remove beams
					RD.Beam_clear(ent)
					break
				end
			end
		end

		index.network = 0
	end
end

--[[
	UnlinkAllFromNode( netid)
	
		This function disconnects all devices and network connection from the network with that specific netid
		
		This is called by the Link tool(s)

]]
function RD.UnlinkAllFromNode(netid)
	if nettable[netid] then
		for k, v in pairs(nettable[netid].cons) do
			--[[for l, w in pairs(nettable[v].cons) do
				if w == netid then
					table.remove(nettable[v].cons, l)
					break
				end
			end
			table.remove(nettable[netid].cons, k)]]
			RD.UnlinkNodes(netid, v)
		end

		for l, w in pairs(nettable[netid].entities) do
			RD.Unlink(w)
			--table.remove(nettable[netid].entities, l)
		end

		--[[for l, w in pairs(nettable[netid].resources) do
			w.value = 0
			w.maxvalue = 0
			w.haschanged = true
		end]]
		nettable[netid].haschanged = true

		return true
	end

	return false
end

--[[
	UnLinkNodes(netid, netid2)
	
		This function will break the link between these 2 networks
		
		This is called by the Link tool(s)

]]
function RD.UnlinkNodes(netid, netid2)
	if nettable[netid] and nettable[netid2] then
		for k, v in pairs(nettable[netid].cons) do
			if v == netid2 then
				table.remove(nettable[netid].cons, k)
			end
		end

		for k, v in pairs(nettable[netid2].cons) do
			if v == netid then
				table.remove(nettable[netid2].cons, k)
			end
		end

		nettable[netid].haschanged = true
		nettable[netid2].haschanged = true

		return true
	end

	return false
end

--[[
	LinkNodes(netid, netid2)
	
		This function will create a link between these 2 networks
		
		This is called by the Link tool(s)

]]
function RD.LinkNodes(netid, netid2)
	if netid and netid2 and netid == netid2 then return end

	if nettable[netid] and nettable[netid2] and not table.HasValue(nettable[netid].cons, netid2) then
		table.insert(nettable[netid].cons, netid2)
		table.insert(nettable[netid2].cons, netid)
		nettable[netid].haschanged = true
		nettable[netid2].haschanged = true

		return true
	end

	return false
end

--[[
nettable[netid] = {}
	nettable[netid].resources = {}
	nettable[netid].resources[resource] = {}
	nettable[netid].resources[resource] .value = value
	nettable[netid].resources[resource] .maxvalue = value
	nettable[netid].resources[resource].haschanged = true/false
	nettable[netid].entities = {}
	nettable[netid].haschanged = true/false
	nettable[netid].clear = true/false
	nettable[netid].new = true/false

]]
--[[
	CreateNetwork(entity)
	
		Used to register a Resource Node with the system
		
			Returns the id of the network
]]
function RD.CreateNetwork(ent)
	local nextid = nextnetid
	nextnetid = nextnetid + 1
	nettable[nextid] = {}
	local index = nettable[nextid]
	index.resources = {}
	index.entities = {}
	index.cons = {}
	index.haschanged = false
	index.clear = false
	index.new = true
	index.nodeent = ent

	return nextid
end

-- [[ Save Stuff  - Testing]]
local function MySaveFunction(save)
	print("Calling RD Save method")

	local data = {
		net = nettable,
		ents = ent_table,
		res_names = resourcenames,
		res = resources
	}

	saverestore.WriteTable(data, save)
end

local function MyRestoreFunction(restore)
	print("Calling RD Restore method")
	local data = saverestore.ReadTable(restore)
	nettable = data.net
	ent_table = data.ents

	-- needed?
	for k, v in pairs(nettable) do
		v.haschanged = true
		v.new = true
	end

	-- needed?
	for k, v in pairs(ent_table) do
		v.haschanged = true
		v.new = true
	end

	resourcenames = data.res_names
	resources = data.res
end

saverestore.AddSaveHook("caf_rd_save", MySaveFunction)
saverestore.AddRestoreHook("caf_rd_save", MyRestoreFunction)

--[[ Dupe Stuff]]
function RD.BuildDupeInfo(ent)
	--save any beams
	RD.Beam_dup_save(ent)

	if ent.IsPump then
		if ent.netid ~= 0 then
			local nettable1 = RD.GetNetTable(ent.netid)

			if nettable1.nodeent then
				local info = {}
				info.node = nettable1.nodeent:EntIndex()
				duplicator.ClearEntityModifier(ent, "RDPumpDupeInfo")
				duplicator.StoreEntityModifier(ent, "RDPumpDupeInfo", info)
			end
		end

		return
	end

	if ent.IsValve or ent.IsEntityValve then
		local info = {}
		--store active state
		info.active = ent.Active

		--store node1 info
		if ent.connected.node1 and ent.connected.node1.netid ~= 0 then
			local nettable1 = RD.GetNetTable(ent.connected.node1.netid)

			if nettable1.nodeent then
				info.node1 = nettable1.nodeent:EntIndex()
			end
		end

		--store node2 info
		if ent.connected.node2 and ent.connected.node2.netid ~= 0 then
			local nettable2 = RD.GetNetTable(ent.connected.node2.netid)

			if nettable2.nodeent then
				info.node2 = nettable2.nodeent:EntIndex()
			end
		end

		--store node info
		if ent.connected.node and ent.connected.node.netid ~= 0 then
			local nettable1 = RD.GetNetTable(ent.connected.node.netid)

			if nettable1.nodeent then
				info.node = nettable1.nodeent:EntIndex()
			end
		end

		--store ent info
		if ent.connected.ent then
			info.ent = ent.connected.ent:EntIndex()
		end

		duplicator.ClearEntityModifier(ent, "RDValveDupeInfo")
		duplicator.StoreEntityModifier(ent, "RDValveDupeInfo", info)

		return
	end

	if not ent.IsNode then return end
	local nettable1 = RD.GetNetTable(ent.netid)
	local info = {}
	--info.resources = table.Copy(nettable.resources)
	local entids = {}

	for k, v in pairs(nettable1.entities) do
		table.insert(entids, v:EntIndex())
	end

	local cons = {}

	for k, v in pairs(nettable1.cons) do
		local nettab = RD.GetNetTable(v)

		if nettab and nettab.nodeent and IsValid(nettab.nodeent) then
			table.insert(cons, nettab.nodeent:EntIndex())
		end
	end

	info.entities = entids
	info.cons = cons

	if info.entities then
		duplicator.ClearEntityModifier(ent, "RDDupeInfo")
		duplicator.StoreEntityModifier(ent, "RDDupeInfo", info)
	end
end

--apply the DupeInfo
function RD.ApplyDupeInfo(ent, CreatedEntities)
	if ent.EntityMods and ent.EntityMods.RDDupeInfo and ent.EntityMods.RDDupeInfo.entities then
		local RDDupeInfo = ent.EntityMods.RDDupeInfo

		if RDDupeInfo.entities then
			for _, ent2ID in pairs(RDDupeInfo.entities) do
				local ent2 = CreatedEntities[ent2ID]

				if ent2 and ent2:IsValid() then
					RD.Link(ent2, ent.netid)
				end
			end
		end

		if RDDupeInfo.cons then
			for _, ent2ID in pairs(RDDupeInfo.cons) do
				local ent2 = CreatedEntities[ent2ID]

				if ent2 and ent2:IsValid() then
					RD.LinkNodes(ent.netid, ent2.netid)
				end
			end
		end

		ent.EntityMods.RDDupeInfo = nil --trash this info, we'll never need it again
	elseif ent.EntityMods and ent.EntityMods.RDPumpDupeInfo and ent.EntityMods.RDPumpDupeInfo.node then
		--This entity is a pump and has a network to connect to 
		local ent2 = CreatedEntities[ent.EntityMods.RDPumpDupeInfo.node] --Get the new node entity

		if ent2 then
			ent:SetNetwork(ent2.netid)
			ent:SetResourceNode(ent2)
		end
	elseif ent.EntityMods and ent.EntityMods.RDValveDupeInfo and (ent.EntityMods.RDValveDupeInfo.node1 or ent.EntityMods.RDValveDupeInfo.node2 or ent.EntityMods.RDValveDupeInfo.node or ent.EntityMods.RDValveDupeInfo.ent) then
		--This entity is a valve and has networks to connect to
		--restore node1 connection
		if ent.EntityMods.RDValveDupeInfo.node1 then
			local ent2 = CreatedEntities[ent.EntityMods.RDValveDupeInfo.node1]

			if ent2 then
				ent:SetNode1(ent2)
			end
		end

		--restore node2 connection
		if ent.EntityMods.RDValveDupeInfo.node2 then
			local ent3 = CreatedEntities[ent.EntityMods.RDValveDupeInfo.node2] --Get the new node2 entity

			if ent3 then
				ent:SetNode2(ent3)
			end
		end

		--restore node connection
		if ent.EntityMods.RDValveDupeInfo.node then
			local ent2 = CreatedEntities[ent.EntityMods.RDValveDupeInfo.node]

			if ent2 then
				ent:SetNode(ent2)
			end
		end

		--restore ent
		if ent.EntityMods.RDValveDupeInfo.ent then
			local ent3 = CreatedEntities[ent.EntityMods.RDValveDupeInfo.ent] --Get the new entity

			if ent3 then
				ent:SetRDEntity(ent3)
			end
		end

		--restore active state
		if ent.EntityMods.RDValveDupeInfo.active and ent.EntityMods.RDValveDupeInfo.active == 1 then
			ent:TurnOn()
		else
			ent:TurnOff()
		end
	end

	--restore any beams
	RD.Beam_dup_build(ent, CreatedEntities)
end

--[[ Shared stuff ]]
function RD.GetConnectedNets(netid)
	local contable = {}

	local tmpcons = {netid}

	while #tmpcons > 0 do
		for k, v in pairs(tmpcons) do
			if not table.HasValue(contable, v) then
				table.insert(contable, v)

				if nettable[v] and nettable[v].cons then
					for l, w in pairs(nettable[v].cons) do
						table.insert(tmpcons, w)
					end
				end
			end

			table.remove(tmpcons, k)
		end
	end

	return contable
end

function RD.GetNetResourceData(netid, resource, sumconnectednets)
	if not nettable[netid] then return 0, 0, 0, "Not a valid network" end
	if not resource then return 0, 0, 0, "No resource given" end
	local amount = 0
	local capacity = 0
	local index = {}
	sumconnectednets = sumconnectednets or (sumconnectednets == nil)
	index.network = netid

	local temperature = 0

	if sumconnectednets and table.Count(nettable[index.network].cons) > 0 then
		for k, v in pairs(RD.GetConnectedNets(index.network)) do
			if nettable[v] and nettable[v].resources and nettable[v].resources[resource] then
				local addAmount = nettable[v].resources[resource].value
				amount = amount + addAmount
				capacity = capacity + nettable[v].resources[resource].maxvalue
				temperature = temperature + (nettable[v].resources[resource].temperature * addAmount)
			end
		end
	else
		if nettable[index.network].resources[resource] then
			amount = nettable[index.network].resources[resource].value
			capacity = nettable[index.network].resources[resource].maxvalue
			temperature = nettable[index.network].resources[resource].temperature * amount
		end
	end

	if amount > 0 then
		temperature = temperature / amount
	end

	return amount, capacity, temperature
end

function RD.GetResourceData(ent, resource, sumconnectednets, ignorenet)
	if not IsValid(ent) then return 0, 0, 0, "Not a valid entity" end
	if not resource then return 0, 0, 0, "No resource given" end

	if not ent_table[ent:EntIndex()] then
		return 0, 0, 0
	end
	local index = ent_table[ent:EntIndex()]

	if ignorenet or index.network == 0 then
		if index.resources[resource] then
			return index.resources[resource].value, index.resources[resource].maxvalue, index.resources[resource].temperature
		end
		return 0, 0, 0
	end
	sumconnectednets = sumconnectednets or (sumconnectednets == nil)
	return RD.GetNetResourceData(index.network, resource, sumconnectednets)
end

function RD.GetNetResourceAmount(...)
	local amount, _, _, err = RD.GetNetResourceData(...)
	return amount, err
end

function RD.GetResourceAmount(...)
	local amount, _, _, err = RD.GetResourceData(...)
	return amount, err
end

function RD.GetUnitCapacity(ent, resource)
	local _, capacity, _, err = RD.GetResourceData(ent, resource, false, true)
	return capacity, err
end

function RD.GetNetNetworkCapacity(...)
	local _, capacity, _, err = RD.GetNetResourceData(...)
	return capacity, err
end

function RD.GetNetworkCapacity(...)
	local _, capacity, _, err = RD.GetResourceData(...)
	return capacity, err
end

function RD.GetEntityTable(ent)
	return ent_table[ent:EntIndex()] or {}
end

function RD.GetNetTable(netid)
	return nettable[netid] or {}
end

function RD.GetNetworkIDs()
	local ids = {}

	for k, v in pairs(nettable) do
		if not v.clear then
			table.insert(ids, k)
		end
	end

	return ids
end

function RD.PrintDebug(ent)
	if ent then
		if ent.IsNode then
			PrintTable(RD.GetNetTable(ent.netid))
		else
			PrintTable(RD.GetEntityTable(ent))
		end
	end
end