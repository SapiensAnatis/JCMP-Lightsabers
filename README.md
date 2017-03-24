# Lightsabers

Lightsabers is a script for the Just Cause 2 Multiplayer Mod that I have made which uses dreadmullet's OBJ importer to import custom models, in order to create an authentic-looking lightsaber. The script uses ClientLights and the Model class to achieve this.

You will start with your lightsaber sheathed. Press G to start using it. Q (or whatever you have melee bound to in Just Cause 2 singleplayer) will move it, or you can just run at people with it.

Use the commands "/lightsaber blue" or red, or green, to change lightsabers. At the moment, I have models for Luke's lightsaber from ROTJ, Anakin's lightsaber/Luke's first lightsaber, and Darth Vader's lightsaber.

A simple raycasting call determines whether your lightsaber is about to cut someone's limbs off (or a vehicle's tyres) and damages them accordingly (almost completely client-side, with additional server verification - beware that this could be abused).

# Screenshots

- http://i.imgur.com/EeyBSt6l.jpg
- http://i.imgur.com/vnelAlrl.jpg
- http://i.imgur.com/3EkZGTYl.jpg

# For scripters/server owners:

The script requires those OBJ files in the base directory. On a client loading the module, the client will request the 6 models in the server directory and cache them, and then use them to construct all models.

Depending on your user's internet connection to the server, the time this takes will vary. From my locally hosted server to me (i.e. 0 ping) the average loading time for models (which will be necessitated on the client of a player joining, or on all clients if the module is reloaded), tends to be from 1.3 seconds to 2 seconds.

The models and data that is transmitted is of a size around 500 KB.

For scripters who want to extend the script:

The script uses a class system to make a lightsaber an object, which has members including position, bound player, angle, hilt and blade model, etc. You can 'construct' a lightsaber like so:

`Lightsaber(model, lightColor, modelname, player, hilt, bone, bone_s, position, position_s, angle, angle_s)`


The properties, in order, are as follows. Bold denotes a required argument.:

-    Model: the Model object that represents the active, unsheathed lightsaber
-    LightColor: the Color object that the ClientLight should be
-    modelname: the filename of the Model's OBJ file, minus extension. Currently not in use, but required anyway, for possible identification purposes.
-    player: The player who's lightsaber this is. Used to index in a table (and so this player will be the one who damages people, and the one who can sheath/unsheath), and to save preferences.
-    hilt: The Model object that will be drawn when the lightsaber is sheathed.
-    Bone: the bone that the lightsaber should be attached to, if no position is given later on. If not given, defaults to left hand.
-    Bone_s: the bone that the lightsaber should be attached to when sheathed.
-    position: the position that the lightsaber should assume by default. The current script modifies this every render frame, from a function outside of the class, using the class' SetPosition method.
-    position_s: the position that the lightsaber should assume, when sheathed, by default. See note above about being changed every frame outside of the class.
-    angle/angle_s: The angle used by default when not sheathed/sheathed, respectively (you get the drill). Also changed every frame outside of the class


The script does require a player to be tied to a lightsaber, so doing something like having a lightsaber on display isn't possible without modifying the class itself. However, custom position means that if you were really willing, you could add things like throwing lightsabers. Or, with some modelling skill and by seperating the blade from the hilt model and using scaled transformaton, you could try making activation animations and dual bladed lightsabers, using angles and postions. That would likely take much more effort than it's worth.

The class contains a number of methods:

-    SetModel(newModel): takes a Model object as argument, and starts drawing that instead
-    SetLightColor(newColor): takes a Color object and sets the integrated ClientLight to be that color.
-    Remove(): deletes the light and makes the class nil
-    SetPosition(newPos): sets the drawing position of the model and light to the given Vector3
-    GetBone(): returns the bone that the lightsaber was defined to be attached to
-    GetBone_s(): returns the bone that the lightsaber was defined to be attached to when sheathed
-    SetAngle(newAngle): sets the drawing angle to the given Angle object
-    SetPosition_s(newPos): sets the sheathed drawing position to the given Vector3
-    SetAngle_s(newAngle): sets the sheathed drawing angle to the given Angle
-    SetHilt(newModel): sets the sheathed model to the given Model object


# Known issues:

-    Some people may experience high loading times for the models if they are far away from the server and/or their internet connection is sub-optimal.
-   The light sprite can look a bit dodgy from certain camera angles. I might use some better trig to fix that at some point. A lack of understanding of how the camera angles in the modding API worked as well as the maths behind it lead to this problem.
