/**
* vim: set ft=cpp:
* file: scripts\gamemodes\_gamemodes.gsc
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
* 	_gamemodes.gsc
*	Handles game related features, such as Spawns, Difficulty settings, Zombie types (TODO: Move them to _types.gsc?)
*	and the game's end
*
*/

#include scripts\include\physics;
#include scripts\include\data;
#include scripts\include\strings;
#include scripts\include\useful;

init()
{
	// Start gametype related threads (TODO: Move them into appropriate inits of other .gsc files)
	thread scripts\gamemodes\_hud::init();
	thread scripts\gamemodes\_upgradables::init();
	thread scripts\gamemodes\_mysterybox::init();
	
	precache();
	dropSpawns();
	initStats();

	// Initialize basic vars and default difficulty settings
	level.gameEnded = false;
	level.dif_zomHPMod = 1;
	level.dif_zomMax = 100;
	level.dif_zomPP = 5;
	level.dif_zomSpawnRate = .5;
	level.dif_zomDamMod = 1;
	level.dif_killedLast5Sec = 0;
	
	level.ammoStockType = "ammo";
	
	// Duration of credits
	level.creditTime = 6;
}

/**
*	Loads the FX played when players lose and spawn a soul-FX out of their body
*/
precache()
{
	level.soul_deathfx = loadfx("misc/soul_death");
}

/**
*	Gets a map's TDM and DM spawns and moves their origin onto the ground with a playerPhysicsTrace
*/
dropSpawns()
{
	TDMSpawns = getentarray("mp_tdm_spawn", "classname");
	for(i = 0; i < TDMSpawns.size; i++)
	{
		spawn = TDMSpawns[i];
		spawn.origin = dropPlayer(spawn.origin + (0, 0, 32), 300);
	}
	
	DMSpawns = getentarray("mp_dm_spawn", "classname");
	for(i = 0; i < DMSpawns.size; i++)
	{
		spawn = DMSpawns[i];
		spawn.origin = dropPlayer(spawn.origin + (0, 0, 32), 300);
	}
}

/**
*	Creates an array with valid stat values, their corresponding display text and their varying display colour override
*	Can be distinguished via strTok(text, ";")
*	? means optional
*	[0] = script-global prefix
*	[1] = display prefix
*	[2] = colour modification for the displayed value
*	[3] ? = additional suffix
*	[4] ? = additional backgroundColor modification, standard is (.1,.8,0)
*	In case we leave additional cases out, we put a "," as placeholder between the ";"-separators
*/
initStats()
{
	level.statsTypes = [];

	level.statsTypes[level.statsTypes.size] = "kills;Killermachine: ;^7; Kills";
	level.statsTypes[level.statsTypes.size] = "deaths;Situps Trainer: ;^1; times down;(.8,.1,.0)";
	level.statsTypes[level.statsTypes.size] = "assists;Helped where he could: ;^3; Assists;(.5,.5,.0)";
	level.statsTypes[level.statsTypes.size] = "downtime;Most Time spent down: ;^1;,;(.8,.1,.0)";
	level.statsTypes[level.statsTypes.size] = "heals;Healing Hand: ;^2; HP healed;(0,1,.0)";
	level.statsTypes[level.statsTypes.size] = "revives;Field-Medic: ;^2; revives;(1,1,1)";
	level.statsTypes[level.statsTypes.size] = "ammo;Running Ammobelt: ;^2; Rounds supplied;(.1,.1,.8)";
	level.statsTypes[level.statsTypes.size] = "timeplayed;Longest time played: ;^7";
	level.statsTypes[level.statsTypes.size] = "damagedealt;No Mercy: ;^7; Damage dealt;(.7,.6,.0)";
	level.statsTypes[level.statsTypes.size] = "damagedealttoboss;Dance with the Big: ;^7; Damage to Bosses";
	level.statsTypes[level.statsTypes.size] = "turretkills;Remote-Killer: ;^7; Turret Kills";
	level.statsTypes[level.statsTypes.size] = "upgradepointsspent;Shopping Queen: ;^7; U-Points spent";
	level.statsTypes[level.statsTypes.size] = "upgradepoints;Moneyking: ;^7; U-Points in stock";
	level.statsTypes[level.statsTypes.size] = "explosivekills;Holy Handgrenade: ;^7; Explosive Kills;(1,1,0)";
	level.statsTypes[level.statsTypes.size] = "knifekills;Hidden Samurai: ;^7; Knife Kills;(.7,0,.7)";
	level.statsTypes[level.statsTypes.size] = "survivor;Defied Death: ;^2; times down;(.0,.7,0)";
	level.statsTypes[level.statsTypes.size] = "zombiefied;Unlucky Bastard: ;^1; times becoming a Zombie;(.3,.2,.0)";
	level.statsTypes[level.statsTypes.size] = "ignitions;Hot Bullets: ;^7; Zombies ignited";
	level.statsTypes[level.statsTypes.size] = "poisons;Filthy Gun: ;^7; Zombies poisoned";
	level.statsTypes[level.statsTypes.size] = "headshots;Head Hunter: ;^7; Headshot Kills";
	level.statsTypes[level.statsTypes.size] = "barriers;YOU SHALL NOT PASS! ;^7; Barriers repaired";
	level.statsTypes[level.statsTypes.size] = "firstminigun;First minigun bought by: ;^7";
	level.statsTypes[level.statsTypes.size] = "moredeathsthankills;^1EPIC FAIL: ;^7; has more Deaths than Kills;(.8,.1,0)";
}

