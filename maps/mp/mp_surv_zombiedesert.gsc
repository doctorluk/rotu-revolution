#include maps\mp\_zombiescript;
main()
{
    maps\mp\_load::main();

    game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

    setdvar("compassmaxrange", "1800");
    ambientPlay("ambient_backlot_ext");

    // No fence walking
    setDvar("g_gravity", "1100"); //800
    setDvar("jump_height", "21"); //39
    level.barrier = spawn("trigger_radius", (-57.5216,-382.574,136.125), 0, 3, 110 );
    level.barrier setContents(1);
    level.barrier2 = spawn("trigger_radius", (30.1555,-383.331,128.125), 0, 3, 110 );
    level.barrier2 setContents(1);
    level.barrier3 = spawn("trigger_radius", (-43.2222,-382.921,136.125), 0, 3, 110 );
    level.barrier3 setContents(1);
    level.barrier4 = spawn("trigger_radius", (-12.7801,-382.759,136.125), 0, 3, 110 );
    level.barrier4 setContents(1);
    level.barrier5 = spawn("trigger_radius", (6.47138,-382.542,136.125), 0, 3, 110 );
    level.barrier5 setContents(1);

    maps\mp\mp_surv_ZombieDesert_fx::main();
    maps\createfx\mp_surv_ZombieDesert_fx::main();

	thread maps\mp\mp_surv_zombiedesert_waypoints::load_waypoints();
	
	waittillStart();
	
	buildSurvSpawn("spawngroup1", 1);
    buildSurvSpawn("spawngroup2", 1);
    buildSurvSpawn("spawngroup3", 1);
    buildSurvSpawn("spawngroup4", 1);
	buildAmmoStock("ammostock");
	buildWeaponUpgrade("weaponupgrade");
	startSurvWaves();
}
