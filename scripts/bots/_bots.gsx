/**
* vim: set ft=cpp:
* file: scripts\bots\_bots.gsc
*
* authors: Luk, 3aGl3, Bipo, Etheross
* team: SOG Modding
*
* project: RotU - Revolution
* website: http://survival-and-obliteration.com/
*
* Reign of the Undead - Revolution by Luk and 3aGl3
* You may modify this code to your liking or reuse it, as long as you give credit to those who wrote it
* Based on Reign of the Undead 2.1 created by Bipo and Etheross
*/

/***
*
*	TODO: Add file description
*
*/

#include scripts\include\waypoints;
#include scripts\include\entities;
#include scripts\include\physics;
#include scripts\include\hud;

/**
* Loads all zombie elements
*/
init()
{
	// declare all bot variables
	level.bots = [];					// array of known bots
	level.slowBots = 1;					// chance bots won't run, decreases after waves
	level.botsAlive = 0;				// number of bots currently alive
	level.botsLoaded = 0;				// number of bots connected to the server
	level.freezeBots = false;			// freeze all bots
	level.bossIsOnFire = false;			// TODO move this to the boss zombie, if possible
	level.silenceZombies = false;		// disable zombie sound

	// precache zombie weapons
//	precacheItem( "dog_mp" );
//	precacheItem( "flash_grenade_mp" );			// zombie_mp
//	precacheItem( "concussion_grenade_mp" );	// crawler_mp
	
	// precache additional models
	precacheModel( "santa_hat" );

	precacheShellshock( "boss" );
	precacheShellshock( "toxic_gas_mp" );
	// preCacheShellshock("frag_grenade_mp");

	// load all zombie effects
	level.burningFX = loadfx("fire/firelp_med_pm_atspawn");
	// level.burningdogFX = loadfx("fire/dog_onfire");
	level.bossFireFX = loadfx("fire/boss_onfire");
	level.bossShockwaveFX = loadfx("zombies/boss_shockwave");
	
	level.napalmTummyGlowFX = loadfx("misc/napalm_zombie_tummyglow");
	// level.lightningdogFX = loadfx("light/dog_lightning");
	level.toxicFX = loadfx("misc/toxic_gas");
	level.soulFX = loadfx("misc/soul");
	level.groundSpawnFX = loadfx("misc/ground_rising");
	// level.cloudSpawnFX = loadfx("zombies/thunderspawn");
	level.soulspawnFX = loadfx("misc/soulspawn");
	level.incendiaryFX = loadfx("misc/zombie_incendiary_effect");
	level.poisonedFX = loadfx("misc/zombie_poison_effect");
	level.righteyeFX = loadfx("zombies/eye_glow_ri"); 
	level.lefteyeFX = loadfx("zombies/eye_glow_le");
	
	level._effect["zom_explode"] = loadFX( "explosions/pyromaniac" );
	
	// blood and gore splatters
	level._effect["zom_gib_expl"] = loadFx( "gibbing/zombie1_explode" );
	level._effect["zom_gib_head"] = loadFx( "gibbing/zombie1_head" );
	level._effect["zom_gib_larm"] = loadFx( "gibbing/zombie1_larm" );
	level._effect["zom_gib_lleg"] = loadFx( "gibbing/zombie1_lleg" );
	level._effect["zom_gib_rarm"] = loadFx( "gibbing/zombie1_rarm" );
	level._effect["zom_gib_rleg"] = loadFx( "gibbing/zombie1_rleg" );
	
	// init bot realated scripts
	thread loadWaypoints();
	thread scripts\bots\_types::init();
	thread scripts\bots\_debug::init();

	// pathfinding debugging
	// NOTE this is more or less obsolete with the lua plugin on 1.8
	level.botsLookingForWaypoints = 0;			// number of bots runnuing A* at the moment
	if( getDvar( "max_waypoint_bots" ) == "" )
		setDvar( "max_waypoint_bots", 10 );		// max number of bots running A* at the moment

	// wait for reconnecting bots
	wait 1;
	
	// create desired number of bots
	thread loadBots( level.dvar["bot_count"] - level.botsLoaded );
	
	thread onMonkeyExplosion();				// TODO rework this, possibly part of AI
}	/* init */

// LOADING BOTS

/**
* Creates the given amount of bots
*/
loadBots( amount )
{
	// check if bots are already loaded
	if( amount < 0 )
	{
		level notify( "bots_loaded" );
		return;
	}

	for( i=0; i<amount; i++ )
	{
		bot = addTestClient();
		if( !isDefined(bot) )
		{
			printLn( "Could not add bot!" );
			i--;
			
			wait 1;
			continue;
		}
		
		// initialize the bot
		bot loadBot();
		level.botsLoaded++;
	}

	level notify( "bots_loaded" );
}	/* loadBots */

/**
* Initializes the client as a bot
*/
loadBot()
{
	// put the bot into the bots array
	level.bots[level.bots.size] = self;

	// flag the bot as such and as not spawned
	self.isBot = true;
	self.hasSpawned = false;
	
	// wait until the bot has properly connected
	while( !isDefined(self.pers["team"]) )
		wait .05;
	
	// push the bot into the axis team
	self.team = "axis";
	self.sessionteam = self.team;
	self.pers["team"] = self.team;

	wait .1;

	// mark the bot, in case he reconnects
	self setStat( 512, 100 );
	
	// disable the rank icon by setting an invalid rank
	self setRank( 255, 0 );
}	/* loadBot */

/**
* Returns a currently available bot
*/
getAvailableBot()
{
	// go through all bots
	for( i=0; i<level.bots.size; i++ )
	{
		// return the bot, if it's hasSpawned flag isn't set
		if( level.bots[i].hasSpawned == false )
			return level.bots[i];
	}
}	/* getAvailableBot */

/**
* Spawns a partner bot for huge bosses
*/
spawnPartner(spawnpoint, bot)
{
	// TODO we can hopefully get rid of this...
	/*
	type = "boss";
	bot.hasSpawned = true;
	bot.currentTarget = undefined;
	bot.targetPosition = undefined;
	bot.type = type;
	bot.head = undefined;

	bot.sessionstate = "playing";
	bot.spectatorclient = -1;
	bot.killcamentity = -1;
	bot.archivetime = 0;
	bot.psoffsettime = 0;
	bot.statusicon = "";
	bot.untargetable = true;
	bot.isZombie = false;
	bot.wasInfluencedByMonkeyBomb = false;
	bot.influencedByMonkeyBomb = undefined;
	bot.suicided = undefined;
	bot.damagePerLoc = [];
	bot scripts\bots\_types::loadZomStats(type);
	bot.damageMod = 1;
	bot.maxHealth = int(bot.maxHealth * level.dif_zomHPMod);
	
	bot.health = bot.maxHealth;
	
	bot.damagedBy = [];
	bot.myWaypoint = undefined;
	bot.underway = false;
	bot.canTeleport = true;
	bot.quake = false;
	bot.isOnFire = false;
	bot.isPoisoned = false;
	bot.playIdleSound = true;
	if(randomfloat(1) > bot.sprintChance)
		bot.sprinting = false;
	else
		bot.sprinting = true;
	
	bot scripts\bots\_types::loadAnimTree(type);
	
//	bot.animWeapon = bot.animation["stand"];
	bot TakeAllWeapons();
//	bot.pers["weapon"] = bot.animWeapon;
	bot giveWeapon( bot.pers["weapon"] );
	bot giveMaxAmmo( bot.pers["weapon"] );
	bot setSpawnWeapon( bot.pers["weapon"] );
	bot switchToWeapon( bot.pers["weapon"] );

	if (isdefined(spawnpoint.angles))
		bot spawn(spawnpoint.origin, spawnpoint.angles);
	else
		bot spawn(spawnpoint.origin, (0,0,0));
	
	level.botsAlive++;
	
	wait 0.05;
	
	bot detachAll();
	bot.head = "";
	bot setmodel("player_sp_rig_empty");
	
	bot freezeControls(true);
	
	bot.linkObj.origin = bot.origin;
	bot.linkObj.angles = bot.angles;
	
	
	wait 0.05;
	bot linkto(bot.parent.attachment);
//	bot setanim("stand");
	
	bot thread rotateWithParent();
	*/
}	/* spawnPartner */

rotateWithParent(){
	self endon("death");
	self.parent endon("death");

	level endon("wave_finished");
	level endon("game_ended");

	while( isDefined(self) && isDefined(self.parent) )
	{
		self setPlayerAngles( self.parent.angles );
		wait 0.05;
	}
}	/* rotateWithParent */

/**
* Spawn a bot as the given type at the given spawnpoint
*
*	@param type, String zombie type to spawn
*	@param spawnpoint, Spawnpoint to spawn the zombie at
*	@param bot, Bot entity to use as zombie
*/
spawnZombie( type, spawnpoint, bot )
{
	if( level.gameState != "running" )
		return;
		
	// aquire a free bot if required
	if( !isDefined(bot) )
	{
		bot = getAvailableBot();
		if( !isDefined(bot) )	// nothing we can do without a bot
			return;
	}

	// apply the zombie type and mark as used
	bot.type = type;
	bot.hasSpawned = true;

	// apply cod sessionstate and killcam variables
	bot.sessionstate = "playing";
	bot.spectatorclient = -1;		// TODO is this really needed?
	bot.killcamentity = -1;
	bot.archivetime = 0;
	bot.psoffsettime = 0;
	bot.statusicon = "";

	// reset flags
	bot.god = undefined;			// godmode, used for boss partners
	bot.quake = false;				// earthquakes while walking
	bot.suicided = undefined;		// flag to check if a bot suicided, to control death effects
	bot.isOnFire = false;			// burned by a player
	bot.isPoisoned = false;			// poisoned by player
	
	bot.damagedBy = [];				// damage tracking for assists
	bot.damagePerLoc = [];			// damage tracking for gibbing
	
	bot.isZombie = false;			// infected player tracking
	bot.untargetable = false;		// allow turret tracking

	bot.damageMod = 1;				// damage modifier for spawn protection

	// reset AI values
	bot.zRage = 0;
	bot.zInterest = 0;
	bot.zWaypoint = undefined;
	bot.zOnGrid = false;
	bot.zTarget = undefined;
	bot.zTargetOrigin = undefined;
	bot.zTargetWaypoint = undefined;
	bot.zTargetOverride = false;

	// apply the selected types data
	bot scripts\bots\_types::loadZomType();
	bot scripts\bots\_types::loadZomWeapon();
	
	// randomly pick movement speed based on run- and sprintChance
	bot.zMovetype = "walk";
	if( !isDefined(self.walkOnly) )
	{
		if( randomFloat(1) > bot.runChance )
			bot.zMovetype = "run";
		else if( randomFloat(1) > bot.sprintChance )
			bot.zMovetype = "sprint";
	}
	
	// spawn the bot out of sigth to prevent looking at the sky
	bot spawn( (spawnpoint.origin[0],spawnpoint.origin[1],-10000), (0,0,0) );
	
	// apply a zombie model
	bot scripts\bots\_types::loadZomModel();
	
	// stop all bot actions
	bot botStop();
	
	// apply the animation weapon
	bot TakeAllWeapons();
	bot giveWeapon( bot.pers["weapon"] );
	bot giveMaxAmmo( bot.pers["weapon"] );
	bot setSpawnWeapon( bot.pers["weapon"] );
	bot switchToWeapon( bot.pers["weapon"] );
	
	// increase bots alive counter
	level.botsAlive++;
	if( bot.type == "halfboss" )
		level.bossBulletCount++;
	
	// wait for the bot to spawn
	wait 0.05;
	
	// apply spawnprotection if necessary
	if( level.dvar["zom_spawnprot"] && ((bot.type != "tank" && bot.type != "boss") || level.dvar["zom_spawnprot_tank"]) )
	{
		bot.damageMod = 0;
		bot thread endSpawnProtection( level.dvar["zom_spawnprot_time"], level.dvar["zom_spawnprot_decrease"] );
	}
	
	// apply effects to the zombie
	bot scripts\bots\_types::onSpawn( type );
	
	// 'spawn' the bot at the given spawnpoint
	bot setOrigin( spawnpoint.origin );
	if( isDefined(spawnpoint.angles) )
		bot setPlayerAngles( spawnpoint.angles );
	
	// start zombie AI thread
	bot thread zThink();

	return bot;
}	/* spawnZombie */

