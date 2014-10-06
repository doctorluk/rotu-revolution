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

#include scripts\include\hud;
#include scripts\include\useful;
#include scripts\include\entities;

startRegularWave(){
	level endon( "game_ended" );
	wavetype = "normal";
	type = "normal";
	
	prePreWave(wavetype, type);
	preWave(wavetype, type);
	spawntype = 0;

	for ( i = 0; i < level.waveSize; ){ 
		if (level.botsAlive<level.dif_zomMax && !level.spawningDisabled){
			if( getDvar("priospawner") == "1" )
				spawntype = 5;
			if ( isDefined( spawnZombie(undefined, spawntype) ) )
			i++;
		}
		wait level.dif_zomSpawnRate;
	}
	
	postWave(wavetype, type);	
}

startSpecialWave(type){
	level endon( "game_ended" );
	wavetype = "special";
	type = type;
	
	prePreWave(wavetype, type);
	preWave(wavetype, type);

	for ( i = 0; i < level.waveSize; ){
		if ( level.botsAlive < level.dif_zomMax && !level.spawningDisabled){
			toSpawn = scripts\bots\_types::getZombieType(type);
			toSpawnSpawntype = scripts\bots\_types::getSpawnType(toSpawn, type);
			if ( isDefined( spawnZombie(toSpawn, toSpawnSpawntype) ) ){
				i++;
			}
		}
		wait level.dif_zomSpawnRate;
	}
	
	postWave(wavetype, type);
}

/* THE GREAT FINALE */

startFinalWave()
{
	level endon( "game_ended" );
	wavetype = "finale";
	type = "finale";
	
	if( level.activePlayers < level.dvar["surv_finale_minplayers"] ){
		// iprintln("^3Skipping ^7final wave as not enough players are playing!");
		return;
	}
	
	prePreWave(wavetype, type);

	if( level.dvar["surv_extended_finale_announcement"] )
		preWave(wavetype, type);
	else
		preWave(wavetype, type + "_short");
	
	thread burstSpawner(level.burstSpawned);
	
	postWave(wavetype, type);
}

/* Logic before countdown starts */
prePreWave(wavetype, type){
	
	if(!level.weStartedAtLeastOneGame)
		level.weStartedAtLeastOneGame = true;
		
	level.intermission = 1;
	
	level.waveSize = getWaveSize(level.currentWave, type);
	// level.waveSize = 60;
	level.currentType = type;
	level.waveType = wavetype;
	level.waveProgress = 0;
	
	thread scripts\gamemodes\_survival::watchEnd();
	reviveActivePlayers();
	
	scripts\players\_players::spawnJoinQueue();
	
	waveCountdown(type);
}

/* Countdown */
waveCountdown(type){
	switch(type){
		case "normal":
			if(level.currentWave == 1 && level.dvar["surv_timeout_firstwave"] > 0){
				timer(level.dvar["surv_timeout"] + level.dvar["surv_timeout_firstwave"], &"ZOMBIE_NEWWAVEIN", (.2,.7,0), undefined, level.currentWave);
				wait level.dvar["surv_timeout"] + level.dvar["surv_timeout_firstwave"] + 2;
			}
			else{
				timer(level.dvar["surv_timeout"], &"ZOMBIE_NEWWAVEIN", (.2,.7,0), undefined, level.currentWave);
				wait level.dvar["surv_timeout"] + 2;
			}
			break;
		
		case "finale":
			timer(level.dvar["surv_timeout_finale"], &"ZOMBIE_FINALWAVEIN", (.7,.2,0) );
			wait level.dvar["surv_timeout_finale"] + 2;
			break;
		
		default: // Special
			if(level.currentWave == 1 && level.dvar["surv_timeout_firstwave"] > 0){
				timer(level.dvar["surv_timeout"] + level.dvar["surv_timeout_firstwave"], &"ZOMBIE_NEWWAVEIN", (.7,.2,0), undefined, level.currentWave);
				wait level.dvar["surv_timeout"] + level.dvar["surv_timeout_firstwave"] + 2;
			}
			else{
				timer(level.dvar["surv_timeout"], &"ZOMBIE_NEWWAVEIN", (.7,.2,0), undefined, level.currentWave);
				wait level.dvar["surv_timeout"] + 2;
			}
			break;
	}
}

