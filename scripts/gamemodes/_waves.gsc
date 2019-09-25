/**
* vim: set ft=cpp:
* file: scripts\gamemodes\_waves.gsc
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
* 	_waves.gsc
*	Handles all wave mechanics before, during and after every wave
*
*/

#include scripts\include\hud;
#include scripts\include\useful;
#include scripts\include\entities;

/**
*	Start a normal wave 
*/
startRegularWave(){
	level endon("game_ended");
	level endon("abort_wave");
	wavetype = "normal";
	type = "normal";
	
	// Prepare our playfield and start the countdown
	preIntermission(wavetype, type);
	
	// Start announcing the wave after the countdown
	preWave(wavetype, type);
	
	// Type of spawning the zombies (from the sky, from spawn points, somewhere random etc.)
	spawntype = 0;

	level.gameState = "running";
	
	// Spawn all zombies of the wave one after another
	while( level.spawnedInWave < level.waveSize )
	{
		/#	// halt spawning for debugging purposes
		if( getDvarInt("dev_granular_spawning") > 0 )
			level waittill( "DEV_spawn_zombie" );
		#/
		
		// Only allow spawning when the limit of alive zombies isn't hit
		if(level.botsAlive < level.dif_zomMax && !level.spawningDisabled)
		{
			// TODO: This was for testing purposes. Keep testing and remove.
			if(getDvar("priospawner") == "1")
				spawntype = 5;
			// We look for bots that can be used to spawn. If none are found, we start over
			if(isDefined(trySpawnZombie(undefined, spawntype)))
				level.spawnedInWave++;
		}
		
		wait level.dif_zomSpawnRate;
	}
	
	// Once the wave has ended, we clean up our stuff
	watchPostWave(wavetype, type);	
}

/**
*	Start a special wave
*	@type: String, the type of special wave there is. Currently there are:
*
*	"dog"
*	"burning"
*	"helldog"
*	"toxic"
*	"tank"
*	"scary"
*	"boss"
*	"grouped"
*/
startSpecialWave(type){
	level endon("game_ended");
	level endon("abort_wave");
	wavetype = "special";
	type = type;
	
	// Prepare our playfield and start the countdown
	preIntermission(wavetype, type);
	
	// Start announcing the wave after the countdown
	preWave(wavetype, type);
	
	level.gameState = "running";

	// Spawn all zombies of the wave one after another
	for (;level.spawnedInWave < level.waveSize;){
	
		// Only allow spawning when the limit of alive zombies isn't hit
		if (level.botsAlive < level.dif_zomMax && !level.spawningDisabled){
			// Gets a random type if the wavetype is "grouped" or "burning"
			toSpawn = scripts\bots\_types::getZombieType(type);
			
			// Depending on the type of wave, select how the zombies are spawned
			toSpawnSpawntype = scripts\bots\_types::getSpawnType(toSpawn, type);
			
			// We look for bots that can be used to spawn. If none are found, we start over
			if (isDefined(trySpawnZombie(toSpawn, toSpawnSpawntype))){
				level.spawnedInWave++;
			}
		}
		wait level.dif_zomSpawnRate;
	}
	
	// Once the wave has ended, we clean up our stuff
	watchPostWave(wavetype, type);
}

/**
*	Starts the last and final wave
*/
startFinalWave(){
	level endon("game_ended");
	wavetype = "finale";
	type = "finale";
	
	// Check if there are enough players to start the final wave
	if(level.activePlayers < level.dvar["surv_finale_minplayers"]){
		return;
	}
	
	// Prepare our playfield and start the countdown
	preIntermission(wavetype, type);
	
	// Use the intro with multiple lines or a simple short one
	if(level.dvar["surv_extended_finale_announcement"])
		preWave(wavetype, type);
	else
		preWave(wavetype, type + "_short");
	
	// Start the spawning madness
	thread burstSpawner(level.burstSpawned);
	
	// Clean up after the wave
	watchPostWave(wavetype, type);
}

