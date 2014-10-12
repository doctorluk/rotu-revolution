#include maps\mp\_stockmaputil;
#include maps\mp\_zombiescript;
main()
{
    maps\mp\mp_farm_fx::main();
    maps\createart\mp_farm_art::main();
    maps\mp\_load::main();
	prepareStockMap();

    maps\mp\_compass::setupMiniMap("compass_map_mp_farm");

    ambientPlay("ambient_farm");

    game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

    setdvar( "r_specularcolorscale", "5" );
    setdvar("compassmaxrange","2000");

    thread maps\mp\mp_farm_waypoints::load_waypoints();
	
	waittillStart();
	
	buildSurvSpawnByClassname("mp_dm_spawn");
	buildAmmoStock("bombzone");
	buildWeaponUpgrade("hq_hardpoint");
	startSurvWaves();
}
