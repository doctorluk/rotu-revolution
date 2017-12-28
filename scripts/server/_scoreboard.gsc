/**
* vim: set ft=cpp:
* file: scripts\server\_scoreboard.gsc
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

/***
*
*	TODO: Add file description
*
*/

init()
{
	precacheShader("faction_128_usmc");
	setdvar("g_TeamIcon_Allies", "faction_128_usmc");
	setdvar("g_TeamColor_Allies", "0.6 0.64 0.69");
	setdvar("g_ScoresColor_Allies", "0.6 0.64 0.69");

	precacheShader("faction_128_ussr");
	setdvar("g_TeamIcon_Axis", "faction_128_ussr");
	setdvar("g_TeamColor_Axis", "0.62 0.28 0.28");		
	setdvar("g_ScoresColor_Axis", "0 0 0 0");

	setdvar("g_ScoresColor_Spectator", ".25 .25 .25");
	setdvar("g_ScoresColor_Free", ".76 .78 .10");
	setdvar("g_teamColor_MyTeam", ".6 .8 .6");
	setdvar("g_teamColor_EnemyTeam", "1 .45 .5");	
}