/**
*	Sets everything required to initialize the countdown and wave count
*	@wavetype: String, defines the type of wave ("normal", "special" or "finale")
*	@type: String, the type of specialwave-zombies that appear 
*/
preIntermission(wavetype, type){
	
	// Take note that we actually initialized a wave
	if(!level.weStartedAtLeastOneGame)
		level.weStartedAtLeastOneGame = true;

	level.intermission = 1;
	
	level.spawnedInWave = 0;
	
	// Get the wave size for the amount of waves played and amount of players for the given type of zombie
	level.waveSize = getWaveSize(level.currentWave, type);
	
	// Save current wave status
	level.currentType = type;
	level.waveType = wavetype;
	level.waveProgress = 0;

	// Monitor if players have gone down etc.
	thread scripts\gamemodes\_survival::watchEnd();
	
	// Revive downed players if this is enabled in config
	reviveActivePlayers();

	// Spawn players that are currently queued
	scripts\players\_players::spawnJoinQueue();

	// Start the countdown for the given wavetype
	waveCountdown(wavetype);
}

/**
*	Starts the countdown for the given type of wave
*	@wavetype: String, defines the type of wave ("normal", "special" or "finale")
*/
waveCountdown(wavetype){

	level.gameState = "countdown";
	
	switch(wavetype){
	
		// Normal wave timer settings
		case "normal":
			// In case this is our first wave, we wait longer
			if(level.currentWave == 1 && level.dvar["surv_timeout_firstwave"] > 0){
				// Create timer display for the duration
				timer(level.dvar["surv_timeout"] + level.dvar["surv_timeout_firstwave"], &"ZOMBIE_NEWWAVEIN", (.2,.7,0), undefined, level.currentWave);
				
				// Wait until the time has run out 
				wait level.dvar["surv_timeout"] + level.dvar["surv_timeout_firstwave"] + 2;
			}
			// In case this is not the first wave, the rest is basically the same as above
			else{
				timer(level.dvar["surv_timeout"], &"ZOMBIE_NEWWAVEIN", (.2,.7,0), undefined, level.currentWave);
				wait level.dvar["surv_timeout"] + 2;
			}
			break;
		
		// Final wave timer settings
		case "finale":
			timer(level.dvar["surv_timeout_finale"], &"ZOMBIE_FINALWAVEIN", (.7,.2,0));
			wait level.dvar["surv_timeout_finale"] + 2;
			break;
		
		// Special wave timer settings 
		case "special":
			if(level.currentWave == 1 && level.dvar["surv_timeout_firstwave"] > 0){
				timer(level.dvar["surv_timeout"] + level.dvar["surv_timeout_firstwave"], &"ZOMBIE_NEWWAVEIN", (.7,.2,0), undefined, level.currentWave);
				wait level.dvar["surv_timeout"] + level.dvar["surv_timeout_firstwave"] + 2;
			}
			else{
				timer(level.dvar["surv_timeout"], &"ZOMBIE_NEWWAVEIN", (.7,.2,0), undefined, level.currentWave);
				wait level.dvar["surv_timeout"] + 2;
			}
			break;
			
		// Should not get here
		default:
			assertEx(false, "Error: Started waveCountdown() for non-existant wave-type!");
			break;
	}
}

