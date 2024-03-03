if SERVER then
    util.AddNetworkString("CAF_Addon_POPUP")

    --msg, location, color, displaytime
    function CAF.POPUP(ply, msg, location, color, displaytime)
        if msg then
            location = location or "top"
            color = color or CAF.colors.white
            displaytime = displaytime or 1
            net.Start("CAF_Addon_POPUP")
            net.WriteString(msg)
            net.WriteString(location)
            net.WriteUInt(color.r, 8)
            net.WriteUInt(color.g, 8)
            net.WriteUInt(color.b, 8)
            net.WriteUInt(color.a, 8)
            net.WriteUInt(displaytime, 16)
            net.Send(ply)
        end
    end

else
    surface.CreateFont("GModCAFNotify", {
        font = "verdana",
        size = 15,
        weight = 600
    })

    
    local displaypopups = {}
    local popups = {}
    --PopupSettings
    local Font = "GModCAFNotify"
    local clHudVersionCVar = GetConVar("cl_hudversion")

    --End popupsettings
    local function DrawPopups(w, h)
        local obj = displaypopups.top or displaypopups.left or displaypopups.right or displaypopups.bottom
        if (clHudVersionCVar and clHudVersionCVar:GetBool()) or not obj then
            return
        end
        surface.SetFont(Font)
        local width, height = surface.GetTextSize(obj.message)
        if width == nil or height == nil then return end
        width = width + 16
        height = height + 16
        left = 0
        top = 0
        if displaypopups.top then
            left = (w / 2) - (width / 2)
            top = 0
        end

        if displaypopups.left then
            left = 0
            top = h * 2 / 3
        end

        if displaypopups.right then
            left = w - width
            top = h * 2 / 3
        end

        if displaypopups.bottom then
            left = (w / 2) - (width / 2)
            top = h - height
        end

        draw.RoundedBox(4, left - 1, top - 1, width + 2, height + 2, obj.color)
        draw.RoundedBox(4, left + 1, top + 1, width, height, Color(0, 0, 0, 150))
        draw.DrawText(obj.message, Font, left + 8, top + 8, obj.color, 0)
    end

    hook.Add("HUDPaint", "CAF_Core_POPUPS", DrawPopups)

    local locations = {"top", "left", "right", "bottom"}

    --local function ShowNextTopMessage()
    local function ShowNextPopupMessage()
        local ply = LocalPlayer()


        for k, v in pairs(locations) do
            if displaypopups[v] == nil and popups[v] and table.Count(popups[v]) > 0 then
                local obj = popups[v][1]
                table.remove(popups[v], 1)

                if ply and ply.ChatPrint then
                    ply:ChatPrint(obj.message .. "\n")
                else
                    Msg(obj.message .. "\n")
                end

                displaypopups[v] = obj

                timer.Simple(obj.time, function()
                    ClearPopup(obj)
                end)
            end
        end
    end

    --function ClearTopTextMessage(obj)
    function ClearPopup(obj)
        if obj then
            displaypopups[obj.location] = nil
        end

        if table.Count(popups[obj.location]) > 0 then
            ShowNextPopupMessage()
        end
    end

    local MessageLog = {}

    --function AddTopInfoMessage(message)
    function AddPopup(message, location, color, displaytime)

        if not popups[location] then
            popups[location] = {}
        end

        local obj = {
            message = message or "Corrupt Message",
            location = location or "top",
            time = displaytime or 1,
            color = color or CAF.colors.white
        }

        table.insert(popups[location], obj)
        table.insert(MessageLog, obj)
        ShowNextPopupMessage()
    end

    function CAF.POPUP(msg, location, color, displaytime)
        if msg then
            AddPopup(msg, location, color, displaytime)
        end
    end
    
    local function ProccessMessage(len, client)
        local msg = net.ReadString()
        local location = net.ReadString()
        local color = net.ReadColor()
        local displaytime = net.ReadUInt(16)
        CAF.POPUP(msg, location, color, displaytime)
    end
    
    net.Receive("CAF_Addon_POPUP", ProccessMessage)
end

