#include maps\mp\_stockmaputil;
#include maps\mp\_zombiescript;
main()
{
    maps\mp\mp_bloc_fx::main();
    maps\createart\mp_bloc_art::main();
    maps\mp\_load::main();
	prepareMap();

    maps\mp\_compass::setupMiniMap("compass_map_mp_bloc");

    ambientPlay("ambient_middleeast_ext");

    game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

    setdvar( "r_specularcolorscale", "1" );
    setdvar("compassmaxrange","2000");

    thread maps\mp\mp_bloc_waypoints::load_waypoints();
	
	waittillStart();
	
	buildSurvSpawnByClassname("mp_dm_spawn");
	buildAmmoStock("bombzone");
	buildWeaponUpgrade("hq_hardpoint");
	startSurvWaves();
}
