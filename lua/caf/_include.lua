
CAF = {}

stp.IncludeFile("caf/core/general_caf_sh.lua")
stp.IncludeFile("caf/core/icosphere_sv.lua")
stp.IncludeFile("caf/core/popup_sh.lua")

hook.Add("InitPostEntity", "CAF_Start", function()
	CAF.LibRD.__Construct()
	CAF.LibSB.__Construct()

	CAF.LibLS.__Construct()
end)

if SERVER then
    for k, File in ipairs(file.Find("caf/core/server/*.lua", "LUA")) do
        include("caf/core/server/" .. File)
    end
    
    for k, File in ipairs(file.Find("CAF/Core/client/*.lua", "LUA")) do
        AddCSLuaFile("caf/core/client/" .. File)
    end
    
    for k, File in ipairs(file.Find("CAF/Core/shared/*.lua", "LUA")) do
        AddCSLuaFile("caf/core/shared/" .. File)
    end
    
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
    local coreFiles = file.Find("caf/core/client/*.lua", "LUA")

    for k, File in ipairs(coreFiles) do
        include("caf/core/client/" .. File)
    end

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


stp.IncludeFile("caf/core/player_full_load_sh.lua")