/**
*	Prepares gameplay environment depending on the type of wave
*	@wavetype: String, defines the type of wave ("normal", "special" or "finale")
*	@type: String, the type of specialwave-zombies that appear 
*/
preWave(wavetype, type){
	level endon("game_ended");
	
	thread watchWaveProgress();
	
	// Act depending on the type of zombies spawning later
	switch(type){
	
		case "scary":
			thread playSoundOnAllPlayers("wave_start", randomfloat(1));
			// Show a random announcement
			label = [];
			label[label.size] = &"ZOMBIE_SCARYWAVE_AFTER0";
			label[label.size] = &"ZOMBIE_SCARYWAVE_AFTER1";
			label[label.size] = &"ZOMBIE_SCARYWAVE_AFTER2";
			
			// Check whether turrets should or should not be online for this type
			scripts\bots\_types::setTurretsEnabledForType(type);
			
			// Announce the wave
			announceMessage(&"ZOMBIE_SCARYWAVE", level.waveSize, (.7,.2,0), 5.5, 85);
			
			// Enable light for every player
			level.flashlightEnabled = true;
			scripts\players\_players::flashlightForAll(true);
			wait 6.5 + randomfloat(1); // Wait at least as long as the announceMessage takes
			
			// Announce that shit went down 
			announceMessage(label[randomint(label.size)], "", (1,.3,0), 6, 85, undefined, 15);
			wait 2;
			
			// Play with hud settings and vision
			for(i = 0; i < level.players.size; i++){
				if(level.players[i].isActive && level.players[i].isAlive){
					level.players[i] shellshock("general_shock", 7);
					level.players[i] thread scripts\players\_players::flickeringHud(6000);
				}
			}
			wait 3;
			// Once we're here, we start the wave 
			break;
		
		// Announce start of the boss wave 
		case "boss":
			thread playSoundOnAllPlayers("wave_start", randomfloat(1));
			announceMessage(&"ZOMBIE_NEWBOSSWAVE", "", (.7,.2,0), 5, 85);
			wait 5;
			break;
			
		// Announce a normal wave and start map effects for it
		case "normal":
			thread playSoundOnAllPlayers("wave_start", randomfloat(1));
			announceMessage(level.announceNormal[ randomint(level.announceNormal.size) ] , level.waveSize, (.2,.7,0), 5, 95);
			wait 5;
			thread scripts\server\_environment::normalWaveEffects();
			break;
			
		// Complicated and long finale announcement	
		case "finale":
		
			// Change vision and play music
			thread finaleAmbient();
			level.intermission = 0;
			wait 2.50;
			
			// Changes the vision of the players a little once we're a little into the intro
			thread scripts\bots\_types::finaleVision();
			
			// Blacks out the player's vision in one short moment in the intro
			thread scripts\bots\_types::goBlackscreen();
			
			// Freeze controls of all players
			freezeAll();
			
			// Prevent players from being hurt e.g. by burning zombies
			level.godmode = true;
			
			// Put down weapons
			for(i = 0; i < level.players.size; i++)
				level.players[i] disableWeapons();
			
			// Start playing the announcement texts
			scripts\bots\_types::announceFinale(randomint(4));
			
			// Prevent enything interrupting the finale
			level.freezeBots = true;
			level.turretsDisabled = 1;
			level.claymoresEnabled = false;
			
			// Calculate amount of zombie spawns differently
			thread scripts\bots\_types::dynamicFinale();
			
			// Setup special FX all around the map
			scripts\server\_environment::setGlobalFX(scripts\bots\_types::getFxForType(type));
			
			// Spawn a first batch of zombies while still frozen
			for(level.burstSpawned = 0; level.burstSpawned < level.dvar["bot_count"] && level.burstSpawned < level.waveSize;){
				toSpawn = scripts\bots\_types::getFullyRandomZombieType();
				if (isDefined(trySpawnZombie(toSpawn, 3)))
						level.burstSpawned++;
			}
			
			// Wait for the reveal
			wait 4.75;
			
			// Give back full vision
			thread scripts\server\_environment::updateBlur(0);
			killBlackscreen();
			
			// Final announcement before playoff
			for(i = 0; i < level.players.size; i++)
				level.players[i] thread finaleMessage(&"FINALE_LAST", "", (1, 0, 0), 4, 3, 3.2);
			
			wait 1;
			
			// Put weapons back up in preparation of mayhem
			for(i = 0; i < level.players.size; i++)
				level.players[i] enableweapons();
			
			wait 4.3;
			
			// From here on out, shit's on fire, yo!
			level.turretsDisabled = 0;
			level.freezeBots = false;
			level.claymoresEnabled = true;
			level.godmode = level.dvar["game_godmode"];
			unfreezeAll();
			
			thread watchIfZombiesAreDead();
			break;
		
		// The short alternative to the normal finale announcement, usually recommended to be used when switching the finale music
		// It is basically the same as above, just shortened
		case "finale_short":
		
			thread finaleAmbient();
			level.intermission = 0;
			wait 1;
			
			thread scripts\bots\_types::finaleVision();
			thread scripts\bots\_types::goBlackscreen();
			freezeAll();
			
			level.godmode = true;
			
			for(i = 0; i < level.players.size; i++)		
				level.players[i] disableWeapons();
			level.disableWeapons = true;
			
			scripts\bots\_types::announceFinaleShort();
			
			level.freezeBots = true;
			level.turretsDisabled = 1;
			level.claymoresEnabled = false;
			
			thread scripts\bots\_types::dynamicFinale();
			
			scripts\server\_environment::setGlobalFX(scripts\bots\_types::getFxForType("finale"));
			
			for(level.burstSpawned = 0; level.burstSpawned < level.dvar["bot_count"] && level.burstSpawned < level.waveSize && level.burstSpawned < level.finaleToSpawn;){
				toSpawn = scripts\bots\_types::getFullyRandomZombieType();
				if (isDefined(trySpawnZombie(toSpawn, 3)))
						level.burstSpawned++;
			}
			wait 2;
			
			thread scripts\server\_environment::updateBlur(0);
			killBlackscreen();
			
			for(i = 0; i < level.players.size; i++)
				level.players[i] thread finaleMessage(&"FINALE_LAST", "", (1, 0, 0), 4, 3, 3.2);
			
			wait 1;
			
			for(i = 0; i < level.players.size; i++)
				level.players[i] enableweapons();
			
			wait 4.3;
			
			level.turretsDisabled = 0;
			level.freezeBots = false;
			level.claymoresEnabled = true;
			level.godmode = level.dvar["game_godmode"];
			unfreezeAll();
			
			thread watchIfZombiesAreDead();
			break;
			
		// Special type "grouped" announcement
		// pre-initializes a random group of zombies being spawned
		case "grouped":
		
			thread playSoundOnAllPlayers("wave_start", randomfloat(1));
			announceMessage(&"ZOMBIE_NEWSPECIALWAVE", level.zom_typenames[type], (.7,.2,0), 5, 85);
			wait 5;
			thread scripts\bots\_types::randomZombieProbabilityScenario(45);
			break;
			
		// Special type "dog" announcement
		// Adds the normal wave effects
		case "dog":
		
			thread playSoundOnAllPlayers("wave_start", randomfloat(1));
			announceMessage(&"ZOMBIE_NEWSPECIALWAVE", level.zom_typenames[type], (.7,.2,0), 5, 85);
			wait 5;
			thread scripts\server\_environment::normalWaveEffects();
			break;
			
		// Special wave announcement for all other unnamed variants
		default:
		
			thread playSoundOnAllPlayers("wave_start", randomfloat(1));
			announceMessage(&"ZOMBIE_NEWSPECIALWAVE", level.zom_typenames[type], (.7,.2,0), 5, 85);
			wait 5;
			break;
	}
	
	// We're playing now!
	level.intermission = 0;
	
	// TODO: Currently not used in any wave
	thread rotatePrioritizedSpawn(true);
	
	// Start monitoring the progress of players and adjust difficulty
	level notify("start_monitoring");
	
	// Watch the queue and let them join periodically
	thread scripts\players\_players::spawnJoinQueueLoop();
	
	// Start wave music
	if(type != "finale" && type != "finale_short")
		thread waveAmbient(type);
}