/**
*	Loads the given gamemode that is configured in a CFG
*/
initGameMode()
{
	if (!isDefined(level.gameMode))
	level.gameMode = level.dvar["surv_defaultmode"]; // Default gamemode
	
	loadGameMode(level.gameMode);
	loadDifficulty(level.dvar["game_difficulty"]);
}

/**
*	Loads the given 'mode' as gamemode
*	@mode String, Either 'special' or 'endless'
*/
loadGameMode(mode)
{
	switch(mode)
	{
		case "waves_special":
			loadSurvivalMode("special");
		break;
		case "waves_endless":
			loadSurvivalMode("endless");
		break;
		/*
		case "scripted":
			loadScriptedMode();
		break;
		case "onslaught":
			loadOnslaughtMode();
		break;
		*/
		default:
			loadSurvivalMode("special");
		break;
	}
}

/**
*	Scripted mode was never finished
*	TODO: Remove entirely?
*/
loadScriptedMode()
{
	// Scripted mode doesn't do much
}

/**
*	Also a mode that was never finished
*	TODO: Remove entirely?
*/
loadOnslaughtMode()
{
	level.currentPlayer = 0;
}

/**
*	If Survival mode was chosen, it loads "special" or "endless"
*	"special" is currently the only fully scripted mode
*	@mode String, Loads the given mode
*/
loadSurvivalMode(mode)
{
	level.survMode = mode;
	level.survSpawns = [];
	level.survSpawnsTotalPriority = 0;
	thread scripts\gamemodes\_survival::initGame();
}

/**
*	This function is used to mix up random zombies in a 'normal' wave
*	Priorities of certain types are calculated using 'weight', like 'priority'
*	@preset String, Loads a zombie-collection, can be 'regular', 'dogs', 'basic' or 'all'
*/
buildZomTypes(preset)
{
	level.zom_spawntypes = [];
	level.zom_spawntypes_weight = [];
	level.zom_spawntypes_weightotal = 0;
	
	level.zom_typenames["zombie"] = "Zombies";
	level.zom_typenames["dog"] = "Dogs";
	level.zom_typenames["fast"] = "quick Zombies";
	level.zom_typenames["fat"] = "fat Zombies";
	level.zom_typenames["burning"] = "inferno Zombies";
	level.zom_typenames["helldog"] = "Hellhounds";
	level.zom_typenames["toxic"] = "crawler Zombies";
	level.zom_typenames["tank"] = "hell Zombies";
	level.zom_typenames["grouped"] = "grouped Zombies";
	level.zom_typenames["boss"] = "^1One Final Zombie^7";
	
	switch (preset)
	{
		case "regular":
			level.zom_spawntypes[0] = "zombie";
			level.zom_spawntypes_weight[0] = 1;
			level.zom_spawntypes_weightotal = 1;
		break;
		case "dogs":
			level.zom_spawntypes[0] = "dog";
			level.zom_spawntypes_weight[0] = 1;
			level.zom_spawntypes_weightotal = 1;
		break;
		case "basic":
			level.zom_spawntypes[0] = "zombie";
			level.zom_spawntypes_weight[0] = 9;
			level.zom_spawntypes[1] = "fat";
			level.zom_spawntypes_weight[1] = 3;
			level.zom_spawntypes[2] = "fast";
			level.zom_spawntypes_weight[2] = 3;
			level.zom_spawntypes_weightotal = 15;
			
		break;
		case "all":
			level.zom_spawntypes[0] = "zombie";
			level.zom_spawntypes_weight[0] = 9;
			level.zom_spawntypes[1] = "fat";
			level.zom_spawntypes_weight[1] = 3;
			level.zom_spawntypes[2] = "fast";
			level.zom_spawntypes_weight[2] = 3;
			level.zom_spawntypes[3] = "burning";
			level.zom_spawntypes_weight[3] = 2;
			level.zom_spawntypes[4] = "toxic";
			level.zom_spawntypes_weight[4] = 2;
			level.zom_spawntypes[5] = "dog";
			level.zom_spawntypes_weight[5] = 3;
			level.zom_spawntypes[6] = "tank";
			level.zom_spawntypes_weight[6] = 2;
			level.zom_spawntypes[7] = "napalm";
			level.zom_spawntypes_weight[7] = 2;
			level.zom_spawntypes[8] = "helldog";
			level.zom_spawntypes_weight[8] = 2;
			level.zom_spawntypes_weightotal = 28;
		break;
	}
}

