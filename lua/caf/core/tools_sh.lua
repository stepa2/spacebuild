if CLIENT then
    hook.Add("AddToolMenuTabs", "CAFTab", function()
        spawnmenu.AddToolTab("Custom Addon Framework", "CAF")
    end)
end