/**
*	Waiting for the wave to end to start cleanup
*	@wavetype: String, defines the type of wave ("normal", "special" or "finale")
*	@type: String, the type of specialwave-zombies that appear 
*/
watchPostWave(wavetype, type){
	level endon("abort_wave");

	// Once we're through with spawning the zombies, watch if any of the remaining ones aren't getting killed
	if(type != "boss")
		thread killBuggedZombies();
	
	// Wait until the wave is actually over
	level waittill("wave_finished");
	
	postWave(wavetype, type);
}

/**
*	Once a wave has been finished, we clean up everything for the next wave
*	@wavetype: String, defines the type of wave ("normal", "special" or "finale")
*	@type: String, the type of specialwave-zombies that appear 
*/
postWave(wavetype, type){
	
	iprintln("postWave!");
	// Remove lights from players
	if(type == "scary"){
		level.flashlightEnabled = false;
		scripts\players\_players::flashlightForAll(false);
	}
	
	// Reset turrets being enabled
	scripts\bots\_types::setTurretsEnabledForType("");
	
	// Increment the counter which determines whether zombies are running or not
	level.slowBots += 1/(level.dvar["surv_slow_waves"]);
	
	// Resets the environment (second argument is true)
	waveAmbient(type, true);
}

/**
*	Sets up the environment for the given wave type
*	@type: String, type of zombies being spawned in the wave
*	@reset: Boolean, whether to reset all FX and environment vars or not
*/
waveAmbient(type, reset){

	level endon("game_ended");
	if(!isDefined(reset))
		reset = false;
	
	
	if(!reset){
		switch(type){
		
			// Play normal ambient audio
			case "normal":
				level.ambient = "zom_ambient";
				scripts\server\_environment::setAmbient(level.ambient);
				break;		

			// In case of a special wave, play all music/FX/vision for that specific type
			default:
				// Set ambient music
				level.ambient = scripts\bots\_types::getAmbientForType(type);
				scripts\server\_environment::setAmbient(level.ambient);
				
				// Setup FX
				scripts\server\_environment::setGlobalFX(scripts\bots\_types::getFxForType(type));
				
				// Setup Vision
				scripts\server\_environment::setVision(scripts\bots\_types::getVisionForType(type), 10);
				thread scripts\server\_environment::setBlur(scripts\bots\_types::getBlurForType(type), 20);
				
				// Setup fog
				scripts\server\_environment::setFog(scripts\bots\_types::getFogForType(type));
				break;
		}
		
	}
	// Reset all music, fx and vision to default/off
	else{
		scripts\server\_environment::stopAmbient();
		if(type != "normal"){
			scripts\server\_environment::resetVision(10);
			thread scripts\server\_environment::setBlur(level.dvar["env_blur"], 7);
			scripts\server\_environment::setFog("default");
			level notify("global_fx_end");
			level.lastSpecialWave = type;
			level.bossIsOnFire = 0;
		}
		
	}
}