/**
*	Returns the default weight (read: priority) for certain zombie types
*	@type String, Name of zombie type
*	@return Int, Weight of given @type
*/
getDefaultWeight(type)
{
	switch (type)
	{
		case "zombie":
		return 9;
		case "fat":
		return 3;
		case "fast":
		return 3;
		case "burning":
		return 2;
		case "helldog":
		return 2;
		case "toxic":
		return 2;
		case "dog":
		return 3;
		case "tank":
		return 2;
		case "napalm":
		return 2;
	}
}

/**
*	Adds zombie 'type' to level.zom_spawntypes[]
*	@type String, Type of zombie
*/
addSpawnType(type)
{
	// Gets the default weight of the selected type and checks whether that is defined and also prevents it from being added twice to the array
	weight = getDefaultWeight(type);
	if(!isDefined(weight) || arrayContains(level.zom_spawntypes, type))
		return;
	
	// If all is good, add it to the array
	level.zom_spawntypes_weightotal += weight;
	level.zom_spawntypes[level.zom_spawntypes.size] = type;
	level.zom_spawntypes_weight[level.zom_spawntypes_weight.size] = weight;
}

/**
*	@return String, A random zombie type, taking the weight of each type into consideration
*/
getRandomType()
{
	// Calculate a random number based on the total amount of weight all zombies have in the currently selected spawntypes
	weight = randomInt(level.zom_spawntypes_weightotal);
	
	for(i = 0; i < level.zom_spawntypes.size; i++)
	{
		// We go from zombie to zombie, reducing our random number by the weight of the currently selected zombie type
		weight -= level.zom_spawntypes_weight[i];
		
		// If we drop below 0, we select this type and return it
		if(weight < 0)
			return level.zom_spawntypes[i];
	}
}

/**
*	Loads the specified difficulty for the currently running game
*	This modifies the zombies' HP-scaling, the amount of zombies alive per player and the boss phases before he's dead
*	TODO: Fine tune and add more?
*	@difficulty Int, Defines difficulty to load, can be 1, 2, 3 or 4
*/
loadDifficulty(difficulty)
{
	switch (difficulty)
	{
		case 1:
			level.dif_zomPP = 2;
			level.dif_zomHPMod = .5;
			level.maxBossPhases = 3;
			break;
		case 2:
			level.dif_zomPP = 5;
			level.dif_zomHPMod = .75;
			level.maxBossPhases = 4;
			break;
		case 3:
			level.dif_zomPP = 8;
			level.dif_zomHPMod = 1;
			level.maxBossPhases = 4;
			break;
		case 4:
			level.dif_zomPP = 10;
			level.dif_zomHPMod = 1.5;
			level.maxBossPhases = 6;
			break;
	}
	
	// In case we want the game to be more dynamic and not always rush zombies in, especially when the players are not doing well, we also modify it dynamically
	if(level.dvar["zom_dynamicdifficulty"])
		level thread monitorDifficulty();
}

/**
*	Since the situation is always quite chaotic and is never the same since it depends on map design and player skill,
*	this function monitors the killing of zombies and dynamically calculates the spawnrate of zombies, adjusting to the skill of all players
*/
monitorDifficulty()
{	
	level endon("stop_monitoring");
	level endon("game_ended");
	
	thread resumeMonitoring();
	
	// Only run this monitor at the start of a wave, not during intermission
	level waittill("start_monitoring");
	
	while(1)
	{
		level.dif_zomMax = level.dif_zomPP * level.activePlayers;
		level.dif_zomSpawnRate = 0.1;
		
		// If zombies have been killed during the last 5 seconds we calculate the new spawnspeed with the amount of killed zombies and the amount of players
		if (level.dif_killedLast5Sec != 0)
		{
			level.dif_zomSpawnRate = 0.4 * (level.dif_killedLast5Sec / level.activePlayers);
			/* Examples:
				Fixed 
					Last5SecKilled
						  Players
							    Spawntime
				0.4 * (10 / 20) = 0.2
				0.4 * (5 / 5) = 0.4
				0.4 * (20 / 5) = 1.6
				0.4 * (5 / 20) = 0.1
				0.4 * (10 / 10) = 0.4
			*/
			// Prevent infinite loops, since this var is used as 'wait time' between zombie spawns. We can't go below 0.05 sec
			if (level.dif_zomSpawnRate < 0.05)
				level.dif_zomSpawnRate = 0.05;
				
			level.dif_killedLast5Sec = 0;
		}
		
		// Since the if function above can return false, we still need to make sure to never drop below 0.05 seconds for the wait
		if (level.dif_zomSpawnRate < 0.05)
			level.dif_zomSpawnRate = 0.05;
		
		level.dif_zomDamMod = 0.5;
		
		// Based on the amount of players, we modify the zombies' damage
		// TODO: 30 Players is a bunch, but should we really go to 2x damage?
		if (level.activePlayers > 5)
			level.dif_zomDamMod = 0.75;
		
		if (level.activePlayers > 10)
			level.dif_zomDamMod = 1;
		
		if (level.activePlayers > 15)
			level.dif_zomDamMod = 1.25;
		
		if (level.activePlayers > 20)
			level.dif_zomDamMod = 1.5;
		
		if (level.activePlayers > 25)
			level.dif_zomDamMod = 1.75;
		
		if (level.activePlayers > 30)
			level.dif_zomDamMod = 2;
		
		wait 5;
	}
}

