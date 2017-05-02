/**
* vim: set ft=cpp:
* file: maps\mp\mp_fnrp_futurama_v3.gsc
*
* authors: Luk, 3aGl3, Bipo, Etheross
* team: SOG Modding
*
* project: RotU - Revolution
* website: http://survival-and-obliteration.com/
*
* Reign of the Undead - Revolution by Luk and 3aGl3
* You may modify this code to your liking or reuse it, as long as you give credit to those who wrote it
* Based on Reign of the Undead 2.1 created by Bipo and Etheross
*/

#include maps\mp\_zombiescript;

main()
{
	maps\mp\_character_duke::main();
	maps\mp\_character_jugg::main();
	maps\mp\_character_jugg2::main();
	precacheHeadIcon("headicon_map");
	precacheHeadIcon("headicon_fnrp");

	maps\mp\_load::main();
	maps\mp\_playerskins::main();
	maps\mp\mp_fnrp_futurama_rotate::main();
	maps\mp\mp_fnrp_futurama_train::main();
	maps\mp\mp_fnrp_futurama_v3_fx::main();
	maps\createfx\mp_fnrp_futurama_v3_fx::main();

	maps\mp\_compass::setupMiniMap("compass_map_mp_futurama");

	setExpFog(800, 20000, 0.583, 0.631569, 0.553078, 0);

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	setdvar("r_specularcolorscale", "1");
	setdvar("compassmaxrange","2000");
	setdvar("env_fog", "0");
	setDvar("bg_fallDamageMaxHeight", "900");
	setDvar("bg_fallDamageMinHeight", "850");
	setDvar("jump_height", "230");
	setDvar("g_gravity", "180");

	waittillStart();
	buildAmmoStock("ammostock");
	buildWeaponUpgrade("weaponupgrade");
	buildSurvSpawn("spawngroup1", 1);
	buildSurvSpawn("spawngroup2", 1);
	buildSurvSpawn("spawngroup3", 1);
	buildSurvSpawn("spawngroup4", 1);
	buildSurvSpawn("spawngroup5", 1);
	buildSurvSpawn("spawngroup6", 1);
	startSurvWaves();

	level.barricadefx = LoadFX("dust/dust_trail_IR");
	buildBarricade("staticbarricade", 4, 400, level.barricadefx,level.barricadefx);

	wait 10;
	maps\mp\_playerskins::roturecall();	
} 


