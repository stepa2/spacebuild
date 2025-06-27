local RD = CAF.LibRD

local resourcenames = {}
local resourceids = {}
local resources = {}

function RD.AddProperResourceName(resource, name)
	if not resource or not name then return end

	if not table.HasValue(resources, resource) then
		table.insert(resources, resource)
		resourceids[resource] = #resources
	end

	resourcenames[resource] = name
end

function RD.GetProperResourceName(resource)
	if not resource then return "" end
	if resourcenames[resource] then return resourcenames[resource] end

	return resource
end

function RD.GetResourceID(resource)
	return resourceids[resource]
end

function RD.GetResourceNameByID(id)
	return resources[id]
end

function RD.GetAllRegisteredResources()
	if not resourcenames or table.Count(resourcenames) < 0 then return {} end

	return table.Copy(resourcenames)
end

function RD.GetRegisteredResources()
	return table.Copy(resources)
end

do
	RD.AddProperResourceName("energy", CAF.GetLangVar("Energy"))
	RD.AddProperResourceName("water", CAF.GetLangVar("Water"))
	RD.AddProperResourceName("nitrogen", CAF.GetLangVar("Nitrogen"))
	RD.AddProperResourceName("hydrogen", CAF.GetLangVar("Hydrogen"))
	RD.AddProperResourceName("oxygen", CAF.GetLangVar("Oxygen"))
	RD.AddProperResourceName("carbon dioxide", CAF.GetLangVar("Carbon Dioxide"))
	RD.AddProperResourceName("heavy water", CAF.GetLangVar("Heavy Water"))
end