/**
*	Reset the monitor to wait for a wave to start
*/
resumeMonitoring()
{
	level waittill("stop_monitoring");
	
	thread monitorDifficulty();
}

/**
*	@waveNumber String, A wave number
*	@return Boolean, Whether a wave set in the rotu.cfg is actually a wave or not (e.g. difficulty changes)
*/
isWave(waveNumber)
{
	switch(waveNumber)
	{
		case "20":
			return false;
		default:
			return true;
	}
}

/**
*	Adds the time a player was down to his downtimer at the end of the game
*/
stopDownTimer()
{
	self.stats["downtime"] += level.gameEndTime - self.stats["lastDowntime"];
}

/**
*	This function controls the outro sequence
*	@endReasontext String, Text to display at the top of the screen
*	@win Boolean, Whether the map was won or lost
*/
endMap(endReasontext, win)
{
	// TODO: Check whether endMap is ever called without win being defined, if not, remove
	if (!isDefined(win))
		win = false;
	
	// If all players died, we need to check for the Last Chance before we end the game
	if(!win)
	{
		lastChance = scripts\gamemodes\_lastchance::lastChanceMain();
		// If the Last Chance kicked in, we don't end the game
		if(lastChance)
			return;
	}
	
	// All checks are gone, the game must end. We mute zombies and save all data for stats etc.
	level.gameEnded = true;
	level.gameEndTime = getTime();
	game["state"] = "postgame";
	
	level notify("intermission");
	level notify("game_ended");
	
	// Save the stats of this game to RotU-Stats if enabled
	scripts\extras\_rotustats::saveGameStats(win);
	
	// TODO: Is this needed?
	setGameEndTime(0);
	alliedscore = getTeamScore("allies");
	axisscore = getTeamScore("axis");
	//
	
	// If not enabled by default, make sure dead players can chat with Spectators etc.
	setdvar("g_deadChat", 1);
	
	// Disable turrets and make Zombies silent
	level.turretsDisabled = 1;
	level.silenceZombies = true;
	
	// Mute running wave music
	scripts\server\_environment::stopAmbient(3);
	
	// Zombified players should return to humans to get properly reset
	for(i = 0; i < level.players.size; i++)
	{
		if(isReallyPlaying(level.players[i]))
		{
			if(level.players[i].isZombie)
			{
				level.players[i] suicide();
			}
		}
	}
	
	// Wait for the ambient sound to disappear
	wait 3;
	
	// Clean up the players, remove any usabilities, save downtimer stats and remove the HUD
	for(i = 0; i < level.players.size; i++)
	{
		level.players[i] scripts\players\_usables::usableAbort();
		level.players[i] closeMenu();
		level.players[i] closeInGameMenu();
		
		if(isDefined(level.players[i].isDown))
		{
			if(level.players[i].isDown)
				level.players[i] stopDownTimer();
		}
		
		// Remove Health HUD
		level.players[i] scripts\include\hud::updateHealthHud(-1);
		
		// Remove remaining HUD texts and effects
		level.players[i] setClientDvars("ui_upgradetext", "", "ui_specialtext", "", "ui_specialrecharge", 0, "ui_hud_hardcore", 1, "r_blur", 0);
	}
	
	// Clean up wave-specific effects
	scripts\server\_environment::resetVision(1);
	scripts\server\_environment::setFog("default");
	
	// If a boss is on the map, remove the Health display
	if(isDefined(level.bossOverlay))
		level.bossOverlay destroy();
	
	// I better not write what this does. It would spoil the fun. Seriously. Don't look it up.
	if(scripts\include\physics::finalizeStats())
	{
		// Play music for winning or losing
		if(win)
			thread playCreditsSound();
		else
			thread playEndSound();
			
		// Show text when LOSING
		if(!win)
		{
			
			// Flashing Blackscreen
			// Is used to prevent players from seeing themselves being moved to the overview position over the map
			level.blackscreen = newHudElem();
			level.blackscreen.sort = -2;
			level.blackscreen.alignX = "left";
			level.blackscreen.alignY = "top";
			level.blackscreen.x = 0;
			level.blackscreen.y = 0;
			level.blackscreen.horzAlign = "fullscreen";
			level.blackscreen.vertAlign = "fullscreen";
			level.blackscreen.foreground = true;
			level.blackscreen.alpha = 1;
			level.blackscreen setShader("black", 640, 480);
			
			// Text showing the lose message at the top, slowly popping up
			level.end_text = newHudElem();
			level.end_text.font = "objective";
			level.end_text.fontScale = 2.4;
			level.end_text setText(endReasontext);
			level.end_text.alignX = "center";
			level.end_text.alignY = "top";
			level.end_text.horzAlign = "center";
			level.end_text.vertAlign = "top";
			level.end_text.x = 0;
			level.end_text.y = 96;
			level.end_text.sort = -1; //-3
			level.end_text.alpha = 1;
			level.end_text.glowColor = (1, 0, 0);
			level.end_text.glowAlpha = 1;
			level.end_text.foreground = true;
			
			// Fadeout the black screen immediately
			level.blackscreen fadeOverTime(2);
			level.blackscreen.alpha = 0;
			
			// Flash everyone's screen shortly in white
			thread scripts\server\_environment::flashViewAll((1, 1, 1), .2, .5);
			
			// Slowly display the losing message at the top
			level.end_text setPulseFX(150, int(10000), 1000);
			
			// Places the spectateview entity to which players will be attached to to overview the battlefield
			spawnSpectateViewEntity();
			
			// Do another cleanup on all players to prepare for the endview
			for(i = 0; i < level.players.size; i++)
			{
				player = level.players[i];
				
				if(player.isActive)
				{
					// Remove any text on screen
					if(isDefined(player.hinttext))
						player.hinttext destroy();
					
					// Prevent infected Players from going Zombie
					if(player.infected)
						player notify("infection_cured");
					
					// Calculate the time played for all players
					// TODO: This is only done for active players, is the playtime covered for players, who went spectator mid-game?
					player.stats["timeplayed"] += getTime() - player.stats["playtimeStart"];
					
					// Spawn a death FX on all players
					thread soulSpawnOnEnd(player.origin);
					
					// If existing, move the player to the endview entity above the map
					player thread setupSpectateView();
				}
			}
			
			// Show who made the mod
			// TODO: Add waittill and/or remove thread?
			thread displayCredits();
			
			// The credits start 8 seconds later, so we want to delay the blackscreen appearing for 7 seconds
			wait 7;
			
			// Fade in the blackscreen
			level.blackscreen fadeOverTime(4);
			level.blackscreen.alpha = 0.5;
			
			// Fade out the top lose text
			// TODO: Is fadeout needed? The pulsefx removes the text already
			level.end_text fadeOverTime(1);
			level.end_text.alpha = 0;
			
			// Once faded out, remove the text entirely
			wait 1;
			level.end_text destroy();
		}
		else
		{
			// Show text when WINNING
			
			// Blackscreen, this time only fading in after credits
			level.blackscreen = newHudElem();
			level.blackscreen.sort = -2;
			level.blackscreen.alignX = "left";
			level.blackscreen.alignY = "top";
			level.blackscreen.x = 0;
			level.blackscreen.y = 0;
			level.blackscreen.horzAlign = "fullscreen";
			level.blackscreen.vertAlign = "fullscreen";
			level.blackscreen.foreground = true;
			level.blackscreen.alpha = 0;
			level.blackscreen setShader("black", 640, 480);
			
			// Text showing the win message at the top, slowly popping up
			level.end_text = newHudElem();
			level.end_text.font = "objective";
			level.end_text.fontScale = 2.4;
			level.end_text setText(endReasontext);
			level.end_text.alignX = "center";
			level.end_text.alignY = "top";
			level.end_text.horzAlign = "center";
			level.end_text.vertAlign = "top";
			level.end_text.x = 0;
			level.end_text.y = 96;
			level.end_text.sort = -1;
			level.end_text.alpha = 1;
			level.end_text.glowColor = (0, 1, 0);
			level.end_text.glowAlpha = 1;
			level.end_text.foreground = true;
			
			// Slowly display the winning message at the top
			level.end_text setPulseFX(150, int(10000), 1000);
			
			// Cleanup all players (Hud, Infection and save playtime)
			for(i = 0; i < level.players.size; i++)
			{
				player = level.players[i];
				
				if(player.isActive)
				{
					// Remove a hinttext
					if(isDefined(player.hinttext))
						player.hinttext destroy();
						
					// Prevent infected Players from going Zombie
					if(player.infected) 
						player notify("infection_cured");
					
					// Save the player's playtime
					player.stats["timeplayed"] += getTime() - player.stats["playtimeStart"];
				}
				
				player freezePlayerForRoundEnd();
			}
			
			// Show who made the mod
			// TODO: Add waittill and/or remove thread?
			thread displayCredits();
			
			// The credits start 8 seconds later, so we want to delay the blackscreen appearing for 7 seconds
			wait 7;
			
			// Fade in the blackscreen
			level.blackscreen fadeOverTime(4);
			level.blackscreen.alpha = 0.5;
			
			// Fade out the top lose text
			// TODO: Is fadeout needed? The pulsefx removes the text already
			level.end_text fadeOverTime(1);
			level.end_text.alpha = 0;
			
			// Once faded out, remove the text entirely
			wait 1;
			level.end_text destroy();
		}
		
		// Now we just wait until the stats and credits are gone, then we proceed to the mapvoting
		level waittill("credits_gone");
		
		wait 1;
		if(isDefined(level.blackscreen))
			level.blackscreen destroy();
	}
	
	[[level.onChangeMap]]();
}