/* Preparing everything before starting the spawning */
preWave(wavetype, type){
	level endon("game_ended");
	thread watchWaveProgress();
	switch(type){
		case "scary":
			thread playSoundOnAllPlayers( "wave_start", randomfloat(1) );
			label = [];
			label[label.size] = &"ZOMBIE_SCARYWAVE_AFTER0";
			label[label.size] = &"ZOMBIE_SCARYWAVE_AFTER1";
			label[label.size] = &"ZOMBIE_SCARYWAVE_AFTER2";
			scripts\bots\_types::setTurretsEnabledForType(type);
			announceMessage(&"ZOMBIE_SCARYWAVE", level.waveSize, (.7,.2,0), 5.5, 85);
			
			level.flashlightEnabled = true;
			scripts\players\_players::flashlightForAll(true);
			wait 6.5 + randomfloat(1); // Wait at least as long as the announceMessage takes
			
			announceMessage(label[randomint(label.size)], "", (1,.3,0), 6, 85, undefined, 15);
			wait 2;
			
			for(i = 0; i < level.players.size; i++){
				if(level.players[i].isActive && level.players[i].isAlive){
					level.players[i] shellshock("general_shock", 7);
					level.players[i] thread scripts\players\_players::flickeringHud(getTime() + 6000);
				}
			}
			wait 3;
			break;
		case "boss":
			thread playSoundOnAllPlayers( "wave_start", randomfloat(1) );
			announceMessage(&"ZOMBIE_NEWBOSSWAVE", "", (.7,.2,0), 5, 85);
			wait 5;
			break;
		case "normal":
			thread playSoundOnAllPlayers( "wave_start", randomfloat(1) );
			announceMessage( level.announceNormal[ randomint(level.announceNormal.size) ] , level.waveSize, (.2,.7,0), 5, 95);
			wait 5;
			thread scripts\server\_environment::normalWaveEffects();
			break;
		case "finale":
			thread finaleAmbient();
			level.intermission = 0;
			wait 2.50;
			thread scripts\bots\_types::finaleVision();
			thread scripts\bots\_types::goBlackscreen();
			
			freezeAll();
			
			level.godmode = true;
			
			for(i = 0; i < level.players.size; i++)
				level.players[i] disableWeapons();
			
			scripts\bots\_types::announceFinale(randomint(4));
			level.freezeBots = true;
			level.turretsDisabled = 1;
			level.claymoresEnabled = false;
			thread scripts\bots\_types::dynamicFinale();
			scripts\server\_environment::setGlobalFX(scripts\bots\_types::getFxForType(type));
			for( level.burstSpawned = 0; level.burstSpawned < level.dvar["bot_count"] && level.burstSpawned < level.waveSize; ){ // This is the spawning of zombies while players don't see shit
				toSpawn = scripts\bots\_types::getFullyRandomZombieType();
				if ( isDefined( spawnZombie( toSpawn, 3 ) ) )
						level.burstSpawned++;
			}
			wait 4.75;
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
			// announceMessage(&"ZOMBIE_FINALWAVE", "", (1,0,0), 5, 85);
			// wait 5;
			break;
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
			for( level.burstSpawned = 0; level.burstSpawned < level.dvar["bot_count"] && level.burstSpawned < level.waveSize && level.burstSpawned < level.finaleToSpawn; ){ // This is the spawning of zombies while players don't see shit
				toSpawn = scripts\bots\_types::getFullyRandomZombieType();
				if ( isDefined( spawnZombie( toSpawn, 3 ) ) )
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
		case "grouped":
			thread playSoundOnAllPlayers( "wave_start", randomfloat(1) );
			announceMessage(&"ZOMBIE_NEWSPECIALWAVE", level.zom_typenames[type], (.7,.2,0), 5, 85);
			wait 5;
			thread scripts\bots\_types::randomZombieProbabilityScenario(45);
			break;
		case "dog":
			thread playSoundOnAllPlayers( "wave_start", randomfloat(1) );
			announceMessage(&"ZOMBIE_NEWSPECIALWAVE", level.zom_typenames[type], (.7,.2,0), 5, 85);
			wait 5;
			thread scripts\server\_environment::normalWaveEffects();
			break;
		default:
			thread playSoundOnAllPlayers( "wave_start", randomfloat(1) );
			announceMessage(&"ZOMBIE_NEWSPECIALWAVE", level.zom_typenames[type], (.7,.2,0), 5, 85);
			wait 5;
			break;
	}
	
	level.intermission = 0;
	thread rotatePrioritizedSpawn(true);
	level notify("start_monitoring");
	thread scripts\players\_players::spawnJoinQueueLoop();
	if( type != "finale" && type != "finale_short" )
		thread waveAmbient(type);
}

/* Once all bots have spawned, proper cleanup */
postWave(wavetype, type){
	if(type != "boss")
		thread killBuggedZombies();
	
	level waittill( "wave_finished" );
	
	if( type == "scary" ){
		level.flashlightEnabled = false;
		scripts\players\_players::flashlightForAll(false);
	}
	scripts\bots\_types::setTurretsEnabledForType("");
	
	level.slowBots += 1/(level.dvar["surv_slow_waves"]);
	waveAmbient(type, 1);
	level.currentWave++;
}

waveAmbient(type, reset){
	level endon("game_ended");
	if( !isDefined( reset ) )
		reset = false;
		
	if( !reset ){
		switch(type){
			case "normal":
				level.ambient = "zom_ambient";
				scripts\server\_environment::setAmbient(level.ambient);
				break;				
			default:
				level.ambient = scripts\bots\_types::getAmbientForType(type);
				
				scripts\server\_environment::setAmbient(level.ambient);
				scripts\server\_environment::setGlobalFX(scripts\bots\_types::getFxForType(type));
				scripts\server\_environment::setVision(scripts\bots\_types::getVisionForType(type), 10);
				thread scripts\server\_environment::setBlur(scripts\bots\_types::getBlurForType(type), 20);
				
				fogTransition = 5;
				if( type == "scary" ) fogTransition = 0;
				scripts\server\_environment::setFog(scripts\bots\_types::getFogForType(type), fogTransition);
				break;
		}
		
	}
	else{
		scripts\server\_environment::stopAmbient();
		if( type != "normal" ){
			scripts\server\_environment::resetVision(10);
			thread scripts\server\_environment::setBlur(level.dvar["env_blur"], 7);
			scripts\server\_environment::setFog("default", 10);
			level notify("global_fx_end");
			level.lastSpecialWave = type;
			level.bossIsOnFire = 0;
		}
		
	}
}

finaleAmbient(){
	level.ambient = scripts\bots\_types::getAmbientForType("finale");
	scripts\server\_environment::setAmbient(level.ambient, 1);
	thread scripts\server\_environment::setBlur(scripts\bots\_types::getBlurForType("finale"), 20);
	scripts\server\_environment::setFog(scripts\bots\_types::getFogForType("finale"));
}

getWaveSize(wave, type)
{
	// return 1;
	// /*
	if( !isDefined( type ) )
		type = "";
		
	if( type == "boss" )
		return 1;
		
	amount = 0;
	waveid = wave-1;
	players = level.players.size;
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
	if( type == "finale" && amount < level.dvar["bot_count"] )
		amount = level.dvar["bot_count"] + 10;
	return amount;
	// */
}

burstSpawner(i){
	level endon("game_ended");
	level endon("wave_finished");
	
	while( i <= level.waveSize ){
		level waittill("all_zombies_are_dead");
		
		ii = 0;
		loops = 0;
		
		// wayOfSpawning = randomint(2) + 2; // either 2 or 3
		
		// iprintln("^1DEBUG: Starting burst spawn");
		
		// for(; ii < level.dvar["bot_count"] && level.botsAlive <= level.dvar["bot_count"] && i < level.waveSize && ii < level.finaleToSpawn; ){ // Burst spawning during finale
		for(; i < level.waveSize && ii < level.finaleToSpawn; ){ // Burst spawning during finale
			toSpawn = scripts\bots\_types::getFullyRandomZombieType();
			if ( isDefined( spawnZombie( toSpawn, 2 ) ) ){
					i++;
					ii++;
			}
			
			loops++;
			
			if( loops % 10 == 0 ) // More output! <3
				wait 0.05;
		}
		level notify("burst_done");
		// iprintln("^1DEBUG: ^7burst_done with " + loops + " loops and " + ii + " spawns");
	}
}

spawnZombie(typeOverride, spawntype, forcePrioritizedSpawning)
{
	if (!isdefined(spawntype))
		spawntype = 0; // Standard spawning
		
	if(!isDefined(forcePrioritizedSpawning))
		forcePrioritizedSpawning = false;
		
	if ( spawntype == 1 ) // From-sky spawn
	{
		bot = scripts\bots\_bots::getAvailableBot();
		if ( !isDefined( bot ) )
			return undefined;
		
		bot.hasSpawned = true;
		
		type = typeOverride;
		if( level.waypoints.size < 2 ) // Fix for maps without waypoints
			spawn = getRandomSpawn();
		else
			spawn = level.waypoints[randomint(level.waypoints.size)];
			
		thread soulSpawn( type, spawn, bot );
		return bot;
	}
	else if ( spawntype == 2 ) { // Ground spawn for crawlers
		bot = scripts\bots\_bots::getAvailableBot();
		if ( !isDefined( bot ) )
			return undefined;
		
		bot.hasSpawned = true;
		
		type = typeOverride;
		if( level.waypoints.size < 2 ) // Fix for maps without waypoints
			spawn = getRandomSpawn();
		else
			spawn = level.waypoints[randomint(level.waypoints.size)];
		thread groundSpawn( type, spawn, bot );
		return bot;
	}
	else if ( spawntype == 3 ) { // Random spawn for scary zombies
		bot = scripts\bots\_bots::getAvailableBot();
		if ( !isDefined( bot ) )
			return undefined;
		
		bot.hasSpawned = true;
		
		type = typeOverride;
		spawn = scripts\bots\_types::getScarySpawnpoint();
		thread scripts\bots\_bots::spawnZombie( type, spawn, bot );
		return bot;
	}
	else if ( spawntype == 4 ) { // Random instant spawn somewhere on the map
		bot = scripts\bots\_bots::getAvailableBot();
		if ( !isDefined( bot ) )
			return undefined;
		
		bot.hasSpawned = true;
		
		type = typeOverride;
		spawn = level.waypoints[randomint(level.waypoints.size)];
		thread scripts\bots\_bots::spawnZombie( type, spawn, bot );
		return bot;
	}
	else if ( spawntype == 5 ) { // Prioritized Spawn
		bot = scripts\bots\_bots::getAvailableBot();
		if ( !isDefined( bot ) )
			return undefined;
		
		bot.hasSpawned = true;
		
		if(isDefined(typeOverride))
			type = typeOverride;
		else
			type = scripts\gamemodes\_gamemodes::getRandomType();
		spawn = getPrioritizedSpawn();
		thread scripts\bots\_bots::spawnZombie( type, spawn, bot );
		return bot;
	}
	
	if (forcePrioritizedSpawning) { // Selected Spawn from random spawn function
		if(isDefined(typeOverride))
			type = typeOverride;
		else
			type = scripts\gamemodes\_gamemodes::getRandomType();
		spawn = getPrioritizedSpawn();
		return scripts\bots\_bots::spawnZombie( type, spawn );
	}else{
		if (isdefined(typeOverride))
		{
			type = typeOverride;
			spawn = getRandomSpawn();
			return scripts\bots\_bots::spawnZombie( type, spawn );
		}
		else
		{
			type = scripts\gamemodes\_gamemodes::getRandomType();
			spawn = getRandomSpawn();
			return scripts\bots\_bots::spawnZombie( type, spawn );
		}
	}
}

groundSpawn(type, spawn, bot)
{
	//ent = spawn("script_origin", );
	playfx(level.groundSpawnFX, PhysicsTrace(spawn.origin, spawn.origin-200));
	
	scripts\bots\_bots::spawnZombie(type, spawn, bot);
}

cloudSpawn(type, spawn, bot)
{
	playfx(level.cloudSpawnFX, PhysicsTrace(spawn.origin, spawn.origin-200));
	wait 1;
	scripts\bots\_bots::spawnZombie(type, spawn, bot);
}

soulSpawn(type, spawn, bot)
{
	time = 8 + randomint(13); // 20 sec max
	org = spawn("script_model", spawn.origin + (0,0,time * 100));
	org setmodel( "tag_origin" );
	wait .05;
	playFXOnTag( level.soulFX , org, "tag_origin" );
	wait .05;
	time -= randomint(3);
	org moveto(spawn.origin+(0,0,48), time);
	wait time;
	playfx(level.soulspawnFX, org.origin);
	org delete();
	
	scripts\bots\_bots::spawnZombie(type, spawn, bot);
}

watchIfZombiesAreDead(){
	level endon("wave_finished");
	level endon("game_ended");
	
	ran = randomint( 4 ) + 2;
	loops = 0;
	
	timelimit = 5 + randomint(10);
	
	while(1){
		if( level.botsAlive <= ran || level.dvar["bot_count"] <= 5 || loops == (timelimit*10) ){
			wait 0.2 + level.finaleDelay;
			loops = 0;
			timelimit = 5 + randomint(10);
			level notify("all_zombies_are_dead");
			
			// iprintln("^1DEBUG: ^7Firing all_zombies_are_dead notify");
			
			ran = randomint( 4 ) + 2;
			
			wait 3;
		}
		else{
			wait .1;
			loops++;
		}
	}

}

killBuggedZombies(){

	level endon("wave_finished");
	level endon("game_ended");
	level endon("last_chance_start");
	
	if (!level.dvar["surv_find_stuck"])
		return;
		
	tollerance = 0;
	detections = 0;
	
	while(1){
		lastProg = level.waveProgress;
		level.hasReceivedDamage = 0;
		
		wait 5;
		
		if ( level.activePlayers == level.alivePlayers ){
			if (lastProg == level.waveProgress && !level.hasReceivedDamage) {
				tollerance += 5;
			}
			else
			tollerance = 0;
		}
		else
			tollerance = 0;
			
		if (tollerance >= level.dvar["surv_stuck_tollerance"]){
			if( detections >= 3 ){
				iprintlnbold("Game appears to be stuck. Enforcing wave end...");
				wait 3;
				level notify("wave_finished");
				break;
				// wait 3;
				// ran = randomint(3);
				// switch(ran){
					// case 0: thread scripts\gamemodes\_gamemodes::endMap("All Survivors have perished...", 0); break;
					// case 1: thread scripts\gamemodes\_gamemodes::endMap("The human race became extinct", 0); break;
					// case 2: thread scripts\gamemodes\_gamemodes::endMap("Zombies have taken over...", 0); break;
				// }
			}
			detections++;
			iprintlnbold("^1Stuck zombies detected, cutting their head off!");
			wait 1;
			for ( i = 0; i < level.bots.size; i++ )
			{
				level.bots[i] suicide();
				wait 0.05;
			}
		}
	}
}

watchWaveProgress()
{
	level endon( "game_ended" );
	level endon( "wave_finished" );
	while (1){
		level waittill("bot_killed");
		
		level.waveProgress++;
		if (level.waveProgress >= level.waveSize)
			break;
	}
	level notify("wave_finished");
}

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

getPrioritizedSpawn()
{
	spawn = level.prioritizedSpawns[randomint(level.prioritizedSpawns.size)];
	if(!isDefined(spawn))
		return getRandomSpawn();
	else
		return spawn;
}

getRandomSpawn()
{
	spawn = undefined;
	random = randomint(level.survSpawnsTotalPriority);
	for (i=0; i<level.survSpawns.size; i++)
	{
		random = random - level.survSpawnsPriority[i];
		if (random < 0)
		{
		spawn = level.survSpawns[i];
		break;
		}	
	}
	if (isdefined(spawn))
	{
		// return getent(spawn, "targetname");
		array = getentarray(spawn, "targetname");
		choice = randomint(array.size);
		// iprintlnbold("Spawn " + choice + " on " + spawn);
		return array[choice];
	}
}