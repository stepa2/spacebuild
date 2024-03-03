
CAF = {}

AddCSLuaFile("vgui/caf_gui.lua")
AddCSLuaFile("vgui/caf_gui_button.lua")

stp.IncludeList("caf/core/", {
    "general_caf_sh.lua",
    "icosphere_sv.lua",
    "popup_sh.lua",
    "module_loader_sh.lua",
    "other_sv.lua",
    "tools_sh.lua"
})

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