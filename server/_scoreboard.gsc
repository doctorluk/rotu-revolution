/**********************************
	---- Reign of the Undead ----
			   v2.0
	
	(Do not copy without permission)
	
	Date: November 2010
	Version: 2.000
	Author: Bipo
		
	© Reign of the Undead Team
************************************/

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
	setdvar("g_teamColor_MyTeam", ".6 .8 .6" );
	setdvar("g_teamColor_EnemyTeam", "1 .45 .5" );	
}
