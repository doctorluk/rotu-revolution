/**
* vim: set ft=cpp:
* file: scripts\players\_players.gsc
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
* 	_players.gsc
*	This is the big script file that handles the general player behaviour like spawning and damage dealing
*	as well as the spawning behaviour, the spawn queue, player-game-effects and more 
*
*/

#include scripts\include\physics;
#include scripts\include\entities;
#include scripts\include\hud;
#include scripts\include\data;
#include scripts\include\strings;
#include scripts\include\useful;
#include scripts\include\weapons;
#include common_scripts\utility;

init()
{
	// Initialize default vars
	level.activePlayers = 0;
	level.activePlayersArray = [];
	level.alivePlayers = 0;
	level.alivePlayersArray = [];
	level.lastAlivePlayers = 0;
	level.playerspawns = "";
	level.intermission = 1;
	level.joinQueue = [];
	level.godmode = level.dvar["game_godmode"];
	
	// Precache icons before starting other processes
	precache();
	
	// Setup var-function-links
	level.callbackPlayerLastStand = ::Callback_PlayerLastStand;
	level.spawnQueue = ::spawnJoinQueueLoop;
	
	// Start important player-side inits from here
	thread scripts\players\_menus::init();
	thread scripts\players\_classes::init();
	thread scripts\players\_abilities::init();
	thread scripts\players\_weapons::init();
	thread scripts\players\_playermodels::init();
	thread scripts\players\_usables::init();
	thread scripts\players\_infection::init();
	thread scripts\players\_persistence::init();
	thread scripts\players\_damagefeedback::init();
	thread scripts\players\_barricades::init();
	thread scripts\players\_turrets::init();
	thread scripts\players\_rank::init();
	
	// Start Player-Alive monitor
	thread updateActiveAliveCounts();
}

/**
*	Precache Icons, Shellshocks and Shaders
*/
precache()
{
	level.flashlightGlow = loadfx("light/flashlight_glow");
	
	precacheHeadIcon("hud_icon_lowhp");
	precacheHeadIcon("hud_icon_developer");
	precacheHeadIcon("hud_icon_low_ammo");

	precacheStatusIcon("icon_medic");
	precacheStatusIcon("icon_engineer");
	precacheStatusIcon("icon_soldier");
	precacheStatusIcon("icon_specialist");
	precacheStatusIcon("icon_armored");
	precacheStatusIcon("icon_down");
	precacheStatusIcon(	"icon_spec");

	precacheShellShock("general_shock");

	precacheShader("overlay_armored");
}

/**
*	Callback being called when a player connects
*/
onPlayerConnect()
{
	// Prevent players from loading when the game has ended
	// TODO: implement better handling of players when connecting to an ended game, show them the mapvoting(?) etc.
	if (level.gameEnded)
		self.sessionstate = "intermission";
	
	// Initialize default vars for the player
	self.isObj = false;
	self.useObjects = [];
	self.class = "none";
	self.curClass = "none";
	self.isAlive = false;
	self.isActive = false;
	self.hasPlayed = false;
	self.blur = 0;
	self.actionslotweapons = [];
	self setStatusIcon("icon_spec");

	// First restore player info, then initialize the rest of the player's clientdvars and other vars
	self thread scripts\players\_persistence::restoreData();
	self thread scripts\players\_shop::playerSetupShop();
	self thread scripts\players\_rank::onPlayerConnect();
	self thread scripts\server\_environment::onPlayerConnect();
	
	// A loop for testing purposes
	self thread testloopOnConnect();
	
	// Wait a frame to send default ui-dvars and other clientdvars
	waittillframeend;
	self setclientdvars("g_scriptMainMenu", game["menu_class"], "cg_thirdperson", 0, "r_filmusetweaks", 0, "ui_class_ranks", (1 - level.dvar["game_class_ranks"]), "ui_specialrecharge", 0, "ui_ammo_show", 0);
	
	// Every new players automatically joins Spectator onConnect
	self joinSpectator();
}

/**
*	Callback being called when a player disconnectes, used to save persistency data
*/
onPlayerDisconnect()
{
	self.stats["name"] = self.name;
	self.persData.stats = self.stats;
}

/**
*	Called by a player joining the Survivors
*/
joinAllies()
{
	// Ignore it when the game has ended
	if (level.gameEnded)
		return;
	
	// Apply necessary settings to this player if he isn't a Survivor already
	if (self.pers["team"] != "allies")
	{
		self.sessionteam = "allies";
		self.pers["team"] = "allies";
		self setclientdvars("g_scriptMainMenu", game["menu_class"]);
	}
}


/**
*	Adds the player to the join queue
*/
addToJoinQueue()
{
	// See if to-be-added player is already in the queue
	if(!arrayContains(level.joinQueue, self))
		level.joinQueue[level.joinQueue.size] = self;
	
	// Show the player the blinking "Pending Spawn" text on his hud
	self setclientdvar("ui_spawnqueue", "@QUEUE_AWAITING_SPAWN_" + allToUpper(self.class));
}

/**
*	Spawn all players placed inside the spawn queue
*/
spawnJoinQueue()
{
	// Run global queue notification
	level notify("spawn_queue");
	
	// Array containing all players that are actually spawned by the queue
	spawners = [];
	
	for(i = 0; i < level.joinQueue.size; i++) // TODO: Apply Viking's suggestions
	{
		player = level.joinQueue[i];
		
		// Better double-check if a player inside the queue has already spawned
		// TODO: THIS SHOULD NEVER HAPPEN!
		if(isReallyPlaying(player))
		{
			logPrint("We tried to spawn someone from the Spawnqueue who is already playing: " + player.name + "\n");
			iprintln("We tried to spawn someone from the Spawnqueue who is already playing: " + player.name);
			continue;
		}
			
		player thread spawnPlayer(true);
		spawners[spawners.size] = player;
	}
	
	for(i = 0; i < level.joinQueue.size; i++)
	{
		level.joinQueue[i] = undefined;
	}
	
	// Put out some names in the bottom left corner to inform people who has been spawned by the queue
	if(spawners.size > 0)
	{
		string = "^3";
		haveOrHas = "have";
		
		// Add each player's class and name to the message
		for(i = 0; i < spawners.size; i++)
			string += spawners[i].name + "^7 as ^3" + (spawners[i] getFullClassName()) + "^7, ^3";
		
		// Since we are adding characters AFTER the player's name in preparation of the next player
		// we remove the additional characters from the end of the string when it's done
		string = getSubStr(string, 0, string.size - 4);
		
		// Make sure we use proper English, d'uh!
		if(i <= 1)
			haveOrHas = "has";
			
		string += " " + haveOrHas + " joined the fight!";
		
		iprintln(string);
	}
}

