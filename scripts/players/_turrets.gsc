//
// vim: set ft=cpp:
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.7 by Luk and 3aGl3
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
	// Assign Minigun Models
	level.sentry_turret_model["minigun"] = "bo2_turret_sentry_gun";
	level.sentry_base_model["minigun"] = "bo2_turret_sentry_gun";
	
	// Assign GL-Turret Models
	level.sentry_turret_model["gl"] = "mw3_sentry_gl_turret";
	level.sentry_base_model["gl"] = "mw3_sentry_gl_base";
	
	// Load Models and Effects
	precacheModel(level.sentry_turret_model["minigun"]);
	precacheModel(level.sentry_turret_model["gl"]);
	precacheModel(level.sentry_base_model["gl"]);

	level._effect["turret_flash"] = loadFx("muzzleflashes/heavy");
	level._effect["augmented"] = loadFx("turrets/augmented_turret");
	
	level.effect_sentry_hit["gl"] = loadFx("explosions/grenadeExp_blacktop");
	level.effect_sentry_hit["minigun"] = loadFx("impacts/flesh_hit_body_fatal_exit");	
	
	level.sentry_laser = loadFx("misc/sentry_laser");
	level.turret_broken = loadFx("smoke/grenade_smoke");
	
	// Set default turret time
	if(getDvar("turret_time") == "") 
		setDvar("turret_time", 90);

	// Initialize default vars
	level.turrets = 0;
	level.turrets_held = 0;
	level.turretsDisabled = 0;
	
	turretData();
}

/**
*	We save static stats of both types of turrets to refer to them later and to make it easier to
*	modify them via config vars and difficulty settings
*/
turretData()
{
	level.turretData = [];
	
	// Data should be self-explanatory
	level.turretData["minigun"] = spawnstruct();
	level.turretData["minigun"].firespeed = 0.05;
	level.turretData["minigun"].numbullets = 20;
	level.turretData["minigun"].mindamage = 5;
	level.turretData["minigun"].maxdamageadd = 10;
	level.turretData["minigun"].range = 700;
	level.turretData["minigun"].maxupangle = 30;
	level.turretData["minigun"].cooldown = 1;
	level.turretData["minigun"].fireTag = "tag_flash";
	
	level.turretData["gl"] = spawnstruct();
	level.turretData["gl"].firespeed = 0.5;
	level.turretData["gl"].numbullets = 3;
	level.turretData["gl"].mindamage = 50;
	level.turretData["gl"].maxdamageadd = 70;
	level.turretData["gl"].range = 1000;
	level.turretData["gl"].maxupangle = 45;
	level.turretData["gl"].cooldown = 2;
	level.turretData["gl"].firetag = "tag_turret";
}

/**
*	Loads the default turret stats
*	@turret_type String, either 'gl' or 'minigun'
*/
loadTurretData(turret_type)
{
	if(!isDefined(turret_type))
		return;

	self.firespeed = level.turretData[turret_type].firespeed;
	self.numbullets = level.turretData[turret_type].numbullets;
	self.mindamage = level.turretData[turret_type].mindamage;
	self.maxdamageadd = level.turretData[turret_type].maxdamageadd;
	self.range = level.turretData[turret_type].range;
	self.maxupangle = level.turretData[turret_type].maxupangle;
	self.cooldown = level.turretData[turret_type].cooldown;
	self.firetag = level.turretData[turret_type].firetag;
}

