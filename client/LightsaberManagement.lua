LightsaberColors = { -- Define an easy reference of lightsaber colours
	["anakin"] = Color(80, 80, 255), -- keys = filenames
	["darth vader"] = Color(255, 25, 25),
	["luke skywalker"] = Color(25, 255, 25),
}

LightsaberFilenames = { -- Filenames excluding OBJ extension
	"anakin",
	"darth vader",
	"luke skywalker",
}

ModelData = {

}


function CacheModelData(table, name)
	ModelData[name] = table

	if name == "luke skywalker_hilt" then -- The last model to be loadedl
		print("Complete! In " .. loadTimer:GetSeconds() .. " seconds.")

		loadTimer = nil
		Events:Fire("ModelsReady")
	end
end

function ModulesLoad()

	loadTimer = Timer()
	print("Loading and interpreting lightsaber model data... (approx. 0.5 MB)")
	OBJLoader.Request({path = "anakin"}, LocalPlayer, CacheModelData)
	OBJLoader.Request({path = "anakin_hilt"}, LocalPlayer, CacheModelData)

	OBJLoader.Request({path = "darth vader"}, LocalPlayer, CacheModelData)
	OBJLoader.Request({path = "darth vader_hilt"}, LocalPlayer, CacheModelData)

	OBJLoader.Request({path = "luke skywalker"}, LocalPlayer, CacheModelData)
	OBJLoader.Request({path = "luke skywalker_hilt"}, LocalPlayer, CacheModelData)


end

Events:Subscribe("ModuleLoad", ModulesLoad)




function PlayerJoin(args)
	if not args.player:GetValue("Jedi") then
		pValue = "anakin"
	else
		pValue = args.player:GetValue("Jedi")
	end

	Lightsabers[args.player:GetId()] = 
	Lightsaber( -- Construct class
		Model.Create(ModelData[pValue]),
		LightsaberColors[pValue],
		pValue,
		args.player,
		Model.Create(ModelData[pValue .. "_hilt"])
		)
end

Events:Subscribe("PlayerJoin", PlayerJoin)

function init()


	local pValue = LocalPlayer:GetValue("Jedi")

	local model = Model.Create(ModelData[pValue])
	model:SetTopology(Topology.TriangleList)

	local hilt = Model.Create(ModelData[pValue .. "_hilt"])
	hilt:SetTopology(Topology.TriangleList)

	Lightsabers[LocalPlayer:GetId()] = 
	Lightsaber( -- Construct class
		model,
		LightsaberColors[pValue],
		pValue,
		LocalPlayer,
		hilt
		)



	for p in Client:GetPlayers() do

		pValue = p:GetValue("Jedi")

		local model = Model.Create(ModelData[pValue])
		model:SetTopology(Topology.TriangleList)

		local hilt = Model.Create(ModelData[pValue .. "_hilt"])
		hilt:SetTopology(Topology.TriangleList)

		Lightsabers[p:GetId()] = 
		Lightsaber( -- Construct class
			model,
			LightsaberColors[pValue],
			pValue,
			p,
			hilt
			)

	end


	Events:Subscribe("Render", MoveLightsabers) -- Once everything is initialized, start fixing the lightsabers to bones
	Events:Subscribe("NetworkObjectValueChange", DetectLightsaberChange)
end

Events:Subscribe("ModelsReady", init) -- Only allow this script to start runing when everything is finished loading, so that all the classes are in place

function DetectLightsaberChange(args)

	if args.object.__type == "Player" or args.object.__type == "LocalPlayer" then -- If network value change was on a Player object...
		if args.key == "Jedi" then -- If it concerns our script#

			local model = Model.Create(ModelData[args.value])
			local hilt = Model.Create(ModelData[args.value .. "_hilt"])

			model:SetTopology(Topology.TriangleList)
			hilt:SetTopology(Topology.TriangleList)

			Lightsabers[args.object:GetId()]:SetModel(
				model
				)

			Lightsabers[args.object:GetId()]:SetHilt(
				hilt
				)

			Lightsabers[args.object:GetId()]:SetLightColor(
				LightsaberColors[args.value])

		end
	end
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

