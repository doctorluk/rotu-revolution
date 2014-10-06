//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.7 by Luk and 3aGl3
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

#include scripts\include\data;
init()
{
	precache();
	
	level.players = [];
	level.activePlayers = 0;
	SetupCallbacks();
	
}

precache()
{
	// precacheStatusIcon("hud_status_connecting");
}

SetupCallbacks()
{
	level.callbackPlayerConnect = ::Callback_PlayerConnect;
	level.callbackPlayerDisconnect = ::Callback_PlayerDisconnect;
	level.callbackPlayerDamage = ::Callback_PlayerDamage;
	level.callbackPlayerKilled = ::Callback_PlayerKilled;
}

catchBot()
{
	if( self getStat(512) == 100 ) //RELOADING ZOMBIE :]
	{
		level.loadBots = 0;
		self.isBot = true;
		self thread scripts\bots\_bots::loadBot();

		return 1;
	}
	
	return 0;
}

Callback_PlayerConnect()
{
	self.isBot = false;
	
	self catchBot();

	self.statusicon = "";
	self.hasBegun = false;
	self waittill("begin");
	self.hasBegun = true;
	
	//self setclientdvars("rotu2_publickey", getsubstr(level.str,5), "rotu2_baseurl", getdvar("sv_wwwbaseurl"));
	
	self.statusicon = "";
	//self.sessionteam = "spectator";
	//self.sessionstate = "spectator";
	self.pers["team"] = "free";
	
	if (!self.isBot)
	{
		self scripts\players\_weapons::initPlayerWeapons();
		
		iPrintln( self.name + " ^7connected." );
		
		self setClientDvars( "cg_drawSpectatorMessages", 1,
							 "ui_hud_hardcore", 0,
							 "ui_turretsDisabled", level.turretsDisabled,
							 "player_sprintTime", 10,
							 "ui_uav_client", 1,
							 "ui_hintstring", "",
							 "ui_infostring", "",
							 "cg_enemynamefadein", 999999999,
							 "cg_enemynamefadeout", 0,
							 "ui_clientcmd", "empty",
							 "r_filmusetweaks", 0,
							 "cg_fovscale", 1,
							 "ui_healthbar", -1,
							 "ui_upgradetext", "",
							 "ui_specialtext", "",
							 "r_dLightLimit", 4,
							 "r_distortion", 1,
							 "ui_spawnqueue", "",
							 "ui_spawnqueue_show", 1,
							 "ui_rotuversion_short", level.rotuVersion,
							 "ui_classcount_soldier", level.classcount["soldier"],
							"ui_classcount_stealth", level.classcount["stealth"],
							"ui_classcount_armored", level.classcount["armored"],
							"ui_classcount_engineer", level.classcount["engineer"],
							"ui_classcount_scout", level.classcount["scout"],
							"ui_classcount_medic", level.classcount["medic"],
							"ui_soldier_unlocked", (level.classcount["soldier"] < level.dvar["game_max_soldiers"]),
							"ui_assassin_unlocked", (level.classcount["stealth"] < level.dvar["game_max_assassins"]),
							"ui_armored_unlocked", (level.classcount["armored"] < level.dvar["game_max_armored"]),
							"ui_engineer_unlocked", (level.classcount["engineer"] < level.dvar["game_max_engineers"]),
							"ui_scout_unlocked", (level.classcount["scout"] < level.dvar["game_max_scouts"]),
							"ui_medic_unlocked", (level.classcount["medic"] < level.dvar["game_max_medics"]),
							"ui_damagereduced", 0
							);
		
		lpselfnum = self getEntityNumber();
		self.guid = self getGuid();
		logPrint("J;" + self.guid + ";" + lpselfnum + ";" + self.name + "\n");
		
		
		waittillframeend;
		
		level.players[level.players.size] =  self;
		level notify("connected", self);
		
		self thread scripts\players\_players::onPlayerConnect();
		self thread scripts\gamemodes\_hud::onPlayerConnect();
		// self thread scripts\players\_players::joinAllies();
		
	}
}

Callback_PlayerDisconnect()
{
	if (self.isBot || !self.hasBegun)
	return;
	
	// if( isReallyPlaying( self ) )
		// self.persData.lastPlayedWave = level.currentWave;
		
	self scripts\players\_players::onPlayerDisconnect();
		
	if( isDefined( self.persData.lastPlayedWave ) && isAlive( self ) ){
		// logPrint("Updated your lastPlayedWave, " + self.name + ", it is " + level.currentWave + "\n");
		self.lastPlayedWave = level.currentWave;
		self.persData.lastPlayedWave = self.lastPlayedWave;
	}
	
	self scripts\players\_players::cleanup();
	if ( isdefined(self.carryObj) )
			self.carryObj delete();
	
	self setclientdvars("ui_hud_hardcore", 0,
						"ui_rotuversion_short", "",
						"ui_damagereduced", 0);
	
	//iPrintln( self.name + " ^7disconnected." );
	logPrint("LOG_ROTU_RANK;" + self getGuid() + ";" + self.pers["prestige"] + ";" + self.pers["rank"] + "\n");
	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("Q;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");
	
	level.players = removeFromArray(level.players, self);
	level.joinQueue = removeFromArray(level.joinQueue, self);
	
	self notify( "disconnect" );
	level notify("update_classcounts");
}

Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if (self.isBot)
		self thread scripts\bots\_bots::Callback_BotDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
	else
		self thread scripts\players\_players::onPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	if (self.isBot)
		self thread scripts\bots\_bots::Callback_BotKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
	else
		self thread scripts\players\_players::onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
}