/**
*	Gives the calling player a turret
*	@turret_type String, either 'gl' or 'minigun'
*	@time Int, Time the turret was placed on the field, defaults to 0
*	@augmented Boolean, Whether the picked up turret was previously augmented, defaults to false
*/
giveTurret(turret_type, time, augmented)
{
	// Prevent missing arguments, set default values
	if (!isDefined(time))
		time = 0;
		
	if(!isDefined(augmented))
		augmented = false;
	
	// Spawns a script_model (empty) at the position of the player
	self.carryObj = spawn("script_model", (0, 0, 0));
	self.carryObj.origin = self.origin + (0, 0, 32);
	self.carryObj.angles = (70, self.angles[1], self.angles[2]);
	self.carryObj.turret_type = turret_type;
	
	// Save the time the turret was already on the field
	self.turret_time = time;
	
	// Debug print for checking whether spawning of the script_model object has failed
	if(!isDefined(self.carryObj))
	{
		iprintln("^1ERROR: ^7" + self.name + "'s Turret is ^1UNDEFINED^7!");
		return;
	}
	
	// Link the spawn object with the player, so it sticks and change the invisible model to the actual model
	self.carryObj linkTo(self);
	self.carryObj setModel(level.sentry_turret_model[turret_type]);
	self.carryObj setContents(2);
	
	// In case the turret is being removed, we want to handle that, too
	self.carryObj thread onDeath();
	
	// The player is holding an item, make sure he can't use anything else and can't use his weapons
	self.canUse = false;
	self disableweapons();
	
	// Start looping through a placement thread where we check if a player wants to place the turret
	self thread placeTurret(turret_type, augmented);
}

/**
*	Handling the removal of turrets that are being held by players
*/
onDeath()
{
	level.turrets_held++;
	
	self waittill("death");
	
	level.turrets_held--;
}

/**
*	The actual placement loop that monitors the desire of a player to place
*	the turret and to check the surroundings for a valid placement position
*	@turret_type String, Either 'gl' or 'minigun'
*	@augmented Boolean, Whether the turret is augmented or not
*/
placeTurret(turret_type, augmented)
{
	// Prevent this loop from being executed if a player isn't valid to use it anylonger
	self endon("death");
	self endon("disconnect");
	
	// Add a delay from being picked up and being able to place it
	wait 1;
	
	while(1)
	{
		// In case we go down while holding a turret, try to place it at our current position before actually removing it from the player
		if(self.isDown)
		{
			if(self deploy(turret_type, augmented))
			{
				self.carryObj unlink();
				wait 0.2;
				self.carryObj delete();
				self.canUse = true;
				self enableWeapons();
				self notify("placed_turret");
				return;
			}
			// If there is no valid position, we have to remove it from the player
			// TO-DO: Return upgradepoints to this player equal to the remaining time of the turret times the cost of it to compensate for the loss
			else
			{
				self.carryObj unlink();
				wait 0.2;
				self.carryObj delete();
				self.canUse = true;
				self enableWeapons();
				return;
			}
		}
		// Check if a player is trying to place it
		else if(self attackButtonPressed() && self isOnGround())
		{	
			if (self deploy(turret_type, augmented))
			{
				self.carryObj unlink();
				wait 0.2;
				self.carryObj delete();
				self.canUse = true;
				self enableWeapons();
				self notify("placed_turret");
				return;
			}
			else
			{
				wait 1;
			}
		}
		
		wait .05;
	}
	
}

