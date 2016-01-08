#include maps\mp\_zombiescript;
main()
{
    maps\mp\_load::main();

    ambientPlay("ambient_backlot_ext");
    maps\mp\_compass::setupMiniMap("compass_map_mp_4t4scrap");

    game["allies"] = "marines";
    game["axis"] = "opfor";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "desert";
    game["axis_soldiertype"] = "desert";

    setdvar("r_specularcolorscale", "0.5");
    setdvar("r_glowbloomintensity0",".25");
    setdvar("r_glowbloomintensity1",".25");
    setdvar("r_glowskybleedintensity0",".3");
    setdvar("compassmaxrange","1800");
	
	thread maps\mp\mp_4t4scrap_waypoints::load_waypoints();
    thread maps\mp\mp_4t4scrap_tradespawns::load_tradespawns();
	
    waittillStart();
	
	buildSurvSpawnByClassname("mp_dm_spawn");
	startSurvWaves();
}
