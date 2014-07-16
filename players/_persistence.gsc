//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.6 by Luk 
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

init()
{
	level.persistentDataInfo = [];
	
	level.persPlayerData = [];

	level thread onPlayerConnect();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		player setClientDvar("ui_xpText", "1");
		player.enableText = true;
	}
}

restoreData() {
	struct = level.persPlayerData[self.guid];
	if (!isdefined(struct)) {
		struct = spawnstruct();
		level.persPlayerData[self.guid] = struct;
		struct.unlock["primary"] = 0;
		struct.unlock["secondary"] = 0;
		struct.unlock["extra"] = 0;
		struct.primary = level.spawnPrimary;
		struct.primaryAmmoStock = 10;
		struct.primaryAmmoClip = 10;
		struct.secondary = level.spawnSecondary;
		struct.secondaryAmmoStock = 0;
		struct.secondaryAmmoClip = 0;
		struct.extra = "none";
		struct.extraAmmoStock = 0;
		struct.extraAmmoClip = 0;
		struct.points = level.dvar["game_startpoints"];
		struct.isDown = false;
		struct.downOrigin = (0,0,0);
		struct.lastPlayedWave = 0;
		struct.specialRecharge = 100;
		struct.class = "";
	}
	self.persData = struct;
	
	self.points = struct.points;
	self.unlock["primary"] = struct.unlock["primary"];
	self.unlock["secondary"] = struct.unlock["secondary"];
	self.unlock["extra"] = struct.unlock["extra"];
	
	self.lastPlayedWave = struct.lastPlayedWave;
	self.specialRecharge = struct.specialRecharge;
	
}

// ==========================================
// Script persistent data functions
// These are made for convenience, so persistent data can be tracked by strings.
// They make use of code functions which are prototyped below.

/*
=============
statGet

Returns the value of the named stat
=============
*/
statGet( dataName )
{
	//if ( !level.onlineGame )
	//	return 0;
	return self getStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )) );
}

/*
=============
setStat

Sets the value of the named stat
=============
*/
statSet( dataName, value )
{
	//if ( !level.rankedMatch )
	//	return;
	
	self setStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )), value );	
}

/*
=============
statAdd

Adds the passed value to the value of the named stat
=============
*/
statAdd( dataName, value )
{	
	//if ( !level.rankedMatch )
	//	return;

	curValue = self getStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )) );
	self setStat( int(tableLookup( "mp/playerStatsTable.csv", 1, dataName, 0 )), value + curValue );
}
