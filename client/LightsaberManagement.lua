

function CreateSprite(image)
   local imageSize = image:GetSize()
   local size = Vector2(imageSize.x / imageSize.y, 1) / 2
   local uv1, uv2 = image:GetUV()

   local sprite = Model.Create({
      Vertex(Vector2(-size.x, size.y), Vector2(uv1.x, uv1.y)),
      Vertex(Vector2(-size.x,-size.y), Vector2(uv1.x, uv2.y)),
      Vertex(Vector2( size.x,-size.y), Vector2(uv2.x, uv2.y)),
      Vertex(Vector2( size.x,-size.y), Vector2(uv2.x, uv2.y)),
      Vertex(Vector2( size.x, size.y), Vector2(uv2.x, uv1.y)),
      Vertex(Vector2(-size.x, size.y), Vector2(uv1.x, uv1.y))
   })

   sprite:SetTexture(image)
   sprite:SetTopology(Topology.TriangleList)

   return sprite
end

sprites = {
	
}

LightsaberColors = { -- Define an easy reference of lightsaber colours
	["anakin"] = Color(80, 80, 255), -- keys = filenames
	["darth vader"] = Color(255, 25, 25),
	["luke skywalker"] = Color(25, 255, 25),
}



ModelData = {

}

lightsabersNeeded = {
	
}

initiallyLoading = true


function CacheModelData(table, name, player)

	ModelData[name] = table


	-- If this is part 2 of a request:

	if string.find(name, "_hilt") != nil then

		for i, v in pairs(lightsabersNeeded) do
			lastPlayer = v
		end



		if player == LocalPlayer then

			StartMakingDemands(player, true, true)
		else

			if lastPlayer == player and initiallyLoading then
				initiallyLoading = false
				Events:Subscribe("EntitySpawn", ForceSense)
			end
			ForceSensePart2(player)
		end
	end




end

function CallbackForChange(table, name, player)
	ModelData[name] = table
	if string.find(name, "_hilt") != nil then--if it's a secondary request
		name = player:GetValue("Jedi")
		local model = Model.Create(ModelData[name])
		local hilt = Model.Create(ModelData[name .. "_hilt"])

		local sprite = sprites[name]

		Lightsabers[player:GetId()]:SetModel(
			model, sprite
			)

		Lightsabers[player:GetId()]:SetHilt(
			hilt
			)

		Lightsabers[player:GetId()]:SetLightColor(
			LightsaberColors[name]
			)
	end
end


function ModulesLoad()
	print("Lightsabers began on client after server gave OK")
	if IsValid(LocalPlayer) then
		pValue = LocalPlayer:GetValue("HasLightsaber") or false
		if pValue then
			RequestModelData(LocalPlayer:GetValue("Jedi") or "anakin", LocalPlayer) -- LocalPlayer first and foremost
		else
			StartMakingDemands(LocalPlayer, true, false)
		end
	end

	



	Events:Subscribe("Render", MoveLightsabers) -- Once everything is initialized, start fixing the lightsabers to bones
	Events:Subscribe("PreTick", MoveLightsabers) -- Subscribing to three events ensures that they don't drift about at high speeds
	Events:Subscribe("PostTick", MoveLightsabers)
	Events:Subscribe("NetworkObjectValueChange", DetectLightsaberChange)

end

function StartMakingDemands(p, initial, makeForLP) -- For localplayer
	initial = initial or true
	p = p or LocalPlayer -- weird shit happens
	if makeForLP then
		pValue = p:GetValue("Jedi")

		if Lightsabers[p:GetId()] then return end

		Lightsabers[p:GetId()] = Lightsaber(
			Model.Create(ModelData[pValue]),
			LightsaberColors[pValue],
			pValue,
			p,
			Model.Create(ModelData[pValue .. "_hilt"]),
			sprites[pValue]
		)
		Lightsabers[pGetId()]:UnfuckScale()
	end
	if initial then MakeDemands() end
end


function MakeDemands() -- Find out how many lightsabers we initially need

	for p in Client:GetPlayers() do
		if Lightsabers[p:GetId()] then return end
		if p:GetValue("HasLightsaber") then
			if lightsabersNeeded[p:GetValue("Jedi")] == nil then
				lightsabersNeeded[p:GetValue("Jedi")] = p
			end
		end
	end


	for i, v in pairs(lightsabersNeeded) do

		RequestModelData(i, v)
	end
end






Network:Subscribe("BEGIN", ModulesLoad)

function ForceSense(args)
	
	if args.entity.__type != "Player" then return end

	if not args.entity:GetValue("HasLightsaber") then return end 

	local p = args.entity

	if Lightsabers[p:GetId()] != nil then return end -- if they already have a lightsaber from a previous encounter

	print("Someone is streaming in. Here's a Star Wars reference.")
	print("SNOKE: There has been an awakening...have you felt it..?")
	print("KYLO REN: Yes.")
	print("SNOKE: Even you...the leader of the Knights of Ren...have never faced such a test.")

	pValue = p:GetValue("Jedi") or "anakin"

	if ModelData[pValue] and ModelData[pValue .. "_hilt"] and sprites[pValue] then
		Lightsabers[p:GetId()] = Lightsaber(
			Model.Create(ModelData[pValue]),
			LightsaberColors[pValue],
			pValue,
			p,
			Model.Create(ModelData[pValue .. "_hilt"]),
			sprites[pValue]
		)

	print("KYLO REN: It is time.")
	else
		RequestModelData(pValue, p)
	end
