#include maps\mp\_stockmaputil;
#include maps\mp\_zombiescript;

main()
{
    maps\mp\mp_cargoship_fx::main();
    maps\createart\mp_cargoship_art::main();
    maps\mp\_load::main();
	prepareMap();

    maps\mp\_compass::setupMiniMap("compass_map_mp_cargoship");

    ambientPlay("ambient_cargoshipmp_ext");

    game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

    setdvar( "r_specularcolorscale", "1" );
    setdvar( "compassmaxrange", "2100" );

    thread maps\mp\mp_cargoship_waypoints::load_waypoints();
	
	waittillStart();
	
	buildSurvSpawnByClassname("mp_dm_spawn");
	buildAmmoStock("bombzone");
	buildWeaponUpgrade("hq_hardpoint");
	startSurvWaves();
}
