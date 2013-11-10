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
	if(self getStat(512) == 100) //RELOADING ZOMBIE :]
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
		self scripts\server\_ranks::loadPlayerRank();
		self scripts\players\_weapons::initPlayerWeapons();

		if (self.title == "")
		iPrintln( self.name + " ^7connected." );
		else
		iPrintln( self.name + "^7[" + self.title + "^7] connected." );
		
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
							 "ui_rotuversion_short", level.rotuVersion_short,
							 "ui_classcount_soldier", level.classcount["soldier"],
							"ui_classcount_stealth", level.classcount["stealth"],
							"ui_classcount_armored", level.classcount["armored"],
							"ui_classcount_engineer", level.classcount["engineer"],
							"ui_classcount_scout", level.classcount["scout"],
							"ui_classcount_medic", level.classcount["medic"]);
		
		lpselfnum = self getEntityNumber();
		self.guid = self getGuid();
		logPrint("J;" + self.guid + ";" + lpselfnum + ";" + self.name + "\n");
		
		
		waittillframeend;
		
		level.players[level.players.size] =  self;
		level notify("connected", self);
		
		self thread scripts\players\_players::onPlayerConnect();
		self thread scripts\gamemodes\_hud::onPlayerConnect();
		self thread scripts\players\_players::joinAllies();
		
	}
}

Callback_PlayerDisconnect()
{
	if (self.isBot || !self.hasBegun)
	return;
	
	self scripts\players\_players::cleanup();
	
	self setclientdvars("ui_hud_hardcore", 0,
						"ui_rotuversion_short", "");
	
	//iPrintln( self.name + " ^7disconnected." );
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