/**
* Disables or fades out the spawn protection
*/
endSpawnProtection( time, decrease )
{
	self endon( "death" );

	// fade out the spawn protection
	if( decrease )
	{
		for (i=0; i<10; i++)
		{
			wait time/10;
			self.damageMod += .1;
		}
	}
	else	// disable spawn protection after time
	{
		wait time;
		self.damageMod = 1;
	}
}	/* endSpawnProtection */

/**
* Calculates and applies the damage done to bots.
*
*	@eInflictor: Entity that dealth the damage
*	@eAttacker: Player entity that is responsible for the damage
*	@iDamage: Integer, base amount of damage dealth
*	@iDFlags: Integer, damage flags applied describing the type of damage
*	@sMeansOfDeath: String, type of damage
*	@sWeapon: String, name of the weapon
*	@vPoint: Vector, point of impact
*	@vDir: Vector, direction of impact
*	@sHitLoc: String, name of the hit location
*	@psOffsetTime: Float, time to wait before the damage is done???
*/
Callback_BotDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	// don't damage bots that are immune or dead/spectating
	if( !isAlive(self) || isDefined(self.god) || self.sessionteam == "spectator" )
		return;

	// don't damage other bots
	if( eAttacker.isBot )
		return;

	// disable damage on missing limbs
	if( ( (self.legStatus == 1 || self.legStatus == 3) && (sHitLoc == "left_leg_lower" || sHitLoc == "left_foot") ) ||		// left leg missing
		( (self.legStatus == 2 || self.legStatus == 3) && (sHitLoc == "right_leg_lower" || sHitLoc == "right_foot") ) ||	// right leg missing
		( (self.bodyStatus == 1 || self.bodyStatus == 3) && (sHitLoc == "left_arm_lower" || sHitLoc == "left_hand") ) ||	// left arm missing
		( (self.bodyStatus == 2 || self.bodyStatus == 3) && (sHitLoc == "right_arm_lower" || sHitLoc == "right_hand") ) )	// right arm missing
		return;
		
	// don't damage bots that are immune to this type of damage
	if( !self scripts\bots\_types::onDamage( self.type, sMeansOfDeath, sWeapon, iDamage, eAttacker ) )
		return;

	// Apply the player related damage calculations
	if( isDefined(eAttacker) && isPlayer(eAttacker) )
	{
		// Explosive Crossbow sticking to the zombie
		if( sMeansofDeath == "MOD_IMPACT" && (sWeapon == "crossbow_explosive_mp" || sWeapon == "semtex_grenade_mp") )
		{
			eInflictor followTarget( self, (eInflictor.origin - self.origin) );
			return;
		}
		
		// Special Recharge Armored -> KNIFE
		if( eAttacker.curClass == "armored" && !eAttacker.isDown && sMeansOfDeath == "MOD_MELEE" )
		{
			if( iDamage > self.health )
				eAttacker scripts\players\_abilities::rechargeSpecial( self.health/25 );
			else
				eAttacker scripts\players\_abilities::rechargeSpecial( iDamage/25 );
		}
		
		if( !isDefined(iDamage) || !isDefined(eAttacker scripts\players\_abilities::getDamageModifier(sWeapon, sMeansOfDeath, self, iDamage)) || !isDefined(self.damageMod) )
		{
			logPrint("LUK_DEBUG; Definition: iDamage: " + isDefined(iDamage) + ", getDamageModifier: " + isDefined(eAttacker scripts\players\_abilities::getDamageModifier(sWeapon, sMeansOfDeath, self, iDamage)) + ", self.damageMod: " + isDefined(self.damageMod) + ", weapon: " + sWeapon + "\n");
			return;
		}
		
		iDamage = int(iDamage * eAttacker scripts\players\_abilities::getDamageModifier(sWeapon, sMeansOfDeath, self, iDamage) * self.damageMod);
		
		eAttacker notify( "damaged_bot", self );
		
		if( isDefined(eInflictor.isTurret) && eInflictor.isTurret && isDefined(eInflictor.owner) )
			eAttacker scripts\players\_damagefeedback::updateTurretDamageFeedback();
		else
			eAttacker scripts\players\_damagefeedback::updateDamageFeedback();
		
		// prepare an assist, if this is not a turned player
		if( self.isBot )
			self addToAssist( eAttacker, iDamage );
		
		// enrage the zombie
		if( self.zRage == 0 || (isDefined(self.zTarget) && eAttacker == self.zTarget) )
		{
			self.zRage += 1;
			
			// set as target, if we don't have one
			if( !isDefined(self.zTarget) )
			{
				self.zTarget = eAttacker;
			}
		}
	}

	// disable knockback without a damage direction
	if( !isDefined(vDir) )
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	// apply the damage if the protection flag is not set
	if( !(iDFlags & level.iDFLAGS_NO_PROTECTION) )
	{
		if( iDamage < 1 )	// TODO is this actually the case?
			iDamage = 1;
		
		// total damage stats
		if( isDefined(eAttacker.stats["damageDealt"]) )
			eAttacker.stats["damageDealt"] += iDamage;
			
		// Medic Transfusion
		if( isDefined(eAttacker) && isPlayer(eAttacker) && eInflictor == eAttacker && isDefined(eAttacker.lastTransfusion) )
		{
			if( !eAttacker.isDown && eAttacker.health < eAttacker.maxhealth && eAttacker.transfusion && (eAttacker.lastTransfusion + 1000 < getTime()) && randomfloat(1) <= 0.2 )
			{
				eAttacker.lastTransfusion = getTime();
				eAttacker scripts\players\_players::healPlayer(eAttacker.maxhealth * 0.03);
			}
		}

		if( isDefined(sHitLoc) && isDefined(self.damagePerLoc) )
		{
			// track damage per location
			if( !isDefined(self.damagePerLoc[sHitLoc]) )
				self.damagePerLoc[sHitLoc] = iDamage;
			else
				self.damagePerLoc[sHitLoc] += iDamage;
			
			// TODO possibly move this into a thread, if it is too performance heavy
			// check for gibbing when shooting a bodypart
			if( isSubStr(sMeansOfDeath, "BULLET") )
			{
				// check if we should gib an arm
				if( (isSubStr(sHitLoc, "arm") || isSubStr(sHitLoc, "hand")) && self.bodyStatus == 0 )
				{
					// check left side
					if( (isSubStr(sHitLoc, "left_arm") || sHitLoc == "left_hand") && isDefined(level.zom_models[self.body].torsoLOff) )
					{
						// calculate cumulative damage to the limb
						damage = 0;
						if( isDefined(self.damagePerLoc["left_hand"]) )
							damage += self.damagePerLoc["left_hand"];
						
						if( isDefined(self.damagePerLoc["left_arm_lower"]) )
							damage += self.damagePerLoc["left_arm_lower"];
							
						if( isDefined(self.damagePerLoc["left_arm_upper"]) )
							damage += self.damagePerLoc["left_arm_upper"];
						
						// gib the arm when damage exceeds 40% of total health
						if( (damage/self.maxHealth) > 0.4 )
						{
							self.bodyStatus = 1;
							self setModel( level.zom_models[self.body].torsoLOff );
							
							self playSound( "zom_splatter" );
							playFx( level._effect["zom_gib_larm"], self getTagOrigin("j_elbow_le") );
						}
					}
					// check right side
					else if( (isSubStr(sHitLoc, "right_arm") || sHitLoc == "right_hand") && isDefined(level.zom_models[self.body].torsoROff) )
					{
						// calculate cumulative damage to the limb
						damage = 0;
						if( isDefined(self.damagePerLoc["right_hand"]) )
							damage += self.damagePerLoc["right_hand"];
						
						if( isDefined(self.damagePerLoc["right_arm_lower"]) )
							damage += self.damagePerLoc["right_arm_lower"];
							
						if( isDefined(self.damagePerLoc["right_arm_upper"]) )
							damage += self.damagePerLoc["right_arm_upper"];
						
						// gib the arm when damage exceeds 40% of total health
						if( (damage/self.maxHealth) > 0.4 )
						{
							self.bodyStatus = 2;
							self setModel( level.zom_models[self.body].torsoROff );
							
							self playSound( "zom_splatter" );
							playFx( level._effect["zom_gib_rarm"], self getTagOrigin("j_elbow_ri") );
						}
					}
				}
				// check if we should gib a leg
				else if( (isSubStr(sHitLoc, "leg") || isSubStr(sHitLoc, "foot")) && self.legStatus != 3 )
				{
					// check left side
					if( self.legStatus != 1 && (isSubStr(sHitLoc, "left_leg") || sHitLoc == "left_foot") && isDefined(level.zom_models[self.body].legsLOff) )
					{
						// calculate cumulative damage to the limb
						damage = 0;
						if( isDefined(self.damagePerLoc["left_foot"]) )
							damage += self.damagePerLoc["left_foot"];
						
						if( isDefined(self.damagePerLoc["left_leg_lower"]) )
							damage += self.damagePerLoc["left_leg_lower"];
							
						if( isDefined(self.damagePerLoc["left_leg_upper"]) )
							damage += self.damagePerLoc["left_leg_upper"];
						
						// gib the leg when damage exceeds 40% of total health
						if( (damage/self.maxHealth) > 0.4 )
						{
							self detach( self.legs );
							
							// set the apropriate leg status and legs
							if( self.legStatus == 0 )
							{
								self.legStatus = 1;
								self.legs = level.zom_models[self.body].legsLOff;
							}
							else if( isDefined(level.zom_models[self.body].legsOff) )
							{
								self.legStatus = 3;
								self.legs = level.zom_models[self.body].legsOff;
							}
							// NOTE if legsOff should be undefined, we'll just attach the old legs model again
							
							self attach( self.legs );
							
							// play splatter sound
							self playSound( "zom_splatter" );
							
							// play an effect for the left leg
							playFx( level._effect["zom_gib_lleg"], self getTagOrigin("j_knee_le") );
							
							// let the AI know we just lost a leg
							self notify( "lost_leg" );
						}
					}
					// check right side
					else if( self.legStatus != 2 && (isSubStr(sHitLoc, "right_leg") || sHitLoc == "right_foot") && isDefined(level.zom_models[self.body].legsROff) )
					{
						// calculate cumulative damage to the limb
						damage = 0;
						if( isDefined(self.damagePerLoc["right_foot"]) )
							damage += self.damagePerLoc["right_foot"];
						
						if( isDefined(self.damagePerLoc["right_leg_lower"]) )
							damage += self.damagePerLoc["right_leg_lower"];
							
						if( isDefined(self.damagePerLoc["right_leg_upper"]) )
							damage += self.damagePerLoc["right_leg_upper"];
						
						// gib the leg when damage exceeds 40% of total health
						if( (damage/self.maxHealth) > 0.4 )
						{
							self detach( self.legs );
							
							// set the apropriate leg status and legs
							if( self.legStatus == 0 )
							{
								self.legStatus = 2;
								self.legs = level.zom_models[self.body].legsROff;
							}
							else if( isDefined(level.zom_models[self.body].legsOff) )
							{
								self.legStatus = 3;
								self.legs = level.zom_models[self.body].legsOff;
							}
							// NOTE if legsOff should be undefined, we'll just attach the old legs model again
							
							self attach( self.legs );
							
							// play splatter sound
							self playSound( "zom_splatter" );
							
							// play an effect for the left leg
							playFx( level._effect["zom_gib_rleg"], self getTagOrigin("j_knee_ri") );
							
							// let the AI know we just lost a leg
							self notify( "lost_leg" );
						}
					}
				}
			}
			// check for gibbing when blowing zombie up
			else if( isExplosiveDamage(sMeansOfDeath) )
			{
				// gib legs based on how much damage we've dealt, relative to remaining health if the explosion was 'below'
				if( closer(vPoint, self getTagOrigin("j_spinelower"), self getTagOrigin("j_spineupper")) && (iDamage/self.health) > randomFloat(1) )
				{
					// check if at least one leg is left and if we have models for missing legs
					if( self.legStatus != 3 && (isDefined(level.zom_models[self.body].legsOff) || isDefined(level.zom_models[self.body].legsLOff) || isDefined(level.zom_models[self.body].legsROff)) )
					{
						// check if the explosion was closer to the left leg
						left = closer( vPoint, self getTagOrigin("j_knee_le"), self getTagOrigin("j_knee_ri") );
						
						// 50% chance to rip off both legs, if we have a model
						both = (randomFloat(1) > 0.5) && isDefined(level.zom_models[self.body].legsOff);
						
						// gib the left leg, if both legs still there and it was closer to explosion
						if( !both && self.legStatus == 0 && level.zom_models[self.body].legsLOff && left )
						{
							// set left leg missing status
							self.legStatus = 1;
								
							// detach clean legs
							self detach( self.legs );
							
							// set left leg off model
							self.legs = level.zom_models[self.body].legsLOff;
							self attach( self.legs );
							
							// play splatter sound
							self playSound( "zom_splatter" );
							
							// play an effect for the left leg
							if( randomFloat(1) > 0.2 )	// 80% chance to spawn a torn off part, 20% just pieces
								playFx( level._effect["zom_gib_lleg"], self getTagOrigin("j_knee_le") );
							else
								playFx( level._effect["zom_gib_head"], self getTagOrigin("j_knee_le") );
							
							// let the AI know we just lost a leg
							self notify( "lost_leg" );
						}
						// gib the right leg, if both legs still there
						else if( !both && self.legStatus == 0 && level.zom_models[self.body].legsROff )
						{
							// set right leg missing status
							self.legStatus = 2;
							
							// detach clean legs
							self detach( self.legs );
							
							// set right leg off model
							self.legs = level.zom_models[self.body].legsROff;
							self attach( self.legs );
							
							// play splatter sound
							self playSound( "zom_splatter" );
							
							// play an effect for the left leg
							if( randomFloat(1) > 0.2 )	// 80% chance to spawn a torn off part, 20% just pieces
								playFx( level._effect["zom_gib_rleg"], self getTagOrigin("j_knee_ri") );
							else
								playFx( level._effect["zom_gib_head"], self getTagOrigin("j_knee_ri") );
							
							// let the AI know we just lost a leg
							self notify( "lost_leg" );
						}
						// gib the other leg, if one is already gone or we rolled override
						else if( level.zom_models[self.body].legsOff )
						{
							// cache leg status to play currect effect
							oldLegs = self.legStatus;
							
							// set both legs missing status
							self.legStatus = 3;
								
							// detach right leg missing
							self detach( self.legs );
							
							// set both legs off model
							self.legs = level.zom_models[self.body].legsOff;
							self attach( self.legs );
							
							// play splatter sound
							self playSound( "zom_splatter" );
							
							// play an effect for the right leg
							if( oldLegs == 0 || oldLegs == 1 )
							{
								if( randomFloat(1) > 0.2 )	// 80% chance to spawn a torn off part, 20% just pieces
									playFx( level._effect["zom_gib_rleg"], self getTagOrigin("j_knee_ri") );
								else
									playFx( level._effect["zom_gib_head"], self getTagOrigin("j_knee_ri") );
							}
							
							// play an effect for the left leg
							if( oldLegs == 0 || oldLegs == 2 )
							{
								if( randomFloat(1) > 0.2 )	// 80% chance to spawn a torn off part, 20% just pieces
									playFx( level._effect["zom_gib_lleg"], self getTagOrigin("j_knee_le") );
								else
									playFx( level._effect["zom_gib_head"], self getTagOrigin("j_knee_le") );
							}
							
							// let the AI know we just lost a leg
							self notify( "lost_leg" );
						}
					}
				}
			}
		}

		// actually apply the damage to the bot
		self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, level.weaponKeyS2C[sWeapon], vPoint, vDir, sHitLoc, psOffsetTime );
	}
	// TODO what if level.iDFLAGS_NO_PROTECTION is set?
}	/* Callback_BotDamage */

