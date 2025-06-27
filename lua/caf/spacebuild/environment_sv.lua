TrueSun = {}
SunAngle = nil

local SB = CAF.LibSB

local Environments = {}
local Planets = {}
local Stars = {}
local numenv = 0

function SB.Register_Sun()
	Msg("Registering Sun\n")
	local suns = ents.FindByClass("env_sun")

	for _, ent in ipairs(suns) do
		if ent:IsValid() then
			local values = ent:GetKeyValues()

			for key, value in pairs(values) do
				if (key == "target") and (string.len(value) > 0) then
					local targets = ents.FindByName("sun_target")

					for _, target in pairs(targets) do
						SunAngle = (target:GetPos() - ent:GetPos()):Normalize()
						--Sunangle set, all that was needed

						return
					end
				end
			end

			--Sun angle still not set, but sun found
			local ang = ent:GetAngles()
			ang.p = ang.p - 180
			ang.y = ang.y - 180
			--get within acceptable angle values no matter what...
			ang.p = math.NormalizeAngle(ang.p)
			ang.y = math.NormalizeAngle(ang.y)
			ang.r = math.NormalizeAngle(ang.r)
			SunAngle = ang:Forward()

			return
		end
	end

	--no sun found, so just set a default angle
	if not SunAngle then
		SunAngle = Vector(0, 0, -1)
	end
end


local sb_space = {}

function sb_space.Get()
	if sb_space.instance then return sb_space.instance end
	local space = {}

	function space:CheckAirValues()
		-- Do nothing
	end

	function space:IsOnPlanet()
		return nil
	end

	function space:AddExtraAirResource(resource, start, ispercentage)
		-- Do nothing
	end

	function space:PrintVars()
		Msg("No Values for Space\n")
	end

	function space:Convert(res1, res2, amount)
		return 0
	end

	function space:GetEnvironmentName()
		return "Space"
	end

	function space:GetResourceAmount(res)
		return 0
	end

	function space:GetResourcePercentage(res)
		return 0
	end

	function space:SetEnvironmentName(value)
		--not implemented
	end

	function space:Convert(air1, air2, value)
		return 0
	end

	function space:GetSize()
		return 0
	end

	function space:SetSize(size)
		--not implemented
	end

	function space:GetSBGravity()
		return 0
	end

	function space:UpdatePressure(ent)
		-- not implemented
	end

	function space:GetO2Percentage()
		return 0
	end

	function space:GetCO2Percentage()
		return 0
	end

	function space:GetNPercentage()
		return 0
	end

	function space:GetHPercentage()
		return 0
	end

	function space:GetEmptyAirPercentage()
		return 0
	end

	function space:UpdateGravity(ent)
		if not ent then return end
		if ent.gravity and ent.gravity == 0 then return end
		ent.gravity = 0

		local phys = ent:GetPhysicsObject()
		if not phys:IsValid() then return end

		phys:EnableGravity(false)
		phys:EnableDrag(false)
		ent:SetGravity(0.00001)
		if ent:IsPlayer() then
			ent:SetNWFloat("gravity", ent.gravity)
		end
	end

	function space:GetPriority()
		return 0
	end

	function space:GetAtmosphere()
		return 0
	end

	function space:GetPressure()
		return 0
	end

	function space:GetTemperature()
		return 14
	end

	function space:GetEmptyAir()
		return 0
	end

	function space:GetO2()
		return 0
	end

	function space:GetCO2()
		return 0
	end

	function space:GetN()
		return 0
	end

	function space:CreateEnvironment(gravity, atmosphere, pressure, temperature, o2, co2, n)
		--Not implemented
	end

	function space:UpdateSize(oldsize, newsize)
		--not implemented
	end

	function space:UpdateEnvironment(gravity, atmosphere, pressure, temperature, o2, co2, n)
		--not implemented
	end

	function space:GetVolume()
		return 0
	end

	function space:IsPlanet()
		return false
	end

	function space:IsStar()
		return false
	end

	function space:IsSpace()
		return true
	end

	sb_space.instance = space

	return space
end


local function ResetGravity()
	for k, ent in ipairs(ents.GetAll()) do
		local phys = ent:GetPhysicsObject()

		if IsValid(phys) and not (ent.IgnoreGravity and ent.IgnoreGravity == true) then
			ent:SetGravity(1)
			ent.gravity = 1
			if ent:IsPlayer() then
				ent:SetNWFloat("gravity", ent.gravity)
			end
			phys:EnableGravity(true)
			phys:EnableDrag(true)
		end
	end
end

