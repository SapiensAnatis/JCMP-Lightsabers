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
	OBJLoader.Request({path = LocalPlayer:GetValue("Jedi") .. "_hilt"}, LocalPlayer, AddHiltToClass)
end

Network:Subscribe("LightsaberReady", PlayerJoin)

function init()

	OBJLoader.Request({path = LocalPlayer:GetValue("Jedi")}, LocalPlayer, ConstructClass) -- Client:GetPlayers() does NOT include LocalPlayer
	OBJLoader.Request({path = LocalPlayer:GetValue("Jedi") .. "_hilt"}, LocalPlayer, AddHiltToClass)

	for p in Client:GetPlayers() do
		--print("Making request for foreign player " .. p:GetName())
		OBJLoader.Request({path = p:GetValue("Jedi")}, p, ConstructClass) -- Load in the model for every player
		OBJLoader.Request({path = p:GetValue("Jedi") .. "_hilt"}, p, AddHiltToClass)
	end
	--print("Making request for Kylo Ren")

	Events:Subscribe("Render", MoveLightsabers) -- Once everything is initialized, start fixing the lightsabers to bones
	Events:Subscribe("NetworkObjectValueChange", DetectLightsaberChange)
end

Events:Subscribe("ModulesLoad", init) -- Only allow this script to start runing when everything is finished loading, so that all the classes are in place

function DetectLightsaberChange(args)
	--print(tostring(args.object).."'s "..args.key.." was set to "..tostring(args.value))
	if args.object.__type == "Player" or args.object.__type == "LocalPlayer" then -- If network value change was on a Player object...
		if args.key == "Jedi" then -- If it concerns our script#
			--print("----Requesting new models")
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
	--print("Constructing lightsaber class for " .. p:GetName()) -- Debug

	local lightsaberColor = LightsaberColors[name]

	Lightsabers[p:GetId()] = Lightsaber(model, lightsaberColor, name, p) -- Add to global array to keep track of lightsabers
	-- Debug: print("Lightsabers ["..p:GetId().."] = his") -- Debug

	-- Request hilt model
	

	--print("------------------------------------------------------------------------------------------------")
end

function AddHiltToClass(model, name, p)
	local class = Lightsabers[p:GetId()] -- Lookup class
	if class then
		class:SetHilt(model)
	end
end

function MoveLightsabers()
	for p in Client:GetPlayers() do

		if Lightsabers[p:GetId()] then
			local class = Lightsabers[p:GetId()]
			
			Lightsabers[p:GetId()]:SetPosition(p:GetBonePosition(class:GetBone())) -- Set to hand every frame
			Lightsabers[p:GetId()]:SetAngle(p:GetBoneAngle(class:GetBone()))

			Lightsabers[p:GetId()]:SetPosition_s(p:GetBonePosition(class:GetBone())) -- Set to hip every frame
			Lightsabers[p:GetId()]:SetAngle_s(p:GetBoneAngle(class:GetBone()))

		end
	end

	if Lightsabers[LocalPlayer:GetId()] then
		local class = Lightsabers[LocalPlayer:GetId()]

		class:SetPosition(LocalPlayer:GetBonePosition(class:GetBone()))
		class:SetAngle(LocalPlayer:GetBoneAngle(class:GetBone())) -- Again, Client:GetPlayers() does not include LocalPlayer

		class:SetPosition_s(LocalPlayer:GetBonePosition(class:GetBone_s()))
		class:SetAngle_s(LocalPlayer:GetBoneAngle(class:GetBone()_s))

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