/**
* Returns true if the given damage is explosive
*/
isExplosiveDamage( sMeansOfDeath )
{
	if( sMeansOfDeath == "MOD_EXPLOSIVE" || sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_GRENADE_SPLASH" )
		return true;
	
	return false;
}	/* isExplosiveDamage */

/**
* Makes the entity follow the given target entity
*/
followTarget( target, offset )
{
	self endon( "death" );
	target endon( "death" );

	if(!isDefined(offset))
		offset = (0,0,0);
	
	while( isDefined(self) && isAlive(target) )
	{
		self.origin = (target.origin + offset);
		wait 0.05;
	}
}	/* followTarget */

/**
* Applies fire effect to the bot, caused by the given attacker
*/
igniteBot( eAttacker )
{
	self.isOnFire = true;
	self thread damageOverTime(eAttacker, (self.maxhealth * 0.05), 1, "fire");
	if(self.type != "dog" && self.type != "helldog")
		self thread scripts\bots\_types::createEffectEntity(level.incendiary_FX, "j_spinelower");
	else
		self thread scripts\bots\_types::createEffectEntity(level.incendiary_FX, "j_head", (0,0,-35)); // Prevent effect from being too far up above the head
}	/* igniteBot */

/**
* Applies poison effect to the bot, caused by the given attacker
*/
poisonBot( eAttacker )
{
	self.isPoisoned = true;
	self thread damageOverTime(eAttacker, (self.maxhealth * 0.05), 1, "poison");
	if(self.type != "dog" && self.type != "helldog")
		self thread scripts\bots\_types::createEffectEntity(level.poisoned_FX, "j_spinelower");
	else
		self thread scripts\bots\_types::createEffectEntity(level.poisoned_FX, "j_head", (0,0,-35)); // Prevent effect from being too far up above the head
}	/* poisonBot */

/**
* Keeps damaging the bot with the given damage values
*/
damageOverTime(eAttacker, damage, time, type)
{
	self endon("disconnect");
	self endon("death");
	while( isDefined(eAttacker) )
	{
		wait time + randomFloat( 2 );
		self Callback_BotDamage(eAttacker, eAttacker, int(damage), 0, "MOD_RIFLE_BULLET", "none", eAttacker.origin, vectornormalize(self.origin - eAttacker.origin), "none", 0);

		if( type == "poison" )
			eAttacker thread bulletModFeedback("poison");
		if( type == "fire" )
			eAttacker thread bulletModFeedback("fire");
	}
}	/* damageOverTime */

/**
* Adds the given player to the assist tracking of the zombie
*/
addToAssist(player, damage)
{
	if(!isDefined(self.damagedBy))
		return;
	
	for (i=0; i<self.damagedBy.size; i++)
	{
		if (self.damagedBy[i].player == player)
		{
			self.damagedBy[i].damage += damage;
			return;
		}
	}
	struct = spawnstruct();
	self.damagedBy[self.damagedBy.size] = struct;
	struct.player = player;
	struct.damage = damage;
}	/* addToAssist */

/**
* Handles all bot deaths, awarding points etc.
*
*	@eInflictor: Entity that dealth the damage
*	@attacker: Player entity that is responsible for the damage
*	@iDamage: Integer, base amount of damage dealth
*	@iDFlags: Integer, damage flags applied describing the type of damage
*	@sMeansOfDeath: String, type of damage
*	@sWeapon: String, name of the weapon
*	@vPoint: Vector, point of impact
*	@vDir: Vector, irection of impact
*	@sHitLoc: String, name of the hit location
*	@psOffsetTime: Float, time to wait before the damage is done???
*/
Callback_BotKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	// don't do anything for spectators, if we even get here at all
	if( self.sessionteam == "spectator" )
		return;

	// apply headshots
	if( (sHitLoc == "head" || sHitLoc == "helmet") && sMeansOfDeath != "MOD_MELEE" )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	// print a obituary message
	if( level.dvar["zom_orbituary"] )
		obituary( self, attacker, sWeapon, sMeansOfDeath );

	// set the bot as dead and notify scripts
	self.sessionstate = "dead";
	self notify( "killed" );

	// check if we have a valid attacker
	if( isPlayer(attacker) && attacker != self )
	{
		// increase the attackers scoreboard kills
		attacker.kills++;
		
		// apply the apropriate attackers stats
		attacker.stats["kills"]++;
		
		if( isDefined(eInflictor.isTurret) )
			attacker.stats["turretKills"]++;
		
		if( scripts\players\_weapons::isExplosive(sWeapon) && sMeansOfDeath != "MOD_MELEE" && !attacker.isDown )
			attacker.stats["explosiveKills"]++;
		
		if( sMeansOfDeath == "MOD_MELEE" )
			attacker.stats["knifeKills"]++;
		else if( sMeansOfDeath == "MOD_HEAD_SHOT" )
			attacker.stats["headshotKills"]++;
		
		if( isDefined(attacker.stats["killedZombieTypes"][self.type]) )
			attacker.stats["killedZombieTypes"][self.type]++;
		else
			logPrint( "LUK_DEBUG;killedZombieTypes for " + self.type + " aint defined, bro\n" );
			
		// give XP and UPoints to the attacker and assistants
		attacker thread scripts\players\_rank::giveRankXP( "kill" );
		
		assert( isDefined(self.rewardMultiplier) );
		attacker scripts\players\_players::incUpgradePoints(int(10 * level.rewardScale * self.rewardMultiplier));
		
		self giveAssists( attacker );
		
		// apply killing sprees for the attacker
		attacker thread scripts\players\_spree::checkSpree();
		
		// calculate attackers on kill abilities
		if( attacker.curClass == "specialist" && !attacker.isDown )
			attacker scripts\players\_abilities::rechargeSpecial( 5 );
		
		if( attacker.curClass == "scout" && sMeansOfDeath == "MOD_HEAD_SHOT" && !attacker.isDown )
			attacker scripts\players\_abilities::rechargeSpecial( 10 );
		
		// if(sWeapon == "bulletmod_poison")
			// attacker iprintlnbold("Killed with POISON!");
			// attacker.poisonKills++;
		// else if(sWeapon == "bulletmod_fire")
			// attacker iprintlnbold("Killed with FIRE!");
			// attacker.incendiaryKills++;
	}
	
	// play a death sound
	if( self.soundType == "zombie" )
		self playSound( "zom_death" );
	else if( self.soundType == "dog" )
		self playSound( "dog_death" );
	
	// play gore effects and create a ragdoll if needed
	corpse = self scripts\bots\_types::onCorpse();
	if( !self doSplatter( attacker, sMeansOfDeath, sWeapon, sHitLoc ) )
	{
		if( corpse > 0 )
		{
			body = self clonePlayer( deathAnimDuration );
			if( corpse > 1 )
			{
				thread delayStartRagdoll( body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath );
			}
		}
	}
	
//	self setOrigin( (0,0,-10000) );	// TODO is this required?
	self.untargetable = true;
	
	if( self.type == "halfboss" )
		level.bossBulletCount--;
	
	level.dif_killedLast5Sec++;
	level.killedZombies++;

	// Remove effect on death
	if( isDefined(self.effect) )
		self.effect delete();
		
	wait 0.5;

	self.hasSpawned = false;
	self.parent = undefined;
	self.number = undefined;
	
	level.botsAlive--;
	
	level notify( "bot_killed" );
}	/* Callback_BotKilled */

