
CAF = { LibSB = {}, LibRD = {} }

AddCSLuaFile("caf/tool_loader_sh.lua")

stp.IncludeList("caf/", {
    "general_caf_sh.lua",
    "icosphere_sv.lua",
    "popup_sh.lua",
    "module_loader_sh.lua",
    "other_sv.lua",
    "other_cl.lua",
    "tools_sh.lua",
    "entity_util_sv.lua",

    "resource/types_sh.lua",

    "spacebuild/environment_sv.lua",
    "spacebuild/environment_parse_sv.lua",
    "spacebuild/fx_sh.lua"
})

hook.Add("InitPostEntity", "CAF_Start", function()
	CAF.LibRD.__Construct()
    if SERVER then
	    CAF.LibSB.Register_Sun()
	    CAF.LibSB.Register_Environments()
        CAF.LibSB.ResetGravity()

	    CAF.LibSB.StartEnvironmentChecker()
    end

	CAF.LibLS.__Construct()
end)

if SERVER then
    for k, File in ipairs(file.Find("caf/languagevars/*.lua", "LUA")) do
        AddCSLuaFile("caf/languagevars/" .. File)
        include("caf/languagevars/" .. File)
    end
    
    --Main Addon
    for k, File in ipairs(file.Find("caf/addons/server/*.lua", "LUA")) do
        include("caf/addons/server/" .. File)
    end
    
    for k, File in ipairs(file.Find("caf/addons/client/*.lua", "LUA")) do
        AddCSLuaFile("caf/addons/client/" .. File)
    end
    
    for k, File in ipairs(file.Find("caf/addons/shared/*.lua", "LUA")) do
        AddCSLuaFile("caf/addons/shared/" .. File)
    end
else
    local languageFiles = file.Find("caf/languagevars/*.lua", "LUA")

    for k, File in ipairs(languageFiles) do
        include("caf/languagevars/" .. File)
    end

    --Addons
    local addonFiles = file.Find("caf/addons/client/*.lua", "LUA")

    for k, File in ipairs(addonFiles) do
        include("caf/addons/client/" .. File)
    end
end


stp.IncludeFile("caf/player_full_load_sh.lua")