/**
*	Returns whether a turret is placeable at the current position and places it, if a valid position has been found
*	@turret_type String, Either 'gl' or 'minigun'
*	@augmented Boolean, Whether the turret is augmented or not
*	@return Boolean, Whether the turret can be deployed at the current position or not
*/
deploy(turret_type, augmented)
{
	// Another thread that we don't want happening if the player disconnects or dies
	self endon("disconnect");
	self endon("death");
	
	// We get the player's orientation and draw a line in front of him that we will check
	angles = self getPlayerAngles();
	start = self.origin + (0, 0, 40) + vectorScale(anglesToForward(angles), 20);
	end = self.origin + (0, 0, 40) + vectorScale(anglesToForward(angles), 38);
	
	// We get the left, right and back area coordinates relative to the player's position
	left = vectorScale(anglesToRight(angles), -10);
	right = vectorScale(anglesToRight(angles), 10);
	back = vectorScale(anglesToForward(angles), -6);

	// Multiple checks are being run if we have a clean area in front of us and to the sides
	canPlantThere1 = bulletTracePassed(start, end, true, self);
	canPlantThere2 = bulletTracePassed(start + (0, 0, -7) + left, end + left + back, true, self);
	canPlantThere3 = bulletTracePassed(start + (0, 0, -7) + right , end + right + back, true, self);
	
	// If any of these checks fail, we report that it's not working and start over
	if(!canPlantThere1 || !canPlantThere2 || !canPlantThere3)
	{
		self iPrintlnBold("Can not deploy ^2defence turret ^7here.");
		return false;
	}

	// If, however, we find a valid place, we run a trace to determine the ground position in front of us to place it at
	// TODO: This can place a turret far above the player if it encounters a wall just above him, also make it fail-save so it won't float (mp_fnrp_cube)
	trace = bulletTrace(end + (0, 0, 100), end - (0, 0, 300), false, self);
	
	// During scary waves, the turrets are deactivated. If turrets are active however, we play a sound
	if(!level.turretsDisabled)
		self playsound("turret_activate");
		
	// We call the turret upon us in the found position!
	self thread defenceTurret(turret_type, trace["position"], (0, angles[1], 0), augmented);
	return true;
}

/**
*	Here we spawn the actual turret at the given permission and assign the turret_type's values
*	@turret_type String, Either 'gl' or 'minigun'
*	@pos Vector, Origin of the turret
*	@angles Vector, Orientation of the turret
*	@augmented Boolean, Whether the turret is augmented or not
*/
defenceTurret(turret_type, pos, angles, augmented)
{
	// Since there's another wait in this thread, we make sure to not run into problems and kill it if the turret dies during initialization
	self endon("kill_turret");

	offset = (0, 0, 0);
	
	iprintln("^2" + self.name + " ^2deployed a " + turret_type + " turret.");
	level.turrets++;
	
	// The GL turret 'head' has to be moved up a little, so it stands on its base
	if(turret_type == "gl")
		offset = (0, 0, 20);
	
	// Spawn the default models, assign the given turret_type models and hide necessary parts
	self.turret_gun = spawn("script_model", pos + offset);
	self.turret_bipod = spawn("script_model", pos);

	self.turret_gun setModel(level.sentry_turret_model[turret_type]);
	self.turret_bipod setModel(level.sentry_base_model[turret_type]);
	
	if(turret_type == "minigun")
	{
		self.turret_gun thread hideLowerParts();
		self.turret_bipod hideUpperParts();
	}
	
	// Make them not-solid
	self.turret_gun setContents(0);
	self.turret_bipod setContents(0);

	self.turret_gun.angles = angles + (0, 50, 0);
	self.turret_bipod.angles = angles;

	self.turret_gun.owner = self;
	self.turret_gun.turret_type = turret_type;
	
	// Loads the default stats for the turret
	self.turret_gun loadTurretData(self.turret_gun.turret_type);
	
	if(!isDefined(augmented))
		augmented = false;
	
	// Start the actual threads for the turrets, enemy-detection, rotation and shooting algorithms
	self.turret_gun.isTurret = true;
	self.turret_gun thread targetAcquisition();
	self.turret_gun thread rotate();
	
	if(self.turret_gun.turret_type  == "gl")
		self.turret_gun thread shootGL();
		
	if(self.turret_gun.turret_type == "minigun")
		self.turret_gun thread shootMinigun();
	
	// Process the time the turrets have been spawned to save them for later when they have to time out
	self.turret_gun.spawnTime = getTime();
	self.turret_gun.timePassed = self.turret_time;
	self.turret_gun.bipod = self.turret_bipod;
	self.turret_gun thread disableEffects();
	
	// Since we can re-place already augmented turrets by the Engineer, we make sure they are re-augmented on placement
	if(augmented)
		self.turret_gun goAugmented();
	else
		self.turret_gun.isAugmented = false;
	
	// What did they say? Give cheese time? We do the same with these turrets, before we make them movable again
	wait 1;
	
	// Make the turret pick-up-able (is that even a word?)
	self scripts\players\_usables::addUsable(self.turret_gun, "turret", &"USE_TURRET", 96);
	
	// Give turrets an extended duration on the field if you've unlocked the Engineer's ability
	if(self.longerTurrets)
		duration = level.dvar["game_turret_time"] * 1.4;
	else
		duration = level.dvar["game_turret_time"];
	
	// Thread to remove the turrets after a certain time, or when the player has left the active game
	level thread deleteTurretInTime(self.turret_gun, self.turret_bipod, duration - self.turret_gun.timePassed, self.turret_gun.turret_type, self);
	level thread deleteTurretOnDC(self.turret_gun, self.turret_bipod);
}

