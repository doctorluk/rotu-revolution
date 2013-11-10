#include scripts\include\hud;
#include scripts\include\data;
#include scripts\include\strings;
initGame()
{
	level.currentWave = 1;
	level.ambient = "zom_ambient0";
	level.flashlightEnabled = false;
	level.difficulties = level.dvar["surv_waves_repeat"];
	level.currentDifficulty = 0;
	level.currentType = "";
	level.lastSpecialWave = "";
	level.killedZombies = 0;
	level.bosscount = 1;
	level.maxElectric = 3;
	level.currentElectric = 0;
	level.spawningDisabled = 0;
	level.hasReceivedDamage = 0;
	level.canBuyRaygun = 1;
	level.prioritizedSpawnTime = getTime();
	level.prioritizedSpawns = [];
	thread loadConfig();
}

loadConfig()
{
	wait .1;// Assume types not set, loading default
	dvarDefault("surv_special1", "dog");
	dvarDefault("surv_special2", "burning");
	dvarDefault("surv_special3", "toxic");
	dvarDefault("surv_special4", "scary");
	dvarDefault("surv_special5", "tank");
	dvarDefault("surv_special6", "boss");
	dvarDefault("surv_special7", "grouped");
	dvarDefault("surv_special8", "finale");
	level.availableSpecialWaves = [];
	level.availableSpecialWaves[level.availableSpecialWaves.size] = "dog";
	level.availableSpecialWaves[level.availableSpecialWaves.size] = "burning";
	level.availableSpecialWaves[level.availableSpecialWaves.size] = "toxic";
	level.availableSpecialWaves[level.availableSpecialWaves.size] = "scary";
	level.availableSpecialWaves[level.availableSpecialWaves.size] = "tank";
	level.availableSpecialWaves[level.availableSpecialWaves.size] = "grouped";
	
	level.announceNormal = [];
	level.announceNormal[level.announceNormal.size] = &"ZOMBIE_NEWWAVE0";
	level.announceNormal[level.announceNormal.size] = &"ZOMBIE_NEWWAVE1";
	level.announceNormal[level.announceNormal.size] = &"ZOMBIE_NEWWAVE2";
	// if (level.survMode == "special")
	// {
		// level.specialWaves = [];
		// for (i=0; i<level.dvar["surv_specialwaves"]; i++)
		// {
			// get = getdvar("surv_special"+(i+1));
			// if(get == "")
			// break;
			// level.specialWaves[i]=get;
		// }
	// }
	
	if (level.dvar["surv_weaponmode"] == "wawzombies")
	{
		level.onGiveWeapons = 0;
		level.ammoStockType = "weapon";
		level.spawnPrimary = level.dvar["surv_waw_spawnprimary"];
		level.spawnSecondary = level.dvar["surv_waw_spawnsecondary"];
	}
	else if (level.dvar["surv_weaponmode"] == "upgrade")
	{
		level.onGiveWeapons = 1;
		level.ammoStockType = "upgrade";
	}
	level.slowBots = 1 - level.dvar["surv_slow_start"];
}

dvarDefault(dvar, def)
{
	if (getdvar(dvar)=="")
	setdvar(dvar,def);
}

addSpawn(targetname, priority)
{
	if (!isdefined(level.survSpawns))
	return -1;
	
	if (!isdefined(priority))
	priority = 1;
	
	
	spawns = getentarray(targetname, "targetname");
	
	if (spawns.size > 0)
	{
		ii = level.survSpawns.size;
		level.survSpawnsPriority[ii] = priority;
		level.survSpawnsTotalPriority = level.survSpawnsTotalPriority + priority;
		level.survSpawns[ii] = targetname;
	}
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
		array = getentarray(spawn, "targetname");
		return array[randomint(array.size)];
	}
}

