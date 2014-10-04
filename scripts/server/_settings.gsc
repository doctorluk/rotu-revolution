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

init()
{

	level.dvar = [];
	
	loadSettings();
	
}

loadSettings()
{
	players = (getDvarInt("sv_maxclients") - getDvarInt("bot_count"));
	
	dvarInt(	"bot",			"count",				20,		0,		63); // Amount of bots loaded
	dvarBool(	"bot", 			"scores",		 		0);
	
	dvarInt(	"logfile",			"2",				3,		0,		3);
	
	dvarBool(	"zom", 			"orbituary",			0);
	dvarBool(	"zom", 			"dominoeffect",	 		1);
	dvarBool(	"zom", 			"dynamicdifficulty",	1);
	dvarBool(	"zom", 			"infection",			1);
	dvarBool(	"zom",			"headshotonly",			0);
	dvarBool(	"zom",			"antilagmonitor",		1); // Check for too many waypoint calculations per frame to reduce infinite loop detections
	dvarInt(	"zom", 			"infectiontime",		25, 	0, 		120);
	dvarBool(	"zom",			"spawnprot",			1);
	dvarBool(	"zom",			"spawnprot_decrease", 	1);
	dvarFloat(	"zom",			"spawnprot_time",		6,		0,		30);
	dvarBool(	"zom",			"spawnprot_tank",		0);
	
	dvarBool(	"game",			"lan_mode",				1);
	
	dvarInt(	"game",			"max_soldiers",			players,		0,		getDvarInt("sv_maxclients"));
	dvarInt(	"game",			"max_assassins",		players,		0,		getDvarInt("sv_maxclients"));
	dvarInt(	"game",			"max_armored",			players,		0,		getDvarInt("sv_maxclients"));
	dvarInt(	"game",			"max_engineers",		players,		0,		getDvarInt("sv_maxclients"));
	dvarInt(	"game",			"max_scouts",			players,		0,		getDvarInt("sv_maxclients"));
	dvarInt(	"game",			"max_medics",			players,		0,		getDvarInt("sv_maxclients"));
	
	dvarBool(	"game", 		"extremeragdoll",	 	1);
	dvarBool(	"game", 		"godmode",	 			0);
	dvarBool(	"game", 		"version_banner",	 	1); // Display version information and website in iprintln area
	dvarBool(	"game", 		"friendlyfire",	 		0);
	dvarInt(	"game", 		"difficulty",	 		2,		1,		5);
	dvarBool(	"game",			"welcomemessages",		0);
	dvarBool(	"game",			"mapvote",				1);
	dvarInt(	"game",			"mapvote_time",			20,		5,		60);
	dvarInt(	"game",			"mapvote_count",		8, 	1, 		15);
	dvarInt(	"game", 		"rewardscale",	 		25,		1,		10000);
	dvarBool(	"game",			"delayed_upgradepoints",	1); // Enable/Disabled delayed upgradepoints
	dvarInt(	"game", 		"delayed_upgradepoints_amount",3000,		1,	100000); // Upgradepoints received for each wave missed
	dvarInt(	"game", 		"startpoints",	 		2000,	0,		100000);
	dvarInt(	"game", 		"xpmultiplier",	 		1,	1,		20); // XP Multiplier
	dvarInt(	"game",			"max_mg_barrels",		4,		0,		20);
	dvarInt(	"game",			"max_turrets",			5,		0,		12);
	dvarInt(	"game",			"max_turrets_perplayer",3,		0,		12);
	dvarInt(	"game",			"max_claymores",		10,		0,		50); // Max claymores per player
	dvarInt(	"game",			"max_c4",				10,		0,		50); // Max c4 per player
	dvarInt(	"game",			"max_barrels",			12,		0,		30);
	dvarInt(	"game",			"max_portals",			3,		0,		10);
	dvarBool(	"game",			"use_custom",			1);
	dvarBool(	"game",			"mg_overheat",			1);
	dvarBool(	"game",		"disable_spectating_bots",	1);
	dvarBool(	"game",			"enable_join_queue",	1);
	dvarBool(	"game",		"player_spawnprotection",	1);
	dvarFloat(	"game",	"player_spawnprotection_time",	3,		0,		10);
	dvarFloat(	"game",			"mg_overheat_speed",	2.5,		0.25,	10);
	dvarFloat(	"game",			"mg_cooldown_speed",	1,		0.2,	10);
	dvarFloat(	"game",			"mg_barrel_time",		150,	10,		99999);
	dvarFloat(	"game",			"portal_time",			180,	10,		99999);
	dvarFloat(	"game",			"turret_time",			120,	10,		99999);
	dvarFloat(	"game",			"spawn_requirement",	0.5, 0, 1);
	dvarBool(	"game",			"class_ranks",			1);
	dvarBool(	"game",			"changing_hostname",	0);
	dvarInt(	"game",			"changing_hostname_time",10,	2,		60);
	
	// AFK SETTINGS
	dvarBool(	"game",			"afk_enabled",			1); 						// AFK Enabled?
	dvarInt(	"game",			"afk_time_warn",		240,	5,		6000); 	// Time in s how long a player is afk
	dvarInt(	"game",			"afk_warn_amount",		5,		1,		100); 	// Times a player should be warned after afk_time_warn has been reached
	dvarInt(	"game",			"afk_time",				300,	5,		6000); 	// Time in s how long a player is afk
	dvarInt(	"game",			"afk_type",				0,		0,		1); 		// AFK-handle type, 0 = kick, 1 = spec
	
	dvarBool(	"hud",			"survivors_left",		1);
	dvarBool(	"hud",			"survivors_down",		1);
	dvarBool(	"hud",			"wave_number",			1);
	dvarBool(	"hud",			"zombies_alive",		0);
	
	dvarBool(	"env", 			"ambient",	 			1);
	dvarBool(	"env", 			"fog",	 				1);
	dvarInt(	"env", 			"fog_start_distance",	200,	0,		10000);
	dvarInt(	"env", 			"fog_half_distance",	480,	0,		10000);
	dvarInt(	"env", 			"fog_red",				5,		0,		255);
	dvarInt(	"env", 			"fog_green",			0,		0,		255);
	dvarInt(	"env", 			"fog_blue",				5,		0,		255);
	dvarInt(	"env",			"blur",					.1, 	0,		10);
	dvarBool(	"env",			"override_vision",		1);
	
	// dvarInt(	"surv", 		"specialinterval",	 	2,		1,		20);
	// dvarInt(	"surv", 		"specialwaves",	 		5,		1,		100);
	
	// 1 = Normal, 2 = Dogs, 3 = Burning, 4 = Crawlers, 5 = Hell, 6 = Scary, 7 = Boss (to be changed), 8 = grouped Normal, 20 = Increase Shop Costs and Zombie Damage
	dvarString( "surv",			"waves",				"1;2;6;4;7;20;8;3;6;7");
	dvarInt(	"surv", 		"zombies_initial",		10,		1,		1000);
	dvarInt(	"surv", 		"zombies_perplayer",	10,		1,		1000);
	dvarInt(	"surv", 		"zombies_perwave",		5,		1,		1000);
	dvarFloat(	"surv",			"revivetime",			3,		0.25,	30);
	dvarInt(	"surv", 		"wavesystem",			2,		0,		2);
	dvarInt(	"surv", 		"timeout",	 			30,		2,		120);
	dvarInt(	"surv", 		"timeout_firstwave",	30,		0,		60);
	dvarInt(	"surv",			"timeout_finale",		5,		60,		300); // Time in seconds being waited before starting the final wave
	dvarString(	"surv",			"defaultmode",			"waves_special");
	dvarString(	"surv",			"weaponmode",			"upgrade"); //wawzombies or upgrade
	dvarString(	"surv",			"waw_spawnprimary",		"none");
	dvarString(	"surv",			"waw_spawnsecondary",	"beretta_mp");
	dvarInt(	"surv",			"waw_costs",			750,	1,		100000);
	dvarBool(	"surv",			"waw_alwayspay",		1);
	dvarBool(	"surv",			"slow_start",			1);
	dvarBool(	"surv",			"extended_finale_announcement",			1);
	dvarInt(	"surv",			"slow_waves",			3,		1,		10);
	dvarInt(	"surv",			"dontplaylastmaps",		3,		0,		100);
	dvarBool(	"surv",			"find_stuck",			1);
	dvarInt(	"surv",			"stuck_tollerance",		30,		10,		360);
	dvarInt(	"surv",			"waves_repeat",			2,		1,		100);
	dvarBool(	"surv",			"dynamic_finale_difficulty",		1); // Use game_difficulty settings or not
	dvarInt(	"surv",			"finale_minplayers",	7,	1, 64 ); // A minimum amount of players that have to play in order to start the final wave
	dvarBool(	"surv",			"endround_revive",		1);
	dvarBool(	"surv",			"rotu_stats",			0); // Enable RotU-R stats logging when a round ends?
	
	dvarInt(	"surv",			"phoenix_minplayers",	3,	1, 64 );
	dvarInt(	"surv",			"phoenix_minwave",	3,	1, 64 );
	dvarFloat(	"surv",			"phoenix_base_percentage",	0.2, 0.01, 1.0 );
	dvarInt(	"surv",			"phoenix_wave_stepsize",	2, 1, 100 );
	dvarFloat(	"surv",			"phoenix_wave_percentage",	0.03, 0,  1 );
	
	
	dvarInt(	"shop", 		"item1_costs",	 		2000,		1,		100000); // Restore Health
	dvarInt(	"shop", 		"item2_costs",	 		1500,		1,		100000); // Restore Ammo
	dvarInt(	"shop", 		"item3_costs",	 		3500,		1,		100000); // Cure Infection
	dvarInt(	"shop", 		"item4_costs",	 		1000,		1,		100000); // Frag Grenades
	dvarInt(	"shop", 		"item5_costs",	 		1250,		1,		100000); // C4
	dvarInt(	"shop", 		"item6_costs",	 		2000,		1,		100000); // Claymore
	dvarInt(	"shop", 		"item7_costs",	 		10000,		1,		100000); // Raygun
	
	dvarInt(	"shop", 		"defensive1_costs",	 	1000,		1,		100000); // Barrel
	dvarInt(	"shop", 		"defensive2_costs",	 	1500,		1,		100000); // Exploding Barrel
	dvarInt(	"shop", 		"defensive3_costs",	 	4000,		1,		100000); // Sentry Turret
	dvarInt(	"shop", 		"defensive4_costs",	 	7000,		1,		100000); // GL Turret
	dvarInt(	"shop", 		"defensive5_costs",	 	8000,		1,		100000); // Barrel + MG
	dvarInt(	"shop", 		"defensive6_costs",	 	8500,		1,		100000); // Portal
	
	dvarInt(	"shop", 		"support1_costs",	 	2500,		1,		100000);
	dvarInt(	"shop", 		"support2_costs",	 	15000,		1,		100000);
	dvarInt(	"shop", 		"support3_costs",	 	20000,		1,		100000);
	dvarInt(	"shop", 		"support4_costs",	 	30000,		1,		100000);
	dvarInt(	"shop", 		"support5_costs",	 	50000,		1,		100000);
	
	dvarBool(	"shop",			"multiply_costs",			1);
	dvarInt(	"shop", 		"multiply_costs_amount",	 	40,		0,		100);
	
	dvarString(	"surv",		"playedmaps",	"");
	dvarString(	"surv",		"recentmaps",	"");


	setdvar("g_teamname_axis", "^9Zombies");
	setdvar("g_teamname_allies", "Survivors");
	/*dvarString("surv_defaultmode", "waves_special"); // In case the map doesn't set the gamemode
	dvarString("surv_wave_system", "pp"); // The way wave size is calculated (pp/pw/pppw)
	dvarInt("surv_preparetime", 10, 0, 100);
	
	
	dvarInt("surv_wave_zombiespp", 5, 1, 100); // Zombies per player in wave one
	dvarInt("surv_wave_zombiespp_inc", 5, 1, 100); // Increase in zombies per player per wave
	dvarInt("surv_wave_zombiespw", 20, 1, 5000); // Zombies in wave 1
	dvarInt("surv_wave_zombiespw_inc", 10, 1, 1000); // Increase in zombies per wave
	
	dvarInt("surv_wave_zombiehealth", 200, 1, 1000); // Initial zombie health
	dvarInt("surv_wave_zombiehealth_inc", 10, 1, 200); // Zombie health increase per wave
	dvarInt("surv_wave_zombiehealthpp_inc", 5, 1, 200); // Zombie health increase per player
	
	dvarInt("surv_wave_spawnspeed", 5, 1, 1000); // Wait time in seconds between a zombie spawn
	dvarFloat("surv_wave_spawnspeedpw_dec", .3, 0, 10); // Wait time in seconds percentage change per wave 
	dvarFloat("surv_wave_spawnspeedpp_prc", .9, 0, 1); // Wait time in seconds percentage change per player 
	
	dvarFloat("surv_wave_dog_prc", .01, 0, 1); // 10 percent chance at spawning a dog
	dvarFloat("surv_wave_burning_prc", .03, 0, 1);
	dvarFloat("surv_wave_toxic_prc", .02, 0, 1);
	//dvarFloat("surv_wave_spc_toxic", .02, 0, 1);
	
	dvarInt("surv_spc_waveinterval", 5, 1, 20); // Amount of normal waves before a special one
	dvarInt("surv_spc_specialwaves", 4, 1, 20); // Amount of special waves before victory
	dvarString("surv_spc_specialwave1", "dogs");
	dvarString("surv_spc_specialwave2", "burning");
	dvarString("surv_spc_specialwave3", "toxic");
	dvarString("surv_spc_specialwave4", "boss");
	
	dvarBool("zombie_obituary", 0);
	dvarBool("zombie_dominoeffect", 1);
	dvarFloat("zombie_dif_spawn_pp", 10, 1, 63);
	dvarFloat("zombie_dif_death_pp", 2, 1, 63);
	dvarBool("zombie_dynamicdifficulty", 1);
	dvarBool("extreme_ragdoll", 1);
	dvarBool("rotu_persistentitems", 0);
	dvarBool("rotu_friendlyfire", 0);*/
	
	level.rewardScale = level.dvar["game_rewardscale"];
}