/** 
*	Spawn the players in certain situations and in certain states of the waves
*/
spawnJoinQueueLoop()
{
	// Prevent this from running during intermissions or after the game
	level endon("wave_finished");
	level endon("game_ended");
	
	// For very small waves or the boss the calculation we use doesn't make any sense, so we use a simple timer in these
	if(level.currentType == "boss" || level.waveSize < 20)
	{
		while(1)
		{
			wait 180;
			spawnJoinQueue();
		}
	}
	
	// Judging from the wave's size, we roughly select certain 'points' when players should be spawned
	if(level.waveSize <= 100)
		intersections = 50;
	else if(level.waveSize > 100 && level.waveSize < 300)
		intersections = 70;
	else
		intersections = 100;
	
	zombiesKilled = 0;
	while(zombiesKilled < level.waveSize)
	{
		level waittill("bot_killed");
		zombiesKilled++;
		
		// When we've met a certain interval, spawn the players
		if(zombiesKilled % intersections == 0)
			spawnJoinQueue();
	}
}

/**
*	Removes the calling player from the Spawnqueue
*/
removeFromQueue()
{
	// Reset the player's ui-dvars and remove the blinking 'PENDING SPAWN' hud element
	self setclientdvars("cg_thirdperson", 0, "ui_spawnqueue", "");
	
	// Remove the player from the queue-list in case he's in there
	if(arrayContains(level.joinQueue, self))
	{
		level.joinQueue = removeFromArray(level.joinQueue, self);
		self iprintlnbold("You have been removed from the queue!");
		
		// A player that is removed from the queue is automatically considered a Spectator, thus moved there
		self joinSpectator();
	}
}

/**
*	Called when a player is being set to Spectator
*/
joinSpectator()
{
	// By default we don't do anything if the game is over and we're inside the mapvoting process
	if(level.gameEnded)
		return;
	
	// Process the player if he's not spectator already
	if(self.pers["team"] != "spectator")
	{
		// In case he was living, save his stats in the persistency area and kill him
		if(isAlive(self))
		{
			self.persData.stats = self.stats;
			self.lastPlayedWave = level.currentWave;
			self.persData.lastPlayedWave = self.lastPlayedWave;
			self suicide();
		}
		
		// Reset everything to default
		self cleanup();
		// TODO Shouldn't the carryObj be removed in cleanup(), too?
		if (isDefined(self.carryObj))
			self.carryObj delete();
		
		self.isActive = false;
		
		// Notify locally and globally that this player is now spectating
		self notify("join_spectator");
		level notify("spawned_spectator", self);
		
		// Assign team vars for Spectator
		self.pers["team"] = "spectator";
		self.sessionteam = "spectator";
		self.sessionstate = "spectator";
		
		// Select one of the existing spectator positions to spawn him at
		spawns = getEntArray("mp_global_intermission", "classname");
		if(spawns.size > 0)
		{
			spawn = spawns[randomint(spawns.size)];
			origin = spawn.origin;
			angles = spawn.angles;
		}
		// Make sure to give coordinates even if the mapper forgot to add spectator-spawn entities
		else
		{
			origin = (0, 50, 50);
			angles = (0, 0, 0);
		}
		
		// Save the player's playtime to his stats
		if(self.hasPlayed)
			self.stats["timeplayed"] += getTime() - self.stats["playtimeStart"];
		
		// Finally spawn the player as spectator at the selected location
		spawnSpectator(origin, angles);
	}
	
	// Update the game's class counter
	if(self.hasPlayed)
		level notify("update_classcounts");
	
	// Starting the debug function to display the current coordinates of a player
	self thread scripts\level\_spectatecoords::giveCoordinatesToSpec();
}

/**
*	Default Spawn function for a Spectator
*	@origin: Vector, the position the player is being spawned at
*	@angles: Vector, the orientation the player is having when spawned
*/
spawnSpectator(origin, angles)
{
	self notify("spawned"); // ?? Is that good?
	resettimeout();
	
	// Assign spectator team vars
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.friendlydamage = undefined;
	
	// Give or take the player permission to spectate the bots
	self allowSpectateTeam("axis", !level.dvar["game_disable_spectating_bots"]);
	
	// Global notification that this player is now spectating
	level notify("spawned_spectator", self);

	self spawn(origin, angles);
}

