--print("RESTART----------------------------------------------------------------------------------------------------------------------")

ActiveSteamIds = {}
LightsaberPreferences = {}

for p in Server:GetPlayers() do
	ActiveSteamIds[p:GetSteamId().string] = p
	p:SetNetworkValue("sheathed", false)

	if p:GetValue("Jedi") == nil then
		p:SetNetworkValue("Jedi", "anakin")
		p:SetColor(Color(100, 100, 255))
	end
end


function RemoveFromList(args)
	if ActiveSteamIds[args.player:GetSteamId().string] then
		ActiveSteamIds[args.player:GetSteamId().string] = nil
	end
end

Events:Subscribe("PlayerQuit", RemoveFromList)