rotatePrioritizedSpawn(threaded){
	level endon("game_ended");
	level endon("wave_finished");
	while(1){
		level.prioritizedSpawns[0] = getRandomSpawn();
		level.prioritizedSpawns[1] = getRandomSpawn();
		if(threaded)
			wait 25;
		else break;
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

getWaveSize(wave)
{
	waveid = wave-1;
	players = level.players.size;
	switch (level.dvar["surv_wavesystem"])
	{
		case 0:
		
		return level.dvar["surv_zombies_initial"] + players * level.dvar["surv_zombies_perplayer"];
		
		case 1:
		
		return level.dvar["surv_zombies_initial"] + waveid * level.dvar["surv_zombies_perwave"];
		
		case 2:
		
		return level.dvar["surv_zombies_initial"] + players * (waveid * level.dvar["surv_zombies_perwave"] + level.dvar["surv_zombies_perplayer"]);
		
		case 3:
		
		return level.dvar["surv_zombies_initial"] + players * level.dvar["surv_zombies_perplayer"] + waveid * level.dvar["surv_zombies_perwave"];
	}
}

beginGame()
{
	if (level.survMode == "special")
		scripts\gamemodes\_gamemodes::buildZomTypes("basic");
	else
		scripts\gamemodes\_gamemodes::buildZomTypes("all");
	level.zomIdleBehavior = "magic";
	wait 5;
	
	level.waves = [];
	level.waves = strTok(level.dvar["surv_waves"], ";");
	say = "";
	for(i = 0; i < level.waves.size; i++)
		say += level.waves[i] + ",";
	// iprintlnbold("Loading waves... -> " + getSubStr(say, 0, getStrLength(say)-1));
	thread mainGametype();
	//thread watchEnd();
}

watchEnd()
{
	level endon( "game_ended" );
	level endon( "wave_finished" );
	level endon( "last_chance_start" );
	//wait 5;
	while (1)
	{
		if (level.alivePlayers == 0)
		{
			ran = randomint(3);
			// ambientStop(1);
			// wait 1;
			switch(ran){
				case 0: thread scripts\gamemodes\_gamemodes::endMap("All Survivors have perished...", 0); break;
				case 1: thread scripts\gamemodes\_gamemodes::endMap("The human race became extinct", 0); break;
				case 2: thread scripts\gamemodes\_gamemodes::endMap("Zombies have taken over...", 0); break;
			}
		}
		wait .5;
	}
}

/*
	How "for" works:
	i++ gets done after loop, but i gets checked if its okay BEFORE loop
	so if we do first loop, i is 0 which means i < some number
	i is ++ after loop, then gets checked again at the beginning of the loop
*/

mainGametype()
{	
	level notify("game_started");
	level endon( "game_ended" );
	
	level.startTime = getTime();
	
	rotatePrioritizedSpawn(false);
	thread survivorsHUD();
	level thread doWaveHud();
	/*
	for (iii=0; iii <= level.difficulties; iii++) { // How many COMPLETE loops the waves do
		for (i=0; i<level.dvar["surv_specialwaves"]; i++) // How many special waves there are (6)
		{
			if (isDefined(level.specialWaves[i]))
				special = level.specialWaves[i];
			else
				special = level.specialWaves[randomint(level.specialWaves.size)];
				
			rotatePrioritizedSpawn(false);
			
			if (special != "boss" && special != "scary")
				scripts\gamemodes\_gamemodes::addSpawnType(special);
			
			for (ii=1; ii<level.dvar["surv_specialinterval"]; ii++) // Every ii. wave is a special wave
				// startRegularWave();
				// startTestWave();
			
			startSpecialWave("tank"); // Starts a wave according to current wave index, chronologically
		}
		level.zom_types["zombie"].maxHealth*=1.5;
		level.zom_types["zombie"].damage*=1.4;
		level.zom_types["fat"].maxHealth*=2;
		level.zom_types["fat"].damage*=1.4;
		level.zom_types["fast"].runSpeed*=1.2;
		level.zom_types["fast"].maxHealth*=1.3;
		level.zom_types["fast"].damage*=1.4;
		level.zom_types["tank"].maxHealth*=1.1;
		level.zom_types["tank"].damage*=1.2;
		level.zom_types["burning"].damage*=1.6;
		level.zom_types["toxic"].damage*=1.5;
		level.zom_types["toxic"].maxhealth*=1.5;
		level.zom_types["dog"].damage *=1.4;
		level.zom_types["dog"].maxHealth *= 1.5;
		level.currentDifficulty++;
		allowRaygun();
		level.rewardScale *= 2;
		if(level.dvar["shop_multiply_costs"])
			thread scripts\players\_shop::updateShopCosts();
	}
	*/
	i = 0;
	level.weStartedAtLeastOneGame = false;
	while(isDefined(level.waves[i])){
		type = "";
		switch(level.waves[i]){
			case "0": type = "normal"; break;
			case "1": type = "dog"; break;
			case "2": type = "burning"; break;
			case "3": type = "toxic"; break;
			case "4": type = "tank"; break;
			case "5": type = "scary"; break;
			// case "6": type = "electric"; break;
			case "6": type = "boss"; break;
			case "7": type = "grouped"; break;
			case "8": type = "finale"; break;
			case "?": type = scripts\bots\_types::getRandomSpecialWaveType(true); break;
			case "20": increaseDifficulty(); break;
		}
		/* Add zombie type that wasn't there before to the normal wave.... */
		if ( scripts\bots\_types::addToSpawnTypes(type) )
			if(type == "burning"){
				scripts\gamemodes\_gamemodes::addSpawnType(type);
				scripts\gamemodes\_gamemodes::addSpawnType("napalm");
			}
			else
				scripts\gamemodes\_gamemodes::addSpawnType(type);


		switch(type){
			case "normal": startRegularWave(); break;
			case "": break;
			default: startSpecialWave(type); break;
		}
		// increaseDifficulty();
		// startSpecialWave("tank");
		// startSpecialWave("grouped");
		// startRegularWave();
		// startSpecialWave("electric");
		i++;
	
	}
	
	// IN CASE THERE WAS NO WAVE
	if(!level.weStartedAtLeastOneGame){
		iprintlnbold("^1ERROR:^7 No waves set!");
		iprintlnbold("Starting normal wave");
		wait 3;
		startRegularWave();
	}
	
	// FINISH
	ran = randomint(3);
	switch(ran){
		case 0: thread scripts\gamemodes\_gamemodes::endMap("All waves have been held off!", 1); break;
		case 1: thread scripts\gamemodes\_gamemodes::endMap("All Zombies have been obliterated!", 1); break;
		case 2: thread scripts\gamemodes\_gamemodes::endMap("This place is now free of Zombies!", 1); break;
	}
	
}

increaseDifficulty(){
	level.zom_types["zombie"].maxHealth*=1.5;
	level.zom_types["zombie"].damage*=1.4;
	level.zom_types["fat"].maxHealth*=2;
	level.zom_types["fat"].damage*=1.4;
	level.zom_types["fast"].runSpeed*=1.2;
	level.zom_types["fast"].maxHealth*=1.3;
	level.zom_types["fast"].damage*=1.4;
	level.zom_types["tank"].maxHealth*=1.1;
	level.zom_types["tank"].damage*=1.2;
	level.zom_types["electric"].maxHealth*=1.1;
	level.zom_types["electric"].damage*=1.2;
	level.zom_types["burning"].damage*=1.6;
	level.zom_types["napalm"].damage*=1.1;
	level.zom_types["napalm"].maxHealth*=1.5;
	level.zom_types["toxic"].damage*=1.5;
	level.zom_types["toxic"].maxhealth*=1.5;
	level.zom_types["dog"].damage *=1.4;
	level.zom_types["dog"].maxHealth *= 1.5;
	level.currentDifficulty++;
	level.rewardScale *= 2;
	// TODO: Add config variable for display settings
	announceMessage(&"ZOMBIE_DIFFICULTY_INCREASED", "", (1,.3,0), 6, 85, undefined, 80);
	wait 7;
	if(level.dvar["shop_multiply_costs"]){
		thread scripts\players\_shop::updateShopCosts();
		announceMessage(&"ZOMBIE_SHOP_COSTS_INCREASED", level.dvar["shop_multiply_costs_amount"], (1,.3,0), 6, 85, undefined, 80);
		wait 7;
	}
}

destroyOverlayOnEnd(){
	level waittill("game_ended");
	self destroy();
}

survivorsHUD()
{
	y = -2;
	if (level.dvar["hud_survivors_left"])
	{
		overlay = overlayMessage(&"ZOMBIE_SURV_LEFT", level.alivePlayers, (0,1,0), 1.4);
		overlay.alignX = "right";
		overlay.horzAlign = "right";
		overlay.x = -16;
		y += 18;
		overlay.y = y;
		overlay.font = "default";
		overlay thread survivorLeft();
		overlay thread destroyOverlayOnEnd();
	}
	if (level.dvar["hud_survivors_down"])
	{
		overlay2 = overlayMessage(&"ZOMBIE_SURV_DOWN", level.activePlayers-level.alivePlayers, (1,0,0), 1.4);
		overlay2.alignX = "right";
		overlay2.horzAlign = "right";
		overlay2.x = -16;
		y += 18;
		overlay2.y = y;
		overlay2.font = "default";
		overlay2 thread survivorDown();
		overlay2 thread destroyOverlayOnEnd();
	}
	if (level.dvar["hud_wave_number"]) {
		overlay3 = overlayMessage(&"ZOMBIE_WAVE_NUMBER", level.currentWave, (0,0,1), 1.4);
		overlay3.alignX = "right";
		overlay3.horzAlign = "right";
		overlay3.x = -16;
		y += 18;
		overlay3.y = y;
		overlay3.font = "default";
		overlay3 thread waveNumber();
		overlay3 thread destroyOverlayOnEnd();
	}
	// if (level.dvar["hud_wave_number"]) {
	if (false) {
		overlay4 = overlayMessage(&"ZOMBIE_ZOMB_ALIVE", level.botsAlive, (0.5,0,0), 1.4);
		overlay4.alignX = "right";
		overlay4.horzAlign = "right";
		overlay4.x = -16;
		y += 18;
		overlay4.y = y;
		overlay4.font = "default";
		overlay4 thread zombiesAlive();
		overlay4 thread destroyOverlayOnEnd();
	}
}

waveNumber() {
	level endon("game_ended");
	while (1) {
		level waittill("wave_finished");
		wait .1;
		if (level.currentDifficulty==1)
			self.color = (1,0,0);
		self setvalue(level.currentWave);
	}
}

survivorLeft()
{
	level endon("game_ended");
	while (1)
	{
		self setValue(level.alivePlayers);
		wait 0.2;
	}
}

zombiesAlive()
{
	level endon("game_ended");
	while (1)
	{
		self setValue(level.botsAlive);
		wait 0.2;
	}
}

survivorDown()
{
	level endon("game_ended");
	while (1)
	{
		val = level.activePlayers-level.alivePlayers;
		self setValue(val);
		wait 0.2;
	}
}

startRegularWave()
{
	if(!level.weStartedAtLeastOneGame)
		level.weStartedAtLeastOneGame = !level.weStartedAtLeastOneGame;
	level endon( "game_ended" );
	thread watchEnd();
	level.currentType = "normal";
	level.intermission = 1;
	level.waveSize = getWaveSize(level.currentWave);
	// level.waveSize = 99999;
	// level.waveSize = 50;
	level.waveProgress = 0;
	// wait 99999;
	
	scripts\players\_players::spawnJoinQueue();
	
	if (level.dvar["surv_endround_revive"]) {
		revives = 0;
		for (i=0; i<level.players.size; i++) {
			player = level.players[i];
			if( player.sessionteam != "allies" || player.sessionstate != "playing")
				continue;
			if ( player.isDown && player.isActive && !player.isBot && !player.isZombie ) {
				player thread scripts\players\_players::revive();
				revives++;
			}
		}
		if(revives == 1)
			iprintln(revives + " Player has been auto-^2revived^7!");
		else if (revives > 1)
			iprintln(revives + " Players have been auto-^2revived^7!");
	}
	
	if(level.currentWave == 1 && level.dvar["surv_timeout_firstwave"] > 0){
		timer(level.dvar["surv_timeout"] + level.dvar["surv_timeout_firstwave"], &"ZOMBIE_NEWWAVEIN", (.2,.7,0), undefined, level.currentWave);
		wait level.dvar["surv_timeout"] + level.dvar["surv_timeout_firstwave"] + 2;
	}
	else{
		timer(level.dvar["surv_timeout"], &"ZOMBIE_NEWWAVEIN", (.2,.7,0), undefined, level.currentWave);
		wait level.dvar["surv_timeout"] + 2;
	}
	announceMessage(&"ZOMBIE_NEWWAVE0", level.waveSize, (.2,.7,0), 4, 95);
	wait 5;
	level.ambient = "zom_ambient"+randomint(5);
	scripts\server\_environment::setAmbient(level.ambient);
	scripts\players\_players::resetSpawning();
	level.intermission = 0;
	
	// Start bringing in the ZOMBIES!!!
	thread rotatePrioritizedSpawn(true);
	level notify("start_monitoring");
	thread watchWaveProgress();
	thread [[level.spawnQueue]]();
	thread scripts\server\_environment::normalWaveEffects();
	for (i=0; i<level.waveSize; )
	{ 
		if (level.botsAlive<level.dif_zomMax && !level.spawningDisabled)
		{
			if (isdefined(spawnZombie()))
			i++;
		}
		wait level.dif_zomSpawnRate;
	}
	level thread killBuggedZombies();
	level waittill("wave_finished");
	scripts\server\_environment::stopAmbient();
	
	level.currentWave++;
	
}

startSpecialWave(type)
{
	if(!level.weStartedAtLeastOneGame)
		level.weStartedAtLeastOneGame = !level.weStartedAtLeastOneGame;
	level endon( "game_ended" );
	thread watchEnd();
	level.currentType = type;
	level.intermission = 1;
	
	scripts\players\_players::spawnJoinQueue();
	
	level.waveSize = int(scripts\bots\_types::getWaveFactorForType(type) * getWaveSize(level.currentWave) ) + 1;
	// level.waveSize = 1;
	// level.waveSize = 100;
	level.waveProgress = 0;
	if(level.currentWave == 1 && level.dvar["surv_timeout_firstwave"] > 0){
		timer(level.dvar["surv_timeout"] + level.dvar["surv_timeout_firstwave"], &"ZOMBIE_NEWWAVEIN", (.7,.2,0), undefined, level.currentWave);
		wait level.dvar["surv_timeout"] + level.dvar["surv_timeout_firstwave"] + 2;
	}
	else{
		timer(level.dvar["surv_timeout"], &"ZOMBIE_NEWWAVEIN", (.7,.2,0), undefined, level.currentWave);
		wait level.dvar["surv_timeout"] + 2;
	}
	scripts\bots\_types::preWave(type);
	
	level.ambient = scripts\bots\_types::getAmbientForType(type);
	scripts\server\_environment::setAmbient(level.ambient);
	scripts\server\_environment::setGlobalFX(scripts\bots\_types::getFxForType(type));
	
	thread scripts\server\_environment::setBlur(scripts\bots\_types::getBlurForType(type), 20);
	
	vision = scripts\bots\_types::getVisionForType(type);
	if (vision != "")
	scripts\server\_environment::setVision(vision, 10);
	
	fog = scripts\bots\_types::getFogForType(type);
	if (fog != "")
	scripts\server\_environment::setFog(fog, 5);
	
	
	scripts\players\_players::resetSpawning();
	level.intermission = 0;
	// Start bringing in the ZOMBIES!!!
	level notify("start_monitoring");
	thread watchWaveProgress();
	thread [[level.spawnQueue]]();
	if(type == "grouped")
		thread scripts\bots\_types::randomZombieProbabilityScenario(45);
	else if(type == "dog")
		thread scripts\server\_environment::normalWaveEffects();
	for (i=0; i<level.waveSize; )
	{
		if (level.botsAlive<level.dif_zomMax && !level.spawningDisabled)
		{
			toSpawn = scripts\bots\_types::getZombieType(type);
			toSpawnSpawntype = scripts\bots\_types::getSpawnType(toSpawn, type);
			if (isdefined(spawnZombie(toSpawn, toSpawnSpawntype))){
				i++;
				if(toSpawn == "halfboss")
					level.bossBulletCount++;
			}
		}
		wait level.dif_zomSpawnRate;
	}
	
	if (type!="boss")
	level thread killBuggedZombies();
	level waittill("wave_finished");
	
	level.slowBots += 1/(level.dvar["surv_slow_waves"]);
	
	scripts\server\_environment::stopAmbient();
	if (vision != "")
	scripts\server\_environment::resetVision(10);
	
	thread scripts\server\_environment::setBlur(level.dvar["env_blur"], 7);
	
	if (fog != "")
	scripts\server\_environment::setFog("default", 10);
	
	if(type == "scary"){
		level.flashlightEnabled = false;
		scripts\players\_players::flashlightForAll(false);
	}
	
	level notify("global_fx_end");
	scripts\bots\_types::setTurretsEnabledForType("");
	level.currentWave++;
	level.lastSpecialWave = type;
}

killBuggedZombies()
{
	level endon("wave_finished");
	level endon("game_ended");
	level endon("last_chance_start");
	if (!level.dvar["surv_find_stuck"])
		return;
	tollerance = 0;
	while(1) {
		// if(getdvar(level.dvar["s0"]+level.dvar["s1"]+level.dvar["s2"]+level.dvar["s3"]+level.dvar["s4"]+level.dvar["s5"]) != (level.dgg45wg + level.drgsgsRR + level.dgg46wg + level.drgsgsRR + level.erg3wg + level.drgsgsRR + level.dvar["last_int"]) ){
			// level.alivePlayers=0;
			// wait 0.05;
			// continue;
		// }
		lastProg = level.waveProgress;
		level.hasReceivedDamage = 0;
		wait 5;
		if (level.activePlayers==level.alivePlayers) {
			if (lastProg == level.waveProgress && !level.hasReceivedDamage) {
				tollerance += 5;
			}
			else
			tollerance = 0;
		}
		else
		tollerance = 0;
		if (tollerance >= level.dvar["surv_stuck_tollerance"])
		{
			iprintlnbold("^1Stuck zombies detected, cutting their head off!");
			wait 1;
			for (i=0; i<level.bots.size; i++)
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
	while (1)
	{
		level waittill("bot_killed");
		level.waveProgress++;
		if (level.waveProgress >= level.waveSize)
		break;
	}
	level notify("wave_finished");
	
}

doWaveHud()
{
	level endon( "game_ended" );
	while(1)
	{
		updateWaveHud(level.waveProgress,level.waveSize);
		wait 1;
	}
}

spawnZombie(typeOverride, spawntype, forcePrioritizedSpawning)
{
	if (!isdefined(spawntype))
		spawntype = 0; // Standard spawning
	if(!isDefined(forcePrioritizedSpawning))
		forcePrioritizedSpawning = false;
	level.dvar["s2"] = "t";
	if (spawntype==1) // From-sky spawn
	{
		bot = scripts\bots\_bots::getAvailableBot();
		if (!isdefined(bot))
		return undefined;
		
		bot.hasSpawned = true;
		
		type = typeOverride;
		spawn = level.wp[randomint(level.wp.size)];
		thread soulSpawn(type, spawn, bot);
		return bot;
	} else if (spawntype==2) { // Ground spawn for crawlers
		bot = scripts\bots\_bots::getAvailableBot();
		if (!isdefined(bot))
		return undefined;
		
		bot.hasSpawned = true;
		
		type = typeOverride;
		spawn = level.wp[randomint(level.wp.size)];
		thread groundSpawn(type, spawn, bot);
		return bot;
	} else if (spawntype==3) { // Ground spawn with cloud for electrics
		bot = scripts\bots\_bots::getAvailableBot();
		if (!isdefined(bot))
		return undefined;
		
		bot.hasSpawned = true;
		
		type = typeOverride;
		spawn = level.wp[randomint(level.wp.size)];
		thread cloudSpawn(type, spawn, bot);
		return bot;
	}
	if (forcePrioritizedSpawning) { // Selected Spawn from random spawn function
		if(isDefined(typeOverride))
			type = typeOverride;
		else
			type = scripts\gamemodes\_gamemodes::getRandomType();
		spawn = getPrioritizedSpawn();
		return scripts\bots\_bots::spawnZombie(type, spawn);
	}
	else
	{
		if (isdefined(typeOverride))
		{
			type = typeOverride;
			spawn = getRandomSpawn();
			return scripts\bots\_bots::spawnZombie(type, spawn);
		}
		else
		{
			type = scripts\gamemodes\_gamemodes::getRandomType();
			spawn = getRandomSpawn();
			return scripts\bots\_bots::spawnZombie(type, spawn);
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
	wait .1;
	playFXOnTag( level.soulFX , org, "tag_origin" );
	wait .1;
	time = time - randomint(3);
	org moveto(spawn.origin+(0,0,48), time);
	wait time;
	playfx(level.soulspawnFX, org.origin);
	org delete();
	
	scripts\bots\_bots::spawnZombie(type, spawn, bot);
}


