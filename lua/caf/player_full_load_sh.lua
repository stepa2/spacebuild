-- TODO: replace with built-in hook

if SERVER then
    net.Receive("CAF_PlayerFullLoad", function(_, ply)
        if ply.PlayerFullLoaded then
            return
        end
        ply.PlayerFullLoaded = true
        hook.Run("PlayerFullLoad", ply)
    end)
    util.AddNetworkString("CAF_PlayerFullLoad")
else    
    hook.Add("InitPostEntity", "InitPostEntity_FullLoad", function()
        net.Start("CAF_PlayerFullLoad")
        net.SendToServer()
    end)
end