/**
* Checks if the zombie has taken critical damage to the head, thus resulting in it's head being blown up
*/
doSplatter( attacker, sMeansOfDeath, sWeapon, sHitLoc )
{
	// make sure we have a valid attacker
	if( !isDefined(attacker) || !isDefined(attacker.primary) || !isDefined(attacker.secondary) )
		return false;
	
	// accumulate damage dealt to the head region
	damage = 0;
	if( isDefined(self.damagePerLoc["head"]) )
		damage += self.damagePerLoc["head"];
	
	if( isDefined(self.damagePerLoc["neck"]) )
		damage += self.damagePerLoc["neck"];
	
	if( isDefined(self.damagePerLoc["helmet"]) )
		damage += self.damagePerLoc["helmet"];
	
	// make sure the damage doesn't exceed maxHealth
	if( damage > self.maxHealth )
		damage = self.maxHealth;
	
	// don't play splatter effects for dogs or exploding zombies
	if( self.type != "dog" && self.type != "helldog" && self.type != "burning" && self.type != "napalm" )
	{
		// play a zombie splatter effect for explosive damage
		if( scripts\players\_weapons::isExplosive(sWeapon) )
		{
			// play apropriate exploding effect
			self zomExplodeBody();
			
			// let the script know we exploded the whole zombie
			return true;
		}
		else
		{
			// make sure damage was dealt with the primary or secondary weapon
			if( sWeapon == attacker.primary || sWeapon == attacker.secondary )
			{
				// make sure zombie received at least 80% damage to the head and killing blow was to the head
				if( (damage/self.maxhealth) > 0.8 && sMeansOfDeath != "MOD_MELEE" && (sHitLoc == "head" || sHitLoc == "neck" || sHitLoc == "helmet") )
				{
					// check if we have a neck stump model
					if( isDefined(level.zom_models[self.body].headOff) )
					{
						// play splatter sound
						self playSound( "zom_splatter" );
						
						// play head splatter effect
						playFx( level._effect["zom_gib_head"], self getTagOrigin("j_head") );
						
						// detach the current head model
						self detach( self.head );
						
						// set and attach the neck stump model
						self.head = level.zom_models[self.body].headOff;
						self attach( self.head );
					}
					else
					{
						// play apropriate exploding effect
						self zomExplodeBody();
						
						// let the script know we exploded the whole zombie
						return true;
					}
				}
			}
		}
	}

	// let the script know to spawn a ragdoll
	return false;
}	/* doSplatter */

/**
* Explodes the zombies body and spawns apropriate bodyparts
*/
zomExplodeBody()
{
	// play splatter sound
	self playSound( "zom_splatter" );

	// play main splatter effect
	if( self.type == "dog" || self.type == "helldog" )
		playFx( level._effect["zom_gib_expl"], self getTagOrigin("j_spine2") );
	else
		playFx( level._effect["zom_gib_expl"], self getTagOrigin("j_spinelower") );
	
	// play head splatter effect
	playFx( level._effect["zom_gib_head"], self getTagOrigin("j_head") );
	
	// play arm splatter effect(s)
	if( self.bodyStatus == 1 )			// left arm missing
		playFx( level._effect["zom_gib_rarm"], self getTagOrigin("j_elbow_ri") );
	else if( self.bodyStatus == 2 )		// right arm missing
		playFx( level._effect["zom_gib_larm"], self getTagOrigin("j_elbow_le") );
	else if( self.bodyStatus == 0 )		// no arm missing
	{
		playFx( level._effect["zom_gib_larm"], self getTagOrigin("j_elbow_le") );
		playFx( level._effect["zom_gib_rarm"], self getTagOrigin("j_elbow_ri") );
	}
	
	// play leg splatter effect(s)
	if( self.legStatus == 1 )			// left leg missing
		playFx( level._effect["zom_gib_rleg"], self getTagOrigin("j_knee_ri") );
	else if( self.legStatus == 2 )		// right leg missing
		playFx( level._effect["zom_gib_lleg"], self getTagOrigin("j_knee_le") );
	else if( self.legStatus == 0 )		// no leg missing
	{
		playFx( level._effect["zom_gib_lleg"], self getTagOrigin("j_knee_le") );
		playFx( level._effect["zom_gib_rleg"], self getTagOrigin("j_knee_ri") );
	}
	
	// play extra effects for bosses
	if( self.type == "boss" || self.type == "halfboss" )
	{
		playFx( level._effect["zom_gib_head"], self getTagOrigin("j_head") );
		playFx( level._effect["zom_gib_head"], self getTagOrigin("j_elbow_le") );
		playFx( level._effect["zom_gib_head"], self getTagOrigin("j_elbow_ri") );
		playFx( level._effect["zom_gib_head"], self getTagOrigin("j_knee_le") );
		playFx( level._effect["zom_gib_head"], self getTagOrigin("j_knee_ri") );
	}
}	/* zomExplodeBody */

/**
*	Gives assist upgradepoints and XP to people who shot self (the zombie that died)
*	@killer: Entity, the entity that killed that zombie
*/
giveAssists( killer )
{
	// Loop through all players that have damaged the zombie
	for (i = 0; i < self.damagedBy.size; i++)
	{
		struct = self.damagedBy[i];
		health = self.maxhealth;
		
		// Check existing player in list
		if( isDefined(struct.player) )
		{
			if( struct.player.isActive && struct.player != killer )
			{
				// Stats for assists
				struct.player.assists++;
				struct.player.stats["assists"]++;
				
				// Get percentage damage dealt
				damagePercentage = struct.damage / self.maxHealth;
				rewardMP = 1;
				
				Assert( isDefined(self.rewardMultiplier) );
				rewardMP = self.rewardMultiplier;
				
				// Give player the amount of upgradepoints directly connected to the % of damage dealt to this zombie
				struct.player thread scripts\players\_players::incUpgradePoints(int((10 * level.rewardScale * rewardMP) * damagePercentage));
				
				// Give XP depending on the amount of damage dealt
				if (damagePercentage * 100 > 85){
					struct.player thread scripts\players\_rank::giveRankXP("assist5");
				}
				else if (damagePercentage * 100 > 75){
					struct.player thread scripts\players\_rank::giveRankXP("assist4");
				}
				else if (damagePercentage * 100 > 50){
					struct.player thread scripts\players\_rank::giveRankXP("assist3");
				}
				else if (damagePercentage * 100 > 30){
					struct.player thread scripts\players\_rank::giveRankXP("assist2");
				}
				else if (damagePercentage * 100 > 15){
					struct.player thread scripts\players\_rank::giveRankXP("assist1");
				}
				else if (damagePercentage * 100 > 0){
					struct.player thread scripts\players\_rank::giveRankXP("assist0");
				}
			}
		}
	}
	
	// reset the assist tracking array
	self.damagedBy = undefined;
}	/* giveAssists */

onMonkeyExplosion(){
	self endon("death");
	self endon("disconnect");
	while(1){
		level waittill("monkey_bomb_exploded"); // Wait until a monkey bomb exploded somewhere on the map
		for(i = 0; i < level.bots.size; i++){ // Check bot one by one
			bot = level.bots[i];
			
			foundMonkey = false;
			if(isDefined(bot.targetedMonkey)){ // see if the bot has been targeting a monkey
				for(ii = 0; ii < level.monkeyEntities.size; ii++){ // Find out if the zombie has targeted one of the monkey entities that have exploded and are no longer existant
					if(level.monkeyEntities[ii].index == bot.targetedMonkeyEntIndex){ // Stop the loop if the zombie actually targets a monkey bomb that still exists
						foundMonkey = true;
						break;
					}
					
				}
			}
			if(!foundMonkey){
				bot.targetedMonkey = undefined;
				bot.targetedMonkeyEntIndex = undefined;
				if(isAlive(bot) && isDefined(bot getClosestTarget())) // Giving the zombie a new target, preventing "onSight"-checks in case the zombie is stuck inside a wall
					bot zomSetTarget(bot getClosestTarget().origin);
			}
		}

	}
}