/**
*	Start the extended finale ambient
*/
finaleAmbient(){
	level.ambient = scripts\bots\_types::getAmbientForType("finale");
	scripts\server\_environment::setAmbient(level.ambient, 1);
	thread scripts\server\_environment::setBlur(scripts\bots\_types::getBlurForType("finale"), 20);
	scripts\server\_environment::setFog(scripts\bots\_types::getFogForType("finale"));
}

/**
*	Calculates the amount of zombies per wave
*	@wave: Int, amount of waves played
*	@type: String, type of zombie in the wave
*	@returns: Int, amount of zombies to be in the wave
*/
getWaveSize(wave, type)
{

	if(!isDefined(type))
		type = "";
		
	if(type == "boss")
		return 1; // There is only one zombie in the "boss" wave, d'uh!
		
	amount = 0;
	waveid = wave - 1;
	players = level.players.size;
	
	// Calculate the amount of zombies depending on the config settings
	switch (level.dvar["surv_wavesystem"]){
		case 0:
			amount = level.dvar["surv_zombies_initial"] + players * level.dvar["surv_zombies_perplayer"];
			break;
			
		case 1:
			amount = level.dvar["surv_zombies_initial"] + waveid * level.dvar["surv_zombies_perwave"];
			break;
			
		case 2:
			amount = level.dvar["surv_zombies_initial"] + players * (waveid * level.dvar["surv_zombies_perwave"] + level.dvar["surv_zombies_perplayer"]); // 10 + a * (x * 7 + 10)
			break;
			
		case 3:
			amount = level.dvar["surv_zombies_initial"] + players * level.dvar["surv_zombies_perplayer"] + waveid * level.dvar["surv_zombies_perwave"]; // 10 + a * 10 + x * 7
			break;			
	}
	
	// In case the calculation resulted in a small amount for the finale, crank it up a little
	if(type == "finale" && amount < level.dvar["bot_count"])
		amount = level.dvar["bot_count"] + 10;
	return amount;
}