/**
*	Hides gun-part of Sentry Gun
*/
hideUpperParts()
{
	self hidePart("tag_aim");
	self hidePart("tag_aim_pitch");
	self hidePart("tag_spin");
}

/**
*	Hides bipod-part of Sentry Gun
*/
hideLowerParts()
{
	// Since we need to wait for the FX to spawn,
	// we make sure that this entity doesn't suddenly despawn within 0.05 secs (how high is the chance though?)
	self endon("death");
	
	self hidePart("bi_base");
	wait 0.05;
	playFXonTag(level.sentry_laser, self, "tag_flash");
}

/**
*	Engineer's Special -> Boosts the default stats of the calling turret
*/
goAugmented()
{
	type = self.turret_type;
	
	switch(type)
	{
		case "gl":
			self.fireSpeed = level.turretData[type].firespeed / 2;
			self.numBullets = level.turretData[type].numbullets + 2;
			self.range = level.turretData[type].range + 200;
			self.cooldown = level.turretData[type].cooldown * 0.8;
			self.isAugmented = true;
			self thread scripts\players\_turrets::createEffectEntity(level._effect["augmented"], "tag_origin", "augmented");
			// TODO: Find a better way to signal augmentation
			self.owner iprintln("^3Augmenting ^7GL turret!");
			break;
		case "minigun": 
			self.numBullets = level.turretData[type].numbullets * 2;
			self.maxDamageAdd = level.turretData[type].maxdamageadd * 2;
			self.range = level.turretData[type].range + 300;
			self.cooldown = level.turretData[type].cooldown * 0.5;
			self.isAugmented = true;
			self thread scripts\players\_turrets::createEffectEntity(level._effect["augmented"], "tag_origin", "augmented");
			// TODO: Find a better way to signal augmentation
			self.owner iprintln("^3Augmenting ^7Sentry turret!");
			break;
		default:
			iprintlnbold("^1ERROR: ^7Wrong turret type for Engineer special!");
			break;
	}
}

/**
*	Delete the turret after it has reached the max. duration on the field
*	@gun Entity, The upper part of the turret
*	@bipod Entity, The lower part of the turret
*	@time Int, The duration it will take for deletion to happen
*	@owner Entity, The player that owns this turret
*/
deleteTurretInTime(gun, bipod, time, type, owner)
{
	// Prevent this from executing if any of the turret is removed
	gun endon("death");
	bipod endon("death");
	
	wait time;
	if(isDefined(owner))
		// TODO: Find a better way to notify the player of a turret being removed
		owner iPrintLn("Your " + type + " turret timed out!");
		
	thread deleteTurret(gun, bipod);
}

/**
*	Delete the turret when the player disconnects or switches to spectator
*	@gun Entity, The upper part of the turret
*	@bipod Entity, The lower part of the turret
*/
deleteTurretOnDC(gun, bipod)
{
	// Prevent this from executing if any of the turret is removed
	gun endon("death");
	bipod endon("death");
	
	// If the owner stopped participating in the game, remove it
	gun.owner waittill_any("disconnect", "join_spectator");
	thread deleteTurret(gun, bipod);
}