monkeyOverride(){
	self endon("death");
	self endon("disconnect");
	while(1){
		if(level.monkeyEntities.size == 0)
			level waittill("monkey_bomb");
		else
			wait .05;
		while(level.monkeyEntities.size > 0 && self.type != "boss" && self.type != "halfboss"){
			nearestEnt = undefined;
			nearestDistance = 9999999999;
			for (i = 0; i < level.monkeyEntities.size; i++)
			{
				ent = level.monkeyEntities[i];
				if(!isDefined(self.origin) || !isDefined(ent.origin))
					continue;
					
				distance = Distance(self.origin, ent.origin);
			
				if(distance < nearestDistance && distance < 800)
				{
					nearestDistance = distance;
					nearestEnt = ent;
				}
			}
			if(isDefined(nearestEnt)){
				self zomSetTarget(nearestEnt.origin);
				self.targetedMonkey = true;
				self.targetedMonkeyEntIndex = nearestEnt.index;
				self.sprinting = true;
				if (distance(nearestEnt.origin, self.origin) < (self.meleeRange - 40)){
					self zomGoIdle();
				}
			}
			wait .05;
		}
	}
}

freezeBotOnLC(){
	self endon("death");
	self endon("disconnect");
	level waittill("last_chance_start");
	// self notify("stop_main");
	
	self.lastMemorizedPos = undefined;
	self.playIdleSound = false;
	self zomGoIdle();
	level waittill("last_chance_succeeded");
	self.playIdleSound = true;
	wait 3;
	
	// self thread zomMain();
	if(isAlive(self) && isDefined(self getClosestTarget())) // Giving the zombie a new target, preventing "onSight"-checks in case the zombie is stuck inside a wall
		self zomSetTarget(self getClosestTarget().origin);
}

freezeBot(){
	self endon("death");
	self endon("disconnect");
	while(1){
		while(1){
			if(level.freezeBots)
				break;
			else
				wait 0.5;
		}
		self notify("kill_main");
		self.lastMemorizedPos = undefined;
		self.playIdleSound = false;
		self zomGoIdle();
		
		while(level.freezeBots){
			wait 0.05;
		}
			
		self.playIdleSound = true;
		
		
		if(isDefined(self getClosestTarget())) // Giving the zombie a new target, preventing "onSight"-checks in case the zombie is stuck inside a wall
			self zomSetTarget(self getClosestTarget().origin);
		self thread zomMain();
	}
}

zomMain()
{
	self endon("disconnect");
	self endon("death");
	self endon("kill_main");
	
	self.lastTargetWp = -2;
	self.nextWp = -2;
	//self.intervalScale = 1;
	update = 0;
	
	while (1)
	{
		switch (self.status)
		{
			case "idle":
				zomWaitToBeTriggered();
				switch(level.zomIdleBehavior)
				{
					case "magic":
						if (update==5) {
							if (level.zomTarget != "")
							{
								if (level.zomTarget == "player_closest")
								{
									ent = self getClosestTarget();
									if (isdefined(ent))
									{
										self zomSetTarget(ent.origin);
									}
								}
								else
								self zomSetTarget(getRandomEntity(level.zomTarget).origin);
							}
							else
							{
								ent = self getClosestTarget();
								if (isdefined(ent))
								self zomSetTarget(ent.origin);
							}
							update = 0;
						}
						else
							update++;
					break;
				}
				break;
			case "triggered":
				if (update==10){
					self.bestTarget = zomGetBestTarget();
					update = 0;
				}
				else 
					update++;
				if (isdefined(self.bestTarget))
					if(self.bestTarget.isTargetable && self.bestTarget.visible)
					{
						self.lastMemorizedPos = self.bestTarget.origin;
						if (!checkForBarricade(self.bestTarget.origin))
						{
							if (distance(self.bestTarget.origin, self.origin) < self.meleeRange)
							{
								self thread zomMoveLockon(self.bestTarget, self.meleeTime, self.meleeSpeed);
								switch(self.type){
									case "napalm": self zomExplode(); break;
									case "boss": self bossAttack(); break;
									default: self zomMelee(); break;
								}
								//doWait = false;
							}
							else
							{
								zomMovement();
								self zomMoveTowards(self.bestTarget.origin);
								//doWait = false;
							}
						}
						else
							self zomMelee();
					}
					else
						self zomGoSearch();
				else
					self zomGoSearch();
				break;
			
			case "searching":
			zomWaitToBeTriggered();
				if (isdefined(self.lastMemorizedPos))
				{
					if (!checkForBarricade(self.lastMemorizedPos))
					{
						if (distance(self.lastMemorizedPos, self.origin) > 48)
						{
							zomMovement();
							self zomMoveTowards(self.lastMemorizedPos);
							//doWait = false;
						}
						else
							self.lastMemorizedPos = undefined;
					}
					else
						self zomMelee();
				}
				else
					zomGoIdle();
					
				break;
			}
		//if (doWait)
		wait level.zomInterval;
	}
}

zomGetBestTarget()
{
	if (!isdefined(self.currentTarget))
	{
		for (i=0; i<level.players.size; i++)
		{
			player = level.players[i];
			if (zomSpot(player))
			{
				self.currentTarget = player;
				return player;
			}
			wait 0.05;
		}
		/*for (i=0; i<level.zomTargets.size; i++)
		{
			obj = level.zomTargets[i];
			if (zomSpot(obj))
			{
				self.currentTarget = obj;
				return obj;
			}
		}*/
	}
	else
	{
		if (!zomSpot(self.currentTarget))
		{
			self.currentTarget = undefined;
			return undefined;
		}
		
		
		targetdis = distancesquared(self.origin, self.currentTarget.origin) - level.zomPreference;
		for (i=0; i<level.players.size; i++)
		{
			player = level.players[i];
			if (distancesquared(self.origin, player.origin) < targetdis)
			{
				if (zomSpot(player))
				{
					self.currentTarget = player;
					return player;
				}
			}
		}
		/*for (i=0; i<level.zomTargets.size; i++)
		{
			obj = level.zomTargets.size[i];
			if (distancesquared(self.origin, obj.origin) - obj.zomPreference < targetdis)
			{
				if (zomSpot(obj))
				{
					self.currentTarget = obj;
					return obj;
				}
			}
		}*/
		return self.currentTarget;
		
	}
}

zomMovement()
{
	self.cur_speed = 0;
	
	if ((self.alertLevel >= 200 && (!self.walkOnly || self.quake)) || self.sprinting) //GO RUNNING... AAHH
	{
		self botAction( "+sprint" );
	//	self setanim("sprint");
	//	self.cur_speed = self.runSpeed;
		if (self.quake)
		{
			Earthquake(0.25, .3, self.origin, 380);
		}
		
		if (level.dvar["zom_dominoeffect"])
			thread alertZombies(self.origin, 480, 5, self); 
	}
	else
	{
		self botAction( "-sprint" );
	//	self setanim("walk");
	//	self.cur_speed = self.walkSpeed;
		if (self.quake)
		{
			Earthquake(0.17, .3, self.origin, 320);
		}
	}
}


zomGoIdle()
{
//	self setanim("stand");
	self botStop();
	self.cur_speed = 0;
	self.alertLevel = 0;
	self.status = "idle";
	//iprintlnbold("IDLE!");
}

zomGoTriggered()
{
	self.status = "triggered";
	//self.update = 10;
	self.bestTarget = zomGetBestTarget();
	//iprintlnbold("TRIGGERED!");
}

zomGoSearch()
{
	self.status = "searching";
	//iprintlnbold("SEARCHING!");
}

zomWaitToBeTriggered()
{
	for (i=0; i<level.players.size; i++)
	{
		player = level.players[i];
		if(self zomSpot(player))
		{
			self zomGoTriggered();
			break;
		}
	}
}

zomSpot(target)
{
  if (!target.isObj)
  {
	  if (!target.isAlive)
	  return false;
	  
	  if (!target.isTargetable)
	  return false;
  }
  
  if (!target.visible)
	return false;
  
  distance = distance(self.origin, target.origin);
  
  if (distance > level.zombieSight)
  return false;
  
  /*switch (target getStance())
  {
	case "stand":
	if (distance < 256)
	return 1;
	break;
	case "crouch":
	if (distance < 148)
	return 1;
	break;
	case "prone":
	if (distance < 96)
	return 1;
	break;
  }*/
  
  /*speed = Length(target GetVelocity());
  
  if (speed > 80 && distance < 256)
  return 1;
  if (speed > 160 && distance < 416)
  return 1;
  if (speed > 240 && distance < 672)
  return 1;*/
  
  dot = 1.0;
  
  //if nearest target hasn't attacked me, check to see if it's in front of me
   fwdDir = anglestoforward(self getplayerangles());
   dirToTarget = vectorNormalize(target.origin-self.origin);
   dot = vectorDot(fwdDir, dirToTarget);
  

  //try see through smoke
  /*if(!SmokeTrace(self GetEyePos(), self.bestTarget GetEyePos()))
  {
    return false;
  }*/
  
  //in front of us and is being obvious
  if(dot > -0.2)
  {
    //do a ray to see if we can see the target
	if (!target.isObj)
	{
		visTrace = bullettrace(self.origin + (0,0,68), target getPlayerHeight(), false, self);
	}
	else
	{
	 visTrace = bullettrace(self.origin + (0,0,68), target.origin +(0,0,20), false, self);
	}
	if(visTrace["fraction"] == 1)
	{
		   //line(self.origin + (0,0,68), visTrace["position"], (0,1.0,0));
		return true;
	}
	else
	{
		if (isdefined(visTrace["entity"]))
		if (visTrace["entity"] == target)
		return true;
		//line(self.origin + (0,0,68), visTrace["position"], (1,0,0));            
		return false;
	}

  }
  
  return false;
}

zomGoToClosestWaypoint(){
	self endon("death");
	self zomMovement();
	self zomMoveTowards(level.waypoints[getNearestWp(self.origin)].origin);
	wait 0.5;
	self zomGoSearch();
	self thread zomMain();
}

setAnim(animation)
{
	printLn( "ERROR: setAnim called, use botAction instead" );
/*	if (isdefined(self.animation[animation]))
	{
		self.animWeapon = self.animation[animation];
		self TakeAllWeapons();
		self.pers["weapon"] = self.animWeapon;
		self giveweapon(self.pers["weapon"]);
		self givemaxammo(self.pers["weapon"]);
		//self SetWeaponAmmoClip(self.pers["weapon"], 30);
		//self SetWeaponAmmoStock(self.pers["weapon"], 0);
		self setspawnweapon(self.pers["weapon"]);
		self switchtoweapon(self.pers["weapon"]);
	}
*/
}

getPlayerHeight()
{
	  switch (self getStance())
	  {
		case "stand":
		return self.origin + (0,0,68);
		case "crouch":
		return self.origin + (0,0,40);
		case "prone":
		return self.origin + (0,0,22);
	  }
}