/**
*	Function to spawn a player
*	@forceSpawn: Boolean, whether the player is spawned no matter what
*/
spawnPlayer(forceSpawn)
{
	// Set default var if argument is not given
	if(!isDefined(forceSpawn))
		forceSpawn = false;
	
	// In case of a regular spawn
	if(!forceSpawn)
	{
		// If the game has ended, the player is not in the queue or the game is in progress and the queue is enabled,
		// do not spawn him
		if(level.gameEnded)
			return;
		
		if(self.sessionteam == "spectator" || arrayContains(level.joinQueue, self))
			return;
		
		if(!level.intermission && level.activePlayers > 2 && level.dvar["game_enable_join_queue"])
		{
			self addToJoinQueue();
			self iprintlnbold("You have been put into an automated joining queue.");
			self iprintlnbold("You will join soon! Just be patient ;)");
			return;
		}
	}
	
	// Start spawning of the player
	self notify("spawned");

	// Setting up the player's team and necessary default vars
	self.team = self.pers["team"];
	self.sessionteam = self.team;
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	
	self.health = 100;
	self.headicon = "";
	self.isPlayer = true;
	
	// Check whether this player has played already and load them
	if(self.persData.hasPlayed)
	{
		self.stats = self.persData.stats;
		self.hasPlayed = true;
	}
	// Initiate first time stats if he's new
	else if(!self.hasPlayed)
	{
		self.persData.stats = self.stats;
		self.hasPlayed = true;
		self.persData.hasPlayed = true;
	}
	// ?? If he has returned to play after going spec, offset his playtime by the time it takes the server to initialize
	else{
		self.stats["playtimeStart"] = getTime() - 5500;
	}
	
	// Initialize a shit-ton of default vars and settings
	self.spawnProtectionTime = getTime();
	self.upgradeHudPoints = 0;
	self.lastBossHit = undefined;
	self.fireCatchCount = 0;
	self.hasDoneCombat = false;
	self.canHaveStealth = true;
	self.visible = true;
	self.isTargetable = true;
	self.inTrance = false;
	self.trance = "";
	self.isDown = false;
	self.isBot = false;
	self.isBusy = false;
	self.hasParachute = false;
	self.isObj = false;
	self.isParachuting = false;
	self.god = false;
	self.infected = false;
	self.isActive = true;
	self.canUse = true;
	self.entoxicated = false;
	self.onTurret = false;
	self.hasRadar = false;
 	self.tweaksOverride = 0;
	self.tweaksPermanent = 0;
	self.tweakBrightness = "0.25";
	self.tweakContrast = "1.4";
	self.tweakDarkTint = "1 1 1";
	self.tweakLightTint = "1 1 1";
	self.tweakDesaturation = "0";
	self.tweakInvert = "0";
	self.tweakFovScale = 1;
	self.canTeleport = true;
	self.canUseSpecial = true;
	self.lastHurtTime = getTime();
	self.incdammod = 1;
	self.c4Array = [];
	self setStatusIcon("icon_" + self.class);
	
	resettimeout();
	
	// Give the player points for missed waves
	self giveDelayedUpgradepoints();

	// Spawn the player at a random point
	if (level.playerspawns == "")
		spawn = getRandomTdmSpawn();
	else
		spawn = getRandomEntity(level.playerspawns);

	origin = spawn.origin;
	angles = spawn.angles;

	self spawn(origin, angles);
	
	// Check whether the player's class he has now was the one he had before, otherwise make sure to return him to default progress
	self.curClass = self.class;
	if(self.persData.class != self.curClass)
	{
		resetUnlocks();
		self.specialRecharge = 100; // Fully load the special on spawn when player has changed class
		self.persData.specialRecharge = self.specialRecharge;
	}
	self.persData.class = self.curClass;

	// Setting random player class model
	self scripts\players\_playermodels::setPlayerClassModel(self.curClass);
	
	// Set default clientdvars
	self setclientdvars("cg_thirdperson", 0, "ui_upgradetext", "Upgrade Points: " + int(self.points), "ui_specialtext", "^1Special Unavailable", "ui_specialrecharge", 1, "ui_spawnqueue", "");
	
	// Load class-specific stats
	self scripts\players\_abilities::loadClassAbilities(self.curClass);
	self SetMoveSpeedScale(self.speed);
	self.health = self.maxhealth;
	
	// Set his Health-bar to 100%
	self updateHealthHud(1);
	
	waittillframeend;

	// Give weapons
	self scripts\players\_weapons::initPlayerWeapons();
	self scripts\players\_weapons::givePlayerWeapons();

	// Notify locally and globally that he's now in the game
	self notify("spawned_player");
	level notify("spawned_player", self);
	
	// Start all important threads a player must have
	self thread scripts\players\_usables::checkForUsableObjects();
	self thread scripts\players\_weapons::watchWeaponUsage();
	self thread scripts\players\_weapons::watchWeaponSwitching();
	self thread scripts\players\_weapons::watchThrowable();
	self thread scripts\players\_weapons::watchMonkey();
	self thread scripts\players\_claymore::init();
	self thread scripts\players\_rank::onPlayerSpawned();
	self thread scripts\players\_abilities::watchSpecialAbility();
	self thread scripts\server\_welcome::onPlayerSpawn();
	self thread scripts\players\_spree::onPlayerSpawn();
	self thread watchHPandAmmo();
	
	// A loop for testing purposes
	self thread testloopOnSpawn();

	// Check for wave-dependent environment vars etc.
	if(level.flashlightEnabled)
		self thread flashlightOn(true);
		
	if(level.freezePlayers)
		self thread freezePlayerForRoundEnd();
		
	if(level.disableWeapons)
		self disableWeapons();
	
	// Lastly make him alive and update the game's class counters
	self.isAlive = true;
	level notify("spawned", self);
	level notify("update_classcounts");
}

/**
*	Debugging-Loop started onPlayerConnect
*/
testloopOnConnect()
{
	self endon("disconnect");
}

/**
*	Debugging-Loop started onPlayerSpawn
*/
testloopOnSpawn()
{
	self endon("disconnect");
	// self setclientdvar("cg_thirdperson", 1);
	
}

/**
*	Callback when a player takes damage (Warning: Huge ._.)
*
*	@eInflictor: Entity, that causes the damage (e.g. a turret)
*	@eAttacker: Entity, that is attacking (e.g. a player)
*	@iDamage: Integer, specifying the amount of damage done
*	@sMeansOfDeath: String, specifying the method of death
*	@sWeapon: String, name of the weapon used to inflict the damage
*	@vPoint: Vector3, Origin the damage is from
*	@vDir: Vector3, Direction the damage is from
*	@sHitLoc: String, Name of limb that has been hit
*/
onPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	// Prevent damage on Spectator Entities
	if( self.sessionteam == "spectator" )
		return;
	
	// adjust zombie damage
	if( sWeapon == "zombie_mp" || sWeapon == "quad_mp" || sWeapon == "dog_mp" )
	{
		if( eAttacker.damage )
			iDamage = int(eAttacker.damage*level.dif_zomDamMod);
		
		eAttacker scripts\bots\_types::onAttack( eAttacker.type, self );
		if( level.dvar["zom_infection"] )
			self scripts\bots\_bots::infection( eAttacker.infectionChance );
	}
	
	// Check for damage between regular and zombified players
	if(isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker.team == self.team)
	{
		// Prevent further processing if friendly fire is on or the attacker is not zombifed
		if (!level.dvar["game_friendlyfire"] && eAttacker != self)
		{
			return;
		}
	}
	else
	{
		// Used to monitor whether zombies are attacking players (for bugged-zombies-check)
		if (!level.hasReceivedDamage)
			level.hasReceivedDamage = 1;
	}
	
	// Check all cases of immunity of the player
	if (self.isDown /*|| self.god || level.godmode */ || (self.spawnProtectionTime + (level.dvar["game_player_spawnprotection_time"] * 1000) > getTime() && level.dvar["game_player_spawnprotection"]))
		return;

	// ??
	if(!isDefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;
	// ??
	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		if(sWeapon == "ak74u_acog_mp" || sWeapon == "barrett_acog_mp" || sWeapon == "at4_mp" || sWeapon == "rpg_mp" || issubstr(sMeansOfDeath, "GRENADE"))	// TODO: What were these weapons, what are they now?
			return;
		
		// Reduce damage by Armored Damage reduction (10%)
		iDamage = int(iDamage * self.damageDoneMP);
		
		// Check for Armored Health & Ability
		if(self.heavyArmor)
		{
			if (self.health / self.maxhealth >= 0.65)
			{
				iDamage = int(iDamage / 2);
				// Flash the screen of the armored in blue to make him notice he's taking reduced damage 
				// TODO: Find better means of notifying the player that he's taking reduced damage
				self thread screenFlash((0, 0, .7), 0.35, 0.5);
			}
		}
		
		// Apply damage-multipliers of certain zombie types
		iDamage = int(iDamage * self.incdammod);
		
		// Play 'hurt' sound of players and keep track of it being last played to prevent it from being spammed
		if(isDefined(self.lastHurtTime) && (self.lastHurtTime < (getTime() - 1000)) && iDamage < self.health)
		{
			self playsound("self_hurt");
			self.lastHurtTime = getTime();
		}
		
		// Reduce damage dealt to players within the forcefield
		if(level.armoredForcefields.size)
		{
			for(i = 0; i < level.armoredForcefields.size; i++)
			{
				ff = level.armoredForcefields[i];
				ffPos = ff.origin;
				playerEye = self getEye();
				playerPos = self getOrigin();
				
				if((playerPos[2] + 15) >= ffPos[2] && distance(ffPos, playerEye) <= level.special["armoredforcefield"]["radius"])
				{
					previousIDamage = iDamage;
					iDamage = int((1 - level.special["armoredforcefield"]["damagereduction"]) * iDamage);
					self iprintln("Damage reduced by " + (previousIDamage - iDamage) + " to " + iDamage + " for being in forcefield"); 
					break;
				}
			}
		}
		
		// Medics take half damage while reviving
		if(self.reviveWill && isDefined(self.curEnt) && self.curEnt.type == "revive" && self.isBusy)
			iDamage = int(iDamage * 0.5);
		
		// Make sure that damage cannot be less than 1
		iDamage = int(max(iDamage, 1));
		
		if(self.god || level.godmode) // TODO: For debugging purposes further down, move up to reduce compute load
			return;
		
		// Calculation is done, make the actual damage happen
		self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, level.weaponKeyS2C[sWeapon], vPoint, vDir, sHitLoc, psOffsetTime );
		
		// Update the health bar of that player
		updateHealthHud(self.health / self.maxhealth);
	}
	// TODO what if iDFLAGS_NO_PROTECTION is set...?
}

