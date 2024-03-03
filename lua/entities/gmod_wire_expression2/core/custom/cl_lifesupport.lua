E2Helper.Descriptions["lsInfo(e:)"] = "returns a table of atmosphere info from position of e, much like an atmospheric probe"
E2Helper.Descriptions["lsInfo"] = "returns a table of atmosphere info from E2 position, much like an atmospheric probe"

E2Helper.Descriptions["lsGetResources(e:)"] = "returns an array (of strings) of avaliable resource types avaliable on the network that node E is connected to."
E2Helper.Descriptions["lsGetName(s)"] = "takes resource name and converts to propper ls name, example: 'carbon dioxide' would be converted to 'Carbon Dioxide'"
E2Helper.Descriptions["lsGetAmount(e:s)"] = "returns the current amount of s (example: 'carbon dioxide') from network that node E is connected to"
E2Helper.Descriptions["lsGetCapacity(e:s)"] = "returns the max amount of s (example: 'carbon dioxide') from network that node E is connected to"
E2Helper.Descriptions["lsGetTemperature(e:s)"] = "returns the temperatore of s (example: 'water') from network that node E is connected to"

E2Helper.Descriptions["lsPumpSetResourceAmount(e:sn)"] = "sets pump e to output n amount of resource s. Example lsPumpSetResourceAmount(Pump,'water',1000)"
E2Helper.Descriptions["lsPumpLink(e:e)"] = "links pump e1 to e2"
E2Helper.Descriptions["lsPumpUnlink(e:)"] = "unlinks pump e"
E2Helper.Descriptions["lsPumpSetActive(e:n)"] = "e:lsPumpSetActive(1) will turn on the pump, 0 will turn off, equal to opening the pump and clicking turn on"
E2Helper.Descriptions["lsPumpSetName(e:s)"] = "will set the name of pump e to s"
E2Helper.Descriptions["lsPumpGetName(e:)"] = "will return the name of pump e"
E2Helper.Descriptions["lsPumpGetConnectedPump(e:)"] = "will return entity of the pump that pump e is connected to"
E2Helper.Descriptions["lsPumpGetResources(e:)"] = "will return table of all resources avaliable for pump e to send."

E2Helper.Descriptions["lsLink(e:e)"] = "links entity e1 to node e2, example: WindGenerator:lsLink(Node)"
E2Helper.Descriptions["lsUnlink(e:)"] = "unlinks e from its node, example: WindGenerator:lsUnlink()"
E2Helper.Descriptions["lsUnlinkAll(e:)"] = "unlinks everything from node e, example: Node:lsUnlinkAll()"

E2Helper.Descriptions["lsLinkNodes(e:e)"] = "links node e1 and e2 together"
E2Helper.Descriptions["lsUnlinkNodes(e:e)"] = "breaks the link between nodes e1 and e2"