zomMoveTowards(target_position)
{
	self endon("disconnect");
	self endon("death");
	self notify("zomMoveTowards");
	self endon("zomMoveTowards");
	
	//self thread pushOutOfPlayers();
	
	if (!isdefined(self.myWaypoint))
	{
		self.myWaypoint = getNearestWp(self.origin);
	}
	
	targetWp = getNearestWp(target_position);
	
	nextWp = self.nextWp;
	
	direct = false;
	//
	//if (distancesquared(target_position, self.origin) <= distancesquared(level.waypoints[targetWp].origin, self.origin) || targetWp == self.myWaypoint)
	if (self.underway)
	{
	
	//if (targetWp == self.myWaypoint)
	//
		//if (distancesquared(target_position, self.origin) >= distancesquared(level.waypoints[nextWp].origin, self.origin))
		//direct = true;
		
		if (targetWp == self.myWaypoint) //|| distancesquared(target_position, self.origin) <= distancesquared(level.waypoints[nextWp].origin, self.origin)
		{
			direct = true;
			self.underway = false;
			self.myWaypoint = undefined;
		}
		else
		{
			if (!isdefined(nextWp))
			return ;
			if (targetWp == nextWp)
			{

				if (distancesquared(target_position, self.origin) <= distancesquared(level.waypoints[nextWp].origin, self.origin))
				{
					direct = true;
					self.underway = false;
					self.myWaypoint = undefined;
				}
			}
		}
	}
	else
	{
		//if (self.lastTargetWp != targetWp || self.myWaypoint == nextWp)
		if (targetWp == self.myWaypoint)
		{
			//iprintln(level.waypoints[getNearestWp(self.origin)].origin+":"+level.waypoints[getNearestWp(target_position)].origin);
			direct = true;
			self.underway = false;
			self.myWaypoint = undefined;
		}
		else
		{
			//time = GetTime();
			/* This way may not be the safest and most reliable */
			if(level.waypointLoops > 100000 && level.dvar["dev_antilagmonitor"]){
				// logPrint("DEBUG: Caught > 200000 loops in level.waypointLoops!\n");
				// logPrint("DEBUG: Caught " + level.waypointLoops + " loops in level.waypointLoops!\n");
				// iprintln("Caught > 200000 loops, mitigating load to more frames...");
				// iprintln("DEBUG: Caught " + level.waypointLoops + " loops in level.waypointLoops!\n");
				wait 0.05;
				if(isDefined(target_position))
					self thread zomMoveTowards(target_position);
				return;
			}
			if(level.botsLookingForWaypoints > getDvarInt("max_waypoint_bots")){
				if(getDvarInt("debug_max_waypoint_bots"))
					iprintln("Caught > " + getDvarInt("max_waypoint_bots") + " bots looking for waypoints!");
				wait 0.05;
				if(isDefined(target_position))
					self thread zomMoveTowards(target_position);
				return;
			}
			level.botsLookingForWaypoints++;
			nextWp = AStarSearch(self.myWaypoint, targetWp);
			//newtime = GetTime()-time;
			//iprintlnbold("MILISEC:" + newtime);
			self.nextWp = nextWp;
			self.underway = true;
		}
	}
	
	//self.lastTargetWp = targetWp;
	
	//TARGET SET! MOVING!
	//line(self.origin, target_position, (0,0,1));
	if (direct)
	{
		moveToPoint(target_position, self.cur_speed);
		/*lineCol = (1,0,0);
		line(level.waypoints[self.myWaypoint].origin, target_position, lineCol);*/
	}
	else
	{
		/*lineCol = (1,0,0);
		line(level.waypoints[self.myWaypoint].origin, level.waypoints[nextWp].origin, lineCol);*/
		if (isdefined(nextWp))
		{
			moveToPoint(level.waypoints[nextWp].origin, self.cur_speed);
			if (distance(level.waypoints[nextWp].origin, self.origin) <  64)
			{
				self.underway = false;
				self.myWaypoint = nextWp;
				//if (self.myWaypoint != nextWp)
				//nextWp = AStarSearch(self.myWaypoint, targetWp);
				//else
				//break;
			}
		}
		/*else
		
			self zomGoIdle();
		*/
		
	}
}

zomMoveLockon(player, time, speed)
{
	intervals = int(time / level.zomInterval);
	for (i=0; i<intervals; i++)
	{
		if(!isDefined(player))
			break;
		dis = distance(self.origin, player.origin);
		if (dis > 48)
		{
			pushOutDir = VectorNormalize((self.origin[0], self.origin[1], 0)-(player.origin[0], player.origin[1], 0));
			self moveToPoint(player.origin + pushOutDir * 32, speed);
			self pushOutOfPlayers();
		}
		targetDirection = vectorToAngles(VectorNormalize(player.origin - self.origin));		
	//	self SetPlayerAngles(targetDirection);
		self botLookAt( player.origin );
		wait level.zomInterval;
	}
}

pushOutOfPlayers() // ON SELF
{
  //push out of other players
  //players = level.players;
  players = getentarray("player", "classname");
  for(i = 0; i < players.size; i++)
  {
    player = players[i];
    
    if(player == self || !isalive(player))
      continue;
    self thread pushout(player.origin);

  }
  for (i=0; i <level.dynamic_barricades.size; i++)
  {
	if (isdefined(level.dynamic_barricades[i]))
	{
		if (level.dynamic_barricades[i].hp > 0)
		self thread pushout(level.dynamic_barricades[i].origin);
	}
  }
   /*for (i=0; i <level.barricades.size; i++)
  {
	if (isdefined(level.barricades[i]))
	{
		if (level.barricades[i].hp > 0)
		self thread pushout(level.barricades[i].parts[0].startPosition);
	}
  }*/
}

pushout(org)
{
	printLn( "ERROR, LinkObj removed, pushout not supported!" );
/*	linkObj = self.linkObj;
    distance = distance(org, linkObj.origin);
    minDistance = 28;
    if(distance < minDistance) //push out
    {
      pushOutDir = VectorNormalize((linkObj.origin[0], linkObj.origin[1], 0)-(org[0], org[1], 0));
      pushoutPos = linkObj.origin + (pushOutDir * (minDistance-distance));
      linkObj.origin = (pushoutPos[0], pushoutPos[1], self.origin[2]);
    }
*/
}

zomExplode()
{
	self endon("disconnect");
	self endon("death");
	
//	self setAnim("melee");
	self botAction( "+melee" );
	wait 0.5;
	self botAction( "-melee" );
	
	PlayFX( level.explodeFX, self.origin );
	self PlaySound("explo_metal_rand");
	self scripts\bots\_bots::zomAreaDamage(self.damage);
	
	self zomExplodeBody();
	
	self setorigin((0,0,-10000));
	self.untargetable = true;
	self.suicided = true;
	
	self suicide();
}	/* zomExplode */

getMeleePreTime(){
	switch(self getCurrentWeapon()){
		case "bot_zombie_melee_mp": return 0.5;
		case "brick_blaster_mp":	return 0.3;
		default: 					return 0.5;
	}
}

getMeleePostTime(){
	switch(self getCurrentWeapon()){
		case "bot_zombie_melee_mp": return 1.2;
		case "brick_blaster_mp":	return 0.6;
		default: 					return 1.2;
	}
}

zomMelee(bDoDamage)
{
	if(!isDefined(bDoDamage))
		bDoDamage = true;
	self endon("disconnect");
	self endon("death");
	self.movementType = "melee";
	/*if (self hasAnim("run"))
	{
		self setAnim("run2melee");
		wait .4;
	}
	else
	{
		self setAnim("stand2melee");
		wait .6;
	}*/
//	self setAnim("melee");
	self botAction( "+melee" );
	
//	wait self getMeleePreTime();
	wait .5;
	if( self.quake )
		Earthquake(0.25, .2, self.origin, 380);
	if( isAlive(self) )
	{
		if(bDoDamage)
			self zomDoDamage(self.meleeRange);
		if(self.type != "dog" && self.type != "helldog")
		self zomSound(0, "zom_attack");
		else
		self zomSound(0, "dog_attack");
	}
	// wait .6;
	wait self getMeleePostTime();
	// wait 1.1;
	/*wait .5;
	if (isalive(self))
	{
		self zombieDoDamage(90, 30);
		self zombieSound(0, "zom_attack", randomint(10));
	}
	wait .5;
	if (isalive(self))
	{
		self zombieDoDamage(90, 30);
		self zombieSound(0, "zom_attack", randomint(10));
	}
	wait .7;*/
//	self setAnim("stand");
	self botAction( "-melee" );
	//self.movementType = "walk";

	//self setAnim("run");
	//self thread zombieMelee();
}

bossAttack()
{
	self endon("disconnect");
	self endon("death");
		
	if(level.nextBossJump < getTime() && randomfloat(1) < 0.15){
	//	self setAnim("jump");
	//	self botAction( "+melee" );	TODO
	//	NOTE we could actuall just put him a few units into the air and let the drop anim play
	
		playFX(level.bossShockwaveFX, self.origin);
		self playsound("boss_charge");
		wait 1.1;
		Earthquake(0.8, 1, self.origin, 600);
		
		if (isalive(self))
		{
			self zomAreaDamage(360);
			self playsound("detpack_explo_main");
		}
		
		wait .2;
	//	self setAnim("stand");
		level.lastBossJump = getTime();
		level.nextBossJump = level.lastBossJump + (10000 + randomint(10000));
	}
	else
		self zomMelee();

}

infection(chance)
{
	if (self.infected)
	return;
	
	chance = self.infectionMP * chance;
	if (randomfloat(1)<chance)
	{
		self thread scripts\players\_infection::goInfected();
	}
	
}

moveToPoint(origin, speed)
{
	self botLookAt( origin );
	self botMoveTo( origin );
	/*
	dis = distance(self.linkObj.origin, origin);
	if (dis < speed)
	speed = dis;
	else
	speed = speed * level.zomSpeedScale;
	targetDirection = vectorToAngles(VectorNormalize(origin - self.linkObj.origin));
	step = anglesToForward(targetDirection) * speed ;
					
	self SetPlayerAngles(targetDirection);
	
	//self.mover zomMove(step, time);
	//wait time * 0.05;
	//self.mover dropToGround();
	newPos = self.linkObj.origin + step + (0,0,40);
	dropNewPos = dropPlayer(newPos, 200);
	if (isdefined(dropNewPos))
	{
		newPos = (dropNewPos[0], dropNewPos[1], self compareZ(origin[2], dropNewPos[2]));
	}
	self.linkObj moveto(newPos, level.zomInterval , 0, 0);
	*/
}

compareZ(z1, z2)
{
	dif_z2 = z2 - self.origin[2];
	if (dif_z2 > 30) // Heavy rise in Z
	{
		if (z1 > z2) // z1 is even higher, np
		{
			if (dif_z2 > 20)
			z2 = self.origin[2] + 20;
			return z2;
		}
		else
		return self.origin[2];
		
	}
	if (dif_z2 < -30)// Heavy fall in Z
	{
		if (z1 < z2) // z2 is even lower, np
		{
			return z2;
		}
		else
		return self.origin[2];
	}
	return z2;
	
}

