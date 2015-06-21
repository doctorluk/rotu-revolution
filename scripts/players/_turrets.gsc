//
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
	precacheModel( level.sentry_turret_model["minigun"] );
	precacheModel( level.sentry_turret_model["gl"] );
	precacheModel( level.sentry_base_model["gl"] );

	level._effect["turret_flash"] = loadFx( "muzzleflashes/heavy" );
	level._effect["augmented"] = loadFx( "turrets/augmented_turret" );
	
	level.effect_sentry_hit["gl"] = loadFx( "explosions/grenadeExp_blacktop" );
	level.effect_sentry_hit["minigun"] = loadFx( "impacts/flesh_hit_body_fatal_exit" );	
	
	level.sentry_laser = loadFx( "misc/sentry_laser" );
	level.turret_broken = loadFx( "smoke/grenade_smoke" );
	
	// Set default turret time
	if( getDvar( "turret_time" ) == "" ) 
		setDvar( "turret_time", 90 );

	// Initialize default vars
	level.turrets = 0;
	level.turrets_held = 0;
	level.turretsDisabled = 0;
	
	turretData();
}

/*
	We save static stats of both types of turrets to refer to them later and to make it easier to
	modify them via config vars and difficulty settings
*/
turretData(){
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

/*
	Gives the calling player a turret
	'augmented' keeps persistency for turrets that have been augmented by the Engineer's special and will be re-placed
*/
giveTurret(turret_type, time, augmented)
{
	// Prevent missing arguments, set default values
	if ( !isDefined( time ) )
		time = 0;
		
	if( !isDefined( augmented ) )
		augmented = false;
	
	// Spawns a script_model (empty) at the position of the player
	self.carryObj = spawn( "script_model", ( 0, 0, 0 ) );
	self.carryObj.origin = self.origin + ( 0, 0, 32 );
	self.carryObj.angles = ( 70, self.angles[1], self.angles[2] );
	self.carryObj.turret_type = turret_type;
	
	// Save the time the turret was already on the field
	self.turret_time = time;
	
	// Debug print for checking whether spawning of the script_model object has failed
	if( !isDefined( self.carryObj ) ){
		iprintln( "^1ERROR: ^7" + self.name + "'s Turret is ^1UNDEFINED^7!" );
		return;
	}
	
	// Link the spawn object with the player, so it sticks and change the invisible model to the actual model
	self.carryObj linkTo( self );
	self.carryObj setModel( level.sentry_turret_model[turret_type] );
	self.carryObj setContents( 2 );
	
	// In case the turret is being removed, we want to handle that, too
	self.carryObj thread onDeath();
	
	// The player is holding an item, make sure he can't use anything else and can't use his weapons
	self.canUse = false;
	self disableweapons();
	
	// Start looping through a placement thread where we check if a player wants to place the turret
	self thread placeTurret( turret_type, augmented );
}

/*
	Handling the removal of turrets that are being held by players
*/
onDeath()
{
	level.turrets_held++;
	
	self waittill( "death" );
	
	level.turrets_held--;
}

/*
	The actual placement loop that monitors the desire of a player to place
	the turret and to check the surroundings for a valid placement position
*/
placeTurret( turret_type, augmented )
{
	// Prevent this loop from being executed if a player isn't valid to use it anylonger
	self endon( "death" );
	self endon( "disconnect" );
	
	// Add a delay from being picked up and being able to place it
	wait 1;
	
	while( 1 )
	{
		// In case we go down while holding a turret, try to place it at our current position before actually removing it from the player
		if( self.isDown ){
			if( self deploy( turret_type, augmented ) )
			{
				self.carryObj unlink();
				wait 0.2;
				self.carryObj delete();
				self.canUse = true;
				self enableWeapons();
				self notify( "placed_turret" );
				return;
			}
			// If there is no valid position, we have to remove it from the player
			// TO-DO: Return upgradepoints to this player equal to the remaining time of the turret times the cost of it to compensate for the loss
			else{
				self.carryObj unlink();
				wait 0.2;
				self.carryObj delete();
				self.canUse = true;
				self enableWeapons();
				return;
			}
		}
		// Check if a player is trying to place it
		else if( self attackButtonPressed() && self isOnGround() )
		{	
			if ( self deploy( turret_type, augmented ) )
			{
				self.carryObj unlink();
				wait 0.2;
				self.carryObj delete();
				self.canUse = true;
				self enableWeapons();
				self notify( "placed_turret" );
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

/*
	Returns whether a turret is placeable at the current position and places it, if a valid position has been found
*/
deploy( turret_type, augmented )
{
	// Another thread that we don't want happening if the player disconnects or dies
	self endon( "disconnect" );
	self endon( "death" );
	
	// We get the player's orientation and draw a line in front of him that we will check
	angles = self getPlayerAngles();
	start = self.origin + ( 0, 0, 40 ) + vectorScale( anglesToForward( angles ), 20 );
	end = self.origin + ( 0, 0, 40 ) + vectorScale( anglesToForward( angles ), 38 );
	
	// We get the left, right and back area coordinates relative to the player's position
	left = vectorScale( anglesToRight( angles ), -10 );
	right = vectorScale( anglesToRight( angles ), 10 );
	back = vectorScale( anglesToForward( angles ), -6 );

	// Multiple checks are being run if we have a clean area in front of us and to the sides
	canPlantThere1 = BulletTracePassed( start, end, true, self );
	canPlantThere2 = BulletTracePassed( start + ( 0, 0, -7 ) + left, end + left + back, true, self );
	canPlantThere3 = BulletTracePassed( start + ( 0, 0, -7 ) + right , end + right + back, true, self );
	
	// If any of these checks fail, we report that it's not working and start over
	if( !canPlantThere1 || !canPlantThere2 || !canPlantThere3 )
	{
		self iPrintlnBold( "Can not deploy ^2defence turret ^7here." );
		return false;
	}

	// If, however, we find a valid place, we run a trace to determine the ground position in front of us to place it at
	trace = bulletTrace( end + (0,0,100), end - (0,0,300), false, self );
	
	// During scary waves, the turrets are deactivated. If turrets are active however, we play a sound
	if( !level.turretsDisabled )
		self playsound( "turret_activate" );
		
	// We call the turret upon us in the found position!
	self thread defenceTurret( turret_type, trace["position"], ( 0, angles[1], 0), augmented );
	return true;
}

/*
	Here we spawn the actual turret at the given permission and assign the turret_type's values
*/
defenceTurret( turret_type, pos, angles, augmented )
{
	// Since there's another wait in this thread, we make sure to not run into problems and kill it if the turret dies during initialization
	self endon("kill_turret");

	level.turrets++;
	offset = ( 0, 0, 0 );
	iprintln( "^2" + self.name + " ^2deployed a " + turret_type + " turret." );
	// The GL turret 'head' has to be moved up a little, so it stands on its base
	if( turret_type == "gl" )
		offset = (0,0,20);
	
	// Spawn the default models, assign the given turret_type models and hide necessary parts
	self.turret_gun = spawn( "script_model", pos + offset);
	self.turret_bipod = spawn( "script_model", pos );

	self.turret_gun setModel( level.sentry_turret_model[turret_type] );
	self.turret_bipod setModel( level.sentry_base_model[turret_type] );
	
	if(turret_type == "minigun"){
		self.turret_gun thread hideLowerParts();
		self.turret_bipod hideUpperParts();
	}

	self.turret_gun setContents( 0 );
	self.turret_bipod setContents( 0 );

	self.turret_gun.angles = angles + (0,50,0);
	self.turret_bipod.angles = angles;

	self.turret_gun.owner = self;
	self.turret_gun.turret_type = turret_type;

	// Give these turrets the previously defined static stats
	if( self.turret_gun.turret_type == "gl" )
	{
		self.turret_gun.fireSpeed = level.turretData["gl"].firespeed;
		self.turret_gun.numBullets = level.turretData["gl"].numbullets;
		self.turret_gun.minDamage = level.turretData["gl"].mindamage;
		self.turret_gun.maxDamageAdd = level.turretData["gl"].maxdamageadd;
		self.turret_gun.range = level.turretData["gl"].range;
		self.turret_gun.maxUpAngle = level.turretData["gl"].maxupangle;
		self.turret_gun.cooldown = level.turretData["gl"].cooldown;
		self.turret_gun.fireTag = level.turretData["gl"].firetag;
	}

	if( self.turret_gun.turret_type == "minigun" )
	{
		self.turret_gun.fireSpeed = level.turretData["minigun"].firespeed;
		self.turret_gun.numBullets = level.turretData["minigun"].numbullets;
		self.turret_gun.minDamage = level.turretData["minigun"].mindamage;
		self.turret_gun.maxDamageAdd = level.turretData["minigun"].maxdamageadd;
		self.turret_gun.range = level.turretData["minigun"].range;
		self.turret_gun.maxUpAngle = level.turretData["minigun"].maxupangle;
		self.turret_gun.cooldown = level.turretData["minigun"].cooldown;
		self.turret_gun.fireTag = level.turretData["minigun"].firetag;
	}
	
	if( !isDefined( augmented ) )
		augmented = false;
	
	// Start the actual threads for the turrets, enemy-detection, rotation and shooting algorithms
	self.turret_gun.isTurret = true;
	self.turret_gun thread CheckForPlayers();
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
	if( augmented )
		self.turret_gun goAugmented();
	else
		self.turret_gun.isAugmented = false;
	
	// What did they say? Give cheese time? We do the same with these turrets, before we make them movable again
	wait 1;
	
	// Make the turret pick-up-able (is that even a word?)
	self scripts\players\_usables::addUsable(self.turret_gun, "turret", &"USE_TURRET", 96 );
	
	// Give turrets an extended duration on the field if you've unlocked the Engineer's ability
	if( self.longerTurrets )
		duration = level.dvar["game_turret_time"] * 1.4;
	else
		duration = level.dvar["game_turret_time"];
	
	// Thread to remove the turrets after a certain time, or when the player has left the active game
	level thread deleteTurretInTime( self.turret_gun, self.turret_bipod, duration - self.turret_gun.timePassed, self.turret_gun.turret_type, self );
	level thread deleteTurretOnDC( self.turret_gun, self.turret_bipod, duration - self.turret_gun.timePassed );
}

/*
	Hides gun-part of Sentry Gun
*/
hideUpperParts()
{
	self hidePart("tag_aim");
	self hidePart("tag_aim_pitch");
	self hidePart("tag_spin");
}

/*
	Hides bipod-part of Sentry Gun
*/
hideLowerParts()
{
	// Since we need to wait for the FX to spawn,
	// we make sure that this entity doesn't suddenly despawn within 0.05 secs (how high is the chance though?)
	self endon("death");
	
	self hidePart("bi_base");
	wait 0.05;
	playFXonTag( level.sentry_laser, self, "tag_flash" );
}

/*
	Engineer's Special -> Boosts the default stats of the calling turret
*/
goAugmented()
{
	type = self.turret_type;
	
	switch( type ){
		case "gl":
			self.fireSpeed = level.turretData[type].firespeed / 2;
			self.numBullets = level.turretData[type].numbullets + 2;
			self.range = level.turretData[type].range + 200;
			self.cooldown = level.turretData[type].cooldown * 0.8;
			self.isAugmented = true;
			self thread scripts\players\_turrets::createEffectEntity( level._effect["augmented"], "tag_origin", "augmented" );
			self.owner iprintln("^3Augmenting ^7GL turret!");
			break;
		case "minigun": 
			self.numBullets = level.turretData[type].numbullets * 2;
			self.maxDamageAdd = level.turretData[type].maxdamageadd * 2;
			self.range = level.turretData[type].range + 300;
			self.cooldown = level.turretData[type].cooldown * 0.5;
			self.isAugmented = true;
			self thread scripts\players\_turrets::createEffectEntity( level._effect["augmented"], "tag_origin", "augmented" );
			self.owner iprintln("^3Augmenting ^7Sentry turret!");
			break;
		default:
			iprintlnbold("^1ERROR: ^7Wrong turret type for Engineer special!");
			break;
	}
}

/*
	Deleted the turret after it has reached the max. duration on the field
*/
deleteTurretInTime( gun, bipod, time, type, owner )
{
	// Prevent this from executing if any of the turret is removed
	gun endon( "death" );
	bipod endon( "death" );
	
	wait time;
	if( isDefined( owner ) )
		owner iPrintLn( "Your " + type + " turret timed out!" );
		
	thread deleteTurret( gun, bipod );
}

deleteTurretOnDC(gun, bipod, time)
{
	// Prevent this from executing if any of the turret is removed
	gun endon( "death" );
	bipod endon( "death" );
	
	// If the owner stopped participating in the game, remove it
	gun.owner waittill_any( "disconnect", "join_spectator");
	thread deleteTurret( gun, bipod );
}

/*
	When the scary wave is running, the turrets show an animation of being disabled and stop firing
*/
disableEffects()
{
	// Since this is a timed thread, we want it to stop if the turret breaks or the game ends
	self endon( "death" );
	level endon( "game_ended" );
	
	if( !level.turretsDisabled ){
		level waittill( "turrets_disabled" );
		// Add some randomness to the disable animation - prevents all turrets from breaking down at the same time
		wait randomfloat( 2 );
	}
	// Shows and plays the desired effects to display its broken state
	self playsound( "turret_broken" );
	self createEffectEntity( level.turret_broken, self.fireTag, "broken" );
	self moveDisabledPosition();
	
	// There is a time after being disabled, start here
	self thread enableAgain();
}

/*
	Moves the turret's head downwards, so it either looks sad and broken
*/
moveDisabledPosition()
{
	currentAngle = self.angles;
	
	if( self.turret_type == "gl" )
		self rotateto( ( 50, currentAngle[1], 0 ), 3 );
	else
		self rotateto( ( 15, currentAngle[1], 0 ), 3 );
}

/*
	Enables disabled turrets with an animation
*/
enableAgain()
{
	// A waiting function, so we want it to terminate if anything bad happens
	self endon( "death" );
	level endon( "game_ended" );
	
	// Wait for turrets to be enabled
	level waittill( "turrets_enabled" );
	
	currentAngle = self.angles;
	
	// Remove disabled effect and move it back to its default position
	if( isDefined( self.effect["broken"] ) )
		self.effect["broken"] delete();
	self rotateto( ( 0, currentAngle[1], 0 ), 3, 0.5, 2 );
	
	// Prepare it to be disabled again
	wait 3;
	self thread disableEffects();
}

/*
	Creates an augmentation or broken effect at the given position
*/
createEffectEntity( effect, origin, type )
{
	// Fail-safe definition of an effect var
	if( !isDefined( self.effect ) )
		self.effect = [];
		
	// Make sure to remove any effect if one is existing
	if( isDefined( self.effect[type] ) )
		self.effect[type] delete();
	
	// When working with effects, we most likely have a wait. Just like here, so we want it to be stopped if it's not there anymore
	self endon( "death" );
	
	// Augmentation and broken effects are spawned differently, so we do distinguish them here
	if( type == "augmented" )
	{
		self.effect[type] = spawnFx( effect, self.origin, ( 0, 0, 1 ), ( 1, 0, 0 ) );
		triggerFx( self.effect[type] );
	}
	else
	{
		self.effect[type] = spawn( "script_model", self getTagOrigin( origin ) );
		self.effect[type] setModel( "tag_origin" );
		wait 0.05;
		PlayFXOnTag( effect, self.effect[type], "tag_origin" );
		self.effect[type] LinkTo( self );
	}
}

/*
	Removes a turret from the field
*/
deleteTurret( gun, bipod )
{
	// Removes the ability to re-place the turret from the turret's owner
	if ( isDefined( gun.owner ) )
		gun.owner scripts\players\_usables::removeUsable( gun );
		
	level.turrets--;
	
	// Remove the turret and its effects, play a sound of it being destroyed
	if( isDefined( gun.effect ) )
	{
		if( isDefined( gun.effect["broken"] ) )
			gun.effect["broken"] delete();
		if( isDefined( gun.effect["augmented"] ) )
			gun.effect["augmented"] delete();
	}
	
	gun playsound( "turret_deactivate" );
	
	bipod delete();
	gun delete();
}

/*
	Firing algorithm of the GL-Turret
*/
glDamage(targetSpot, range, damage, attacker)
{
	// Loop through all existing bots
	for ( i = 0 ; i < level.bots.size; i++ )
	{
		selectedBot = level.bots[i];
		
		// See if the currently selected bot is valid and can be targeted
		if ( isDefined( selectedBot ) && isAlive( selectedBot ) && !selectedBot.untargetable )
		{
			distance = distance( targetSpot, selectedBot.origin );
			// In case that bot is within range and can be seen, apply damage
			if ( distance <= range )
			{
				visibility = selectedBot sightConeTrace( targetSpot, selectedBot );
				if( visibility != 0 )
					// Apply damage
					selectedBot thread [[level.callbackPlayerDamage]](self, attacker, int(damage * visibility), 0, "MOD_RIFLE_BULLET", "turret_mp", self.origin, vectornormalize(self.origin - selectedBot.origin), "none", 0);
			}
		}
	}
}

/*
	Approximately calculates the time it takes for a GL-bullet to travel to its target's destination
	Increases feel of realism
*/
travelDistance( distance )
{
	// Maxrange: 850, wait ~ 0.5 sec max
	delay = distance / 1600;
	
	// The server can't wait less than 0.05 secs, so we set this as the minimum delay
	if( delay < 0.05 )
		delay = 0.05;
		
	return( delay );
}

/*
	Algorithm of the Grenade Launcher-Turret
*/
shootGL()
{
	// This is a loop, so we want to kill it whenever the turret is being removed
	self endon( "death" );
	self endon( "kill_turret" );
	
	shotsFired = 0;
	while( 1 )
	{
		// First we need a target that our CheckForPlayers() algorithm has provided
		if( isDefined( self.targetPlayer ) )
		{
			// A turret is a mechanical thing, so we wait for its rotation to have finished, before we're actually able to shoot
			self waittill("rotation_done");
			for ( i = 0; i < self.numBullets; i++ )
			{
				// For each bullet we want to shoot, we need to check if the target is still valid, ergo: defined, in view and alive
				if ( !isDefined( self.targetPlayer ) || self isInView( self.targetPlayer ) <= 0 || !isAlive( self.targetPlayer ) )
					break;
				
				// Calculating the distance between the muzzle and the target's lower body position
				// We want to prevent the turrets from firing too far and too close to themselves
				dist = distance( self getTagOrigin(self.fireTag), self.targetPlayer getTagOrigin("tag_eye") - (0,0,36) );
				if( dist > self.range || dist < 40 )
					break;
				
				// Checks finished, we're firing!
				shotsFired++;
				
				// We play a firing sound and an FX at the muzzle
				self playsound( "weap_m203_fire_npc" );
				playFx( level._effect["turret_flash"], self getTagOrigin( self.fireTag ), anglesToForward( self.angles - ( 0, 50, 0 ) ) );
				targetSpot = self.targetPlayer.origin;
				wait travelDistance(dist);
				
				if( !isDefined( self.targetPlayer ) ){
					wait 0.05;
					continue;
				}
				
				
				thread playSoundOnSpot("clusterbomb_explode_default", targetSpot);
				playFx( level.effect_sentry_hit[self.turret_type], targetSpot );

				self thread glDamage(targetSpot, 195, int(self.minDamage + randomInt(self.maxDamageAdd)), self.owner);
				
				wait self.fireSpeed;
			}
			
			if( (shotsFired / self.numBullets) * self.cooldown < 0.05 )
				wait 0.05;
			else
				wait (shotsFired / self.numBullets) * self.cooldown;
				
			shotsFired = 0;
		}
		else if (shotsFired > 0) {
			wait (shotsFired / self.numBullets) * self.cooldown;
			shotsFired = 0;
		}
		wait .1;
		resettimeout();
	}
}

shootMinigun()
{
	self endon("death");
	self endon("kill_turret");
	shotsFired = 0;
	while(1)
	{
		if( isDefined( self.targetPlayer ) )
		{
			self waittill("rotation_done");
			for ( i = 0; i < self.numBullets; i++ ) {
				if (!isDefined(self.targetPlayer) || self isInView(self.targetPlayer) <= 0 || !isAlive(self.targetPlayer))
					break;
				
				dist = distance( self getTagOrigin(self.fireTag), self.targetPlayer getTagOrigin("tag_eye") - (0,0,36) );
				if(dist > self.range || dist < 40)
					break;
				
				shotsFired++;
				playFx( level._effect["turret_flash"], self getTagOrigin(self.fireTag), anglesToForward( self.angles - (0,50,0) ) );
				playFx( level.effect_sentry_hit["minigun"], self.targetPlayer getTagOrigin("tag_eye") );
				self playsound("weap_minigun_fire");

				self.targetPlayer thread [[level.callbackPlayerDamage]](self, self.owner, (self.minDamage + randomInt(self.maxDamageAdd)), 0, "MOD_RIFLE_BULLET", "turret_mp", self.origin, vectornormalize(self.targetPlayer.origin - self.origin), "none", 0);
				
				wait self.fireSpeed;
			}
			// if(shotsFired == self.numBullets)
				// playFx(level._effect["overheat"], self getTagOrigin("tag_flash"));
			if( (shotsFired / self.numBullets) * self.cooldown < 0.05 )
				wait 0.05;
			else
				wait (shotsFired / self.numBullets) * self.cooldown;
				
			shotsFired = 0;
		}
		else if (shotsFired > 0) {
			wait (shotsFired / self.numBullets) * self.cooldown;
			shotsFired = 0;
		}
		wait .1;
		resettimeout();
	}
}

playSoundOnSpot(sound, origin){

	spot = spawn( "script_origin", origin);
	wait 0.05;
	spot playsound(sound);
	spot delete();

}

CheckForPlayers()
{
	self endon("joined_spectators");
	self endon("disconnect");
	self endon("death");
	self endon("kill_turret");

	self.targetPlayer = undefined;
	while(1)
	{  
		if(level.turretsDisabled){
			self.targetPlayer = undefined;
			wait 1;
			continue;
		}
		closestDist = undefined;
		closestPlayer = undefined;
                  

		for(i = 0; i < level.bots.size; i++)
		{
			bot = level.bots[i];

			if( bot.sessionstate == "playing" && (bot.type != "boss" || level.bossPhase == 2) && !level.turretsDisabled)
			{
				res = self IsInView(bot);
				if(res >= 0)
				{	
		
					if(!isDefined(closestDist) || (res < closestDist && res > 40))
					{
			 
						closestDist = res;
						closestPlayer = bot;
					}	
				}
			}
		}

		if(isDefined(closestPlayer))
			self.targetPlayer = closestPlayer;
         
		while(isDefined(closestPlayer) && isAlive(closestPlayer) && (closestPlayer.type != "boss" || level.bossPhase == 2 ) && closestPlayer.sessionstate == "playing" && self IsInView(closestPlayer) >= 0 && !level.turretsDisabled)
		{
		
			self.targetPlayer = closestPlayer;
			wait 0.05;
		}

		self.targetPlayer = undefined;
             
		wait 0.5;
	}
}

rotate()
{
	self endon("joined_spectators");
	self endon("disconnect");
	self endon("death");
	self endon("kill_turret");

	while(1)
	{
		while( isDefined(self.targetPlayer) && !self.targetPlayer.untargetable )
		{
			time = 0.4;
			dist = distance( self.origin, self.targetPlayer.origin + (0,0,36) );
			if( dist <= 200 )
				time = 0.35;
			else if( dist <= 70 )
				time = 0.45;
			else if(dist > 7000){
				wait 0.1;
				continue;
			}

			aim = vectortoangles( self.targetPlayer.origin - self.origin );
			// self rotateto( (aim[0], aim[1]+50, 0), time );
			self rotateto( (aim[0], aim[1], 0), time );
			self thread notifyRotation(time);
			wait 0.05;
		}
		wait 0.5;
	}
}


notifyRotation(delay){
	self endon("kill_turret");
	self endon("death");
	self endon("disconnect");
	self endon("rotation_done");
	
	wait delay;
	self notify("rotation_done");
}

IsInView(target)
{
	dist = distanceSquared( self.origin, target.origin );
	if(dist < 400000)
	{
		trace = bullettrace( self getTagOrigin(self.fireTag) , target getEye() , false, self );
		vector = self.origin - target.origin;
		vector = vectorToAngles(vector);
   		if( distance( self.origin, target.origin ) < 800 && trace["fraction"] == 1 && aSin(anglesToUp(vector)[2]) > (90 - self.maxUpAngle) )
			return dist;
	}
	return -1;
}

