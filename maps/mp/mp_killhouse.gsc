#include maps\mp\_stockmaputil;
#include maps\mp\_zombiescript;
main()
{
    maps\mp\mp_killhouse_fx::main();
    maps\createart\mp_killhouse_art::main();
    maps\mp\_load::main();
	prepareMap();

    maps\mp\_compass::setupMiniMap("compass_map_mp_killhouse");

    ambientPlay("ambient_overgrown_day");

    game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

    setdvar( "r_specularcolorscale", "1" );
    setdvar("r_glowbloomintensity0",".25");
    setdvar("r_glowbloomintensity1",".25");
    setdvar("r_glowskybleedintensity0",".3");
    setdvar("compassmaxrange","2200");

    thread maps\mp\mp_killhouse_waypoints::load_waypoints();
	
	waittillStart();
	
	buildSurvSpawnByClassname("mp_dm_spawn");
	buildAmmoStock("bombzone");
	buildWeaponUpgrade("hq_hardpoint");
	startSurvWaves();
}