/**
*	Spawns zombies in bursts once all currently living zombies are dead
*/
burstSpawner(i){
	level endon("game_ended");
	level endon("wave_finished");
	
	while(i <= level.waveSize){
		// For each iteration, wait till all zombies have died
		level waittill("all_zombies_are_dead");
		
		ii = 0;
		loops = 0;
		
		// Spawn zombies in bursts
		for(; i < level.waveSize && ii < level.finaleToSpawn;){
			toSpawn = scripts\bots\_types::getFullyRandomZombieType();
			if (isDefined(trySpawnZombie(toSpawn, 2))){
					i++;
					ii++;
			}
			
			loops++;
			
			// Spawn 10 zombies in each server frame
			if(loops % 10 == 0)
				wait 0.05;
		}
		
		// Recalculate the amount of zombies once a burst is done
		level notify("burst_done");
	}
}

/**
*	Try spawning a zombie
*	@typeOverride: String, type of zombie to spawn (otherwise random and determined by wave)
*	@spawntype: Int, the way of spawning the zombie (e.g. zombie spawns, from the sky, anywhere from the ground etc.)
*	@forcePrioritizedSpawning: TODO Seems unused?
*/
trySpawnZombie(typeOverride, spawntype, forcePrioritizedSpawning)
{
	if (!isDefined(spawntype))
		spawntype = 0; // Standard spawning
		
	if(!isDefined(forcePrioritizedSpawning))
		forcePrioritizedSpawning = false;
	
	// Decide how to spawn a zombie
	if(spawntype >= 1 && spawntype <= 5){
	
		bot = scripts\bots\_bots::getAvailableBot();
		if (!isDefined(bot))
			return undefined;
			
		bot.hasSpawned = true;
		type = typeOverride;
		
		switch(spawntype){
		
			// Spawning from "hell" (from above)
			case 1:

				if(level.waypoints.size < 2) // Fix for maps without waypoints
					spawn = getRandomSpawn();
				else
					spawn = level.waypoints[randomint(level.waypoints.size)];
					
				thread soulSpawn(type, spawn, bot);
				return bot;
			
			// Spawning somewhere random with ground FX
			case 2:

				if(level.waypoints.size < 2) // Fix for maps without waypoints
					spawn = getRandomSpawn();
				else
					spawn = level.waypoints[randomint(level.waypoints.size)];
				thread groundSpawn(type, spawn, bot);
				return bot;
			
			// Spawning "away" from players
			case 3:
			
				spawn = scripts\bots\_types::getScarySpawnpoint();
				thread scripts\bots\_bots::spawnZombie(type, spawn, bot);
				return bot;
			
			// Spawning somewhere random
			case 4:
			
				spawn = level.waypoints[randomint(level.waypoints.size)];
				thread scripts\bots\_bots::spawnZombie(type, spawn, bot);
				return bot;
			
			// Spawn zombie at a prioritized spawnpoint
			case 5:
			
				if(!isDefined(type))
					type = scripts\gamemodes\_gamemodes::getRandomType();
				spawn = getPrioritizedSpawn();
				thread scripts\bots\_bots::spawnZombie(type, spawn, bot);
				return bot;
		}
	}
	
	// Selected Spawn from random spawn function
	if (forcePrioritizedSpawning){ 
	
		if(isDefined(typeOverride))
			type = typeOverride;
		else
			type = scripts\gamemodes\_gamemodes::getRandomType();
		spawn = getPrioritizedSpawn();
		
		return scripts\bots\_bots::spawnZombie(type, spawn);
		
	}
	else{
		if (isDefined(typeOverride)){
		
			type = typeOverride;
			spawn = getRandomSpawn();
			
			return scripts\bots\_bots::spawnZombie(type, spawn);
		}
		else{
		
			type = scripts\gamemodes\_gamemodes::getRandomType();
			spawn = getRandomSpawn();
			
			return scripts\bots\_bots::spawnZombie(type, spawn);
		}
	}
}

