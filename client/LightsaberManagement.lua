LightsaberColors = { -- Define an easy reference of lightsaber colours
	["anakin"] = Color(100, 100, 255), -- keys = filenames
	["darth vader"] = Color(255, 25, 25),
	["luke skywalker"] = Color(25, 255, 25),
}

LightsaberFilenames = { -- Filenames excluding OBJ extension
	"anakin",
	"darth vader",
	"luke skywalker",
}

function PlayerJoin(args)
	OBJLoader.Request({path = args.player:GetValue("Jedi")}, args.player, ConstructClass)
end

Events:Subscribe("PlayerJoin", PlayerJoin)

function init()

	OBJLoader.Request({path = LocalPlayer:GetValue("Jedi")}, LocalPlayer, ConstructClass) -- Client:GetPlayers() does NOT include LocalPlayer
	OBJLoader.Request({path = LocalPlayer:GetValue("Jedi") .. "_hilt"}, LocalPlayer, AddHiltToClass)

	for p in Client:GetPlayers() do

		OBJLoader.Request({path = p:GetValue("Jedi")}, p, ConstructClass) -- Load in the model for every player
		OBJLoader.Request({path = p:GetValue("Jedi") .. "_hilt"}, p, AddHiltToClass)
	end


	Events:Subscribe("Render", MoveLightsabers) -- Once everything is initialized, start fixing the lightsabers to bones
	Events:Subscribe("NetworkObjectValueChange", DetectLightsaberChange)
end

Events:Subscribe("ModulesLoad", init) -- Only allow this script to start runing when everything is finished loading, so that all the classes are in place

function DetectLightsaberChange(args)

	if args.object.__type == "Player" or args.object.__type == "LocalPlayer" then -- If network value change was on a Player object...
		if args.key == "Jedi" then -- If it concerns our script#

			OBJLoader.Request({path = args.value}, args.object, ModifyClass) -- OBJLoader uses cached requests so not much cleanup is needed
			OBJLoader.Request({path = args.value .. "_hilt"}, args.object, AddHiltToClass)
		end
	end
end

function ModifyClass(model, name, p) -- Callback
	if Lightsabers[p:GetId()] then
		local class = Lightsabers[p:GetId()] -- Lookup the lightsaber
		class:SetModel(model) -- aand change the model
		class:SetLightColor(LightsaberColors[p:GetValue("Jedi")]) -- make light color correspond
	end
	
end



function ConstructClass(model, name, p) -- Callback from OBJLoader

	name = name:lower() -- just making sure

	local lightsaberColor = LightsaberColors[name]

	Lightsabers[p:GetId()] = Lightsaber(model, lightsaberColor, name, p) -- Add to global array to keep track of lightsabers
	-- Debug: print("Lightsabers ["..p:GetId().."] = his") -- Debug

	-- Request hilt model
	

end

function AddHiltToClass(model, name, p)
	local class = Lightsabers[p:GetId()] -- Lookup class
	class:SetHilt(model)
end

function MoveLightsabers()
	for p in Client:GetPlayers() do

		if Lightsabers[p:GetId()] then
			
			Lightsabers[p:GetId()]:SetPosition(p:GetBonePosition("ragdoll_LeftHand")) -- Set to hand every frame
			Lightsabers[p:GetId()]:SetAngle(p:GetBoneAngle("ragdoll_LeftHand"))

			Lightsabers[p:GetId()]:SetPosition_s(p:GetBonePosition("ragdoll_LeftUpLeg")) -- Set to hip every frame
			Lightsabers[p:GetId()]:SetAngle_s(p:GetBoneAngle("ragdoll_LeftUpLeg"))

		end
	end

	if Lightsabers[LocalPlayer:GetId()] then

		Lightsabers[LocalPlayer:GetId()]:SetPosition(LocalPlayer:GetBonePosition("ragdoll_LeftHand"))
		Lightsabers[LocalPlayer:GetId()]:SetAngle(LocalPlayer:GetBoneAngle("ragdoll_LeftHand")) -- Again, Client:GetPlayers() does not include LocalPlayer

		Lightsabers[LocalPlayer:GetId()]:SetPosition_s(LocalPlayer:GetBonePosition("ragdoll_LeftUpLeg"))
		Lightsabers[LocalPlayer:GetId()]:SetAngle_s(LocalPlayer:GetBoneAngle("ragdoll_LeftUpLeg"))

	end
end

function DeleteLightsaberQuit(args)
	if Lightsabers[args.player:GetId()] then
		Lightsabers[args.player:GetId()]:Remove()
	end
end

Events:Subscribe("PlayerQuit", DeleteLightsaberQuit)



function SheathUnsheathKeys(args)
	if args.key == string.byte("G") then
		Network:Send("SheathKeyTrigger", player)
	end
end

Events:Subscribe("KeyUp", SheathUnsheathKeys)

function ForceSheath() -- use the force, heh
	if LocalPlayer:InVehicle() then
		LocalPlayer:SetValue("sheathed", true) -- It looks really weird if you have a lightsaber out while flying a plane. And it's irresponsible.
	end
end



Events:Subscribe("PostTick", ForceSheath)