end

Events:Subscribe("EntitySpawn", ForceSense)


function ucantcme(args)
	if args.entity.__type == "Player" then
		if args.entity:GetValue("HasLightsaber") then
			if Lightsabers[args.entity:GetId()] then
				Lightsabers[args.entity:GetId()].model = nil
				Lightsabers[args.entity:GetId()].sprite = nil
				Lightsabers[args.entity:GetId()].hilt = nil
				Lightsabers[args.entity:GetId()]:Remove()
				Lightsabers[args.entity:GetId()] = nil
			end
		end
	end
end

Events:Subscribe("EntityDespawn", ucantcme)

function ForceSensePart2(p)


	if p == LocalPlayer then return end -- localplayer has a seperate function
	if not IsValid(p) then return end
	if Lightsabers[p:GetId()] then return end -- no duplicates
	pValue = p:GetValue("Jedi")


	Lightsabers[p:GetId()] = Lightsaber(
		Model.Create(ModelData[pValue]),
		LightsaberColors[pValue],
		pValue,
		p,
		Model.Create(ModelData[pValue .. "_hilt"]),
		sprites[pValue]
	)

end



function RequestModelData(name, p, callback)
	if not IsValid(p) then return end

	if Lightsabers[p:GetId()] then

		if Lightsabers[p:GetId()].name == name then return end
	end
	callback = callback or CacheModelData
	if ModelData[name] == nil then
		OBJLoader.Request({path = name}, p, callback)
	else
		callback(ModelData[name], name, p)
	end

	if ModelData[name .. "_hilt"] == nil then 
		OBJLoader.Request({path = name .. "_hilt"}, p, callback)
	else
		callback(ModelData[name .. "_hilt"], name .. "_hilt", p)
	end

	sprites[name] = CreateSprite(Image.Create(AssetLocation.Resource, name))

	
	

end


function DetectLightsaberChange(args)
	if IsValid(args.object) then

		if args.object.__type == "Player" or args.object.__type == "LocalPlayer" then -- If network value change was on a Player object...

			if args.key == "Jedi" then -- If it concerns our script#
				if ModelData[args.value] and ModelData[args.value .. "_hilt"] and sprites[args.value] then
					local model = Model.Create(ModelData[args.value])
					local hilt = Model.Create(ModelData[args.value .. "_hilt"])

					local sprite = sprites[args.value]

					model:SetTopology(Topology.TriangleList)
					hilt:SetTopology(Topology.TriangleList)

					Lightsabers[args.object:GetId()]:SetModel(
						model, sprite
						)

					Lightsabers[args.object:GetId()]:SetHilt(
						hilt
						)

					Lightsabers[args.object:GetId()]:SetLightColor(
						LightsaberColors[args.value])
				else
					RequestModelData(args.value, args.object, CallbackForChange)
				end

			elseif args.key == "HasLightsaber" then

				if args.value then
					pValue = args.object:GetValue("Jedi")
					if ModelData[pValue] and ModelData[pValue .. "_hilt"] and sprites[pValue] then
						Lightsabers[args.object:GetId()] = Lightsaber(
							Model.Create(ModelData[pValue]),
							LightsaberColors[pValue],
							pValue,
							args.object,
							Model.Create(ModelData[pValue .. "_hilt"]),
							sprites[pValue]
						)
					else
						RequestModelData(pValue, args.object, CacheModelData)
					end
				else
					if Lightsabers[args.object:GetId()] then

						Lightsabers[args.object:GetId()]:Remove()
						Lightsabers[args.object:GetId()].model = nil
						Lightsabers[args.object:GetId()].sprite = nil
						Lightsabers[args.object:GetId()].hilt = nil
						Lightsabers[args.object:GetId()]:Remove()
						Lightsabers[args.object:GetId()] = nil
					end
				end
			end
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
	if LocalPlayer:GetValue("HasLightsaber") then
		if args.key == string.byte("G") and not LocalPlayer:InVehicle() then
			Network:Send("KeyPressSheath", not LocalPlayer:GetValue("sheathed"))
		end
	end
end

Events:Subscribe("KeyUp", SheathUnsheathKeys)

function ForceSheath() -- use the force, heh
	if LocalPlayer:GetValue("HasLightsaber") then
		if LocalPlayer:InVehicle() then
			Network:Send("KeyPressSheath", true) -- It looks really weird if you have a lightsaber out while flying a plane. And it's irresponsible.
		end
	end
end



Events:Subscribe("PostTick", ForceSheath)