/**
*	When the scary wave is running, the turrets show an animation of being disabled and stop firing
*/
disableEffects()
{
	// Since this is a timed thread, we want it to stop if the turret breaks or the game ends
	self endon("death");
	level endon("game_ended");
	
	if(!level.turretsDisabled)
	{
		level waittill("turrets_disabled");
		// Add some randomness to the disable animation - prevents all turrets from breaking down at the same time
		wait randomfloat(2);
	}
	
	// Shows and plays the desired effects to display its broken state
	self playsound("turret_broken");
	self createEffectEntity(level.turret_broken, self.fireTag, "broken");
	self moveDisabledPosition();
	
	// There is a time after being disabled, start here
	self thread enableAgain();
}

/**
*	Moves the turret's head downwards, so it looks sad and broken
*/
moveDisabledPosition()
{
	currentAngle = self.angles;
	
	if(self.turret_type == "gl")
		self rotateto((50, currentAngle[1], 0), 3);
	else
		self rotateto((15, currentAngle[1], 0), 3);
}

/**
*	Enables disabled turrets with an animation
*/
enableAgain()
{
	// A waiting function, so we want it to terminate if anything bad happens
	self endon("death");
	level endon("game_ended");
	
	// Wait for turrets to be enabled
	level waittill("turrets_enabled");
	
	currentAngle = self.angles;
	
	// Remove disabled effect and move it back to its default position
	if(isDefined(self.effect["broken"]))
		self.effect["broken"] delete();
	self rotateto((0, currentAngle[1], 0), 3, 0.5, 2);
	
	// Prepare it to be disabled again
	wait 3;
	self thread disableEffects();
}

/**
*	Creates an augmentation or broken effect at the given position
*	@effect String, The effect's name to be played
*	@origin Vector, The position the effect is about to be played
*	@type String, Distinguishes between the types 'augmented' and 'broken' to prevent double-casting the same effect
*/
createEffectEntity(effect, origin, type)
{
	// Fail-safe definition of an effect var
	if(!isDefined(self.effect))
		self.effect = [];
		
	// Make sure to remove any effect if one is existing
	if(isDefined(self.effect[type]))
		self.effect[type] delete();
	
	// When working with effects, we most likely have a wait. Just like here, so we want it to be stopped if it's not there anymore
	self endon("death");
	
	// Augmentation and broken effects are spawned differently, so we distinguish them here
	if(type == "augmented")
	{
		self.effect[type] = spawnFx(effect, self.origin, (0, 0, 1), (1, 0, 0));
		triggerFx(self.effect[type]);
	}
	else
	{
		self.effect[type] = spawn("script_model", self getTagOrigin(origin));
		self.effect[type] setModel("tag_origin");
		wait 0.05;
		PlayFXOnTag(effect, self.effect[type], "tag_origin");
		self.effect[type] LinkTo(self);
	}
}

/**
*	Removes a turret from the field
*	@gun Entity, The upper part of the turret
*	@bipod Entity, The lower part of the turret
*/
deleteTurret(gun, bipod)
{
	// Removes the ability to re-place the turret from the turret's owner
	if (isDefined(gun.owner))
		gun.owner scripts\players\_usables::removeUsable(gun);
		
	level.turrets--;
	
	// Remove the turret and its effects, play a sound of it being destroyed
	if(isDefined(gun.effect))
	{
		if(isDefined(gun.effect["broken"]))
			gun.effect["broken"] delete();
		if(isDefined(gun.effect["augmented"]))
			gun.effect["augmented"] delete();
	}
	
	gun playsound("turret_deactivate");
	
	bipod delete();
	gun delete();
}