/**
*	Handling of Players being killed, this is ONLY called when a player has turned into
*	a zombie and is killed by other players
*
*	@eInflictor: Entity, that causes the damage (e.g. a turret)
*	@attacker: Entity, that is attacking (e.g. a player)
*	@iDamage: Integer, specifying the amount of damage done
*	@sMeansOfDeath: String, specifying the method of death
*	@sWeapon: String, name of the weapon used to inflict the damage
*	@vDir: Vector3, Direction the damage is from
*	@sHitLoc: String, Name of limb that has been hit
*	@psOffsetTime: ?
*	@deathAnimDuration: Float, duration of the death animation
*/
onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Prevent this from running if a player disconnects mid-cleanup
	self endon("death");
	self endon("disconnect");
	
	// Make sure the player resets entirely
	self cleanup();
	
	self endon("spawned"); // ??
	self notify("killed_player"); // ??

	// Prevent further handling if a player has joined the Spectators
	if(self.sessionteam == "spectator")
		return;

	// TODO: Is this needed at all?
	if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
		sMeansOfDeath = "MOD_HEAD_SHOT";
	if (level.dvar["zom_orbituary"])
		obituary(self, attacker, sWeapon, sMeansOfDeath);
	//
	
	self.sessionstate = "dead";
	
	body = self clonePlayer(deathAnimDuration);

	if (self isOnLadder() || self isMantling())
		body startRagdoll();

	thread delayStartRagdoll(body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath);
}

/**
*	Handling of players going down when gaining fatal damage
*
*	@eInflictor: Entity, that causes the damage (e.g. a turret)
*	@attacker: Entity, that is attacking (e.g. a player)
*	@iDamage: Integer, specifying the amount of damage done
*	@sMeansOfDeath: String, specifying the method of death
*	@sWeapon: String, name of the weapon used to inflict the damage
*	@vDir: Vector3, Direction the damage is from
*	@sHitLoc: String, Name of limb that has been hit
*	@psOffsetTime: ?
*	@deathAnimDuration: Float, duration of the death animation
*/
Callback_PlayerLastStand(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// Notify other threads that the player is down
	level scripts\players\_usables::removeUsable(self);
	level notify("downed", self);
	self notify("downed");
	self setDown(true);
	self scripts\players\_usables::usableAbort();
	self.isTargetable = false;
	
	// Save the currently held weapons to restore later when he's revived
	self.lastStandWeapons = self getweaponslist();
	self.lastStandAmmoStock = [];
	self.lastStandAmmoClip = [];
	for(i = 0; i < self.lastStandWeapons.size; i++)
	{
		self.lastStandAmmoClip[i] = self getWeaponAmmoClip(self.lastStandWeapons[i]);
		self.lastStandAmmoStock[i] = self getWeaponAmmoStock(self.lastStandWeapons[i]);
	}
	self.lastStandWeapon = self GetCurrentWeapon();
	
	// Remove Hud-elements that are no longer needed
	self setclientdvars("ui_hintstring", "", "ui_specialtext", "^1Special Unavailable");
	self.hinttext.alpha = 0;
	self.health = 10;
	self updateHealthHud(0);
	self removeTimers();
	
	// Reset any Specials
	self scripts\players\_abilities::stopActiveAbility();
	self setclientdvar("ui_specialrecharge", 0);
	
	// Save this event in the player's stats
	self.deaths++;
	self.stats["deaths"]++;
	self.isAlive = false;
	self.stats["lastDowntime"] = getTime();
	
	// Give the player a secondary weapon to shoot with while being down
	weaponslist = self getWeaponslist();
	for(i = 0; i < weaponslist.size; i++)
	{
		weapon = level.weaponKeyC2S[weaponslist[i]];
		
		if( weapon == self.secondary )
			self switchToWeap(weapon);
		else
			self takeWeap(weapon);
	}
	
	// Notify other players that this player is down
	iPrintln(self.name + " ^7is down!");
	self playsound("self_down");
	self setStatusIcon("icon_down");
	level scripts\players\_usables::addUsable(self, "revive", &"USE_REVIVE", 96);
	self thread compassBlinkMe();
}

/**
*	General Player cleanup, used whenever a player is being revived or returns to a normal player when being zombified etc. etc.
*/
cleanup()
{
	// Remove the player from the usable game object list
	scripts\players\_usables::removeUsable(self);
	
	// Stop the player from using anything
	self scripts\players\_usables::usableAbort();
	
	// Empty the player's actionslotweapons (C4, Claymores etc.)
	self.actionslotweapons = [];
		
	// Destroy any existing hud elements
	if (isDefined(self.infection_overlay))
		self.infection_overlay destroy();
	
	if(isDefined(self.armored_hud))
		self.armored_hud destroy();
		
	self destroyProgressBar();
	self removeTimers();
	self flashlightOff();
	self setStatusIcon("");
	self.headicon = "";
	
	// Remove the tomb if the player was zombified
	if (isDefined(self.tombEnt))
		self.tombEnt delete();
	
	// Make the player a non-valid target for bots
	self.isTargetable = false;
	
	// Replace all clientdvars with default values
	self setclientdvars("r_filmusetweaks", 0, "ui_upgradetext", "", "ui_specialtext", "", "cg_draw2d", 1, "g_compassShowEnemies", 0, "ui_uav_client", 0, "ui_wavetext", "", "ui_waveprogress", 0, "ui_spawnqueue", "", "ui_ammo_show", 0);
	
	// Remove the player from the activity list and mark him as dead, also save all of his equipment via persistency
	if (self.isActive)
	{
		self.isActive = false;
		if (self.isAlive)
		{
			self.isAlive = false;
			
			if (self.primary != "none")
			{
				self.persData.primaryAmmoClip = self getweaponammoclip(self.primary);
				self.persData.primaryAmmoStock = self getweaponammostock(self.primary);
			}
			
			if (self.secondary != "none")
			{
				self.persData.secondaryAmmoClip = self getweaponammoclip(self.secondary);
				self.persData.secondaryAmmoStock = self getweaponammostock(self.secondary);
			}
			
			if (self.extra != "none")
			{
				self.persData.extraAmmoClip = self getweaponammoclip(self.extra);
				self.persData.extraAmmoStock = self getweaponammostock(self.extra);
			}
		}
	}
	
	// End invisibility for Assassins
	self notify("end_trance");
	
	// Remove health hud
	self updateHealthHud(-1);
	self unfreezePlayerForRoundEnd();
	
	// If the last chance is running, remove the player from the potential list of money-recipients
	if(isDefined(level.cantPayLC) && arrayContains(level.cantPayLC, self))
		level.cantPayLC = removeFromArray(level.cantPayLC, self);
}