/**
*	Spawn zombie from "below the ground" with an FX
*	@type: String, name of the zombie type
*	@spawn: Entity, the spawn of the zombie
*	@bot: Entity, the bot that controls that zombie
*/
groundSpawn(type, spawn, bot)
{
	//ent = spawn("script_origin",);
	playfx(level.groundSpawnFX, PhysicsTrace(spawn.origin, spawn.origin-200));
	
	scripts\bots\_bots::spawnZombie(type, spawn, bot);
}

/**
*	Spawn zombie in a cloud
*	@type: String, name of the zombie type
*	@spawn: Entity, the spawn of the zombie
*	@bot: Entity, the bot that controls that zombie
*	TODO: This is unused?
*/
cloudSpawn(type, spawn, bot)
{
	playfx(level.cloudSpawnFX, PhysicsTrace(spawn.origin, spawn.origin-200));
	wait 1;
	scripts\bots\_bots::spawnZombie(type, spawn, bot);
}

/**
*	Spawn zombie from the sky 
*	@type: String, name of the zombie type
*	@spawn: Entity, the spawn of the zombie
*	@bot: Entity, the bot that controls that zombie
*/
soulSpawn(type, spawn, bot)
{
	// The time it takes the glowing orb to come down
	time = 8 + randomint(13);
	
	// Spawn the orb above the landing position
	// TODO: Allow for non-vertical spawning?
	org = spawn("script_model", spawn.origin + (0, 0, time * 100));
	
	// Spawn orb effect
	org setModel("tag_origin");
	wait 0.05;
	playFXOnTag(level.soulFX , org, "tag_origin");
	wait 0.05;
	
	// Give it a little random speed
	time -= randomint(3);
	
	// Move to actual spawning position
	org moveTo(spawn.origin + (0, 0, 48), time);
	
	// Wait for arrival
	wait time;
	
	// Play spawning FX and remove orb
	playFx(level.soulspawnFX, org.origin);
	org delete();
	
	scripts\bots\_bots::spawnZombie(type, spawn, bot);
}

/**
*	A loop that keeps running and checks whether all zombies are dead
*	It also triggers after a certain time to prevent the game from getting stuck on a single hidden zombie
*/
watchIfZombiesAreDead(){

	level endon("wave_finished");
	level endon("game_ended");
	
	// Give it a little randomness
	ran = randomint(4) + 2;
	timelimit = 5 + randomint(10);
	
	loops = 0;
	
	// Notify that another burst spawn can start once enough zombies were killed or we've waited long enough
	while(1){
		if(level.botsAlive <= ran || level.dvar["bot_count"] <= 5 || loops == (timelimit * 10)){
			wait 0.2 + level.finaleDelay;
			loops = 0;
			timelimit = 5 + randomint(10);
			level notify("all_zombies_are_dead");
			
			ran = randomint(4) + 2;
			
			wait 3;
		}
		else{
			wait 0.1;
			loops++;
		}
	}

}