/**
*	Bullet impact function for GL-Turret shots
*	@targetSpot Vector, Center position of the areal damage
*	@range Int, Range of the explosion
*	@damage Int, Amount of damage dealt max.
*	@attacker Entity, The damage inflicting entity
*/
glDamage(targetSpot, range, damage, attacker)
{
	// Loop through all existing bots
	for (i = 0 ; i < level.bots.size; i++)
	{
		selectedBot = level.bots[i];
		
		// See if the currently selected bot is valid and can be targeted
		if (isDefined(selectedBot) && isAlive(selectedBot) && !selectedBot.untargetable)
		{
			distance = distance(targetSpot, selectedBot.origin);
			// In case that bot is within range and can be seen, apply damage
			if (distance <= range)
			{
				visibility = selectedBot sightConeTrace(targetSpot, selectedBot);
				if(visibility != 0)
					// Apply damage
					selectedBot thread [[level.callbackPlayerDamage]](self, attacker, int(damage * visibility), 0, "MOD_RIFLE_BULLET", "turret_mp", self.origin, vectornormalize(self.origin - selectedBot.origin), "none", 0);
			}
		}
	}
}

/**
*	Approximately calculates the time it takes for a GL-bullet to travel to its target's destination
*	Increases feel of realism
*	@distance Int, The distance the bullet will travel
*	@return Float, The time it will approx. take for the bullet to travel @distance
*/
travelDistance(distance)
{
	// Maxrange: 850, wait ~ 0.5 sec max
	delay = distance / 1600;
	
	// The server can't wait less than 0.05 secs, so we set this as the minimum delay
	if(delay < 0.05)
		delay = 0.05;
		
	return(delay);
}

/**
*	Algorithm of the Grenade Launcher-Turret
*/
shootGL()
{
	// This is a loop, so we want to kill it whenever the turret is being removed
	self endon("death");
	self endon("kill_turret");
	
	shotsFired = 0;
	while(1)
	{
		// First we need a target that our targetAcquisition() algorithm has provided
		if(isDefined(self.targetPlayer))
		{
			// A turret is a mechanical thing, so we wait for its rotation to have finished, before we're actually able to shoot
			self waittill("rotation_done");
			
			for (i = 0; i < self.numBullets; i++)
			{
				// For each bullet we want to shoot, we need to check if the target is still valid, ergo: defined, in view and alive
				if (!isDefined(self.targetPlayer) || self isInView(self.targetPlayer) <= 0 || !isAlive(self.targetPlayer))
					break;
				
				// Calculating the distance between the muzzle and the target's lower body position
				// We want to prevent the turrets from firing too far and too close to themselves
				dist = distance(self getTagOrigin(self.fireTag), self.targetPlayer getTagOrigin("tag_eye") - (0, 0, 36));
				if(dist > self.range || dist < 40)
					break;
				
				// Checks finished, we're firing!
				shotsFired++;
				
				// We play a firing sound and an FX at the muzzle
				self playsound("weap_m203_fire_npc");
				playFx(level._effect["turret_flash"], self getTagOrigin(self.fireTag), anglesToForward(self.angles - (0, 50, 0)));
				
				// Calculate the travel distance from the gun to the target and wait some time
				targetSpot = self.targetPlayer.origin;
				wait travelDistance(dist);
				
				// Since we wait some frames, the target can be disappeared in the mean time. We catch that here and wait one frame
				if(!isDefined(self.targetPlayer))
				{
					wait 0.05;
					continue;
				}
				
				// We play a sound at the impact position and show an impact effect
				thread playSoundOnSpot("clusterbomb_explode_default", targetSpot);
				playFx(level.effect_sentry_hit[self.turret_type], targetSpot);
				
				// All things are done for the turret itself, the only thing left is making the impact damage its surroundings
				self thread glDamage(targetSpot, 195, int(self.minDamage + randomInt(self.maxDamageAdd)), self.owner);
				
				wait self.fireSpeed;
			}
			
			// In case we didn't fire all shots we have per salve, we wait for a fraction of time relative to the actual amount of fired shots
			// We HAVE to wait for at least one frame to prevent an infinite loop, in case the calculated delay is below 0.05s
			if((shotsFired / self.numBullets) * self.cooldown < 0.05)
				wait 0.05;
			else
				wait (shotsFired / self.numBullets) * self.cooldown;
				
			shotsFired = 0;
		}
		// In case we lost our target, we make sure to cool ourselves down for the shots we fired already
		else if (shotsFired > 0)
		{
			wait (shotsFired / self.numBullets) * self.cooldown;
			shotsFired = 0;
		}
		
		wait 0.1;
		resetTimeout();
	}
}