finishDvar(type, dvar, val)
{
	setDvar(type + "_" + dvar, val);
	level.dvar[type + "_" + dvar] = val;
}

dvarChoice(type, dvar, def, values)
{
	var = type + "_" + dvar;
	val = getDvar(var);
	
	for (i=0; i<values.size; i++)
	{
		if (values[i] == val)
		{
			finishDvar(type, dvar, val);
			return;
		}
	}
	finishDvar(type, dvar, def);
}

dvarString(type, dvar, def)
{
	var = type + "_" + dvar;
	val = getDvar(var);
	
	if (val == "")
		finishDvar(type, dvar,def);
	else
		finishDvar(type, dvar,val);
}

dvarBool(type, dvar, def)
{
	var = type + "_" + dvar;
	if (getDvar(var) == "")
		finishDvar(type, dvar, def);
	else
	{
		val = getDvarInt(var);
		
		if (val > 1)
		val = 1;
		if (val < 0)
		val = 0;
		
		finishDvar(type, dvar, val);
	}
}

dvarInt(type, dvar, def, min, max)
{
	var = type + "_" + dvar;
	if (getDvar(var) == "")
		finishDvar(type, dvar, def);
	else
	{
		val = getDvarInt(var);
		
		if (isdefined(max))
		if (val > max)
		val = max;
		if (isdefined(min))
		if (val < min)
		val = min;
		
		
		finishDvar(type, dvar, val);
	}
}

dvarFloat(type, dvar, def, min, max)
{
	var = type + "_" + dvar;
	if (getDvar(var) == "")
		finishDvar(type, dvar, def);
	else
	{
		val = getDvarFloat(var);
		
		if (isdefined(max))
		if (val > max)
		val = max;
		if (isdefined(min))
		if (val < min)
		val = min;
		
		finishDvar(type, dvar, val);
	}
}