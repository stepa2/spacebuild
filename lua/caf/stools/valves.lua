TOOL.Category = "Resource Distribution"
TOOL.Name = "#Resource Valves"
TOOL.DeviceName = "Resource Valve"
TOOL.DeviceNamePlural = "Resource Valves"
TOOL.ClassName = "valves"
TOOL.DevSelect = true
TOOL.CCVar_type = "caf_rd_value_entity"
TOOL.CCVar_sub_type = "normal"
TOOL.CCVar_model = "models/ResourcePump/resourcepump.mdl"
TOOL.Limited = true
TOOL.LimitName = "valves"
TOOL.Limit = 10
CAFToolSetup.SetLang("RD Resource Valves", "Create Resource Valves attached to any surface.", "Left-Click: Spawn a Device.  Reload: Repair Device.")
TOOL.ExtraCCVars = {}

local function resource_valve_func(ent, type, sub_type, devinfo, Extra_Data, ent_extras)
	local volume_mul = 1 --Change to be 0 by default later on
	local base_volume = 2272
	local base_mass = 10
	local base_health = 50
	local phys = ent:GetPhysicsObject()

	if phys:IsValid() then
		volume_mul = math.Round(phys:GetVolume()) / base_volume
	end

	local mass = math.Round(base_mass * volume_mul)
	local maxhealth = math.Round(base_health * volume_mul)

	return mass, maxhealth
end

TOOL.Devices = {
	caf_rd_value_entity = {
		Name = "Entity <-> Resource Node valve",
		type = "caf_rd_value_entity",
		class = "caf_rd_value_entity",
		func = resource_valve_func,
		devices = {
			normal = {
				Name = "Default",
				model = "models/ResourcePump/resourcepump.mdl",
			},
			normal_2 = {
				Name = "CE Valve",
				model = "models/ce_ls3additional/resource_pump/resource_pump.mdl",
			},
		},
	},
	caf_rd_value_node = {
		Name = "Resource Node <-> Resource Node (2-way) valve",
		type = "caf_rd_value_node",
		class = "caf_rd_value_node",
		func = resource_valve_func,
		devices = {
			normal = {
				Name = "Default",
				model = "models/ResourcePump/resourcepump.mdl",
			},
			normal_2 = {
				Name = "CE Valve",
				model = "models/ce_ls3additional/resource_pump/resource_pump.mdl",
			},
		},
	},
	caf_rd_value_node_oneway = {
		Name = "Resource Node -> Resource Node (1-way) valve",
		type = "caf_rd_value_node_oneway",
		class = "caf_rd_value_node_oneway",
		func = resource_valve_func,
		devices = {
			normal = {
				Name = "Default",
				model = "models/ResourcePump/resourcepump.mdl",
			},
			normal_2 = {
				Name = "CE Valve",
				model = "models/ce_ls3additional/resource_pump/resource_pump.mdl",
			},
		},
	},
}