zomAreaDamage(range)
{
	for (i=0; i<=level.players.size; i++)
	{
					target = level.players[i];
					if (isdefined(target) && isalive(target))
					{
						distance = distance(self.origin, target.origin);
						if (distance < range)
						{
							target.isPlayer = true;
							//target.damageCenter = self.Mover.origin;
							target.entity = target;
							target damageEnt(
								self, // eInflictor = the entity that causes the damage (e.g. a claymore)
								self, // eAttacker = the player that is attacking
								int(self.damage*level.dif_zomDamMod), // iDamage = the amount of damage to do
								"MOD_EXPLOSIVE", // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
								self.pers["weapon"], // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
								self.origin, // damagepos = the position damage is coming from
								//(0,self GetPlayerAngles()[1],0) // damagedir = the direction damage is moving in      
								vectorNormalize(target.origin-self.origin)
							);
							self scripts\bots\_types::onAttack(self.type, target);
						}
					}
	}
}

zomDoDamage(meleeRange)
{
	/*
	closest = getClosestPlayerArray();
	for (i=0; i<=closest.size; i++)
	{
					target = closest[i];
					if (isdefined(target))
					{
						distance = distance(self.origin, target.origin);
						if (distance <meleeRange)
						{
							fwdDir = anglestoforward(self getplayerangles());
							dirToTarget = vectorNormalize(target.origin-self.origin);
							dot = vectorDot(fwdDir, dirToTarget);
							if (dot > .5)
							{
							target.isPlayer = true;
							//target.damageCenter = self.Mover.origin;
							target.entity = target;
							target damageEnt(
									self, // eInflictor = the entity that causes the damage (e.g. a claymore)
									self, // eAttacker = the player that is attacking
									int(self.damage*level.dif_zomDamMod), // iDamage = the amount of damage to do
									"MOD_MELEE", // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
									self.pers["weapon"], // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
									self.origin, // damagepos = the position damage is coming from
									//(0,self GetPlayerAngles()[1],0) // damagedir = the direction damage is moving in      
									vectorNormalize(target.origin-self.origin)
								);
							self scripts\bots\_types::onAttack(self.type, target);
							if (level.dvar["zom_infection"])
							target infection(self.infectionChance);
							//target shellshock("zombiedamage", 1);
							break;
							}
						}
					}
	}
	*/
	/*for (i=0; i<level.attackable_obj.size; i++)
	{
		obj = level.attackable_obj[i];
		distance = distance2d(self.origin, obj.origin);
		if (distance <meleeRange)
		{
			fwdDir = anglestoforward(self getplayerangles());
			dirToTarget = vectorNormalize(obj.origin-self.origin);
			dot = vectorDot(fwdDir, dirToTarget);
			if (dot > .5)
			{
				obj notify("damage", self.damage);
			}
		}
		
		
	}*/
	for (i=0; i<level.barricades.size; i++)
	{
		ent = level.barricades[i];
		distance = distance2d(self.origin, ent.origin);
		if (distance <meleeRange*2)
		{
			ent thread scripts\players\_barricades::doBarricadeDamage(self.damage*level.dif_zomDamMod);
			break;
		}
	}
	for (i=0; i<level.dynamic_barricades.size; i++)
	{
		ent = level.dynamic_barricades[i];
		distance = distance2d(self.origin, ent.origin);
		if (distance <meleeRange)
		{
			ent thread scripts\players\_barricades::doBarricadeDamage(self.damage*level.dif_zomDamMod);
			break;
		}
	}
	

}

zomGroan()
{
	self endon("death");
	self endon("disconnect");
	
	soundtype = "";
	
	if (self.soundType == "dog")
		soundtype = "dog";
	else if(self.soundType == "zombie")
		soundtype = "zom";
	
	for (;;)
	{
		wait 3 + randomfloat(3);
		
		//self zombieSound(randomfloat(.5), "zom_run", 0);
		if (self.isDoingMelee == false && self.playIdleSound)
		{
			if (self.alertLevel == 0 && soundtype == "dog")
			{
				self zomSound(randomfloat(.5), soundtype + "_" + "idle");
			}
			else if (self.alertLevel < 200)
			{
				if(soundtype == "zom")
					self zomSound(randomfloat(.5), soundtype + "_" + "walk");
			}
			else if(soundtype == "zom")
			{
				self zomSound(randomfloat(.5), "zom_run");
			}
		}
	}
}

zomSound(delay, sound)
{
	if (delay > 0) {
		self endon("death");
		wait delay;
	}
	if(level.silenceZombies)
		return;
	if (isalive(self))
	self playSound(sound);
}

zomSetTarget(target)
{
	//wait .5;
	//self.targetPosition = getentarray(target, "targetname")[0].origin;
	//self.alertLevel = 1;
	self zomGoSearch();
	self.lastMemorizedPos = target;
}


checkForBarricade(targetposition)
{
	for (i=0; i<level.barricades.size; i++)
	{
		ent = level.barricades[i];
		if (isDefined(ent) && self istouching(ent) && ent.hp > 0)
		{
			fwdDir = vectorNormalize(targetposition-self.origin);
			dirToTarget = vectorNormalize(ent.origin-self.origin);
			dot = vectorDot(fwdDir, dirToTarget);
			if (dot > 0 && dot < 1)
			{
				return 1;
			}
		}
	}
	for (i=0; i<level.dynamic_barricades.size; i++)
	{
		ent = level.dynamic_barricades[i];
		if (isDefined(ent) && distance(self.origin, ent.origin) < 48 && ent.hp > 0)
		{
			fwdDir = vectorNormalize(targetposition-self.origin);
			dirToTarget = vectorNormalize(ent.origin-self.origin);
			dot = vectorDot(fwdDir, dirToTarget);
			if (dot > 0 && dot < 1)
			{
				return 1;
			}
		}
	}
	return 0;
}

/**
* NEW ZOMBIE AI
*	All parts below are used in the new zombie AI.
*/

/**
* Main zombie ai algorithm, tracks zombie target and makes him move and attack
*	NOTE I did additional comments on ending brackets in an effort to make this a little more readable
*/
zThink()
{
	self endon( "death" );
	self endon( "killed" );
	self endon( "kill_ai" );
	self endon( "disconnect" );

	bored = randomInt(level.dvar["zom_max_boredom"]);	// bored value, makes the zombie look for a random target when full
	targetTime = undefined;								// time the target was last seen
	
	moveDirect = false;
	nextWaypoint = undefined;

	/**
	* AI variables
	*	zTarget, Entity|Struct current target
	*	zTargetOrigin, Vector3 last known target origin
	*	zTargetWaypoint, Integer id of the last valid target waypoint
	*	zTargetOverride, Bool if the current target is forced, e.g Money Bomb
	*	zInterest, Integer interest value in the current target
	*	zRage, Integer value of the current anger
	*	zWaypoint, Integer id of the current waypoint
	*	zOnGrid, Bool true if moving with waypoints
	*	zMovetype, String movetype, crawl, walk, run, sprint
	*/
	
	// start sub ai threads
	self thread zMonitorLegs();			// monitor legs being shot off
	/#
	if( level.dvar["zom_developer"] )
		self thread zDebugThink();
	#/
	
	// get the current waypoint, if needed
	if( !isDefined(self.zWaypoint) )
		self.zWaypoint = getNearestEntityWp( self );
	
	// main thinking loop, updates the zombie target every tick
	for(;;)
	{
		//
		// TARGET AQUISITION & TRACKING
		//
		// check if we have a target and if it's still valid
		if( isDefined(self.zTarget) )
		{
			// check if we can still see the target
			if( self zSpot() )
			{
				// update the last known target origin
				self.zTargetOrigin = self.zTarget.origin;
				
				// try to get the waypoint closest to the target
				waypoint = getNearestEntityWp( self.zTarget );
				
				if( isDefined(waypoint) )
				{
					// update the current target waypoint, if required
					if( !isDefined(self.zTargetWaypoint) || self.zTargetWaypoint != waypoint )
					{
						// update the target waypoint
						self.zTargetWaypoint = waypoint;
					}
				}
				
				tDist = distance( self.zTarget.origin, self.origin );
				if( tDist < getDvarInt("player_meleeRange") )
					self zAttack( self.zTarget );
			}
			else // loose the target, depending on interest and rage
			{
				// slowly loose interest in target while it's not visible
				if( self.zInterest > 0 )
					self.zInterest -= randomInt(10);
				
				// memorize the time the target was lost
				if( !isDefined(targetTime) )
					targetTime = getTime();
				else
				{
					// get the time difference when the zombie was lost
					lostTime = (getTime() - targetTime)/10;
					
					// loose the target, if it's lost longer than zInterest*zRage
					if( lostTime > self.zInterest * self.zRage )
					{
						targetTime = undefined;
						self.zTarget = undefined;
						self.zInterest = 0;
					}
				}
			}
		}	/* if( isDefined(self.zTarget) ) */
		
		// attempt to aquire a target, if we don't have one
		if( !isDefined(self.zTarget) )
		{
			// try to get a suitable target
			target = self zFindTarget();
			if( isDefined(target) )
			{
				self.zTarget = target;
				self.zInterest = int(100* self zSpot());	// set a base interest value depending on the targets visibility
			}
			else if( !isDefined(self.zTargetOrigin) )
			{
				// aquire a random target, if idle for too long
				if( bored >= level.dvar["zom_max_boredom"] )
				{
					// get a random waypoint as target origin
					self.zTargetWaypoint = randomInt(level.waypointCount);
					self.zTargetOrigin = level.waypoints[self.zTargetWaypoint].origin;
					bored = 0;
				}
				
				// increase bored every frame we have no target and no target origin
				bored += randomInt(10);
			}
		}	/* if( !isDefined(self.zTarget) ) */
		else
			bored = 0;	// reset bored time when we have a target
		
		// check for barricades
		barricade = self zBarricadeCheck();
		if( isDefined(barricade) )
		{
			if( barricade.hp > 0 )
				self zAttack( barricade );
			
			// warp through barricades
			if( isDefined(barricade) )
			{
				printLn( "TODO, barricade warping!" );
				wait 0.05;
				continue;
			}
		}	/* isDefined(barricade) */
		
		//
		// WAYPOINTING & MOVEMENT
		//
		// check if we have anywhere to go
		if( isDefined(self.zTargetOrigin) )
		{
			// get the distance to our target origin
			tDist = distance( self.origin, self.zTargetOrigin );
			
			// check if we have arrived
			if( tDist < 4 )
			{
				// clear the target origin
				self.zTargetOrigin = undefined;
				
				// disable direct movement
				moveDirect = false;
			}
			else
			{
				// make sure we have a target waypoint
				if( !isDefined(self.zTargetWaypoint) )
				{
					waypoint = getNearestWp(self.zTargetOrigin);
					if( waypoint > -1 )
						self.zTargetWaypoint = waypoint;
				}
				
				// get the AStarPath to the next waypoint
				if( !isDefined(nextWaypoint) && isDefined(self.zTargetWaypoint) )
					nextWaypoint = AStarSearch( self.zWaypoint, self.zTargetWaypoint );
				
				// get the distance to the next waypoint if possible
				wDist = undefined;
				if( isDefined(nextWaypoint) && nextWaypoint > -1 )
				{
					// get the distance to the next waypoint
					wDist = distance( self.origin, level.waypoints[nextWaypoint].origin );
					
					// check if we have already arrived at the waypoint
					if( wDist < 4 )
					{
						// set the waypoint as our current one
						self.zWaypoint = nextWaypoint;
						
						// clear the nextWaypoint
						nextWaypoint = undefined;
					}
				}
				
				// get back to the waypoint grid if needed
				if( !self.zOnGrid && !moveDirect )
				{
					mdist = distance( self.origin, level.waypoints[self.zWaypoint].origin );
					if( mDist < 4 )
						self.zOnGrid = true;
					else
						self zMove( level.waypoints[self.zWaypoint].origin );
				}
				else
				{
					// move to the target origin if it's closer than the waypoint
					if( !isDefined(wDist) || tDist < wDist )
					{
						moveDirect = true;
						self zMove( self.zTargetOrigin );
						self.zOnGrid = false;
					}
					else
						if( isDefined(nextWaypoint) )	// move to the next waypoint
							self zMove( level.waypoints[nextWaypoint].origin );
				}
			}
		}
		
		// wait for the next server frame
		wait 0.05;
	}	/* for(;;) */
}	/* zThink */

