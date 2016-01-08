#include maps\mp\_zombiescript;
main()
{
    maps\mp\mp_countdown_fx::main();
    maps\createart\mp_countdown_art::main();
    maps\mp\_load::main();

    maps\mp\_compass::setupMiniMap("compass_map_mp_countdown");

    ambientPlay("ambient_crossfire");

    game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

    setdvar( "r_specularcolorscale", "1.5" );
    setdvar("compassmaxrange","2000");

    thread maps\mp\mp_countdown_waypoints::load_waypoints();
    thread maps\mp\mp_countdown_tradespawns::load_tradespawns();
	
	waittillStart();
	
	buildSurvSpawnByClassname("mp_dm_spawn");
	startSurvWaves();
}