/**
*	Displays on-screen who created the mod
*/
displayCredits()
{
	// Set the starting height of the text, incremented every time another credit text is displayed
	level.startY = 220;
	
	// Wait until the initial win/lose message has been displayed
	// TODO: Use waittills and not waits and seemingly random times
	wait 8;
	
	// Show text, delaying every display by 0.5 seconds
	thread showCredit("REVOLUTION Development:", "credit", 1.4, 80);
	wait 0.5;
	
	// WARNING !!!!!!!!!!!!!!!!!!!!!!!
	// WARNING !!!!!!!!!!!!!!!!!!!!!!!
	// WARNING !!!!!!!!!!!!!!!!!!!!!!!
	// WARNING !!!!!!!!!!!!!!!!!!!!!!!
	// --->> DO NOT REMOVE LUK OR EAGLE FROM THE CREDITS LIST 
	// --->> PLEASE RESPECT US FOR MAKING THIS MOD
	// --->> DO NOT MODIFY THE LINE AT ALL
	// --->> UNCOMMENT THE LINE BELOW IT AND ADD YOURSELF IF YOU WANT TO
	thread showCredit("Luk, 3aGl3", "credit", 1.5, 100);
	// thread showCredit("YOUR_NAME_HERE" + " (Modifications)", "credit", 1.5, 100);
	// WARNING !!!!!!!!!!!!!!!!!!!!!!!
	// WARNING !!!!!!!!!!!!!!!!!!!!!!!
	// WARNING !!!!!!!!!!!!!!!!!!!!!!!
	// WARNING !!!!!!!!!!!!!!!!!!!!!!!
	wait 0.5;
	
	// "" is used as a separator
	// TODO: Modify level.startY instead? Something like
	// level.startY += 20;
	thread showCredit("", "credit", 1.4, 80);
	thread showCredit("Based on RotU 2.1 by:", "credit", 1.4, 80);
	wait 0.5;
	thread showCredit("Bipo, Etheross", "credit", 1.5, 100);
	wait 0.5;
	thread showCredit("Additional help:", "credit", 1.4, 80);
	wait 0.5;
	thread showCredit("Viking, Rycoon, Punk, Puffy", "credit", 1.5, 100);
	wait 0.5;
	
	// "" is used as a separator
	// TODO: Modify level.startY instead? Something like
	// level.startY += 20;
	thread showCredit("", "credit", 1.4, 80);
	thread showCredit("More credits in ccfg.iwd/CREDITS.txt", "credit", 1.4, 80);
	
	// Wait 6 seconds for the credits to fade out and show game statistics
	wait 6;
	thread displayStats();

}

