/**
* vim: set ft=cpp:
* file: scripts\server\_settings.gsc
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
* 	_settings.gsc
*	Defines all configurable settings that can be changed in .cfg files
*
*/

init()
{
	level.dvar = [];
	loadSettings();
}

/**
*
*	dvarInt: 	<prefix>, 	<setting_name>,	<defaultValue>,	<min>, 	<max>
*	dvarFloat:	<prefix>, 	<setting_name>,	<defaultValue>,	<min>, 	<max>
*	dvarBool:	<prefix>, 	<setting_name>,	<defaultValue>
*	dvarString: <prefix>, 	<setting_name>,	<defaultValue>
*
*	The dvars are accessible via level.dvar["<prefix>_<setting_name>"]
*	In the .cfg they're called <prefix>_<setting_name>
*/

loadSettings()
{
	players = (getDvarInt("sv_maxclients") - getDvarInt("bot_count"));
	
	/*
	* DEVELOPER SETTINGS
	*/
	// Check for too many waypoint calculations per frame to reduce infinite loop detections
	dvarBool(	"dev",			"antilagmonitor",		1); 
	
	
	/*
	* SERVER SETTINGS
	*/
	// Amount of bots
	dvarInt(	"bot",			"count",				20,		0,		63);
	
	// Alternative logfile setting
	dvarInt(	"logfile",			"2",				3,		0,		3);
	
	/*
	* ZOMBIE SETTINGS
	*/
	// Zombie debug mode
	dvarBool(	"zom",			"developer",			0);
	
	
	/*
	* ROTU GAMETYPE SETTINGS
	*/
	// Show killing info
	dvarBool(	"zom", 			"orbituary",			0);
	
	// Alerts zombies around another zombie
	dvarBool(	"zom", 			"dominoeffect",	 		1);
	
	// Dynamic difficulty 
	dvarBool(	"zom", 			"dynamicdifficulty",	1);
	
	// Infection
	dvarBool(	"zom", 			"infection",			1);
	
	// Only headshots TODO: NOT IMPLEMENTED
	dvarBool(	"zom",			"headshotonly",			0);
	
	// Time it takes for a player to become zombie
	dvarInt(	"zom", 			"infectiontime",		25, 	0, 		120);
	
	// Spawn protection of zombies
	dvarBool(	"zom",			"spawnprot",			1);
	
	// Graceful reduction of zombie spawnprotection
	dvarBool(	"zom",			"spawnprot_decrease", 	1);
	
	// Duration of spawnprotection
	dvarFloat(	"zom",			"spawnprot_time",		6,		0,		30);
	
	// Spawnprotection of hell zombies or the boss
	dvarBool(	"zom",			"spawnprot_tank",		0);
	
	// Disable security checks if local game
	dvarBool(	"game",			"lan_mode",				1);
	
	// Maximum class settings
	dvarInt(	"game",			"max_soldiers",			players,		0,		getDvarInt("sv_maxclients"));
	dvarInt(	"game",			"max_specialists",		players,		0,		getDvarInt("sv_maxclients"));
	dvarInt(	"game",			"max_armored",			players,		0,		getDvarInt("sv_maxclients"));
	dvarInt(	"game",			"max_engineers",		players,		0,		getDvarInt("sv_maxclients"));
	dvarInt(	"game",			"max_medics",			players,		0,		getDvarInt("sv_maxclients"));
	
	// Increases ragdoll forces, TODO: doesn't seem to work
	dvarBool(	"game", 		"extremeragdoll",	 	1);
	
	// Godmode for players
	dvarBool(	"game", 		"godmode",	 			0);
	
	// Display version information and website in iprintln area
	dvarBool(	"game", 		"version_banner",	 	1);
	
	// Allow friendly fire
	dvarBool(	"game", 		"friendlyfire",	 		0);
	
	// Difficulty setting
	dvarInt(	"game", 		"difficulty",	 		2,		1,		5);
	
	// Welcome messages
	dvarBool(	"game",			"welcomemessages",		0);
	
	// Allow mapvoting at the end of the game
	dvarBool(	"game",			"mapvote",				1);
	
	// Time for the mapvote
	dvarInt(	"game",			"mapvote_time",			20,		5,		60);
	
	// Amount of maps displayed when voting for a map
	dvarInt(	"game",			"mapvote_count",		8,		1, 		15);
	
	// Multiplier for rewards
	dvarInt(	"game", 		"rewardscale",	 		25,		1,		10000);
	
	// Give players upgradepoints when they've missed out on some waves
	dvarBool(	"game",			"delayed_upgradepoints",		1);
	
	// Amount of upgradepoints given after missing out x waves
	dvarInt(	"game", 		"delayed_upgradepoints_amount",	3000,	1,		100000);
	
	// Points players start with
	dvarInt(	"game", 		"startpoints",	 		2000,	0,		100000);
	
	// Multiplier for XP gain
	dvarInt(	"game", 		"xpmultiplier",	 		1,		1,		20);
	
	// Maximum turrets overall
	dvarInt(	"game",			"max_turrets",			5,		0,		12);
	
	// Maximum turrets per player
	dvarInt(	"game",			"max_turrets_perplayer",3,		0,		12);
	
	// Maximum Claymores per player
	dvarInt(	"game",			"max_claymores",		10,		0,		50);
	
	// Maximum C4 per player
	dvarInt(	"game",			"max_c4",				10,		0,		50);
	
	// Maximum barrels overall
	dvarInt(	"game",			"max_barrels",			12,		0,		30);
	
	// Disables spectating of the bot team for all players
	dvarBool(	"game",			"disable_spectating_bots",	1);
	
	// Spawns players in waves
	dvarBool(	"game",			"enable_join_queue",	1);
	
	// Protects players upon spawning
	dvarBool(	"game",			"player_spawnprotection",	1);
	
	// Duration of player spawn protection
	dvarFloat(	"game",			"player_spawnprotection_time",	3,		0,		10);

	// Duration of turrets
	dvarFloat(	"game",			"turret_time",			120,	10,		99999);

	// Enable skill points
	dvarBool(	"game",			"class_ranks",			1);
	
	// Rotating server name
	dvarBool(	"game",			"changing_hostname",	0);
	
	// Time between every server name update
	dvarInt(	"game",			"changing_hostname_time",		10,		2,	60);
	
	
	/*
	* AFK SETTINGS
	*/
	// Enable AFK-checker
	dvarBool(	"game",			"afk_enabled",			1);
	
	// Time in seconds how long a player is afk
	dvarInt(	"game",			"afk_time_warn",		240,	5,		6000);
	
	// Times a player should be warned after afk_time_warn has been reached
	dvarInt(	"game",			"afk_warn_amount",		5,		1,		100);
	
	// Time in seconds how long a player is afk
	dvarInt(	"game",			"afk_time",				300,	5,		6000);
	
	// AFK-handle type, 0 = kick, 1 = spec
	dvarInt(	"game",			"afk_type",				0,		0,		1);
	
	
	/*
	* HUD SETTINGS
	*/
	// Display amount of living players
	dvarBool(	"hud",			"survivors_left",		1);
	
	// Display amount of downed players
	dvarBool(	"hud",			"survivors_down",		1);
	
	// Display # of current wave
	dvarBool(	"hud",			"wave_number",			1);
	
	// Display # of alive zombies
	dvarBool(	"hud",			"zombies_alive",		0);
	
	/*
	* ENVIRONMENTAL SETTINGS
	*/
	
	// Use ambient music in waves
	dvarBool(	"env", 			"ambient",	 			1);
	
	// Enable fog
	dvarBool(	"env", 			"fog",	 				1);
	
	// Fog start distance
	dvarInt(	"env", 			"fog_start_distance",	200,	0,		10000);
	
	// Fog 50% intensity distance
	dvarInt(	"env", 			"fog_half_distance",	480,	0,		10000);
	
	// Fog RGB settings
	dvarInt(	"env", 			"fog_red",				5,		0,		255);
	dvarInt(	"env", 			"fog_green",			0,		0,		255);
	dvarInt(	"env", 			"fog_blue",				5,		0,		255);
	
	// Blur multiplier
	dvarInt(	"env",			"blur",					.1, 	0,		10);
	
	// Override map vision with "rotu"
	dvarBool(	"env",			"override_vision",		1);
	
	// Default wave order
	/*
		1 = Normal
		2 = Dogs
		3 = Burning
		4 = Crawlers
		5 = Hell
		6 = Scary
		7 = Boss (to be changed)
		8 = grouped Normal
		20 = Increase Shop Costs and Zombie Damage
	*/
	dvarString(	"surv",			"waves",				"1;2;6;4;7;20;8;3;6;7");
	
	// Starting amount of zombies
	dvarInt(	"surv", 		"zombies_initial",		10,		1,		1000);
	
	// Amount of zombies added per player playing
	dvarInt(	"surv", 		"zombies_perplayer",	10,		1,		1000);
	
	// Amount of zombies added per played wave
	dvarInt(	"surv", 		"zombies_perwave",		5,		1,		1000);
	
	// Time in seconds for a player to revive another player
	dvarFloat(	"surv",			"revivetime",			3,		0.25,	30);

	// Type of wave-amount calculation
	/*
		0: surv_zombies_initial + players * surv_zombies_perplayer
		1: surv_zombies_initial + waveid * level.dvarsurv_zombies_perwave
		2: surv_zombies_initial + players * (waveid * surv_zombies_perwave + surv_zombies_perplayer)
		3: surv_zombies_initial + players * surv_zombies_perplayer + waveid * surv_zombies_perwave
	*/
	dvarInt(	"surv", 		"wavesystem",			2,		0,		2);
	
	// Time between waves
	dvarInt(	"surv", 		"timeout",	 			30,		2,		120);
	
	// Additional time for the first wave TODO: Don't make it add, make it autonomous
	dvarInt(	"surv", 		"timeout_firstwave",	30,		0,		60);
	
	// Time before the "finale" wave
	dvarInt(	"surv",			"timeout_finale",		5,		60,		300);
	
	// Type of waves
	// There is "waves_special" and "waves_endless", but "waves_endless" isn't implemented
	dvarString(	"surv",			"defaultmode",			"waves_special");
	
	// Type of weapon upgrading
	// "upgrade" is upgrading all weapons, "wawzombies" is the special box
	dvarString(	"surv",			"weaponmode",			"upgrade");
	
	// Primary weapon to spawn with (only active with "wawzombies")
	dvarString(	"surv",			"waw_spawnprimary",		"none");
	
	// Secondary weapon to spawn with (only active with "wawzombies")
	dvarString(	"surv",			"waw_spawnsecondary",	"beretta_mp");
	
	// Costs per magic-box-use
	dvarInt(	"surv",			"waw_costs",			750,	1,		100000);
	
	// Always pay when using the magic-box or only when accepting the weapon
	dvarBool(	"surv",			"waw_alwayspay",		1);
	
	// Spawn walking zombies
	dvarBool(	"surv",			"slow_start",			1);
	
	// Music-cut finale announcement with text
	dvarBool(	"surv",			"extended_finale_announcement",			1);
	
	// Amount of waves where zombies spawn walking instead of running
	dvarInt(	"surv",			"slow_waves",			3,		1,		10);
	
	// Amount of maps that shouldn't be listed in the mapvoting
	dvarInt(	"surv",			"dontplaylastmaps",		3,		0,		100);
	
	// Stuck-Zombie killer
	dvarBool(	"surv",			"find_stuck",			1);
	
	// Tolerance for stuck zombies
	dvarInt(	"surv",			"stuck_tolerance",		30,		10,		360);
	
	// Adjust finale difficulty by game_difficulty
	dvarBool(	"surv",			"dynamic_finale_difficulty",	1);
	
	// Minimum amount of players for the finale to start, game ends there otherwise
	dvarInt(	"surv",			"finale_minplayers",	7,		1,		64);
	
	// Revive players automatically at the end of the round
	dvarBool(	"surv",			"endround_revive",		1);
	
	// Write stats about all players once the map ends
	dvarBool(	"surv",			"rotu_stats",			0);
	
	// Enable seasonal fun things e.g. the santa hat
	dvarBool(	"surv",			"seasonal_features",	0);
	
	
	/*
	* PHOENIX SETTINGS
	*/
	
	// Minimum amount of players to enable phoenix
	dvarInt(	"surv",			"phoenix_minplayers",	3,		1, 		64);
	
	// Minimum amount of waves played before enabling the phoenix
	dvarInt(	"surv",			"phoenix_minwave",		3,		1,		64);
	
	// Start amount of upgradepoints in % of the overall average amount of upgradepoints
	dvarFloat(	"surv",			"phoenix_base_percentage",		0.2,	0.01,	1.0);
	
	// # of waves between every increase of upgradepoints needed
	dvarInt(	"surv",			"phoenix_wave_stepsize",		2,		1,		100);
	
	// Increase percentage after phoenix_wave_stepsize
	dvarFloat(	"surv",			"phoenix_wave_percentage",		0.03,	0,		1);
	
	
	/*
	* SHOP SETTINGS
	*/
	// Restore Health
	dvarInt(	"shop", 		"item1_costs",	 		2000,		1,		100000);
	
	// Restore Ammo
	dvarInt(	"shop", 		"item2_costs",	 		1500,		1,		100000);
	
	// Cure Infection
	dvarInt(	"shop", 		"item3_costs",	 		3500,		1,		100000);
	
	// Frage Grenade
	dvarInt(	"shop", 		"weapon1_costs",	 	1000,		1,		100000);
	
	// C4
	dvarInt(	"shop", 		"weapon2_costs",	 	1250,		1,		100000);
	
	// Claymore
	dvarInt(	"shop", 		"weapon3_costs",	 	2000,		1,		100000);
	
	// Raygun
	dvarInt(	"shop", 		"weapon4_costs",	 	10000,		1,		100000);
	
	// Barrel
	dvarInt(	"shop", 		"defensive1_costs",	 	1000,		1,		100000);
	
	// Exploding Barrel
	dvarInt(	"shop", 		"defensive2_costs",	 	1500,		1,		100000);
	
	// Sentry Turret
	dvarInt(	"shop", 		"defensive3_costs",	 	4000,		1,		100000);
	
	// GL Turret
	dvarInt(	"shop", 		"defensive4_costs",	 	7000,		1,		100000);
	
	// Enable cost increase after increasing zombie difficulty (wave type "20")
	dvarBool(	"shop",			"multiply_costs",			1);
	
	// Amount of cost increase
	dvarInt(	"shop", 		"multiply_costs_amount",	 	40,		0,		100);
	
	
	/*
	* MISC SETTINGS
	*/
	// Used in script to save recently played maps TODO: Remove entry in _settings.gsc and rely on different var
	dvarString(	"surv",			"recentmaps",	"");

	// TODO: Move out of here
	setDvar("g_teamname_axis", "^9Zombies");
	setDvar("g_teamname_allies", "Survivors");
	level.rewardScale = level.dvar["game_rewardscale"];
	//
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