/**
* Attacks the given target until it's out of range
*/
zAttack( target )
{
	self endon( "death" );
	self endon( "killed" );
	self endon( "kill_ai" );
	self endon( "disconnect" );
		
	// get the melee range
	range = getDvarInt( "player_meleeRange" );

	for(;;)
	{
		// check if the target is still alive and defined
		if( !isDefined(target) || (isPlayer(target) && !isAlive(target)) || (!isPlayer(target) && target.hp <= 0) )
			break;
		
		// check if the target is still in range
		tDist = distance( self.origin, target.origin );
		if( tDist > range )
			break;
		
		self botLookAt( target.origin );
		self botAction( "+melee" );
		self thread zSound( "attack", randomFloat(0.5) );
		
		wait 0.05;
		
		self botAction( "-melee" );
		
		// apply damage to non players
		if( !isPlayer(target) )
		{
			target thread scripts\players\_barricades::doBarricadeDamage( self.damage*level.dif_zomDamMod );
		}
		
		// check if the target is still alive
		if( !isDefined(target) || isPlayer(target) && !isAlive(target) || !isPlayer(target) && target.hp <= 0 )
			break;
		
		wait 0.5 + randomFloat( 1.5 );
	}
}	/* zAttack */

/**
* Plays the given zombie sound after the given delay
*/
zSound( sound, delay )
{
	self endon( "death" );
	
	if( isDefined(delay) )
		wait delay;
	
	self playSound( self.soundType + "_" + sound );
}	/* zSound */

/**
* Checks if the zombie is close to a barricade
*/
zBarricadeCheck()
{
	// get the zombies forward vector
	fwdDir = anglesToForward( self getPlayerAngles() );
	
	// go through all static barricades
	for( i=0; i<level.barricades.size; i++ )
	{
		ent = level.barricades[i];
		if( isDefined(ent) && self isTouching(ent) )
		{
			dirToTarget = vectorNormalize( ent.origin-self.origin );
			dot = vectorDot( fwdDir, dirToTarget );
			if( dot > 0 && dot < 1 )
				return ent;
		}
	}
	
	// go through all dynamic barricades
	for( i=0; i<level.dynamic_barricades.size; i++ )
	{
		ent = level.dynamic_barricades[i];
		if( isDefined(ent) && distance(self.origin, ent.origin) < 48 && ent.hp > 0 )
		{
			dirToTarget = vectorNormalize( ent.origin-self.origin );
			dot = vectorDot( fwdDir, dirToTarget );
			if (dot > 0 && dot < 1)
				return ent;
		}
	}
}	/* zBarricadeCheck */

/**
* Displays debugging data for the zombie.
*/
zDebugThink()
{
	self endon( "death" );
	self endon( "killed" );
	self endon( "kill_ai" );
	self endon( "disconnect" );
	
	// update the developer info untill the bot dies or ai is killed
	for(;;)
	{
		// update the text origin
		origin = self.origin + (0,0,64);
		
		// prepare the target text
		if( isDefined(self.zTarget) && isDefined(self.zTarget.name) )
			ttext = "T: " + self.zTarget.name;
		else if( isDefined(self.zTarget) && isDefined(self.zTarget.targetname) )
			ttext = "T: " + self.zTarget.targetname;
		else if( isDefined(self.zTarget) )
			ttext = "T: unknown";
		else
			ttext = "T: undefined";
		
	//	if( isDefined(self.zTargetOrigin) )
	//		ttext = ttext + ", " + self.zTargetOrigin;
		
		// draw the target text
	/#	print3D( origin, ttext, (1.0,1.0,1.0), 1.0, 0.6, 4 );	#/
		
		// prepare and draw the interest text
		itext = "I: "+self.zInterest+" R: "+self.zRage;
	/#	print3D( origin-(0,0,8), itext, (1.0,1.0,1.0), 1.0, 0.6, 4 );	#/
		
		wait 0.05;
	}
}	/* zDebugThink */

/**
* Waits for the zombie to loose a leg, making him go prone
*/
zMonitorLegs()
{
	self endon( "death" );
	self endon( "killed" );
	self endon( "kill_ai" );
	self endon( "disconnect" );
	
	// nothing to do, if the zombie is already crawling
	if( self.zMovetype == "crawl" )
		return;
		
	// nothing to do, if there are no damaged leg models
	if( !isDefined(level.zom_models[self.body].legsOff) && !isDefined(level.zom_models[self.body].legsROff) && !isDefined(level.zom_models[self.body].legsLOff) )
		return;
	
	// wait for the zombie to loose a leg
	self waittill( "lost_leg" );
	
	// stop the bot from walking & sprinting
	self botAction( "-ads" );
	self botAction( "-sprint" );
	
	// put the zombie into prone/crawl stance and save it
	self botAction( "+goprone" );

	self.zMovetype = "crawl";
}	/* zMonitorLegs */

/**
* Calculates the visibility of the given or current zombie target
*/
zSpot( target )
{
	// default to the currently locked on target
	if( !isDefined(target) )
		target = self.zTarget;
	
	// make sure we have a target now
	if( !isDefined(target) )
		return;

	// assume the target is not visible
	visible = 0.0;
	
	// check if target is alive and targetable
	if( !target.isObj )
	{
		if( !target.isAlive )
			return visible;

		if( !target.isTargetable )
			return visible;
	}

	// check if the target is defined as visible by script
	if( !target.visible )
		return visible;
	
	// check if the target is even in front of the bot
	fwdDir = anglesToForward( self getPlayerAngles() );
	dirToTarget = vectorNormalize( target.origin-self.origin );
	dot = vectorDot( fwdDir, dirToTarget );
	if( dot < -0.2 )
		return visible;
		
	
	// get the zombies eye position
	eye = self getTagOrigin( "tag_eye" );
	
	// check how visible the target is
//	if( isPlayer(target) )
		visible = target sightConeTrace( eye, self );
//	else	// just assume everything else is fully visible
//	{
		// NOTE we can possibly use sightConeTrace for certain other objects as well, gotta try that out
//		if( bulletTracePassed( eye, target.origin, false, self ) )
//			visible = 1.0;
//	}
	
	// get personal sight range, based on rage
	sight_range = level.dvar["zom_sight_range"]*max(self.zRage,1);
	
	// make target less visible, the further away
	visible = max( 0.0, visible - distance( self.origin, target.origin )/sight_range );
	
	// show debugging line of sight
	/#
	if( level.dvar["zom_developer"] )
		line( eye, target.origin, (1-visible,visible,0), false, 10 );
	#/
	
	// return the visible value
	return visible;
}	/* zSpot */

/**
* Makes the zombie move to the given origin
*/
zMove( origin )
{
	// make the bot run
	self botAction( "-ads" );
	self botAction( "-sprint" );

	// make the bot sprint or walk (going ads), depending on move type
	if( self.zMovetype == "sprint" )
		self botAction( "+sprint" );
	else if( self.zMovetype == "walk" )
		self botAction( "+ads" );

	// make the bot move to the given origin
	self botLookAt( origin );
	self botMoveTo( origin );
}	/* zMove */

/**
* Returns the most feasible target for the zombie
*/
zFindTarget()
{
	target = undefined;			// best target
	targetValue = 0.01;			// best target value

	// check for players
	players = level.players;
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		if( isDefined(player) && isAlive(player) )
		{
			visible = self zSpot( player );
			if( visible > targetValue )
			{
				target = player;
				targetValue = visible;
			}
		}
	}
	
	// TODO aquire other targets as well
	
	return target;
}	/* zFindTarget */

/**
* Returns the closest target for the zombie.
*/
zFindClosestTarget()
{
	target = undefined;			// closest target
	targetDist = undefined;

	// check for players
	players = level.players;
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		if( isDefined(player) && isAlive(player) )
		{
			dist = distanceSquared( self.origin, player.origin );
			if( !isDefined(targetDist) || targetDist > dist  )
			{
				target = player;
				targetDist = dist;
			}
		}
	}
	
	// TODO possibly aquire other targets as well
	
	return target;
}	/* zFindClosest */

/**
* Alerts all zombies based on the given values
*/
alertZombies( origin, alertDist, alertPower, ignoreBot )
{
	// go through all bots
	for( i=0; i<level.bots.size; i++ )
	{
		zombie = level.bots[i];
		
		// check if this bot should be ignored
		if( isDefined(ignoreBot) && zombie == ignoreBot )
			continue;
		
		// get the distance to the zombie and check if it should be alerted
		dist = distance( origin, zombie.origin );
		if( dist <= alertDist && isAlive(zombie) )
		{
			// override the target if this one can be spotted and the zombie isn't enraged considerable
			if( isDefined(self) && zombie zSpot(self) > 0.0 && zombie.zRage < 3 )
			{
				tdist = 0.0;		// distance to the current target
				
				// get the distance to the current target
				if( isDefined(zombie.zTargetOrigin) )
					tdist = distance( zombie.zTargetOrigin, zombie.origin );
				
				// only override the target if it's closer or we can't spot the old one anymore
				if( !isDefined(zombie.zTarget) || zombie zSpot() == 0.0 || tdist > dist )
				{
					zombie.zTarget = self;
				}
			}
			
			// set a target origin if the zombie doesn't have one
			if( !isDefined(zombie.zTargetOrigin) && !zombie.zTargetOverride )
				zombie.zTargetOrigin = origin;
			
			// increase the zombies interest value
			zombie.zInterest += alertPower;
		}
	}
}	/* alertZombies */