function SB.PerformEnvironmentCheck()
	if not SB_InSpace then return end

	for k, ent in ipairs(ents.GetAll()) do
		if not ent.SkipSBChecks and ent.environment and not ent.IsEnvironment then
			ent.environment:UpdateGravity(ent)
			ent.environment:UpdatePressure(ent)
		end
	end
end


function SB.PerformEnvironmentCheckOnEnt(ent)
	if not SB_InSpace then return end
	if not ent then return end
	if ent.SkipSBChecks then return end

	local environment = sb_space.Get() --restore to default before doing the Environment checks

	for env, _ in pairs(ent.SBInEnvironments) do
		if not IsValid(env) then
			ent.SBInEnvironments[env] = nil
			continue
		end

		if env ~= ent and env:IsPreferredOver(environment) then
			environment = env
		end
	end

	if ent.environment ~= environment then
		ent.environment = environment
		SB.OnEnvironmentChanged(ent)
	end

	ent.environment:UpdateGravity(ent)
	ent.environment:UpdatePressure(ent)

	if ent:IsPlayer() and ent:GetMoveType() == MOVETYPE_NOCLIP and ent.environment and ent.environment:IsSpace() and not ent.EnableSpaceNoclip then
		ent:SetMoveType(MOVETYPE_WALK)
	end

	if (not ent.IsEnvironment or not ent:IsEnvironment() or (ent:GetVolume() == 0 and not ent:IsPlanet() and not ent:IsStar())) and ent.environment and ent.environment:GetTemperature(ent) > 10000 then
		if ent:IsPlayer() then
			ent:SilentKill()
		else
			ent:Remove()
		end
	end
end


-- Environment Functions
-- Do not modify returned table
function SB.GetPlanets()
	return Planets
end

-- Do not modify returned table
function SB.GetStars()
	return Stars
end

function SB.OnEnvironmentChanged(ent)
	if not ent.oldsbtmpenvironment or ent.oldsbtmpenvironment ~= ent.environment then
		local tmp = ent.oldsbtmpenvironment
		ent.oldsbtmpenvironment = ent.environment

		if tmp then
			gamemode.Call("OnEnvironmentChanged", ent, tmp, ent.environment)
		end
	end
end

function SB.GetSpace()
	return sb_space.Get()
end


function SB.AddEnvironment(env)
	if not env or not env.GetEnvClass or env:GetEnvClass() ~= "SB ENVIRONMENT" then return 0 end

	--if v.IsStar and not v:IsStar() and v.IsPlanet and not v:IsPlanet() then
	if env.IsStar and env:IsStar() then
		if not table.HasValue(Stars, env) then
			table.insert(Stars, env)
			numenv = numenv + 1
			env:SetEnvironmentID(numenv)

			return numenv
		end
	elseif env.IsPlanet and env:IsPlanet() then
		if not table.HasValue(Planets, env) then
			table.insert(Planets, env)
			numenv = numenv + 1
			env:SetEnvironmentID(numenv)

			return numenv
		end
	elseif not table.HasValue(Environments, env) then
		table.insert(Environments, env)
		numenv = numenv + 1
		env:SetEnvironmentID(numenv)

		return numenv
	end

	return env:GetEnvironmentID()
end

function SB.RemoveEnvironment(env)
	if not env or not env.GetEnvClass or env:GetEnvClass() ~= "SB ENVIRONMENT" then return end

	if env.IsStar and env:IsStar() then
		for k, v in ipairs(Stars) do
			if env == v then
				table.remove(Stars, k)
			end
		end
	elseif env.IsPlanet and env:IsPlanet() then
		for k, v in ipairs(Planets) do
			if env == v then
				table.remove(Planets, k)
			end
		end
	else
		for k, v in ipairs(Environments) do
			if env == v then
				table.remove(Environments, k)
			end
		end
	end
end

function SB.GetEnvironments()
	local tmp = {}

	for k, v in ipairs(Planets) do
		table.insert(tmp, v)
	end

	for k, v in ipairs(Stars) do
		table.insert(tmp, v)
	end

	for k, v in ipairs(Environments) do
		table.insert(tmp, v)
	end

	return tmp
end



function SB.FindClosestPlanet(pos, starsto)
	local closestplanet = nil
	local closestDist = 99999999999999

	for k, v in pairs(Planets) do
		if not IsValid(v) then
			continue
		end
		local dist = v:GetPos():Distance(pos) - v:GetSize()
		if dist < closestDist then
			closestplanet = v
			closestDist = dist
		end
	end

	return closestplanet
end
