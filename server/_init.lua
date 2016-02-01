--print("RESTART----------------------------------------------------------------------------------------------------------------------")


LightsaberPreferences = {}


Events:Subscribe("ClientModuleLoad", function(args)
	p = args.player
	print(" --------------------------------------- Initializing script for player " .. p:GetName() )
	p:SetNetworkValue("HasLightsaber", true)
	Network:Send(p, "BEGIN")
	p:SetNetworkValue("sheathed", false)
	print("Made " .. p:GetName() .. " a Jedi? " .. tostring(p:GetValue("HasLightsaber")))
	if p:GetValue("Jedi") == nil then
		p:SetNetworkValue("Jedi", "anakin")
		p:SetColor(Color(100, 100, 255))
	end
end)