/**
*	Callback when a player goes down, updating his persistency stat
*
*	@isDown: Boolean, whether the player is down or not
*/
setDown(isDown)
{
	self.isDown = isDown;
	self.persData.isDown = isDown;
	
	if (isDown)
		self.downOrigin = self.origin;
}

/**
*	Makes the playersymbol blink in "!" signs to signalize that this player is currently down
*/
compassBlinkMe()
{
	self endon("revived");
	self endon("disconnect");
	self endon("death");
	self endon("spawned");
	
	while(1)
	{
		self pingPlayer();
		wait 3;
	}
}

/**
*	Fully restores a player's ammo for all weapons, except for weapons that do not allow being refilled
*/
restoreAmmo()
{
	weapons = self getWeaponslist();
	for(i = 0; i < weapons.size; i++)
	{
		// Ignore all weapons that are not allowed to refill their ammo, e.g. special weapons
		if (self scripts\players\_weapons::canRestoreAmmo(weapons[i]))
		{
			self giveMaxAmmo(weapons[i]);
			self setWeaponAmmoClip(weapons[i], weaponClipSize(weapons[i]));
		}
	}
}

/**
*	Checks whether the player's inventory contains an item that can be refilled with new ammo
*
*	@return: Boolean, whether a player has any weapon in his inventory that is missing ammo, 
*	except for weapons that do not allow being refilled
*/
hasFullAmmo()
{
	weapons = self getWeaponslist();
	for(i = 0; i < weapons.size; i++)
	{
		// We need to run a different check for weapons that do not have stock ammo, like C4
		if(isWeaponClipOnly(weapons[i]))
		{
			if(self GetAmmoCount(weapons[i]) != WeaponMaxAmmo(weapons[i]))
				return false;
		}
		else if (self scripts\players\_weapons::canRestoreAmmo(weapons[i]) && (self GetFractionMaxAmmo(weapons[i]) != 1 || weaponClipSize(weapons[i]) != self GetWeaponAmmoClip(weapons[i])))
			return false;
	}
	return true;
}

/**
*	Checks whether the player's currently selected weapon is low on ammo
*
*	@return: Boolean, whether a player's current weapon has less or equal to 30% of its maximum capacity
*/
hasLowAmmo()
{
	if(scripts\players\_weapons::canRestoreAmmo(self getCurrentWeapon()))
	{
		max = self getFractionMaxAmmo(self getCurrentWeapon());
		if(max <= 0.3)
			return true;
	}
	
	return false;
}

/**
*	Loops through all players and finds a player with the highest/lowest stat, depending on what it is looking for
*	TODO: Put this into the _gamemodes.gsc since the ending is handled there, too?
*
*	@type: String, the type of stat that is being looked for
*	@returns: String, either 'player' or 'amount'
*	@return: [?] Entity, if @returns is 'player', the best player based on a minimum or maximum threshold for certain stats
*	@return: [?] Int, if @returns is 'amount', the value of a stat of the best player that is found
*/
getBestPlayer(type, returns)
{
	// Prevent faulty arguments
	if(!isDefined(type))
		return undefined;
	if(!isDefined(returns))
		returns = "player";
	
	// Define default vars
	player = undefined;
	amount = 0;
	amount2 = 999999999;
	
	// Loop through every single player
	for(i = 0; i < level.players.size; i++)
	{
		// Exclude bots and players that never played
		if(level.players[i].isBot || !level.players[i].hasPlayed)
			continue;
			
		// Depending on what we are looking for (type), enter the player into our list if he has more/less than the one checked before
		// resulting in the highest/lowest player being found for the stats
		switch(type)
		{
			case "kills":
				if(level.players[i].kills > amount)
				{
					player = level.players[i];
					amount = level.players[i].kills;
				}
				break;
			case "deaths":
				if(level.players[i].deaths > amount && !isDefined(level.players[i].statsSurvivorWinner))
				{
					player = level.players[i];
					amount = level.players[i].deaths;
				}
				break;
			case "assists":
				if(level.players[i].assists > amount)
				{
					player = level.players[i];
					amount = level.players[i].assists;
				}
				break;
			case "downtime":
				if(level.players[i].stats["downtime"] > amount && level.players[i].stats["downtime"] > 1000)
				{
					player = level.players[i];
					amount = level.players[i].stats["downtime"];
				}
				break;
			case "heals":
				if(level.players[i].stats["healsGiven"] > amount)
				{
					player = level.players[i];
					amount = level.players[i].stats["healsGiven"];
				}
				break;
			case "ammo":
				if(level.players[i].stats["ammoGiven"] > amount)
				{
					player = level.players[i];
					amount = level.players[i].stats["ammoGiven"];
				}
				break;
			case "timeplayed":
				if(level.players[i].stats["timeplayed"] > amount)
				{
					player = level.players[i];
					
					// Workaround for server-initiate delay
					if(level.players[i].stats["timeplayed"] > (level.gameEndTime - level.startTime))
						amount = level.gameEndTime - level.startTime;
					else
						amount = level.players[i].stats["timeplayed"];
				}
				break;
			case "damagedealt":
				if(level.players[i].stats["damageDealt"] > amount)
				{
					player = level.players[i];
					amount = level.players[i].stats["damageDealt"];
				}
				break;
			case "damagedealtToBoss":
				if(level.players[i].stats["damageDealtToBoss"] > amount)
				{
					player = level.players[i];
					amount = level.players[i].stats["damageDealtToBoss"];
				}
				break;
			case "turretkills":
				if(level.players[i].stats["turretKills"] > amount)
				{
					player = level.players[i];
					amount = level.players[i].stats["turretKills"];
				}
				break;
			case "upgradepointsspent":
				if(level.players[i].stats["upgradepointsSpent"] > amount)
				{
					player = level.players[i];
					amount = level.players[i].stats["upgradepointsSpent"];
				}
				break;
			case "upgradepoints":
				if(level.players[i].points > amount)
				{
					player = level.players[i];
					amount = level.players[i].points;
				}
				break;
			case "explosivekills":
				if(level.players[i].stats["explosiveKills"] > amount)
				{
					player = level.players[i];
					amount = level.players[i].stats["explosiveKills"];
				}
				break;
			case "knifekills":
				if(level.players[i].stats["knifeKills"] > amount)
				{
					player = level.players[i];
					amount = level.players[i].stats["knifeKills"];
				}
				break;
			case "survivor":
				if(level.players[i].deaths < amount2 && !isDefined(level.players[i].statsDeathsWinner))
				{
					player = level.players[i];
					amount2 = level.players[i].deaths;
				}
				break;
			case "zombiefied":
				if(level.players[i].stats["timesZombie"] > amount)
				{
					player = level.players[i];
					amount2 = level.players[i].stats["timesZombie"];
				}
				break;
			case "ignitions":
				if(level.players[i].stats["ignitions"] > amount)
				{
					player = level.players[i];
					amount2 = level.players[i].stats["ignitions"];
				}
				break;
			case "poisons":
				if(level.players[i].stats["poisons"] > amount)
				{
					player = level.players[i];
					amount2 = level.players[i].stats["poisons"];
				}
				break;
			case "headshots":
				if(level.players[i].stats["headshotKills"] > amount)
				{
					player = level.players[i];
					amount2 = level.players[i].stats["headshotKills"];
				}
				break;
			case "barriers":
				if(level.players[i].stats["barriersRestored"] > amount)
				{
					player = level.players[i];
					amount2 = level.players[i].stats["barriersRestored"];
				}
				break;
			case "firstminigun":
				if(isDefined(level.gotFirstMinigun))
				{
					player = level.gotFirstMinigun;
					amount = "";
				}
				break;
			case "moredeathsthankills":
				if(level.players[i].deaths > level.players[i].kills)
				
					// DO NOT DIVIDE BY 0!
					if(level.players[i].kills > 0)
					{
						// We want the person with most deaths per kill, in case there is more than 1 guy on the Srv with Deaths > Kills
						if((level.players[i].deaths / level.players[i].kills) > amount)
						{
							player = level.players[i];
							amount = "";
						}
					}
					// In case there is a player with 0 Kills and more than 0 deaths, but no other player on the Server with Deaths > Kills, still give him the award, even though he has 0 Kills
					else if(!isDefined(player))
						player = level.players[i];
				break;
			default:
				break;
		}
	}
	
	if(returns == "player")
	{
		if(type == "deaths" && isDefined(player))
			player.statsDeathsWinner = true;
		if(type == "survivor" && isDefined(player))
			player.statsSurvivorWinner = true;
		return player;
	}
	else if (returns == "amount")
	{
		if(amount2 != 999999999)
			return amount2;
		else
			return amount;
	}
	
	iprintlnbold("^1ERROR: ^7Invalid use of getBestPlayer()");
	return undefined;
}

