local gmod_version_required = 145

if VERSION < gmod_version_required then
	stp.Error("CAF: Your gmod is out of date: found version ", VERSION, "required ", gmod_version_required)
end

stp.IncludeFile("caf/_include.lua")