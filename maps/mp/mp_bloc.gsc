/**
* vim: set ft=cpp:
* file: maps\mp\mp_bloc.gsc
*
* authors: Luk, 3aGl3, Bipo, Etheross
* team: SOG Modding
*
* project: RotU - Revolution
* website: http://survival-and-obliteration.com/
*
* Reign of the Undead - Revolution ALPHA 0.7 by Luk and 3aGl3
* You may modify this code to your liking or reuse it, as long as you give credit to those who wrote it
* Based on Reign of the Undead 2.1 created by Bipo and Etheross
*/

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

    setdvar("r_specularcolorscale", "1");
    setdvar("compassmaxrange","2000");

    thread maps\mp\mp_bloc_waypoints::load_waypoints();
    thread maps\mp\mp_bloc_tradespawns::load_tradespawns();
	
	waittillStart();
	
	buildSurvSpawnByClassname("mp_dm_spawn");
	startSurvWaves();
}