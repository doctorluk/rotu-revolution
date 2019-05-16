/**
* vim: set ft=cpp:
* file: maps\mp\gametypes\surv.gsc
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

main()
{
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	level.callbackStartGameType = ::Callback_StartGameType;

	level.script = toLower(getDvar("mapname"));
	level.gametype = toLower(getDvar("g_gametype"));
	
	// Monitor the game's version
	level.gameversion = getDvar("shortversion");
	if( level.gameversion == "1.7a" )
		level.gameversion = 1.71;
	else
		level.gameversion = getDvarFloat("shortversion");
		
	// In case the version has jumped above 1.8 (e.g. 1.8a) we just assume newer
	if( level.gameversion == 0 )
		level.gameversion = 1.81;
}

Callback_StartGameType()
{
	// TODO I wonder if these are still relevant for anything...?
	if (!isDefined(game["allies"]))
		game["allies"] = "marines";
	if (!isDefined(game["axis"]))
		game["axis"] = "opfor";

	level.starttime = getTime();
	level.activePlayers = 0;
	thread scripts\server\_server::init();
	thread scripts\clients\_clients::init();
	thread scripts\players\_players::init();
	
	thread scripts\gamemodes\_gamemodes::init();
	thread scripts\bots\_bots::init();

	thread precacheDefault();
	
	//thread setupEnvironment();
}

precacheDefault()
{
	preCacheShader( "white" );
	preCacheShader( "black" );

	precacheModel( "tag_origin" );
}