/**
*	Converts milliseconds (usually getTime()) to human readable time
*	@time Int, A time in milliseconds
*	@return String, Formatted milliseconds into xxh xxm xxs
*/
convertTime(time)
{
	// To seconds
	datTime = int(time / 1000);
	
	// Reduce seconds to 0-59
	s = datTime % 60;
	
	// Minutes
	m = int(datTime / 60);
	
	// Hours
	h = int(m / 60);
	
	// Reduce minutes to 0-59
	m = m % 60;
	
	// Add leading zero if single-digit
	if(s < 10)
		s = "0" + s;
	if(m < 10)
		m = "0" + m;

	// xxh xxm xxs	
	return h + "h " + m + "m " + s + "s";
}

/**
*	Displays up to 7 stats lines randomly chosen from all available stats
*/
displayStats()
{

	i = 0;
	
	// Keep displaying stats as long as stats are available, up to 7
	while(level.statsTypes.size > 0 && i < 8)
	{
		// Select a random statistic from the available statistic list
		number = randomint(level.statsTypes.size);
		
		// Every stat has values separated by ';', load them here
		//	[0] = script-global prefix
		//	[1] = display prefix
		//	[2] = colour modification for the displayed value
		//	[3] ? = additional suffix
		//	[4] ? = additional backgroundColor modification, standard is (0.1, 0.8, 0)
		request = strTok(level.statsTypes[number], ";");
		
		// Define default background color for each text display
		backgroundColor = (0.1, 0.8, 0);
		
		// See if the randomly chosen statistic contains a player
		if(isDefined(scripts\players\_players::getBestPlayer(request[0], "player")))
		{
			// CoD sometimes has difficulties displaying big numbers in text, int() makes sure to force the correct display of numbers, but not
			// all stats work with that. However by default we use it
			useInt = true;
			
			// Load player and amount from the given stat
			player = scripts\players\_players::getBestPlayer(request[0], "player");
			amount = scripts\players\_players::getBestPlayer(request[0], "amount");
			
			// Load the color display
			colorcode = request[2];
			
			// These two request types display a duration, so we want to convert it to readable format
			if(request[0] == "timeplayed" || request[0] == "downtime")
			{
				amount = convertTime(amount);
				useInt = false;
			}	
			
			// No values for these two types, so we do not display "-> xx number"
			if(request[0] == "firstminigun" || request[0] == "moredeathsthankills")
			{
				text = request[1] + "^5" + player.name;
			}
			// This is basically default: Prefix Text -> Player name -> '->' -> colorcode -> amount
			else
			{
				if(useInt)
					text = request[1] + "^5" + player.name + " ^7-> " + colorcode + int(amount);
				else
					text = request[1] + "^5" + player.name + " ^7-> " + colorcode + amount;
			}
			
			// In case there is a suffix for this stat, we add it to the end of the line
			if(request.size >= 4 && request[3] != ",")
				text += "^7" + request[3];
			
			// In case there is a background color in there, we add it
			if(request.size >= 5)
				backgroundColor = strToVec(request[4]);
				
			// First result needs the Y overwrite, this resets the level.startY to the default position, all others increment it
			if(i == 0)
				thread showCredit(text, "stats", 1.4, -80, "right", backgroundColor, 1);
			else
				thread showCredit(text, "stats", 1.4, -80, "right", backgroundColor);
				
			i++;
			wait 0.5;
		}
		
		// We've used this stat type now, we remove it from the list of valid stats
		level.statsTypes = removeFromArray(level.statsTypes, level.statsTypes[number]);
	}
	
	// Add two empty lines here to leave some space for the next three lines
	// TODO: Remove these and just increment level.startY manually
	thread showCredit("", "stats", 1.4, 0, "center");
	thread showCredit("", "stats", 1.4, 0, "center");
	
	// Show global stats (playtime, Zombies killed, RotU-R Version)
	thread showCredit("This map lasted " + convertTime(level.gameEndTime - level.startTime), "stats", 1.4, 0, "center", (0.8, 0, 0));
	wait 0.5;
	thread showCredit("Zombies harmed: " + level.killedZombies, "stats", 1.4, 0, "center", (0.8, 0, 0));
	wait 0.5;
	thread showCredit(level.rotuVersion, "stats", 1.4, 0, "center", (0.8, 0, 0));
}