/**
*	Algorithm of the Sentry-Turret (Minigun)
*/
shootMinigun()
{
	// End the algorithm when the turret is removed
	self endon("death");
	self endon("kill_turret");
	
	shotsFired = 0;
	while(1)
	{
		// First we need a target that our targetAcquisition() algorithm has provided
		if(isDefined(self.targetPlayer))
		{
			// Only start firing when the turret is aligned towards the target
			self waittill("rotation_done");
			
			for (i = 0; i < self.numBullets; i++)
			{
				// For each bullet we want to shoot, we need to check if the target is still valid, ergo: defined, in view and alive
				if (!isDefined(self.targetPlayer) || self isInView(self.targetPlayer) <= 0 || !isAlive(self.targetPlayer))
					break;
				
				// Calculating the distance between the muzzle and the target's lower body position
				// We want to prevent the turrets from firing too far and too close to themselves
				dist = distance(self getTagOrigin(self.fireTag), self.targetPlayer getTagOrigin("tag_eye") - (0, 0, 36));
				if(dist > self.range || dist < 40)
					break;
				
				// Checks finished, we're firing!
				shotsFired++;
				
				// We show a shooting effect on the muzzle and an impact effect on the zombie's body plus a firing sound
				playFx(level._effect["turret_flash"], self getTagOrigin(self.fireTag), anglesToForward(self.angles - (0, 50, 0)));
				playFx(level.effect_sentry_hit["minigun"], self.targetPlayer getTagOrigin("tag_eye"));
				self playsound("weap_minigun_fire");
				
				// Effects and checks are done, finally damage the selected target 
				self.targetPlayer thread [[level.callbackPlayerDamage]](self, self.owner, (self.minDamage + randomInt(self.maxDamageAdd)), 0, "MOD_RIFLE_BULLET", "turret_mp", self.origin, vectorNormalize(self.targetPlayer.origin - self.origin), "none", 0);
				
				wait self.fireSpeed;
			}
			
			// In case we didn't fire all shots we have per salve, we wait for a fraction of time relative to the actual amount of fired shots
			// We HAVE to wait for at least one frame to prevent an infinite loop, in case the calculated delay is below 0.05s
			if((shotsFired / self.numBullets) * self.cooldown < 0.05)
				wait 0.05;
			else
				wait (shotsFired / self.numBullets) * self.cooldown;
				
			shotsFired = 0;
		}
		// In case we lost our target, we make sure to cool ourselves down for the shots we fired already
		else if (shotsFired > 0)
		{
			wait (shotsFired / self.numBullets) * self.cooldown;
			shotsFired = 0;
		}
		
		wait 0.1;
		resetTimeout();
	}
}

/**
*	Plays a sound 'sound' at 'origin' rather than on an existing entity
*	Helpful when placing sounds in 3D space
*	@sound String, Sound name
*	@origin Vector, Position the sound should be played at
*/
playSoundOnSpot(sound, origin)
{
	// Spawns an entity at the 'origin' position
	spot = spawn("script_origin", origin);
	
	// Wait until properly initialized
	wait 0.05;
	
	// Play a sound at the location and remove the entity
	spot playsound(sound);
	spot delete();

}

