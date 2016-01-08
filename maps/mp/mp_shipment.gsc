#include maps\mp\_zombiescript;
main()
{
    maps\mp\mp_shipment_fx::main();
    maps\createart\mp_shipment_art::main();
    maps\mp\_load::main();
	prepareMap();

    maps\mp\_compass::setupMiniMap("compass_map_mp_shipment");

    ambientPlay("ambient_middleeast_ext");

    game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

    setdvar( "r_specularcolorscale", "1" );
    setdvar("r_glowbloomintensity0",".1");
    setdvar("r_glowbloomintensity1",".1");
    setdvar("r_glowskybleedintensity0",".1");
    setdvar("compassmaxrange","1400");

    thread maps\mp\mp_shipment_waypoints::load_waypoints();
    thread maps\mp\mp_shipment_tradespawns::load_tradespawns();
	
	waittillStart();
	
	buildSurvSpawnByClassname("mp_dm_spawn");
	startSurvWaves();
}
