﻿TOOL = nil
include("caf/tool_loader_sh.lua")
TOOL = ToolObj:Create()

TOOL.Category = "CAF"
TOOL.Mode = "startup_tool"
TOOL.Name = "CAF Tools Startup"
TOOL.Command = nil
TOOL.ConfigName = nil
TOOL.AddToMenu = false
TOOL.Tab = "Custom Addon Framework"


function TOOL:LeftClick(trace)
	if not trace.Entity:IsValid() then return false end
	if CLIENT then return true end
	--for something else

	return true
end

function TOOL:RightClick(trace)
	if not trace.Entity:IsValid() then return false end
	if CLIENT then return true end
	--for something else

	return true
end

function TOOL:Reload(trace)
	if not trace.Entity:IsValid() then return false end
	if CLIENT then return true end
	--for something else

	return true
end