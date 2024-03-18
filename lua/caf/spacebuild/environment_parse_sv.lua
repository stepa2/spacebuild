
local function Register_Environments()
	local CONFIGS = {}
	Msg("Registering planets\n")
	local Blooms = {}
	local Colors = {}
	local Planetscolor = {}
	local Planetsbloom = {}
	--Load the planets/stars/bloom/color
	local entities = ents.FindByClass("logic_case")
	local case1, case2, case3, case4, case5, case6, case7, case8, case9, case10, case11, case12, case13, case14, case15, case16, hash, angles, pos

	for _, ent in ipairs(entities) do
		case1, case2, case3, case4, case5, case6, case7, case8, case9, case10, case11, case12, case13, case14, case15, case16, hash = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
		local values = ent:GetKeyValues()

		for key, value in pairs(values) do
			if key == "Case01" then
				case1 = value
			elseif key == "Case02" then
				case2 = value
			elseif key == "Case03" then
				case3 = value
			elseif key == "Case04" then
				case4 = value
			elseif key == "Case05" then
				case5 = value
			elseif key == "Case06" then
				case6 = value
			elseif key == "Case07" then
				case7 = value
			elseif key == "Case08" then
				case8 = value
			elseif key == "Case09" then
				case9 = value
			elseif key == "Case10" then
				case10 = value
			elseif key == "Case11" then
				case11 = value
			elseif key == "Case12" then
				case12 = value
			elseif key == "Case13" then
				case13 = value
			elseif key == "Case14" then
				case14 = value
			elseif key == "Case15" then
				case15 = value
			elseif key == "Case16" then
				case16 = value
			end
		end

		table.insert(CONFIGS, {case1, case2, case3, case4, case5, case6, case7, case8, case9, case10, case11, case12, case13, case14, case15, case16, ent:GetAngles(), ent:GetPos()})
	end

	timer.Simple(1, function()
		for _, c in ipairs(CONFIGS) do
			case1, case2, case3, case4, case5, case6, case7, case8, case9, case10, case11, case12, case13, case14, case15, case16, hash, angles, pos = c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12], c[13], c[14], c[15], c[16], nil, c[17], c[18]

			if case1 == "planet" then
				SB_InSpace = true

				--SetGlobalInt("InSpace", 1)
				if not table.HasValue(TrueSun, pos) then
					case2 = tonumber(case2) --radius
					case3 = tonumber(case3) -- gravity
					case4 = tonumber(case4) -- atmosphere
					case5 = tonumber(case5) -- stemperature
					case6 = tonumber(case6) -- ltemperature

					if string.len(case7) == 0 then
						case7 = nil -- COLORID
					end

					if string.len(case8) == 0 then
						case8 = nil -- BloomID
					end

					case15 = tonumber(case15) --disabled
					case16 = tonumber(case16) -- flags

					if case15 ~= 1 then
						local planet = ents.Create("base_sb_planet1")
						planet:SetModel("models/props_lab/huladoll.mdl")
						planet:SetAngles(angles)
						planet:SetPos(pos)
						planet:Spawn()
						planet:CreateEnvironment(case2, case3, case4, case5, case6, case16)

						if case7 then
							Planetscolor[case7] = planet
						end

						if case8 then
							Planetsbloom[case8] = planet
						end

						print(planet)
						table.insert(Planets, planet)
						print("Registered new SB2 planet", planet, planet:GetEnvironmentName())
					end
				end
			elseif case1 == "planet2" then
				SB_InSpace = true

				--SetGlobalInt("InSpace", 1)
				if  not table.HasValue(TrueSun, pos) then
					case2 = tonumber(case2) -- radius
					case3 = tonumber(case3) -- gravity
					case4 = tonumber(case4) -- atmosphere
					case5 = tonumber(case5) -- pressure
					case6 = tonumber(case6) -- stemperature
					case7 = tonumber(case7) -- ltemperature
					case8 = tonumber(case8) -- flags
					case9 = tonumber(case9) -- o2
					case10 = tonumber(case10) -- co2
					case11 = tonumber(case11) -- n
					case12 = tonumber(case12) -- h
					case13 = tostring(case13) --name

					if string.len(case15) == 0 then
						case15 = nil -- COLORID
					end

					if string.len(case16) == 0 then
						case16 = nil -- BloomID
					end

					local planet = ents.Create("base_sb_planet2")
					planet:SetModel("models/props_lab/huladoll.mdl")
					planet:SetAngles(angles)
					planet:SetPos(pos)
					planet:Spawn()

					if case13 == "" then
						case13 = "Planet " .. tostring(planet:GetEnvironmentID())
					end

					planet:CreateEnvironment(case2, case3, case4, case5, case6, case7, case9, case10, case11, case12, case8, case13)

					if case15 then
						Planetscolor[case15] = planet
					end

					if case16 then
						Planetsbloom[case16] = planet
					end

					table.insert(Planets, planet)
					print("Registered new SB3 planet", planet, planet:GetEnvironmentName())
				end
			elseif case1 == "cube" then
				SB_InSpace = true

				--SetGlobalInt("InSpace", 1)
				if table.HasValue(TrueSun, pos) then
					case2 = tonumber(case2) -- radius
					case3 = tonumber(case3) -- gravity
					case4 = tonumber(case4) -- atmosphere
					case5 = tonumber(case5) -- pressure
					case6 = tonumber(case6) -- stemperature
					case7 = tonumber(case7) -- ltemperature
					case8 = tonumber(case8) -- flags
					case9 = tonumber(case9) -- o2
					case10 = tonumber(case10) -- co2
					case11 = tonumber(case11) -- n
					case12 = tonumber(case12) -- h
					case13 = tostring(case13) --name

					if string.len(case15) == 0 then
						case15 = nil -- COLORID
					end

					if string.len(case16) == 0 then
						case16 = nil -- BloomID
					end

					local planet = ents.Create("base_cube_environment")
					planet:SetModel("models/props_lab/huladoll.mdl")
					planet:SetAngles(angles)
					planet:SetPos(pos)
					planet:Spawn()

					if case13 == "" then
						case13 = "Cube Environment " .. tostring(planet:GetEnvironmentID())
					end

					planet:CreateEnvironment(case2, case3, case4, case5, case6, case7, case9, case10, case11, case12, case8, case13)

					if case15 then
						Planetscolor[case15] = planet
					end

					if case16 then
						Planetsbloom[case16] = planet
					end

					table.insert(Planets, planet)
					print("Registered new cube planet", planet, planet:GetEnvironmentName())
				end
			elseif case1 == "sb_dev_tree" then
				local tree = ents.Create("nature_dev_tree")
				tree:SetRate(tonumber(case2), true)
				tree:SetAngles(angles)
				tree:SetPos(pos)
				tree:Spawn()
				print("Registered new SB tree", tree)
			elseif case1 == "planet_color" then
				hash = {}

				if string.len(case2) > 0 then
					hash.AddColor_r = tonumber(string.Left(case2, string.find(case2, " ") - 1))
					case2 = string.Right(case2, string.len(case2) - string.find(case2, " "))
					hash.AddColor_g = tonumber(string.Left(case2, string.find(case2, " ") - 1))
					case2 = string.Right(case2, string.len(case2) - string.find(case2, " "))
					hash.AddColor_b = tonumber(case2)
				end

				if string.len(case3) > 0 then
					hash.MulColor_r = tonumber(string.Left(case3, string.find(case3, " ") - 1))
					case3 = string.Right(case3, string.len(case3) - string.find(case3, " "))
					hash.MulColor_g = tonumber(string.Left(case3, string.find(case3, " ") - 1))
					case3 = string.Right(case3, string.len(case3) - string.find(case3, " "))
					hash.MulColor_b = tonumber(case3)
				end

				if case4 then
					hash.Brightness = tonumber(case4)
				end

				if case5 then
					hash.Contrast = tonumber(case5)
				end

				if case6 then
					hash.Color = tonumber(case6)
				end

				Colors[case16] = hash
				print("Registered new planet color", case16)
			elseif case1 == "planet_bloom" then
				hash = {}

				if string.len(case2) > 0 then
					hash.Col_r = tonumber(string.Left(case2, string.find(case2, " ") - 1))
					case2 = string.Right(case2, string.len(case2) - string.find(case2, " "))
					hash.Col_g = tonumber(string.Left(case2, string.find(case2, " ") - 1))
					case2 = string.Right(case2, string.len(case2) - string.find(case2, " "))
					hash.Col_b = tonumber(case2)
				end

				if string.len(case3) > 0 then
					hash.SizeX = tonumber(string.Left(case3, string.find(case3, " ") - 1))
					case3 = string.Right(case3, string.len(case3) - string.find(case3, " "))
					hash.SizeY = tonumber(case3)
				end

				if case4 then
					hash.Passes = tonumber(case4)
				end

				if case5 then
					hash.Darken = tonumber(case5)
				end

				if case6 then
					hash.Multiply = tonumber(case6)
				end

				if case7 then
					hash.Color = tonumber(case7)
				end

				Blooms[case16] = hash
				print("Registered new planet bloom", case16)
			elseif case1 == "star" then
				SB_InSpace = true

				--SetGlobalInt("InSpace", 1)
				if not table.HasValue(TrueSun, pos) then
					local planet = ents.Create("base_sb_star1")
					planet:SetModel("models/props_lab/huladoll.mdl")
					planet:SetAngles(angles)
					planet:SetPos(pos)
					planet:Spawn()
					planet:CreateEnvironment(tonumber(case2))
					table.insert(TrueSun, pos)
					print("Registered new SB2 star", planet, planet:GetEnvironmentName())
				end
			elseif case1 == "star2" then
				SB_InSpace = true

				--SetGlobalInt("InSpace", 1)
				if not table.HasValue(TrueSun, pos) then
					case2 = tonumber(case2) -- radius
					case3 = tonumber(case3) -- temp1
					case4 = tonumber(case4) -- temp2
					case5 = tonumber(case5) -- temp3
					case6 = tostring(case6) -- name

					local planet = ents.Create("base_sb_star2")
					planet:SetModel("models/props_lab/huladoll.mdl")
					planet:SetAngles(angles)
					planet:SetPos(pos)
					planet:Spawn()

					if case6 == "" then
						case6 = "Star " .. tostring(planet:GetEnvironmentID())
					end

					planet:CreateEnvironment(case2, case3, case4, case5, case6)

					table.insert(TrueSun, pos)
					print("Registered new SB3 star", planet, planet:GetEnvironmentName())
				end
			end
		end

		for k, v in pairs(Blooms) do
			if Planetsbloom[k] then
				Planetsbloom[k]:BloomEffect(v.Col_r, v.Col_g, v.Col_b, v.SizeX, v.SizeY, v.Passes, v.Darken, v.Multiply, v.Color)
			end
		end

		for k, v in pairs(Colors) do
			if Planetscolor[k] then
				Planetscolor[k]:ColorEffect(v.AddColor_r, v.AddColor_g, v.AddColor_b, v.MulColor_r, v.MulColor_g, v.MulColor_b, v.Brightness, v.Contrast, v.Color)
			end
		end

		if SB_InSpace then
			SB.__Construct()
		end
	end)
end