/**
*	The almighty chainsaw that kills the remaining zombies if they're broken
*/
killBuggedZombies(){

	level endon("wave_finished");
	level endon("game_ended");
	level endon("last_chance_start");
	
	// Don't check if not wanted
	if (!level.dvar["surv_find_stuck"])
		return;
		
	tolerance = 0;
	detections = 0;
	
	// Monitor wave progress
	while(1){
		lastProg = level.waveProgress;
		level.hasReceivedDamage = 0;
		
		wait 5;
		
		// Only check for bugged zombies if all players have been revived and no progress has been made
		if (level.activePlayers == level.alivePlayers && lastProg == level.waveProgress && !level.hasReceivedDamage)
			tolerance += 5;
		else
			tolerance = 0;
		
		// React to stuck zombies detected
		if (tolerance >= level.dvar["surv_stuck_tolerance"]){
		
			// If even the chainsaw can't kill the zombies, end the wave
			if(detections >= 3){
				iprintlnbold("Game appears to be stuck. Enforcing wave end...");
				wait 3;
				level notify("wave_finished");
				break;
			}
			
			// Kill all living zombies
			detections++;
			iprintlnbold("^1Stuck zombies detected, cutting their head off!");
			wait 1;
			for (i = 0; i < level.bots.size; i++)
			{
				level.bots[i] suicide();
				wait 0.05;
			}
		}
	}
}

/**
*	Monitoring the game's progress and notifying of "wave_finished" once all zombies in a wave have been killed
*/
watchWaveProgress()
{
	level endon("game_ended");
	level endon("wave_finished");
	while (1){
		level waittill("bot_killed");
		
		level.waveProgress++;
		if (level.waveProgress >= level.waveSize)
			break;
	}
	level notify("wave_finished");
}

/**
*	Forcing the current wave to be aborted (only works while a wave is active!)
*/
abortWave()
{
	if( level.gameState == "running" )
	{
		iprintlnbold("Forcing current wave to end!");
		level notify("abort_wave");
		level notify("wave_finished");
		
		for (i = 0; i < level.bots.size; i++)
			level.bots[i] suicide();
			
		postWave(level.waveType, level.currentType);	
	}
}

/**
*	Rotates some of the possible spawns as prioritized spawns
*	This makes it so that zombies come in hordes from one specific position
*	@threaded: Boolean, determines whether to keep rotating the spawns (true) or to shuffle them once (false)
*/
rotatePrioritizedSpawn(threaded){

	level endon("game_ended");
	level endon("wave_finished");
	
	if(threaded){
		while(1){
			level.prioritizedSpawns[0] = getRandomSpawn();
			level.prioritizedSpawns[1] = getRandomSpawn();
			wait 7 + randomint(5);
		}
	}
	else{
		level.prioritizedSpawns[0] = getRandomSpawn();
		level.prioritizedSpawns[1] = getRandomSpawn();
	}
	
}

/**
*	@returns: Entity, one of the spawns inside the prioritizedSpawns array
*/
getPrioritizedSpawn()
{
	spawn = level.prioritizedSpawns[randomint(level.prioritizedSpawns.size)];
	if(!isDefined(spawn))
		return getRandomSpawn();
	else
		return spawn;
}

/**
*	@returns: Entity, one of the spawns that zombies can spawn on defined by the map
*/
getRandomSpawn()
{
	spawn = undefined;
	random = randomint(level.survSpawnsTotalPriority);
	for (i = 0; i < level.survSpawns.size; i++)
	{
		random = random - level.survSpawnsPriority[i];
		if (random < 0)
		{
		spawn = level.survSpawns[i];
		break;
		}	
	}
	if (isDefined(spawn))
	{
		array = getEntArray(spawn, "targetname");
		choice = randomint(array.size);
		return array[choice];
	}
}