/**
*	Algorithm of all turrets to look for zombies to target
*	TODO: Rename self.targetPlayer to self.targetEntity or something similar
*/
targetAcquisition()
{
	// Shut down this algorithm if the turret gets removed or the owner stops playing
	self.owner endon("joined_spectators");
	self.owner endon("disconnect");
	self endon("death");
	self endon("kill_turret");

	self.targetPlayer = undefined;
	
	while(1)
	{
		// In case all turrets are off, prevent any locks and slowly keep the loop running
		if(level.turretsDisabled)
		{
			self.targetPlayer = undefined;
			wait 1;
			continue;
		}
		
		closestDist = undefined;
		closestPlayer = undefined;
        
		// Loop through all zombies
		for(i = 0; i < level.bots.size; i++)
		{
			bot = level.bots[i];
			
			// Check whether the zombie we target is alive and can be damaged with turrets
			if(bot.sessionstate == "playing" && (bot.type != "boss" || level.bossPhase == 2) && !level.turretsDisabled)
			{
				// Get distance of the currently selected bot
				checkingDistance = self isInView(bot);
				
				// We have a valid distance
				if(checkingDistance >= 0)
				{	
					// If this is the first bot or this bot is closer than any other, save it
					if(!isDefined(closestDist) || (checkingDistance < closestDist && checkingDistance > 40))
					{
						closestDist = checkingDistance;
						closestPlayer = bot;
					}	
				}
			}
		}
		
		// In case our loop found a target that is valid, make it our target
		if(isDefined(closestPlayer))
			self.targetPlayer = closestPlayer;
        
		// Keep ourselves locked on that target until any critical conditions fail
		while(isDefined(closestPlayer) && isAlive(closestPlayer) && (closestPlayer.type != "boss" || level.bossPhase == 2) && closestPlayer.sessionstate == "playing" && self isInView(closestPlayer) >= 0 && !level.turretsDisabled)
		{
			self.targetPlayer = closestPlayer;
			wait 0.05;
		}
		
		// Once one of the conditions above fail, we look for the next target in the next loop
		self.targetPlayer = undefined;
		wait 0.5;
	}
}

/**
*	Function to rotate a turret's head towards its target
*/
rotate()
{
	// This function has to be killed once the turrets or the owner is gone
	self.owner endon("joined_spectators");
	self.owner endon("disconnect");
	self endon("death");
	self endon("kill_turret");

	while(1)
	{
		while(isDefined(self.targetPlayer) && !self.targetPlayer.untargetable)
		{
			// The default rotation time takes 0.4 seconds, hower depending on the distance we de- or increase it slightly
			time = 0.4;
			
			dist = distance(self.origin, self.targetPlayer.origin + (0, 0, 36));
			if(dist <= 200)
				time = 0.35;
			else if(dist <= 70)
				time = 0.45;
			// The target is too far away, so we delay the rotation by 0.1 seconds
			else if(dist > 7000)
			{
				wait 0.1;
				continue;
			}
			
			// Finally make the turret rotate and prepare to notify it being rotated
			aim = vectorToAngles(self.targetPlayer.origin - self.origin);
			self rotateTo((aim[0], aim[1], 0), time);
			self thread notifyRotation(time);
			
			wait 0.05;
		}
		
		wait 0.5;
	}
}

/**
*	We prevent turrets from shooting when not being aligned towards the target
*	This function manually notifies the turret of being rotated once rotateTo has finished
*	@delay Float, Time the rotation will take
*/
notifyRotation(delay)
{
	self.owner endon("disconnect");
	self endon("kill_turret");
	self endon("death");
	self endon("rotation_done");
	
	wait delay;
	self notify("rotation_done");
}

/**
*	@target Entity, Visibility check towards the target
*	@return Float, Returns a distance if target can be seen, otherwise it returns -1
*/
isInView(target)
{
	dist = distanceSquared(self.origin, target.origin);
	if(dist < 400000)
	{
		trace = bulletTrace(self getTagOrigin(self.fireTag), target getEye() , false, self);
		vector = self.origin - target.origin;
		vector = vectorToAngles(vector);
		// We don't only check for the distance, but also for the angle the zombie is at relative to the muzzle to prevent
		// turrets from shooting straight up or down and to control their firing area
   		if(distance(self.origin, target.origin) < 800 && trace["fraction"] == 1 && aSin(anglesToUp(vector)[2]) > (90 - self.maxUpAngle))
			return dist;
	}
	// If all fails, we return -1 which is basically 'false'
	return -1;
}

