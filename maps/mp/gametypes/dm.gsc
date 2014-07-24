/*
	Woot, clean gametype without any 3rd party script calls.
	Without any rules, with spawn player/spectator functions.
*/


main()
{
	if( getDvar( "mapname" ) == "mp_background" )
		return; // this isn't required...
	setDvar("g_gametype", "surv");

	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	//maps\mp\gametypes\_players::SetupCallbacks();
	level.callbackStartGameType = ::Callback_StartGameType;


	level.script = toLower( getDvar( "mapname" ) );
	level.gametype = toLower( getDvar( "g_gametype" ) );
	level.modversion = "RotU-Revolution v0.4.1";
}

Callback_StartGameType()
{
	if ( !isDefined( game["allies"] ) )
		game["allies"] = "marines";
	if ( !isDefined( game["axis"] ) )
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
	precachemodel("tag_origin");
	preCacheShader("white");
	preCacheShader("black");
}

