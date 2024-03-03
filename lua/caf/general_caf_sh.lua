local CAF = CAF

--COLOR Settings
CAF.colors = {}
CAF.colors.red = Color(230, 0, 0, 230)
CAF.colors.green = Color(0, 230, 0, 230)
CAF.colors.white = Color(255, 255, 255, 255)

--END COLOR Settings

function CAF.GetLangVar(name)
	return CAF.LANGUAGE[name] or name
end