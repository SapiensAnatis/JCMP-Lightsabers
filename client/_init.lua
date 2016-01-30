--print("------------------------RESTART----------------------------")

Lightsabers = {}


----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Lightsaber object

class("Lightsaber")

function Lightsaber:__init(model, lightColor, modelname, player, hilt, sprite, bone, bone_s, position, position_s, angle, angle_s)
	-- Debug: print("Initializing....")
	-- Get properties from creation


	self.model 		= model
	self.lightColor = lightColor

	self.light 		= ClientLight.Create({position = Vector3(0, 0, 0), color = Color.Black, multiplier = 5, radius = 7})
	self.player 	= player

	self.light 		= ClientLight.Create({position = Vector3(0, 0, 0), color = Color.Black, multiplier = 5, radius = 7})

	self.light 		= ClientLight.Create({position = Vector3(0, 0, 0), color = Color.Black, multiplier = 5, radius = 7})

	self.light 		= ClientLight.Create({position = Vector3(0, 0, 0), color = Color.Black, multiplier = 5, radius = 2, quadraticattenuation = 44})

	self.player 	= player 

	self.hilt 		= hilt
	self.image 		= Image.Create(AssetLocation.Resource, modelname)

	self.sprite 	= sprite

	self.transform 	= Transform3()

	-- Some default paramaters if they're missing:

	if bone == nil then self.bone 		  = "ragdoll_LeftHand" end
	if bone_s == nil then self.bone_s 	  = "ragdoll_LeftUpLeg" end

	if position == nil then self.position = self.player:GetBonePosition(self.bone) end
	if position_s == nil then self.position_s = self.player:GetBonePosition(self.bone_s) end

	if angle == nil then self.angle 	  = self.player:GetBoneAngle(self.bone) end
	if angle_s == nil then self.angle_s 	  = self.player:GetBoneAngle(self.bone_s) end

	-- Subscriptions

	renderSub = Events:Subscribe("GameRender", self, self.DrawFunction)
	Events:Subscribe("ModuleUnload", self, self.Remove)
end

function Lightsaber:DrawFunction()


	if not IsValid(self.player, true) then
		return 
	end -- If the player is not streamed, don't bother


	------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Drawing and light positioning




	if self.player:GetValue("sheathed") == false then




		----------------------------------------------------------------------------------

		-- Raycast down to account for model offset

		

		actualStart1 = Physics:Raycast(
			self.position,
			self.angle * Vector3.Left, -- For whatever reason, down is left
			0,
			0.105).position

		-- Then right a bit to again account for model offset

		actualStart = Physics:Raycast(
			actualStart1,
			self.angle * Vector3.Down,
			0,
			0.042).position

			-- Perform raycasting to determine self.position of light
		lightPos = Physics:Raycast(
			actualStart,
			self.angle * Vector3.Forward, 
			0, 
			0.5).position -- Raycast 0.5m forward to determine self.position of average point of the blade (to place the light such that it illuminates evenly)

		imgPos = Physics:Raycast(
			lightPos,
			self.angle * Vector3.Forward, 
			0, 
			0.14).position -- Raycast 0.5m forward to determine self.position of average point of the blade (to place the light such that it illuminates evenly)


		self.light:SetPosition(lightPos) -- Based on the raycast, set the light's self.position to be 0.5m along the blade which is roughly 1m long


		self.transform:Translate(self.position)
		self.transform:Rotate(self.angle)
		Render:SetTransform(self.transform)
		
		self.model:Draw()


		Render:ResetTransform()
		self.transform:SetIdentity() -- Clear the transform so that it isn't moved cumulatively every frame

		a = self.angle*Angle(0, 1.57, Camera:GetAngle().pitch/1.57+(Angle.FromVectors(self.angle * Vector3.Down, Camera:GetAngle() * Vector3.Forward)).roll)

		Render:SetTransform(Transform3():Translate(imgPos):Rotate(a):Scale(Vector3(0.2, 1.05, 1)))

		a = self.angle*Angle(0, 1.57, Camera:GetAngle().pitch/1.57+(Angle.FromVectors(self.angle * Vector3.Down, Camera:GetAngle() * Vector3.Forward)).roll)

		Render:SetTransform(Transform3():Translate(imgPos):Rotate(a):Scale(Vector3(0.2, 1.05, 1)))

		Render:SetTransform(Transform3():Translate(imgPos):Rotate(self.angle * Angle(0, 1.57, Camera:GetAngle().pitch * -Camera:GetAngle().yaw)):Scale(Vector3(0.2, 1.05, 1)))

		self.sprite:Draw()
		Render:ResetTransform()


		self.light:SetColor(self.lightColor)

		-------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Deadliness (not in seperate function because it relies on self.position, similar events also)
		
	

		endOfHilt = Physics:Raycast(
			actualStart, 
			self.angle * Vector3.Forward, 
			0, 
			0.22).position -- Hilt is roughly 0.22m long

		-- Raycast from the *end* of the hilt so that the hitcast doesn't see the hilt as deadly (might help with making them less fatal for the user)

		hTable = Physics:Raycast(
			endOfHilt, 
			self.angle * Vector3.Forward, 
			0, 
			0.88) -- Blade is roughly 1m long

		if IsValid(hTable.entity) then -- if the ray hit something

			if hTable.entity.__type == "Player" or hTable.entity.__type == "Vehicle" and self.player == LocalPlayer then -- you can't damage static objects, so do a check

				Network:Send("LightsaberDamage", {entity = hTable.entity})
			end
		end



	else
		if self.hilt then
			self.transform:Translate(self.position_s)
			self.transform:Rotate(self.angle_s)

			Render:SetTransform(self.transform)

			self.hilt:Draw()
			self.light:SetColor(Color.Black) -- Easy way to temp disable
			Render:ResetTransform()
			self.transform:SetIdentity()

		end
	end


	--------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Debug (comment out for release)


end


function Lightsaber:SetModel(newModel, sprite)
	self.model = nil -- Cleanup
	self.model = newModel
	self.sprite = sprite
end

function Lightsaber:SetLightColor(newColor)
	self.lightColor = newColor
	self.light:SetColor(newColor)
end

function Lightsaber:Remove()

	if self.light then
		self.light:SetColor(Color.Black) -- Precaution: if we can't fully quit, at least remove the invisible lights from everywhere
		self.light:Remove()
		self.light = nil
	end



	

	self = nil
end

function Lightsaber:SetPosition(newPos)
	self.position = newPos
end

function Lightsaber:SetAngle(newAngle)
	self.angle = newAngle
end

function Lightsaber:SetPosition_s(newPos)
	self.position_s = newPos
end

function Lightsaber:SetAngle_s(newAngle)
	self.angle_s = newAngle
end


function Lightsaber:SetHilt(newModel)
	self.hilt = newModel
end