/**
*	Loop that regularly updates a player's headicon to notify other players of him having low health and/or low ammo
*/
watchHPandAmmo()
{
	// Only run when a player is playing
	self endon("death");
	self endon("disconnect");
	
	// Initialize default value for this player
	if(!isDefined(self.overwriteHeadicon))
		self.overwriteHeadicon = "";
	
	// Loop infinitely
	while(1)
	{
		wait 1;
		
		// If the player is infected, we don't want other icons to appear above his head
		if(!self.infected)
		{
			if(self.isDown)
			{
				if(self.headicon != self.overwriteHeadicon)
					self.headicon = self.overwriteHeadicon;
				continue;
			}
			// Critically low HP
			if(self.health <= 40)
			{
				// If his old headicon was for ammo, put it for HP now
				if(self.headicon == self.overwriteHeadicon || self.headicon == "hud_icon_low_ammo")
				{
					self.headicon = "hud_icon_lowhp";
					continue;
				}
				
				// If his old headicon was for HP, put it for ammo now
				if(self.headicon != "hud_icon_low_ammo" && self hasLowAmmo())
					self.headicon = "hud_icon_low_ammo";
				else
					self.headicon = self.overwriteHeadicon;
				
				continue;
			}
			// Could use some health, lol
			else if(self.health <= 75)
			{
				// If he has a different headicon that for low HP, give the HP icon
				if(self.headicon != "hud_icon_lowhp")
				{
					self.headicon = "hud_icon_lowhp";
					continue;
				}
				
				// If he has the HP icon already, but also has low ammo, make it change to ammo
				if(self.headicon != "hud_icon_low_ammo" && self hasLowAmmo())
					self.headicon = "hud_icon_low_ammo";
					
				continue;
			}
			// In case he is >75% health, only show the low-ammo icon
			else if(self hasLowAmmo())
			{
				self.headicon = "hud_icon_low_ammo";
				continue;
			}
			
			// Will only get here if person doesn't need a headicon, if he has one, remove it
			if (self.headicon != self.overwriteHeadicon)
				self.headicon = self.overwriteHeadicon;
		}
	}
}

/**
*	Area damage function against bots, used by Explosive Barrels
*	TODO: Move to _barricade.gsc (?) where Explosive Barrels are located, too
*
*	@range: Float, range the area damage has
*	@damage: Int, the amount of damage that is dealt
*	@attacker: Entity, the entity that is dealing the damage
*/
doAreaDamage(range, damage, attacker)
{
	for (i = 0; i <= level.bots.size; i++)
	{
		target = level.bots[i];
		
		if (isDefined(target) && isAlive(target))
		{
			distance = distance(self.origin, target.origin);
			
			if (isDefined(distance) && distance < range)
			{
				// WHAT THE ACTUAL FUCK? Here we set the Bot to be a PLAYER? wowowowo, dude....
				// target.isPlayer = true;
				
				target.entity = target;
				target damageEnt(self, attacker, damage, "MOD_EXPLOSIVE", "none", self.origin, vectorNormalize(target.origin - self.origin));
			}
		}
	}
}

/**
*	Give all playing players the flashlight for the scary wave
*	@on: Boolean, whether the flashlight is turned on or off
*/
flashlightForAll(on)
{
	// Prevent missing argument
	if(!isDefined(on))
		return;
	
	// Grants/removes the flashlight for all playing players
	for(i = 0; i < level.players.size; i++)
	{
		if(!isReallyPlaying(level.players[i]))
			continue;
			
		if(on)
			level.players[i] thread flashlightOn();
		else
			level.players[i] thread flashlightOff();
	}
}

/**
*	Called when the scary wave initializes
*
*	@noWait: Boolean, is defined when there should be close to no delay, otherwise a random delay will be used
*/
flashlightOn(noWait)
{
	// Prevent multiple or wrongly creating a flashlight
	if(isDefined(self.flashlight) || !isReallyPlaying(self))
		return;
	
	// Give it some random delay or not
	if(!isDefined(noWait))
		wait randomFloat(6);
	else
		wait 0.1;
	
	// Spawn in an object that holds the flashlight effect
	self.flashlight = spawn("script_model", self getTagOrigin("j_spinelower"));
	self.flashlight setModel("tag_origin");
	
	wait 0.05;
	
	PlayFXOnTag(level.flashlightGlow, self.flashlight, "tag_origin");
	self.flashlight linkTo(self);
	self playsound("flashlight_on");
	
	// Make sure to remove the glow on death
	self thread removeLightOnDeath();
}

