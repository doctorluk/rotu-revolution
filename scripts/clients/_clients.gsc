/**
* vim: set ft=cpp:
* file: scripts\client\_clients.gsc
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

#include scripts\include\data;

/**
* Initializes client related variables
*/
init()
{
//	precacheStatusIcon("hud_status_connecting");	TODO can we use this again, now that we have only 5 classes?

	level.players = [];
	level.activePlayers = 0;

	// define callbacks
	level.callbackPlayerConnect = ::Callback_PlayerConnect;
	level.callbackPlayerDisconnect = ::Callback_PlayerDisconnect;
	level.callbackPlayerDamage = ::Callback_PlayerDamage;
	level.callbackPlayerKilled = ::Callback_PlayerKilled;
}	/* init */

/**
* Handles all connecting clients (players and bots alike)
*/
Callback_PlayerConnect()
{
	// assume this is a player
	self.isBot = false;
	
	// catch any reconnecting bots
	if( self getStat(512) == 100 )
	{
		// increase loaded bots number
		level.botsLoaded++;
		
		// initialize the bot
		self.isBot = true;
		self thread scripts\bots\_bots::loadBot();
	}

	self.statusicon = "";
	self.hasBegun = false;
	self waittill( "begin" );
	self.hasBegun = true;
	
	//self setclientdvars("rotu2_publickey", getsubstr(level.str,5), "rotu2_baseurl", getdvar("sv_wwwbaseurl"));
	
	self.statusicon = "";
	//self.sessionteam = "spectator";	// TODO why are we not using spectator?
	//self.sessionstate = "spectator";
	self.pers["team"] = "free";

	if( !self.isBot )
	{
		self scripts\players\_weapons::initPlayerWeapons();
		
		iPrintln(self.name + " ^7connected.");
		
		self setClientDvars("cg_drawSpectatorMessages", 1,
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
							"ui_classcount_specialist", level.classcount["specialist"],
							"ui_classcount_armored", level.classcount["armored"],
							"ui_classcount_engineer", level.classcount["engineer"],
							"ui_classcount_medic", level.classcount["medic"],
							"ui_soldier_unlocked", (level.classcount["soldier"] < level.dvar["game_max_soldiers"]),
							"ui_specialist_unlocked", (level.classcount["specialist"] < level.dvar["game_max_specialists"]),
							"ui_armored_unlocked", (level.classcount["armored"] < level.dvar["game_max_armored"]),
							"ui_engineer_unlocked", (level.classcount["engineer"] < level.dvar["game_max_engineers"]),
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
	if( self.isBot || !self.hasBegun )
		return;
	
	// if(isReallyPlaying(self))
		// self.persData.lastPlayedWave = level.currentWave;
		
	self scripts\players\_players::onPlayerDisconnect();
		
	if(isDefined(self.persData.lastPlayedWave) && isAlive(self)){
		// logPrint("Updated your lastPlayedWave, " + self.name + ", it is " + level.currentWave + "\n");
		self.lastPlayedWave = level.currentWave;
		self.persData.lastPlayedWave = self.lastPlayedWave;
	}
	
	self scripts\players\_players::cleanup();
	if (isdefined(self.carryObj))
			self.carryObj delete();
	
	self setclientdvars("ui_hud_hardcore", 0,
						"ui_rotuversion_short", "",
						"ui_damagereduced", 0);
	
	//iPrintln(self.name + " ^7disconnected.");
	logPrint("LOG_ROTU_RANK;" + self getGuid() + ";" + self.pers["prestige"] + ";" + self.pers["rank"] + "\n");
	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("Q;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");
	
	level.players = removeFromArray(level.players, self);
	level.joinQueue = removeFromArray(level.joinQueue, self);
	
	self notify("disconnect");
	level notify("update_classcounts");
}

Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	// convert the weapon name to the script name
	sWeapon = level.weaponKeyC2S[sWeapon];

	if( self.isBot )
		self thread scripts\bots\_bots::Callback_BotDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
	else
		self thread scripts\players\_players::onPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	// convert the weapon name to the script name
	sWeapon = level.weaponKeyC2S[sWeapon];

	if( self.isBot )
		self thread scripts\bots\_bots::Callback_BotKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
	else
		self thread scripts\players\_players::onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration);
}