#include maps\mp\_zombiescript;

main()
{
    maps\mp\mp_bloc_fx::main();
    maps\createart\mp_bloc_art::main();
    maps\mp\_load::main();

    maps\mp\_compass::setupMiniMap("compass_map_mp_bloc");

    ambientPlay("ambient_middleeast_ext");

    game["allies"] = "sas";
    game["axis"] = "russian";
    game["attackers"] = "axis";
    game["defenders"] = "allies";
    game["allies_soldiertype"] = "woodland";
    game["axis_soldiertype"] = "woodland";

    setdvar( "r_specularcolorscale", "1" );
    setdvar("compassmaxrange","2000");

    thread maps\mp\mp_bloc_waypoints::load_waypoints();
    thread maps\mp\mp_bloc_tradespawns::load_tradespawns();
	
	waittillStart();
	
	buildSurvSpawnByClassname("mp_dm_spawn");
	startSurvWaves();
}