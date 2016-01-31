
function DoDamage(args, player)
	if Vector3.Distance(player:GetPosition(), args.entity:GetPosition()) < 2 then
		args.entity:SetHealth(args.entity:GetHealth() - 0.05)
	end
end	

Network:Subscribe("LightsaberDamage", DoDamage)




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
				return false
			else
				args.player:SetNetworkValue("Jedi", "anakin")
			end
		elseif msg[2] == "red" then
			if args.player:GetValue("Jedi") == "darth vader" then
				Chat:Send(args.player, "You already have this lightsaber equipped.", Color.Orange)
				return false
			else
				args.player:SetNetworkValue("Jedi", "darth vader")
			end
		elseif msg[2] == "green" then
			if args.player:GetValue("Jedi") == "luke skywalker" then
				Chat:Send(args.player, "You already have this lightsaber equipped.", Color.Orange)
				return false
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


------------------------------------------------------------------------------------------------------------------------------------------------------------------

function ChangeSheath(args, player)
	player:SetNetworkValue("sheathed", args)
end

Network:Subscribe("KeyPressSheath", ChangeSheath)