/**
*	Checks whether a spectateview coordinate is defined for the current map
*	@return Boolean, Whether there is a spectateview for the map or not
*/
isSpectateViewAvailable()
{
	coords = scripts\level\_spectatecoords::getSpectateCoords();
	if(!isDefined(coords))
		return false;
	return true;
}

/**
*	If existing, this spawns an entity somewhere on the map where the players should look down from when losing
*/
spawnSpectateViewEntity()
{
	if(!isSpectateViewAvailable())
		return;

	coords = scripts\level\_spectatecoords::getSpectateCoords();
	
	level.endViewEnt = spawn("script_model", getSpectateViewCoords(coords, "origin"));
	level.endViewEnt setModel("tag_origin");
}

/**
*	Converts the saved string-coordinates to vectors and returns the requested angle or origin
*	@coords String, Saved coordinates and angles for this map, Format: "Origin x,Origin y,Origin z;Angle roll,Angle pitch,Angle yaw"
*	@type String, Can be 'origin' or 'angle', defines what will be returned
*	@return Vector, Depending on @type it returns either a 3D position or angle
*/
getSpectateViewCoords(coords, type)
{
	// set some default values, we're dealing with user input here
	if( !isDefined(type) )
		type = "origin";

	text = [];
	pos = "0,0,0";
	angle = "0,0,0";

	// Coordinates are saved as
	// "Origin x, Origin y, Origin z; Angle roll, Angle pitch, Angle yaw"
	// Example: "739,-990,1999;46,124,0"
	// Split those two by the separator ';'
	if( isDefined(coords) )
		text = strTok(coords, ";");

	// Split pos (origin) in [0] and angle in [1] after separating
	if( isDefined(text[0]) )
		pos = strTok(text[0], ",");

	if( isDefined(text[1]) )
		angle = strTok(text[1], ",");
	
	// Convert these strings to numbers and put them into a vector
	origin = (int(pos[0]), int(pos[1]), int(pos[2]));
	angle = (int(angle[0]), int(angle[1]), int(angle[2]));
	
	// Return what was requested
	if(type == "origin")
		return origin;

	if(type == "angle")
		return angle;
}

