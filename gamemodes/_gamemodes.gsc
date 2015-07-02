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
	level.soul_deathfx = loadfx( "misc/soul_death" );
}

/**
*	Gets a map's TDM and DM spawns and moves their origin onto the ground with a playerPhysicsTrace
*/
dropSpawns()
{
	TDMSpawns = getentarray( "mp_tdm_spawn", "classname" );
	for( i = 0; i < TDMSpawns.size; i++ )
	{
		spawn = TDMSpawns[i];
		spawn.origin = dropPlayer( spawn.origin + ( 0, 0, 32 ), 300 );
	}
	
	DMSpawns = getentarray( "mp_dm_spawn", "classname" );
	for( i = 0; i < DMSpawns.size; i++ )
	{
		spawn = DMSpawns[i];
		spawn.origin = dropPlayer( spawn.origin + ( 0, 0, 32 ), 300 );
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
*	[4] ? = additional backgroundColour modification, standard is (.1,.8,0)
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
	if ( !isDefined( level.gameMode ) )
	level.gameMode = level.dvar["surv_defaultmode"]; // Default gamemode
	
	loadGameMode( level.gameMode );
	loadDifficulty( level.dvar["game_difficulty"] );
}

/**
*	Loads the given 'mode' as gamemode
*/
loadGameMode( mode )
{
	switch( mode )
	{
		case "waves_special":
			loadSurvivalMode( "special" );
		break;
		case "waves_endless":
			loadSurvivalMode( "endless" );
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
			loadSurvivalMode( "special" );
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
*/
loadSurvivalMode( mode )
{
	level.survMode = mode;
	level.survSpawns = [];
	level.survSpawnsTotalPriority = 0;
	thread scripts\gamemodes\_survival::initGame();
}

/**
*	This function is used to mix up random zombies in a 'normal' wave
*	Priorities of certain types are calculated using 'weight', like 'priority'
*/
buildZomTypes( preset )
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
	
	switch ( preset )
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
*	The default weight (read: priority) for certain zombie types
*/
getDefaultWeight( type )
{
	switch ( type )
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
*	Adds 'type' to level.zom_spawntypes[]
*/
addSpawnType( type )
{
	// Gets the default weight of the selected type and checks whether that is defined and also prevents it from being added twice to the array
	weight = getDefaultWeight( type );
	if( !isDefined( weight ) || arrayContains( level.zom_spawntypes, type ) )
		return;
	
	// If all is good, add it to the array
	level.zom_spawntypes_weightotal += weight;
	level.zom_spawntypes[level.zom_spawntypes.size] = type;
	level.zom_spawntypes_weight[level.zom_spawntypes_weight.size] = weight;
}

/**
*	Returns a random zombie type, taking the weight of each type into consideration
*/
getRandomType()
{
	// Calculate a random number based on the total amount of weight all zombies have in the currently selected spawntypes
	weight = randomInt( level.zom_spawntypes_weightotal );
	for( i = 0; i < level.zom_spawntypes.size; i++ )
	{
		// We go from zombie to zombie, reducing our random number by the weight of the currently selected zombie type
		weight -= level.zom_spawntypes_weight[i];
		// If we drop below 0, we select this type and return it
		if( weight < 0 )
			return level.zom_spawntypes[i];
	}
}

/**
*	Loads the specified difficulty for the currently running game
*	This modifies the zombies' HP-scaling, the amount of zombies alive per player and the boss phases before he's dead
*	TODO: Fine tune and add more?
*/
loadDifficulty( difficulty )
{
	switch ( difficulty )
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
	if( level.dvar["zom_dynamicdifficulty"] )
		level thread monitorDifficulty();
}

/**
*	Since the situation is always quite chaotic and is never the same since it depends on map design and player skill,
*	this function monitors the killing of zombies and dynamically calculates the spawnrate of zombies, adjusting to the skill of all players
*/
monitorDifficulty()
{	
	level endon( "stop_monitoring" );
	level endon( "game_ended" );
	
	thread resumeMonitoring();
	
	// Only run this monitor at the start of a wave, not during intermission
	level waittill( "start_monitoring" );
	
	while( 1 )
	{
		level.dif_zomMax = level.dif_zomPP * level.activePlayers;
		level.dif_zomSpawnRate = 0.1;
		
		// If zombies have been killed during the last 5 seconds we calculate the new spawnspeed with the amount of killed zombies and the amount of players
		if ( level.dif_killedLast5Sec != 0 )
		{
			level.dif_zomSpawnRate = 0.4 * ( level.dif_killedLast5Sec / level.activePlayers);
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
			if ( level.dif_zomSpawnRate < 0.05 )
				level.dif_zomSpawnRate = 0.05;
				
			level.dif_killedLast5Sec = 0;
		}
		
		// Since the if function above can return false, we still need to make sure to never drop below 0.05 seconds for the wait
		if ( level.dif_zomSpawnRate < 0.05 )
			level.dif_zomSpawnRate = 0.05;
		
		level.dif_zomDamMod = 0.5;
		
		// Based on the amount of players, we modify the zombies' damage
		// TODO: 30 Players is a bunch, but should we really go to 2x damage?
		if ( level.activePlayers > 5 )
			level.dif_zomDamMod = 0.75;
		
		if ( level.activePlayers > 10 )
			level.dif_zomDamMod = 1;
		
		if ( level.activePlayers > 15 )
			level.dif_zomDamMod = 1.25;
		
		if ( level.activePlayers > 20 )
			level.dif_zomDamMod = 1.5;
		
		if ( level.activePlayers > 25 )
			level.dif_zomDamMod = 1.75;
		
		if ( level.activePlayers > 30 )
			level.dif_zomDamMod = 2;
		
		wait 5;
	}
}

/**
*	Reset the monitor to wait for a wave to start
*/
resumeMonitoring()
{
	level waittill( "stop_monitoring" );
	
	thread monitorDifficulty();
}

/**
*	Returns whether a wave set in the rotu.cfg is actually a wave or not (e.g. difficulty changes)
*/
isWave( waveNumber )
{
	switch( waveNumber )
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
* 	endReasontext: Text to show the players
*	win: True/False if the players won. Will choose font color and music accordingly
*/
endMap( endReasontext, win )
{
	// TODO: Check whether endMap is ever called without win being defined, if not, remove
	if ( !isDefined( win ) )
		win = false;
	
	// If all players died, we need to check for the Last Chance before we end the game
	if( !win )
	{
		lastChance = scripts\gamemodes\_lastchance::lastChanceMain();
		// If the Last Chance kicked in, we don't end the game
		if( lastChance )
			return;
	}
	
	// All checks are gone, the game must end. We mute zombies and save all data for stats etc.
	level.gameEnded = true;
	level.gameEndTime = getTime();
	game["state"] = "postgame";
	
	level notify( "intermission" );
	level notify( "game_ended" );
	
	// Save the stats of this game to RotU-Stats if enabled
	scripts\extras\_rotustats::saveGameStats( win );
	
	// TODO: Is this needed?
	setGameEndTime( 0 );
	alliedscore = getTeamScore( "allies" );
	axisscore = getTeamScore( "axis" );
	//
	
	// If not enabled by default, make sure dead players can chat with Spectators etc.
	setdvar( "g_deadChat", 1 );
	
	// Disable turrets and make Zombies silent
	level.turretsDisabled = 1;
	level.silenceZombies = true;
	
	// Mute running wave music
	scripts\server\_environment::stopAmbient( 3 );
	
	// Zombified players should return to humans to get properly reset
	for( i = 0; i < level.players.size; i++ )
	{
		if( isReallyPlaying( level.players[i] ) )
		{
			if( level.players[i].isZombie )
			{
				level.players[i] suicide();
			}
		}
	}
	
	// Wait for the ambient sound to disappear
	wait 3;
	
	// Clean up the players, remove any usabilities, save downtimer stats and remove the HUD
	for( i = 0; i < level.players.size; i++ )
	{
		level.players[i] scripts\players\_usables::usableAbort();
		level.players[i] closeMenu();
		level.players[i] closeInGameMenu();
		
		if( isDefined( level.players[i].isDown ) )
		{
			if( level.players[i].isDown )
				level.players[i] stopDownTimer();
		}
		
		// Remove Health HUD
		level.players[i] scripts\include\hud::updateHealthHud( -1 );
		
		// Remove remaining HUD texts and effects
		level.players[i] setClientDvars( "ui_upgradetext", "", "ui_specialtext", "", "ui_specialrecharge", 0, "ui_hud_hardcore", 1, "r_blur", 0 );
	}
	
	// Clean up wave-specific effects
	scripts\server\_environment::resetVision( 1 );
	scripts\server\_environment::setFog( "default", 1 );
	
	// If a boss is on the map, remove the Health display
	if( isDefined( level.bossOverlay ) )
		level.bossOverlay destroy();
	
	// I better not write what this does. It would spoil the fun. Seriously. Don't look it up.
	if ( scripts\include\physics::finalizeStats() )
	{
		if ( win )
			thread playCreditsSound();
		else
			thread playEndSound();
		if( !win )
		{
			/* LOSE OUTRO */
			
			/* FLASH BLACKSCREEN */
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
			
			/* ENDSCREEN FINAL TEXT */
			level.end_text = newHudElem();
			level.end_text.font = "objective";
			level.end_text.fontScale = 2.4;
			level.end_text SetText(endReasontext);
			level.end_text.alignX = "center";
			level.end_text.alignY = "top";
			level.end_text.horzAlign = "center";
			level.end_text.vertAlign = "top";
			level.end_text.x = 0;
			level.end_text.y = 96;
			level.end_text.sort = -1; //-3
			level.end_text.alpha = 1;
			level.end_text.glowColor = (1,0,0);
			level.end_text.glowAlpha = 1;
			level.end_text.foreground = true;
			
			/* Blackscreen flashout */
			level.blackscreen fadeOverTime(2);
			level.blackscreen.alpha = 0;

			thread scripts\server\_environment::flashViewAll((1,1,1), .2, .5);
			level.end_text setPulseFX( 150, int(10000), 1000 );
			
			spawnSpectateViewEntity();
			
			for(i = 0; i < level.players.size; i++)
			{
				p = level.players[i];
				if(p.isActive)
				{
					if(isDefined(p.hinttext))
						p.hinttext destroy();
					if(p.infected) // Prevent infected Players from going Zombie
						p notify("infection_cured");
					p.stats["timeplayed"] += getTime() - p.stats["playtimeStart"];
					thread soulSpawnOnEnd(p.origin);
					p thread setupSpectateView();
				}

			}
			thread displayCredits();
			wait 7;
			level.blackscreen fadeOverTime(4);
			level.blackscreen.alpha = 0.5;
			// wait 3;
			// level.blackscreen destroy();
			level.end_text fadeOverTime(1);
			level.end_text.alpha = 0;
			wait 1;
			level.end_text destroy();
		}
		else{
			/* WIN OUTRO */
			
			/* ENDSCREEN FINAL TEXT */
			level.end_text = newHudElem();
			level.end_text.font = "objective";
			level.end_text.fontScale = 2.4;
			level.end_text SetText(endReasontext);
			level.end_text.alignX = "center";
			level.end_text.alignY = "top";
			level.end_text.horzAlign = "center";
			level.end_text.vertAlign = "top";
			level.end_text.x = 0;
			level.end_text.y = 96;
			level.end_text.sort = -1; //-3
			level.end_text.alpha = 1;
			level.end_text.glowColor = (0,1,0);
			level.end_text.glowAlpha = 1;
			level.end_text.foreground = true;
			
			/* FLASH BLACKSCREEN */
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
			
			level.end_text setPulseFX( 150, int(10000), 1000 );
			
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				if(players[i].isBot)
					continue;
					
				if(players[i].isActive)
				{
					if(isDefined(players[i].hinttext))
						players[i].hinttext destroy();
					if(players[i].infected) // Prevent infected Players from going Zombie
						players[i] notify("infection_cured");
					players[i].stats["timeplayed"] += getTime() - players[i].stats["playtimeStart"];
				}
				players[i] freezePlayerForRoundEnd();

			}
			thread displayCredits();
			wait 7;
			level.blackscreen fadeOverTime(4);
			level.blackscreen.alpha = 0.5;
			level.end_text fadeOverTime(1);
			level.end_text.alpha = 0;
			wait 1;
			level.end_text destroy();
			
			// [[level.onChangeMap]]();
		}
		
		// if (showcredits)
		// {
			/* showCredit(text, scale, indexX, indexY, stat) */
			// thread showCredit("Bipo", 1.8);
			// wait 1;
			// thread showCredit("Scripters:", 2.4);
			// wait 1;
			// thread showCredit("Bipo", 1.8);
			// wait 0.5;
			// thread showCredit("Brax (turret + medkit)", 1.8);
			// wait 1;
			// thread showCredit("2D Art:", 2.4);
			// wait 1;
			// thread showCredit("Mr-X", 1.8);
			// wait 1;
			// thread showCredit("Rigging & Ripping Hellknight:", 2.4);
			// wait 1;
			// thread showCredit("Hacker22 - Rigging", 1.8);
			// wait 0.5;
			// thread showCredit("Brax - Ripping", 1.8);
			
			// if (level.dvar["server_provider"]!="")
			// {
				// wait 1;
				// thread showCredit("Server provided by:", 2.4);
				// wait 1;
				// thread showCredit(level.dvar["server_provider"], 1.8);
				// wait 1;
			// }
			// wait 3;
			// thread showCredit("Thanks for playing RotU 2.1!", 2.4);
			
			// wait level.creditTime + 2;
		// }
		
		level waittill("credits_gone");
		wait 1;
		if( isDefined( level.blackscreen ) )
			level.blackscreen destroy();
	}
	[[level.onChangeMap]]();
}

displayCredits()
{
	level.startY = 220;
	wait 8;
	thread showCredit("REVOLUTION Development:", "credit", 1.4, 80);
	wait 0.5;
	thread showCredit("Luk, 3aGl3", "credit", 1.5, 100);
	wait 0.5;
	thread showCredit("", "credit", 1.4, 80);
	thread showCredit("Based on RotU 2.1 by:", "credit", 1.4, 80);
	wait 0.5;
	thread showCredit("Bipo, Etheross", "credit", 1.5, 100);
	wait 0.5;
	thread showCredit("Additional help:", "credit", 1.4, 80);
	wait 0.5;
	thread showCredit("Viking, Rycoon, Punk, Puffy", "credit", 1.5, 100);
	wait 0.5;
	thread showCredit("", "credit", 1.4, 80);
	thread showCredit("More credits in ccfg.iwd/CREDITS.txt", "credit", 1.4, 80);
	wait 6;
	thread displayStats();

}

convertTime(time)
{
	// To seconds
	datTime = int(time / 1000);
	
	//Seconds left
	s = datTime % 60;
	
	//Minutes
	m = int(datTime / 60);
	
	//Hours
	h = int(m / 60);
	
	// Correct minutes to leave out all above 60m
	m = m % 60;
	
	// Make sure to display two digits for minutes and seconds
	if(s < 10)
		s = "0" + s;
	if(m < 10)
		m = "0" + m;

	// xxh xxm xxs	
	return h + "h " + m + "m " + s + "s";
}

displayStats()
{
	i = 0;
	backgroundColour = (.1,.8,0);
	
	while(level.statsTypes.size > 0 && i <= 7)
	{
		// Display up to 6 stats
		// Select a random statistic from the available statistic list
		randomint = randomint(level.statsTypes.size);
		request = strTok(level.statsTypes[randomint], ";");
		backgroundColour = (.1,.8,0);
		
		// See if the random statistic contains a player
		if(isDefined(scripts\players\_players::getBestPlayer(request[0], "player")))
		{
			useInt = true;
			player = scripts\players\_players::getBestPlayer(request[0], "player");
			amount = scripts\players\_players::getBestPlayer(request[0], "amount");
			colourcode = request[2];
			
			if(request[0] == "timeplayed" || request[0] == "downtime")
			{ // Convert the time to readable format
				amount = convertTime(amount);
				useInt = false;
			}	
				
			if(request[0] == "firstminigun" || request[0] == "moredeathsthankills")
				text = request[1] + "^5" + player.name;
			else{
				if(useInt)
					text = request[1] + "^5" + player.name + " ^7-> " + colourcode + int(amount);
				else
					text = request[1] + "^5" + player.name + " ^7-> " + colourcode + amount;
			}
					
			if(request.size >= 4 && request[3] != ",") // Add additional suffix
				text += "^7" + request[3];
			
			if(request.size >= 5)
				backgroundColour = strToVec(request[4]);
			
			if(i == 0) // First result needs the Y overwrite
				thread showCredit(text, "stats", 1.4, -80, "right", backgroundColour, 1);
			else // All other results dont need the overwrite
				thread showCredit(text, "stats", 1.4, -80, "right", backgroundColour);
				
			i++;
			wait 0.5;
		}
		level.statsTypes = removeFromArray(level.statsTypes, level.statsTypes[randomint]);
	}
	thread showCredit("", "stats", 1.4, 0, "center");
	thread showCredit("", "stats", 1.4, 0, "center");
	thread showCredit("This map lasted " + convertTime(level.gameEndTime - level.startTime), "stats", 1.4, 0, "center", (0.8,0,0));
	wait 0.5;
	thread showCredit("Zombies harmed: " + level.killedZombies, "stats", 1.4, 0, "center", (0.8,0,0));
	wait 0.5;
	thread showCredit(level.rotuVersion, "stats", 1.4, 0, "center", (0.8,0,0));
}

isSpectateViewAvailable()
{
	coords = scripts\level\_spectatecoords::getSpectateCoords();
	if(!isDefined(coords))
		return false;
	return true;
}

spawnSpectateViewEntity()
{
	if(!isSpectateViewAvailable())
		return;

	coords = scripts\level\_spectatecoords::getSpectateCoords();
	
	level.endViewEnt = spawn( "script_model", getSpectateViewCoords(coords, "origin") );
	level.endViewEnt setModel( "tag_origin" );
}

getSpectateViewCoords(coords, type)
{
	text = strTok(coords, ";");
	pos = strTok(text[0], ",");
	angle = strTok(text[1], ",");
	origin = (int(pos[0]),int(pos[1]),int(pos[2]));
	angle = (int(angle[0]),int(angle[1]),int(angle[2]));
	
	if(type == "origin")
		return origin;
	if(type == "angle")
		return angle;
}

setupSpectateView()
{
	coords = scripts\level\_spectatecoords::getSpectateCoords();
	if(isDefined(coords))
	{
		self scripts\players\_players::cleanup();
		self ClonePlayer( 1 );
		self hide();
		self setPlayerAngles( getSpectateViewCoords(coords, "angle") );
		self setOrigin( getSpectateViewCoords(coords, "origin") );
		self takeallweapons();
		self linkTo(level.endViewEnt);
	}
	else{
		self scripts\players\_players::cleanup();
		self setclientdvar("cg_thirdperson", 1);
	}
	self freezePlayerForRoundEnd();
}

soulSpawnOnEnd(origin)
{
	wait 3 + randomfloat(5);
	org = spawn("script_model", origin);
	org setmodel( "tag_origin" );
	wait .1;
	playFXOnTag( level.soul_deathfx , org, "tag_origin" );
	wait .1;
	org moveto(origin+(0,0,150), 11);
	level waittill("post_mapvote");
	org delete();
}

showCredit(text, type, scale, indexX, orientation, backgroundColour, restartYIndex)
{
	if(!isDefined(self.end_textYIndex))
		self.end_textYIndex = 0;
	if(!isDefined(orientation))
		orientation = "left";
	if(isDefined(restartYIndex))
	{
		level.startY = 140;
		self.end_textYIndex = 0;
	}
	if(!isDefined(level.creditNumber))
		level.creditNumber = 0;
		
	level.creditNumber++;
	end_text = newHudElem();
	// end_text endon("death");
	end_text.font = "objective";
	end_text.fontScale = scale;
	end_text SetText(text);
	end_text.alignX = orientation;
	end_text.alignY = "top";
	end_text.horzAlign = orientation;
	end_text.vertAlign = "top";
	if(isDefined(indexX))
		end_text.x = indexX;
	else
		end_text.x = 0;
	end_text.y = level.startY + (self.end_textYIndex * 16);
	end_text.sort = -1; //-3
	if(isDefined(backgroundColour))
		end_text.glowColor = backgroundColour;
	else
		end_text.glowColor = (.1,.8,0);
	end_text.glowAlpha = 1;
	self.end_textYIndex++;
	end_text.alpha = 0;
	end_text fadeOverTime(1);
	end_text.alpha = 1;
	// end_text.y = -60;
	end_text.foreground = true;
	
	if(text == "")
	{ 
		wait 1;
		end_text destroy();
		level.creditNumber--;
		return;
	}
	
	if(type == "stats")
		wait 15;
	else
		wait 9;
	end_text fadeOverTime(1);
	end_text.alpha = 0;
	wait 1;
	level.creditNumber--;
	if(level.creditNumber == 0)
		level notify("credits_gone");
	end_text destroy();
}

playEndSound()
{
	ambientPlay( "zom_lose" );
}

playCreditsSound()
{
	ambientPlay( "zom_win", 2 );
}