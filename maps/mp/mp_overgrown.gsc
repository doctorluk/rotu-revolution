#include maps\mp\_stockmaputil;
#include maps\mp\_zombiescript;
main()
{
	maps\mp\mp_overgrown_fx::main();
	maps\createart\mp_overgrown_art::main();
	maps\mp\_load::main();
	prepareMap();
	

	maps\mp\_compass::setupMiniMap("compass_map_mp_overgrown");

	//setExpFog(100, 3000, 0.613, 0.621, 0.609, 0);
	//VisionSetNaked( "mp_overgrown" );
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
	
	maps\mp\mp_overgrown_waypoints::load_waypoints();
	// convertWaypoints();
	
	waittillStart();
	
	buildSurvSpawnByClassname("mp_dm_spawn");
	buildAmmoStock("bombzone");
	buildWeaponUpgrade("hq_hardpoint");
	
	startSurvWaves();

}