/**
*	Called by a player, this cleans up the player, creates a copy of him on the ground and makes him look down from the
*	provided spectateview position
*/
setupSpectateView()
{
	coords = scripts\level\_spectatecoords::getSpectateCoords();
	
	// In case we have a valid position, we do this!
	if(isDefined(coords))
	{
		// Reset a player entirely, create a copy of him at his current position
		self scripts\players\_players::cleanup();
		self clonePlayer(1);
		
		// Hide the 'real' playermodel and move him to the specateview position
		self hide();
		self setPlayerAngles(getSpectateViewCoords(coords, "angle"));
		self setOrigin(getSpectateViewCoords(coords, "origin"));
		
		// Remove everything that he has so he has nothing in his hands
		self takeAllWeapons();
		
		// When freezing a player, he still slowly floats towards the ground. We circumvent this by linking him to the spawned spectateview entity
		self linkTo(level.endViewEnt);
	}
	else
	{
		// When there is no spectateview position defined, we just run a general cleanup and force third person
		self scripts\players\_players::cleanup();
		self setClientDvar("cg_thirdperson", 1);
	}
	
	// Prevent any movement
	self freezePlayerForRoundEnd();
}

/**
*	Spawns a soul-FX at the given position
*	@origin Vector, Defines the position the FX will be spawned at
*/
soulSpawnOnEnd(origin)
{
	// Don't spawn every soul at the same time
	wait 3 + randomfloat(5);
	
	// Spawn an empty entity at the given position
	org = spawn("script_model", origin);
	org setModel("tag_origin");
	
	// Wait until properly initialized and play the FX
	wait 0.1;
	playFXOnTag(level.soul_deathfx , org, "tag_origin");
	wait 0.1;
	
	// Move the soul upwards within 11 seconds
	org moveTo(origin + (0, 0, 150), 11);
	
	// Wait until after the mapvoting, then delete the FX
	level waittill("post_mapvote");
	org delete();
}

/**
*	Displays a line on the screen, automatically moves the next showCredit() call lower
*	@text String, The text to display
*	@type String, 'stats' or different, influences display duration
*	@scale Float, Size of text
*	@indexX Vector, x-origin
*	@orientation String, x-alignment (left, right, center)
*	@backgroundColor Vector, (r,g,b)
*	@restartYIndex Boolean, Resets the global Y height to 140
*/
showCredit(text, type, scale, indexX, orientation, backgroundColor, restartYIndex)
{
	// Default 'level.end_textYIndex' to 0
	if(!isDefined(level.end_textYIndex))
		level.end_textYIndex = 0;
	
	// Default 'orientation' to left
	if(!isDefined(orientation))
		orientation = "left";
	
	// If we want to start from the top again, we reset the global Y pos
	if(isDefined(restartYIndex) && restartYIndex)
	{
		level.startY = 140;
		level.end_textYIndex = 0;
	}
	
	// Default the number of displayed credits to 0
	if(!isDefined(level.creditNumber))
		level.creditNumber = 0;
	
	// We create a new line, increment by 1
	level.creditNumber++;
	
	// Create a new Hud element
	// Apply given arguments
	end_text = newHudElem();
	end_text.font = "objective";
	end_text.fontScale = scale;
	end_text setText(text);
	end_text.alignX = orientation;
	end_text.alignY = "top";
	end_text.horzAlign = orientation;
	end_text.vertAlign = "top";
	
	if(isDefined(indexX))
		end_text.x = indexX;
	else
		end_text.x = 0;
	
	// We move the text down 16px every time we create one
	end_text.y = level.startY + (level.end_textYIndex * 16);
	end_text.sort = -1;
	
	// Increment Y Index for the next credit/stat line
	level.end_textYIndex++;
	
	if(isDefined(backgroundColor))
		end_text.glowColor = backgroundColor;
	else
		end_text.glowColor = (0.1, 0.8, 0);
		
	end_text.glowAlpha = 1;
	
	// Fade in
	end_text.alpha = 0;
	end_text fadeOverTime(1);
	end_text.alpha = 1;
	end_text.foreground = true;
	
	// Lazy hack to increment the text height without displaying anything
	// TODO: Do this elsewhere, not here, and do it properly
	if(text == "")
	{ 
		wait 1;
		end_text destroy();
		level.creditNumber--;
		return;
	}
	
	// Increase display time if it's a stats display
	if(type == "stats")
		wait 15;
	else
		wait 9;
	
	// Fade out and remove the line
	end_text fadeOverTime(1);
	end_text.alpha = 0;
	wait 1;
	level.creditNumber--;
	
	// When all credits have faded out, we notify the game that all have been displayed
	if(level.creditNumber == 0)
		level notify("credits_gone");
		
	end_text destroy();
}

/**
*	Plays the ambient music when losing
*/
playEndSound()
{
	ambientPlay("zom_lose");
}

/**
*	Plays the ambient music when winning, 2 second fade-in
*/
playCreditsSound()
{
	ambientPlay("zom_win", 2);
}