/**
*	Removes the flashlight on death
*/
removeLightOnDeath()
{
	// Don't remove it if a player was cleaned up or simply disconnected
	self endon("disconnect");
	self endon("join_spectator");
	self endon("downed");

	self waittill("death");
	
	if(isDefined(self.flashlight))
		self.flashlight delete();
}

/**
*	Removes the flashlight effect if defined
*/
flashlightOff()
{
	if(!isDefined(self.flashlight))
		return;
	
	self.flashlight delete();
}

/**
*	Done for debugging purposes. Shows the player the current mapname and his location and angles
*/
reportMyCoordinates()
{

	origin = self getOrigin();
	angle = self getPlayerAngles();
	
	mapname = getDvar("mapname");
	
	logPrint("GETENDVIEW;" + origin[0] + "," + origin[1] + "," + origin[2] + ";" + angle[0] + "," + angle[1] + "," + angle[2] + " for " + mapname + "\n");
	self iprintlnbold("Screenshot this for Luk:");
	self iprintlnbold(origin[0] + "," + origin[1] + "," + origin[2] + ";" + angle[0] + "," + angle[1] + "," + angle[2]);
	self iprintlnbold("Map: " + mapname);
}

/**
*	Resets all weapon progress to 0
*/
resetUnlocks()
{
	// Reset current and persistency unlocks
	self.unlock["primary"] = 0;
	self.unlock["secondary"] = 0;
	self.unlock["extra"] = 0;
	self.persData.unlock["primary"] = 0;
	self.persData.unlock["secondary"] = 0;
	self.persData.unlock["extra"] = 0;

	// If we use the magic box, give the player the weapons that are assigned via config
	if(level.dvar["surv_weaponmode"] == "wawzombies")
	{
		self.persData.primary = getDvar("surv_waw_spawnprimary");
		self.persData.secondary = getDvar("surv_waw_spawnsecondary");
	}
	else
	{
		self.persData.primary = getDvar("surv_" + self.class + "_unlockprimary" + self.unlock["primary"]);
		self.persData.secondary = getDvar("surv_" + self.class + "_unlocksecondary" + self.unlock["secondary"]);
	}

	if(self.persData.primary != "none" && self.persData.primary != "")
	{
		self.persData.primaryAmmoClip = weapClipSize(self.persData.primary);
		self.persData.primaryAmmoStock = weapMaxAmmo(self.persData.primary);
	}
	else
	{
		self.persData.primaryAmmoClip = 0;
		self.persData.primaryAmmoStock = 0;
	}

	if(self.persData.secondary != "none" && self.persData.secondary != "")
	{
		self.persData.secondaryAmmoClip = weapClipSize(self.persData.secondary);
		self.persData.secondaryAmmoStock = weapMaxAmmo(self.persData.secondary);
	}
	else
	{
		self.persData.secondaryAmmoClip = 0;
		self.persData.secondaryAmmoStock = 0;
	}
	
	// If we set this the shop wouldn't work correctly!
	self.persData.extra = "";			
	self.persData.extraAmmoClip = 0;
	self.persData.extraAmmoStock = 0;	
}

/**
*	Simple function to set the player's status icon
*
*	@icon: String, the material name of the icon
*/
setStatusIcon(icon)
{
	self.statusicon = icon;
}

/**
*	@direction: Vector, propells the player towards the given Vector
*/
bounce(direction)
{
	self endon("disconnect");
	self endon("death");
	
	// Give the player two boosts towards 'direction'
	for (i = 0; i < 2; i++)
	{
		self.health = (self.health + 899);
		self finishPlayerDamage(self, self, 899, 0, "MOD_PROJECTILE", "rpg_mp", direction, direction, "none", 0);
		wait 0.05;
	}
}

/**
*	A timed loop that restores all HP for a player
*
*	@speed: Int, amount of HP healed per step
*/
fullHeal(speed)
{
	self endon("death");
	self endon("disconnect");
	self endon("downed");

	while(1)
	{
		self.health += speed;
		
		// Stop at >= 100% Health
		if(self.health >= self.maxhealth)
		{
			self.health = self.maxhealth;
			updateHealthHud(1);
			break;
		}
		
		updateHealthHud(self.health / self.maxhealth);
		wait .1;
	}
}

/**
*	@amount: Int, heals the calling player by the given amount
*/
healPlayer(amount)
{
	// Make sure we only heal by whole numbers
	amount = int(amount);
	self.health += amount;
	
	// Prevent healing > 100%
	if(self.health > self.maxhealth)
		self.health = self.maxhealth;
	
	// Shows a little "+" spawning next to the health bar and updates the bar's display
	self thread healthFeedback();
	updateHealthHud(self.health / self.maxhealth);
}

/**
*	@inc: Int, increases/decreases the calling player's upgradepoints by the given amount
*/
incUpgradePoints(inc)
{
	// Make sure inc is a valid number and not <> than 1/-1
	if (!isDefined(inc) || abs(inc) < 1)
		return;
		
	self.points += inc;
	self.persData.points += inc;
	
	// Whether we in- or decrease the upgradepoints, add it to our score or add it to the spent amount of money
	if(inc > 0)
	{
		self.score += inc;
		self.stats["score"] = self.score;
		self.stats["upgradepointsReceived"] += inc;
	}
	if(inc < 0)
		self.stats["upgradepointsSpent"] += abs(inc);
		
	thread upgradeHud(inc);
}

/** 
*	For each wave missed, we give the players more upgradepoints (if enabled) 
*/
giveDelayedUpgradepoints()
{
	// Check whether we actually missed waves
	if((level.currentWave - self.lastPlayedWave) <= 1)
		return;
	
	// Give us the points that we deserve!
	if(level.dvar["game_delayed_upgradepoints"])
		self incUpgradePoints(((level.currentWave - self.lastPlayedWave - 1) * level.dvar["game_delayed_upgradepoints_amount"]));
}

/** 
*	@return: Int, the total amount of upgradepoints all players ever(!) have earned
*/
getTotalUpgradePoints()
{
	totalpoints = 0;
	
	for(i = 0; i < level.players.size; i++)
	{
		player = level.players[i];
		
		if(player.isActive)
			totalpoints += player.stats["upgradepointsReceived"];
	}
	
	return totalpoints;
}

/**
*	@return: Int, the (basic) average amount of upgradepoints per player
*/
getAverageUpgradePoints()
{
	total = 0;
	playercount = 0;
	
	for(i = 0; i < level.players.size; i++)
	{
		player = level.players[i];
		
		if(player.isActive)
		{
			total += player.points;
			playercount++;
		}
	}
	
	return int(total / playercount);
}

