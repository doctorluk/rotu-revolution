/**
* vim: set ft=cpp:
* file: scripts\gamemodes\_survival.gsc
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

#include scripts\include\hud;
#include scripts\include\data;
#include scripts\include\strings;
#include scripts\include\useful;
#include scripts\gamemodes\_waves;

initGame()
{
	level.freezeProgress = false;
	level.forceWaveNumber = false;
	level.forceWaveType = false;
	
	level.gameState = "idle";
	level.abortWave = false;

	level.currentWave = 1;
	level.ambient = "zom_ambient0";
	level.flashlightEnabled = false;
	level.currentDifficulty = 0;
	level.currentType = "";
	level.lastSpecialWave = "";
	level.killedZombies = 0;
	level.bosscount = 1;
	level.bossPhase = -1;
	level.freezePlayers = false;
	level.disableWeapons = false;
	level.spawningDisabled = 0;
	level.hasReceivedDamage = 0;
	level.prioritizedSpawnTime = getTime();
	level.prioritizedSpawns = [];
	thread loadConfig();
}

loadConfig()
{
	wait .1;// Assume types not set, loading default
	
	dvarDefault("surv_special1", "dog");
	dvarDefault("surv_special2", "burning");
	dvarDefault("surv_special3", "helldog");
	dvarDefault("surv_special4", "toxic");
	dvarDefault("surv_special5", "scary");
	dvarDefault("surv_special6", "tank");
	dvarDefault("surv_special7", "boss");
	dvarDefault("surv_special8", "grouped");
	dvarDefault("surv_special9", "finale");
	
	level.availableSpecialWaves = [];
	level.availableSpecialWaves[level.availableSpecialWaves.size] = "dog";
	level.availableSpecialWaves[level.availableSpecialWaves.size] = "burning";
	level.availableSpecialWaves[level.availableSpecialWaves.size] = "helldog";
	level.availableSpecialWaves[level.availableSpecialWaves.size] = "toxic";
	level.availableSpecialWaves[level.availableSpecialWaves.size] = "scary";
	level.availableSpecialWaves[level.availableSpecialWaves.size] = "tank";
	level.availableSpecialWaves[level.availableSpecialWaves.size] = "grouped";
	
	
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
		level.ammoStockType = "weapon";
		level.spawnPrimary = level.dvar["surv_waw_spawnprimary"];
		level.spawnSecondary = level.dvar["surv_waw_spawnsecondary"];
	}
	else if (level.dvar["surv_weaponmode"] == "upgrade")
	{
		level.ammoStockType = "upgrade";
	}
	level.slowBots = 1 - level.dvar["surv_slow_start"];
}

dvarDefault(dvar, def)
{
	if (getdvar(dvar) == "")
		setdvar(dvar, def);
}

addSpawn(targetname, priority)
{
	if (!isdefined(level.survSpawns))
	return -1;
	
	if (!isdefined(priority))
	priority = 1;
	
	
	spawns = getentarray(targetname, "targetname");
	
	// iprintlnbold("Name: " + targetname + ", size: " + spawns.size);
	
	if (spawns.size > 0)
	{
		ii = level.survSpawns.size;
		level.survSpawnsPriority[ii] = priority;
		level.survSpawnsTotalPriority = level.survSpawnsTotalPriority + priority;
		level.survSpawns[ii] = targetname;
	}
}

removeSpawn(targetname){

	if (!isdefined(level.survSpawns))
	return -1;
	
	for(i = 0; i < level.survSpawns.size; i++){
		if(level.survSpawns[i] == targetname){
			level.survSpawnsTotalPriority = level.survSpawnsTotalPriority - level.survSpawnsPriority[i];
			level.survSpawnsPriority = removeFromArray(level.survSpawnsPriority, level.survSpawnsPriority[i]);
			level.survSpawns = removeFromArray(level.survSpawns, level.survSpawns[i]);
		
		}
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
	// iprintlnbold("Loading waves... -> " + getSubStr(say, 0, say.size - 1));
	thread mainGametype();
	//thread watchEnd();
}

watchEnd()
{
	level endon("game_ended");
	level endon("wave_finished");
	level endon("last_chance_start");
	//wait 5;
	while (1)
	{
		wait .5;
		if (level.alivePlayers == 0)
		{
			ran = randomint(3);
			switch(ran){
				case 0: thread scripts\gamemodes\_gamemodes::endMap("All Survivors have perished...", 0); break;
				case 1: thread scripts\gamemodes\_gamemodes::endMap("The human race became extinct", 0); break;
				case 2: thread scripts\gamemodes\_gamemodes::endMap("Zombies have taken over...", 0); break;
			}
		}
	}
}

mainGametype()
{	
	level notify("game_started");
	level endon("game_ended");
	
	level.startTime = getTime();
	
	rotatePrioritizedSpawn(false);
	thread survivorsHUD();
	thread doWaveHud();
	
	level.weStartedAtLeastOneGame = false;
	while(isDefined(level.waves[level.currentWave-1])){
	
		if(level.lastSpecialWave == "finale") // Whenever we had a finale, we end the game
			break;
		
		if( level.forceWaveType )
			config_wavetype = level.forceWaveType;
		else
			config_wavetype = level.waves[level.currentWave-1];
			
		type = "";
		
		switch(config_wavetype){
			case "": type = ""; break;
			case "0": type = "normal"; break;
			case "1": type = "dog"; break;
			case "2": type = "burning"; break;
			case "3": type = "helldog"; break;
			case "4": type = "toxic"; break;
			case "5": type = "tank"; break;
			case "6": type = "scary"; break;
			case "7": type = "boss"; break;
			case "8": type = "grouped"; break;
			case "9": type = "finale"; break;
			// case "8": iprintlnbold("Finale is currently disabled!"); break;
			case "?": type = scripts\bots\_types::getRandomSpecialWaveType(true); break;
			case "20": increaseDifficulty(); break;
			default: iprintlnbold("^1Error: ^7Bad server configuration of dvar 'surv_waves'! Invalid type: '" + config_wavetype + "'"); break;
		}
		
		
		/* Add zombie type that wasn't there before to the normal wave.... */
		if (scripts\bots\_types::addToSpawnTypes(type))
			if(type == "burning"){
				scripts\gamemodes\_gamemodes::addSpawnType("burning");
				scripts\gamemodes\_gamemodes::addSpawnType("napalm");
				scripts\gamemodes\_gamemodes::addSpawnType("helldog");
			}
			else
				scripts\gamemodes\_gamemodes::addSpawnType(type);

		switch(type){
			case "normal": startRegularWave(); break;
			case "finale": startFinalWave(); break;
			case "": break;
			default: startSpecialWave(type); break;
		}

		// Force a certain wave number (a number in the order of the wave config)
		if( level.forceWaveNumber )
			level.currentWave = level.forceWaveNumber;
		else if( !level.freezeProgress )
			level.currentWave++;
		
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
	level.zom_types["burning"].damage*=1.6;
	level.zom_types["napalm"].damage*=1.1;
	level.zom_types["napalm"].maxHealth*=1.5;
	level.zom_types["toxic"].damage*=1.5;
	level.zom_types["toxic"].maxhealth*=1.5;
	level.zom_types["dog"].damage *=1.4;
	level.zom_types["dog"].maxHealth *= 1.5;
	level.zom_types["helldog"].damage *=1.4;
	level.zom_types["helldog"].maxHealth *= 1.5;
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
	if (level.dvar["hud_zombies_alive"]) {
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
		val = level.activePlayers - level.alivePlayers;
		self setValue(val);
		wait 0.2;
	}
}

doWaveHud()
{
	level endon("game_ended");
	while(1){
		updateWaveHud(level.waveProgress, level.waveSize);
		wait 1;
	}
}