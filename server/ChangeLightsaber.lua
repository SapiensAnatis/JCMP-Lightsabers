function RetrieveStoredPreferences()

	LoadFile("anakin")
	LoadFile("darth vader")
	LoadFile("luke skywalker")

end

function DoDamage(args, player)
	if Vector3.Distance(player:GetPosition(), args.entity:GetPosition()) < 1 then
		args.entity:SetHealth(args.entity:GetHealth() - 0.05)
	end
end	

Network:Subscribe("LightsaberDamage", DoDamage)

function LoadFile(value)
	local fileObject = io.open(value .. ".txt", "r")



	for line in fileObject:lines() do
		if ActiveSteamIds[line] then -- If we actually have an active player on the server with the same SteamId
			playerObject = ActiveSteamIds[line]
			if IsValid(playerObject) then
				playerObject:SetNetworkValue("Jedi", value) -- Update their value
			end
		end

		LightsaberPreferences[line] = value -- Save to table if they aren't active anyway, in case they become active later
		-- And so that their preferences are saved even if they don't log in this session

	end

	for p in Server:GetPlayers() do
		LightsaberPreferences[p:GetSteamId().string] = p:GetValue("Jedi")
	end
end

Events:Subscribe("ModulesLoad", RetrieveStoredPreferences)



LightsaberColors = { -- Define an easy reference of lightsaber colours
	["anakin"] = Color(100, 100, 255),
	["darth vader"] = Color(255, 25, 25),
	["luke skywalker"] = Color(25, 255, 25),
}

function LoadLightsaberOnJoin(args)
	if args.player:GetValue("Jedi") == nil then
		if LightsaberPreferences[args.player:GetSteamId().string] == nil then
			args.player:SetNetworkValue("Jedi", "anakin")
		else
			args.player:SetNetworkValue("Jedi", LightsaberPreferences[args.player:GetSteamId().string])
		end
	end

	Network:Send(args.player, "LightsaberReady")
end

Events:Subscribe("PlayerJoin", LoadLightsaberOnJoin)

function ChangeLightsaberFromChat(args)
	local msg = string.split(args.text, " ")
	if msg[1] == "/lightsaber" then

		if msg[2] == "blue" then -- No case statements in lua :(
			if args.player:GetValue("Jedi") == "anakin" then
				Chat:Send(args.player, "You already have this lightsaber equipped.", Color.Orange)
			else
				args.player:SetNetworkValue("Jedi", "anakin")
			end
		elseif msg[2] == "red" then
			if args.player:GetValue("Jedi") == "darth vader" then
				Chat:Send(args.player, "You already have this lightsaber equipped.", Color.Orange)
			else
				args.player:SetNetworkValue("Jedi", "darth vader")
			end
		elseif msg[2] == "green" then
			if args.player:GetValue("Jedi") == "luke skywalker" then
				Chat:Send(args.player, "You already have this lightsaber equipped.", Color.Orange)
			else
				args.player:SetNetworkValue("Jedi", "luke skywalker")
			end
		else
			Chat:Send(args.player, "No such lightsaber exists in the archives. Choose red, green or blue.", Color.Orange)
			return false
		end

		--print("Player changed!")

		nameProperGrammar = string.gsub(" "..args.player:GetValue("Jedi"), "%W%l", string.upper):sub(2) -- Title case

		Chat:Send(args.player, "You are holding " .. nameProperGrammar .. "'s lightsaber.", LightsaberColors[args.player:GetValue("Jedi")])
		args.player:SetColor(LightsaberColors[args.player:GetValue("Jedi")])

		LightsaberPreferences[args.player:GetSteamId().string] = args.player:GetValue("Jedi") -- Update prefs

		return false

	end
end

Events:Subscribe("PlayerChat", ChangeLightsaberFromChat)

function SaveLightsaberPreferences()
	-- Debug: print("Unloading!")
	local fileA = io.open("anakin.txt", "w+") -- Anakin file first
	local fileD = io.open("darth vader.txt", "w+")
	local fileL = io.open("luke skywalker.txt", "w+")

	for i, v in pairs(LightsaberPreferences) do
		if v == "anakin" then
			fileA:write(i) -- Writing steamids
		elseif v == "darth vader" then
			fileD:write(i)
		elseif v == "luke skywalker" then
			fileL:write(i)
		end

		-- Debug: print("Writing to " .. v .. " SteamID " .. i)
	end
end

Events:Subscribe("ModuleUnload", SaveLightsaberPreferences)


------------------------------------------------------------------------------------------------------------------------------------------------------------------

function UpdateSheathValue(args, player)
	player:SetNetworkValue("sheathed", not player:GetValue("sheathed"))
end

Network:Subscribe("SheathKeyTrigger", UpdateSheathValue)