/**
*	@return: Int, the total amount of upgradepoints all players have in total
*/
getRemainingUpgradePoints()
{
	totalpoints = 0;
	
	for(i = 0; i < level.players.size; i++)
	{
		player = level.players[i];
		
		if(player.isActive)
			totalpoints += player.points;
	}
	
	return totalpoints;
}

/**
*	This is being called when a player successfully held USE to revive a player, or when the endgame-revive kicks in
*
*	@by: Entity, optionally refers to the player that has revived the calling player
*/
revive(by)
{
	// Don't do anything if the game is already over
	if (level.gameEnded)
		return;
		
	self.isAlive = true;
	
	// Load the old weapons the player had when going down
	weapons = self.lastStandWeapons;
	ammoClip = self.lastStandAmmoClip;
	ammoStock = self.lastStandAmmoStock;
	keptWeapons = self getWeaponsList();
	keptAmmoStock = [];
	keptAmmoClip = [];
	for(i = 0; i < keptWeapons.size; i++)
	{
		keptAmmoClip[i] = self getWeaponAmmoClip(keptWeapons[i]);
		keptAmmoStock[i] = self getWeaponAmmoStock(keptWeapons[i]);
	}
	
	// Remove the weapons he had during last-stand (being down)
	self takeallweapons();

	// ??
	if (self.lastStandWeapon == "none")
	{
		if (weapons.size == 0 && keptWeapons.size != 0)
			self.lastStandWeapon = keptWeapons[0];
		else 
			self.lastStandWeapon = weapons[0];
	}
	
	// Spawn the player again at his current position and orientation
	self spawn(self.origin, self.angles);
	
	// Return his previously held weapons
	for(i = 0; i < keptWeapons.size; i++)
	{
		self giveweapon(keptWeapons[i]);
		self setWeaponAmmoClip(keptWeapons[i], keptAmmoClip[i]);
		self setWeaponAmmoStock(keptWeapons[i],  keptAmmoStock[i]);
	}
	
	for(i = 0; i < weapons.size; i++)
	{
		if (!self hasWeapon(weapons[i]))
		{
			self giveWeapon(weapons[i]);
			self setWeaponAmmoClip(weapons[i], ammoClip[i]);
			self setWeaponAmmoStock(weapons[i],  ammoStock[i]);
		}
	}
	
	self setspawnweapon(self.lastStandWeapon);
	self switchtoweapon(self.lastStandWeapon);
	
	// Remove anything related to being down and make him targetable by Bots again
	self setDown(false);
	self.stats["downtime"] += getTime() - self.stats["lastDowntime"];
	level scripts\players\_usables::removeUsable(self);
	self.isTargetable = true;
	
	// Notify locally that he's up again
	self notify("revived");
	
	// Check whether he's still infected, make him curable again
	if (self.infected)
		level scripts\players\_usables::addUsable(self, "infected", &"USE_CURE", 96);
	
	// Reload his Class' abilities
	self scripts\players\_abilities::loadClassAbilities(self.curClass);
	self setMoveSpeedScale(self.speed);
	self.health = self.maxhealth;
	setStatusIcon("icon_" + self.class);
	
	// Reset health and special bar
	self updateHealthHud(1);
	self setclientdvar("ui_specialrecharge", self.specialRecharge / 100);
	
	// Re-initialize player-side threads
	self thread scripts\players\_usables::checkForUsableObjects();
	self thread scripts\players\_weapons::watchWeaponUsage();
	self thread scripts\players\_weapons::watchWeaponSwitching();
	self thread scripts\players\_abilities::watchSpecialAbility();
	// Reassign actionslotweapons if he has any
	if(self.actionslotweapons.size > 0)
		self setActionSlot(4, "weapon", self.actionslotweapons[0]);
	
	// Give credit to the player that has revived the calling player
	if(isDefined(by))
	{
		// Acknowledge the revive by saying 'thanks'... being polite and shit
		self playsound("self_thanks_revived");
		
		// Players being revived gain a certain grace time where they can't be damaged, start calculating now
		self.spawnProtectionTime = getTime();
		
		// Give the promised reward to the reviving player if he's medic
		if(isReallyPlaying(by) && by.curClass == "medic")
			by scripts\players\_abilities::rechargeSpecial(8);
			
		by.stats["revives"]++;
	}
	
	wait 0.05;
	self switchToWeapon(self.lastStandWeapon);
}

/**
*	When a scary wave is being started, make the hud of all players flicker (turn on and off) randomly
*
*	@duration: Int, defines the time in milliseconds the flickering will occur
*/
flickeringHud(duration)
{
	// Since this is a function with loops and waits, we cancel it when it's no longer needed
	self endon("disconnect");
	self endon("death");
	
	// Run the loop for 'duration' time
	start = getTime();
	while(start + duration >= getTime())
	{
		ran1 = randomint(2);
		
		// ran1 is an integer with a value of 0 or 1 and 0 refers to false and 1 to true, so no "==" check is required
		if(ran1)
			self setclientdvar("cg_draw2d", 0);
		else
			self setclientdvar("cg_draw2d", 1);
		
		// Add a minimal delay and some random delay
		wait 0.05 + randomfloat(0.2);
	}
	
	// After the flickering, reset it to "on"
	self setclientdvar("cg_draw2d", 1);
}

/** 
*	Counts through all players, checking whether they are active and/or alive and updates the game's vars accordingly
*	TODO: Implement callbacks to update these on-Spawn/-Connect/-Death or -Disconnect
*/
updateActiveAliveCounts()
{
	// Run this until the game ends
	level endon("game_ended");
	
	// Make sure we never run this thread multiple times
	level notify("update_active_alive_counts");
	level endon("update_active_alive_counts");
	
	// Checks through all players and checks who of them is active and who of them is alive, gently (lol) incrementing the respective var counts
	while(1)
	{
		level.activePlayers = 0;
		level.alivePlayers = 0;
		level.alivePlayersArray = undefined;
		level.activePlayersArray = undefined;
		level.alivePlayersArray = [];
		level.activePlayersArray = [];
		
		for(i = 0; i < level.players.size; i++)
		{
			p = level.players[i];
			
			// Ignore Spectators
			if(!isReallyPlaying (p))
				continue;
				
			if(p.isActive)
			{
				level.activePlayers++;
				level.activePlayersArray[level.activePlayersArray.size] = p;
				
				// isAlive can only be true when a player isActive, too
				if(p.isAlive)
				{
					level.alivePlayers++;
					level.alivePlayersArray[level.alivePlayersArray.size] = p;
				}
			}
		}
		
		wait 0.5;
		
		if(level.lastAlivePlayers > 1 && level.activePlayers > 2 && level.alivePlayers == 1)
			level.alivePlayersArray[0] thread [[level.callbackLastManStanding]]();
			
		level.lastAlivePlayers = level.alivePlayers;
	}
}
