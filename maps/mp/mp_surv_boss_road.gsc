#include maps\mp\_stockmaputil;
#include maps\mp\_zombiescript;
main()
{
    maps\mp\_load::main();
	prepareMap();

    ambientPlay("ambient_backlot_ext");
    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setdvar("r_specularcolorscale", "1");
    setdvar("r_glowbloomintensity0",".25");
    setdvar("r_glowbloomintensity1",".25");
    setdvar("r_glowskybleedintensity0",".3");
    setdvar("compassmaxrange","1800");

    thread maps\mp\mp_surv_boss_road_waypoints::load_waypoints();
	
	waittillStart();
	
	buildSurvSpawn("spawngroup1", 1);
    buildSurvSpawn("spawngroup2", 1);
    buildSurvSpawn("spawngroup3", 1);
    buildSurvSpawn("spawngroup4", 1);
    buildSurvSpawn("spawngroup5", 1);
    buildSurvSpawn("spawngroup6", 1);
    buildSurvSpawn("spawngroup7", 1);
    buildSurvSpawn("spawngroup8", 1);
	buildAmmoStock("bombzone");
	buildWeaponUpgrade("hq_hardpoint");
	startSurvWaves();
}
