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

#include scripts\include\physics;
#include scripts\include\entities;
#include scripts\include\hud;
#include scripts\include\data;
#include scripts\include\strings;
#include scripts\include\useful;
init()
{
	
	level.activePlayers = 0;
	level.activePlayersArray = [];
	level.alivePlayers = 0;
	level.alivePlayersArray = [];
	level.lastAlivePlayers = 0;
	level.playerspawns = "";
	level.intermission = 1;
	level.joinQueue = [];
	level.godmode = level.dvar["game_godmode"];
	// level.luk = 0;
	level.spawnQueue = ::spawnJoinQueueLoop;
	
	precache();
	
	level.callbackPlayerLastStand = ::Callback_PlayerLastStand;
	
	thread scripts\players\_menus::init();
	thread scripts\players\_classes::init();
	thread scripts\players\_abilities::init();
	thread scripts\players\_weapons::init();
	thread scripts\players\_playermodels::init();
	thread scripts\players\_usables::init();
	thread scripts\players\_infection::init();
	thread scripts\players\_persistence::init();
	thread scripts\players\_damagefeedback::init();
	thread scripts\players\_barricades::init();
	thread scripts\players\_turrets::init();
	thread scripts\players\_rank::init();
	//thread scripts\players\_challenges::buildChallegeInfo();
	thread updateActiveAliveCounts();
}

precache()
{
	level.flashlightGlow		= loadfx( "light/flashlight_glow" );
	
	precacheHeadIcon("hud_icon_lowhp");
	precacheHeadIcon("hud_icon_developer");
	precacheHeadIcon("hud_icon_low_ammo");

	precacheStatusIcon( "icon_medic" );
	precacheStatusIcon( "icon_engineer" );
	precacheStatusIcon( "icon_soldier" );
	precacheStatusIcon( "icon_stealth" );
	precacheStatusIcon( "icon_scout" );
	precacheStatusIcon( "icon_armored" );
	
	precacheStatusIcon( "icon_down" );
	// precacheStatusIcon( "icon_admin");
	precacheStatusIcon(	"icon_spec" );
	// precacheStatusIcon(	"icon_dev" );
	PreCacheShellShock("general_shock");
	
	precacheShader("overlay_armored");
}

setDown(isDown) {
	self.isDown = isDown;
	self.persData.isDown = isDown;
	if (isDown) {
		self.downOrigin = self.origin;
	}
}

testloop(){
	self endon("disconnect");
}

Callback_PlayerLastStand( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	level scripts\players\_usables::removeUsable(self);
	
	self notify("downed");
	level notify("downed", self);

	//self.health = int(self.maxhealth / 4);
	self setDown(true);
	self.isTargetable = false;
	
	// Removes a carrying object (turret, barrel, etc.) on down
	// if( isDefined( self.carryObj ) ){
		// self.carryObj delete();
		// self enableweapons();
		// self.canUse = true;
	// }
	
	self scripts\players\_usables::usableAbort();
	
	self.lastStandWeapons = self getweaponslist();
	self.lastStandAmmoStock = [];
	self.lastStandAmmoClip = [];
	for( i = 0; i < self.lastStandWeapons.size; i++ )
	{
		self.lastStandAmmoClip[i] = self getWeaponAmmoClip(self.lastStandWeapons[i]);
		self.lastStandAmmoStock[i] = self getWeaponAmmoStock(self.lastStandWeapons[i]);
	}
	
	self.lastStandWeapon = self GetCurrentWeapon();
	
	self setclientdvars("ui_hintstring", "", "ui_specialtext", "^1Special Unavailable");
	self.hinttext.alpha = 0;
	
	// level scripts\players\_usables::addUsable(self, "revive", "Hold [^3USE^7] to revive", 96);
	level scripts\players\_usables::addUsable(self, "revive", &"USE_REVIVE", 96);
	
	self thread compassBlinkMe();
	iPrintln( self.name + " ^7is down!" );
	self.deaths++;
	self.stats["deaths"]++;
	self.isAlive = false;
	self.stats["lastDowntime"] = getTime();
	self setStatusIcon("icon_down");
	
	self removeTimers();
	
	//self usableAbort();
	
	self.health = 10;
	self updateHealthHud(0);
	
	// Play down-sound
	self playsound( "self_down" );
	// self iprintln("Playing DOWN sound");
	
	weaponslist = self getweaponslist();
	for( i = 0; i < weaponslist.size; i++ )
	{
		weapon = weaponslist[i];
		
		if ( weapon == self.secondary  ) //scripts\players\_weapons::isPistol( weapon )
		{
			self switchtoweapon(weapon);
			continue;
		}
		else
		self takeweapon(weapon);
	}
		
	self scripts\players\_abilities::stopActiveAbility();
	self setclientdvar("ui_specialrecharge", 0);
}

compassBlinkMe(){ // Makes the playersymbol blink in "!" signs to signalize that this player is currently down

	self endon("revived");
	self endon("disconnect");
	self endon("death");
	self endon("spawned");
	while(1){
		self pingPlayer();
		wait 3;
	}
}

restoreAmmo()
{
	weapons = self getweaponslist();
	for( i = 0; i < weapons.size; i++ )
	{
		if (self scripts\players\_weapons::canRestoreAmmo(weapons[i])) {
			self GiveMaxAmmo(weapons[i]);
			self setWeaponAmmoClip(weapons[i], weaponClipSize(weapons[i]));
		}
	}
}

hasFullAmmo()
{
	weapons = self getweaponslist();
	for( i = 0; i < weapons.size; i++ )
	{
		if(isWeaponClipOnly(weapons[i])){
			if(self GetAmmoCount(weapons[i]) != WeaponMaxAmmo(weapons[i]))
				return false;
		}
		else if (self scripts\players\_weapons::canRestoreAmmo(weapons[i]) && ( self GetFractionMaxAmmo(weapons[i]) != 1 || weaponClipSize( weapons[i] ) != self GetWeaponAmmoClip( weapons[i] ) ))
			return false;
	}
	return true;
}

onPlayerDisconnect(){
	self.stats["name"] = self.name;
	self.persData.stats = self.stats;
}

onPlayerConnect()
{
	if (level.gameEnded)
	self.sessionstate = "intermission";
	
	self.isObj = false;
	self.useObjects = [];
	self.class = "none";
	self.curClass = "none";
	self.isAlive = false;
	self.isActive = false;
	self.hasPlayed = false;
	self.nighvision = false;
	self.blur = 0;
	self.actionslotweapons = [];
	self setStatusIcon("icon_spec");

	self thread scripts\players\_persistence::restoreData();
	self thread scripts\players\_shop::playerSetupShop();
	self thread scripts\players\_rank::onPlayerConnect();
	self thread scripts\server\_environment::onPlayerConnect();
	
	waittillframeend;
	self setclientdvars("g_scriptMainMenu", game["menu_class"], "cg_thirdperson", 0, "r_filmusetweaks", 0, "ui_class_ranks", (1 - level.dvar["game_class_ranks"]), "ui_specialrecharge", 0);
	self joinSpectator();
	//self thread scripts\players\_challenges::updateChallenges();
}

onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self endon("death");
	self endon("disconnect");
	if (self.isZombie)
	{
		self thread scripts\players\_infection::cleanupZombie();
		return;
	}
	// CLEANUP
	self cleanup();
	
	self endon("spawned");
	
	self notify("killed_player");

	if(self.sessionteam == "spectator")
		return;

	if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
		sMeansOfDeath = "MOD_HEAD_SHOT";

	if (level.dvar["zom_orbituary"])
	obituary(self, attacker, sWeapon, sMeansOfDeath);

	self.sessionstate = "dead";
	

	//if (isplayer(attacker) && attacker != self)
	//attacker.score++;
	//self.deaths++;
	
	body = self clonePlayer( deathAnimDuration );
	
	doRagdoll = true;
	
	if (doRagdoll)
	{
		if ( self isOnLadder() || self isMantling() )
		body startRagDoll();
				
		thread delayStartRagdoll( body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath );
	}
	
}

onPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{

	if( self.sessionteam == "spectator" )
		return;

	if( isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker.team == self.team )
	{
		if (self.isZombie)
		{
			self scripts\bots\_bots::Callback_BotDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
			updateHealthHud(self.health/self.maxhealth);
			return;
		}
		else if (!level.dvar["game_friendlyfire"] && eAttacker != self)
		{
			if (!eAttacker.isZombie)
			return;
		}
	}
	else
	{
		if (!level.hasReceivedDamage)
			level.hasReceivedDamage = 1;
	}
	if (self.god || level.godmode || ( self.spawnProtectionTime + (level.dvar["game_player_spawnprotection_time"]*1000) > getTime() && level.dvar["game_player_spawnprotection"]) )
		return;
	
	if ( self.isDown )
		return;


	if(!isDefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		if (sWeapon == "ak74u_acog_mp" || sWeapon == "barrett_acog_mp" || sWeapon == "at4_mp" || sWeapon == "rpg_mp" || issubstr(sMeansOfDeath, "GRENADE"))
			return;
		
		iDamage = int(iDamage * self.damageDoneMP);
		if (self.heavyArmor)
		{
			if (self.health / self.maxhealth >= .65)
			{
				iDamage = int(iDamage / 2);
				self thread screenFlash((0,0,.7), .35, .5);
			}
		}
		if(iDamage < 1)
			iDamage = 1;
			
		iDamage = int(iDamage * self.incdammod);
		
		if(isDefined(self.lastHurtTime) && (self.lastHurtTime < (getTime() - 1000) ) && iDamage < self.health ){
			self playsound("self_hurt");
			// self iprintln("Playing HURT sound");
			self.lastHurtTime = getTime();
		}
		// Medics take half damage while reviving
		if( self.reviveWill && isDefined(self.curEnt) && self.curEnt.type == "revive" && self.isBusy )
			iDamage = int(iDamage * 0.5);
			
		self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
		
		updateHealthHud(self.health/self.maxhealth);
	}
}

hasLowAmmo(){

	if( scripts\players\_weapons::canRestoreAmmo( self getCurrentWeapon() ) ){
		max = self GetFractionMaxAmmo( self getCurrentWeapon() );
		if(max <= 0.3)
			return true;
	}
	return false;
}

getBestPlayer(type, returns){
	if(!isDefined(type))
		return undefined;
		
	if(!isDefined(returns))
		returns = "player";
		
	player = undefined;
	amount = 0;
	amount2 = 999999999;
	for(i = 0; i < level.players.size; i++){
		if( level.players[i].isBot || !level.players[i].hasPlayed )
			continue;
			
		switch(type){
			case "kills":
				if(level.players[i].kills > amount){
					player = level.players[i];
					amount = level.players[i].kills;
				}
				break;
			case "deaths":
				if(level.players[i].deaths > amount && !isDefined(level.players[i].statsSurvivorWinner)){
					player = level.players[i];
					amount = level.players[i].deaths;
				}
				break;
			case "assists":
				if(level.players[i].assists > amount){
					player = level.players[i];
					amount = level.players[i].assists;
				}
				break;
			case "downtime":
				if(level.players[i].stats["downtime"] > amount && level.players[i].stats["downtime"] > 1000){
					player = level.players[i];
					amount = level.players[i].stats["downtime"];
				}
				break;
			case "heals":
				if(level.players[i].stats["healsGiven"] > amount){
					player = level.players[i];
					amount = level.players[i].stats["healsGiven"];
				}
				break;
			case "ammo":
				if(level.players[i].stats["ammoGiven"] > amount){
					player = level.players[i];
					amount = level.players[i].stats["ammoGiven"];
				}
				break;
			case "timeplayed":
				if(level.players[i].stats["timeplayed"] > amount){
					player = level.players[i];
					// Workaround for server-initiate delay
					if(level.players[i].stats["timeplayed"] > (level.gameEndTime - level.startTime) )
						amount = level.gameEndTime - level.startTime;
					else
						amount = level.players[i].stats["timeplayed"];
				}
				break;
			case "damagedealt":
				if(level.players[i].stats["damageDealt"] > amount){
					player = level.players[i];
					amount = level.players[i].stats["damageDealt"];
				}
				break;
			case "damagedealtToBoss":
				if(level.players[i].stats["damageDealtToBoss"] > amount){
					player = level.players[i];
					amount = level.players[i].stats["damageDealtToBoss"];
				}
				break;
			case "turretkills":
				if(level.players[i].stats["turretKills"] > amount){
					player = level.players[i];
					amount = level.players[i].stats["turretKills"];
				}
				break;
			case "upgradepointsspent":
				if(level.players[i].stats["upgradepointsSpent"] > amount){
					player = level.players[i];
					amount = level.players[i].stats["upgradepointsSpent"];
				}
				break;
			case "upgradepoints":
				if(level.players[i].points > amount){
					player = level.players[i];
					amount = level.players[i].points;
				}
				break;
			case "explosivekills":
				if(level.players[i].stats["explosiveKills"] > amount){
					player = level.players[i];
					amount = level.players[i].stats["explosiveKills"];
				}
				break;
			case "knifekills":
				if(level.players[i].stats["knifeKills"] > amount){
					player = level.players[i];
					amount = level.players[i].stats["knifeKills"];
				}
				break;
			case "survivor":
				if(level.players[i].deaths < amount2 && !isDefined(level.players[i].statsDeathsWinner) ){
					player = level.players[i];
					amount2 = level.players[i].deaths;
				}
				break;
			case "zombiefied":
				if(level.players[i].stats["timesZombie"] > amount){
					player = level.players[i];
					amount2 = level.players[i].stats["timesZombie"];
				}
				break;
			case "ignitions":
				if(level.players[i].stats["ignitions"] > amount){
					player = level.players[i];
					amount2 = level.players[i].stats["ignitions"];
				}
				break;
			case "poisons":
				if(level.players[i].stats["poisons"] > amount){
					player = level.players[i];
					amount2 = level.players[i].stats["poisons"];
				}
				break;
			case "headshots":
				if(level.players[i].stats["headshotKills"] > amount){
					player = level.players[i];
					amount2 = level.players[i].stats["headshotKills"];
				}
				break;
			case "barriers":
				if(level.players[i].stats["barriersRestored"] > amount){
					player = level.players[i];
					amount2 = level.players[i].stats["barriersRestored"];
				}
				break;
			case "firstminigun":
				if(isDefined(level.gotFirstMinigun)){
					player = level.gotFirstMinigun;
					amount = "";
				}
				break;
			case "moredeathsthankills":
				if(level.players[i].deaths > level.players[i].kills)
					if(level.players[i].kills > 0){ // DO NOT DIVIDE BY 0!
						if( (level.players[i].deaths / level.players[i].kills) > amount) // We want the person with most deaths per kill, in case there is more than 1 guy on the Srv with Deaths > Kills
						{
							player = level.players[i];
							amount = "";
						}
					}
					else if(!isDefined(player)){ // In case there is a player with 0 Kills and more than 0 deaths, but no other player on the Server with Deaths > Kills, still give him the award, even though he has 0 Kills
							player = level.players[i];
					}
				break;
			default:
				break;
		}
	}
	if(returns == "player"){
		if(type == "deaths" && isDefined(player))
			player.statsDeathsWinner = true;
		if(type == "survivor" && isDefined(player))
			player.statsSurvivorWinner = true;
		return player;
	}
	else if (returns == "amount"){
		if(amount2 != 999999999)
			return amount2;
		else
			return amount;
	}
	iprintlnbold("^1ERROR: ^7Invalid use of getBestPlayer()");
	return undefined;
}

watchHPandAmmo()
{
	self endon("death");
	self endon("disconnect");
	
	if( !isDefined( self.overwriteHeadicon ) )
		self.overwriteHeadicon = "";
		
	while( 1 ){
		wait 0.5;
		if( !self.infected )
		{
			if( self.isDown ){
				if( self.headicon != self.overwriteHeadicon )
					self.headicon = self.overwriteHeadicon;
				continue;
			}
			if( self.health <= 40 ){
				if( self.headicon == self.overwriteHeadicon || self.headicon == "hud_icon_low_ammo" )
				{
					self.headicon = "hud_icon_lowhp";
					continue;
				}

				if( self.headicon != "hud_icon_low_ammo" && self hasLowAmmo() )
					self.headicon = "hud_icon_low_ammo";
				else
					self.headicon = self.overwriteHeadicon;
				continue;
			}
			else if( self.health <= 75 ){
				if( self.headicon != "hud_icon_lowhp" ){
					self.headicon = "hud_icon_lowhp";
					continue;
				}

				if( self.headicon != "hud_icon_low_ammo" && self hasLowAmmo() )
					self.headicon = "hud_icon_low_ammo";
					
				continue;
			}
			else if( self hasLowAmmo() ){
				self.headicon = "hud_icon_low_ammo";
				continue;
			}
			
			// Will only get here if person doesn't need a headicon, if he has one, remove it
			if ( self.headicon != self.overwriteHeadicon )
				self.headicon = self.overwriteHeadicon;
		}
	}
}

doAreaDamage(range, damage, attacker)
{
	for (i=0; i<=level.bots.size; i++)
	{
		target = level.bots[i];
		if (isdefined(target) && isalive(target))
		{
			distance = distance(self.origin, target.origin);
			if (isDefined(distance) && distance < range)
			{
				target.isPlayer = true;
				target.entity = target;
				target damageEnt(
					self, // eInflictor = the entity that causes the damage (e.g. a claymore)
					attacker, // eAttacker = the player that is attacking
					damage, // iDamage = the amount of damage to do
					"MOD_EXPLOSIVE", // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
					"none", // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
					self.origin, // damagepos = the position damage is coming from 
					vectorNormalize(target.origin-self.origin)
				);
			}
		}
	}
}

cleanup() // CLEANUP ON DEATH (SPEC) OR DISCONNECT
{
	if ( isDefined(self.isDown) && self.isDown )
		scripts\players\_usables::removeUsable(self);
		
	self scripts\players\_usables::usableAbort();
	self.actionslotweapons = [];
		
	if ( isDefined(self.infection_overlay) )
		self.infection_overlay destroy();
		
	if ( isDefined(self.tombEnt) )
		self.tombEnt delete();
	
	if( isDefined(self.armored_hud) )
		self.armored_hud destroy();
	
	self.headicon = "";
	self setStatusIcon("");
	
	self.isTargetable = false;
	
	level scripts\players\_usables::removeUsable(self);
	self scripts\players\_usables::usableAbort();
	
	self destroyProgressBar();
	
	self removeTimers();
	
	self.hasRadar = false;
	self setclientdvars("r_filmusetweaks", 0, "ui_upgradetext", "", "ui_specialtext", "", "cg_draw2d", 1, "g_compassShowEnemies", 0, "ui_uav_client", 0, "ui_wavetext", "", "ui_waveprogress", 0, "ui_spawnqueue", "");
	if (self.isActive)
	{
		self.isActive = false;
		if (self.isAlive)
		{
			self.isAlive = false;
			
			if (self.primary!="none"){
				self.persData.primaryAmmoClip = self getweaponammoclip(self.primary);
				self.persData.primaryAmmoStock = self getweaponammostock(self.primary);
			}
			if (self.secondary!="none"){
				self.persData.secondaryAmmoClip = self getweaponammoclip(self.secondary);
				self.persData.secondaryAmmoStock = self getweaponammostock(self.secondary);
			}
			if (self.extra!="none"){
				self.persData.extraAmmoClip = self getweaponammoclip(self.extra);
				self.persData.extraAmmoStock = self getweaponammostock(self.extra);
			}
		
		}
		
	}
	
	self notify("end_trance");
	self updateHealthHud(-1);
	self flashlightOff();
	self unfreezePlayerForRoundEnd();
	if(isDefined(level.cantPayLC) && arrayContains(level.cantPayLC, self))
		level.cantPayLC = removeFromArray(level.cantPayLC, self);
}

addToJoinQueue(){
	if( !arrayContains(level.joinQueue, self) ){ // See if to-be-added player is already in the queue
		level.joinQueue[level.joinQueue.size] = self;
	}
	self setclientdvar("ui_spawnqueue", "@QUEUE_AWAITING_SPAWN_" + allToUpper(self.class));
}

spawnJoinQueue(){
	level notify("spawn_queue");
	spawners = [];
	for(i = 0; i < level.joinQueue.size; i++){
		player = level.joinQueue[i];
		level.joinQueue = removeFromArray(level.joinQueue, player);
		if( isReallyPlaying(player) ){
			logPrint("We tried to spawn someone from the Spawnqueue who is already playing: " + player.name + "\n");
			iprintln("We tried to spawn someone from the Spawnqueue who is already playing: " + player.name);
			continue;
		}
			
		// if(player.sessionteam != "allies")
			// player joinAllies();
			
		player thread spawnPlayer(true);
		spawners[spawners.size] = player;
	}
	if(spawners.size > 0){ // Put out some names in the bottom left corner to inform people who has been spawned by the queue
		string = "^3";
		have = "have";
		for(i = 0; i < spawners.size; i++){
			string += spawners[i].name + "^7 as ^3" + ( spawners[i] getFullClassName() ) + "^7, ^3"; 
		}
		string = getSubStr(string, 0, string.size-4);
		if( i <= 1 )
			have = "has";
		string += " " + have + " joined the fight!";
		iprintln(string);
	}
}

/* Spawn the players in certain situations and in certain states of the waves */
spawnJoinQueueLoop(){
	level endon("wave_finished");
	level endon("game_ended");
		
	if( level.currentType == "boss" || level.waveSize < 20 ){
		while(1){
			wait 180;
			spawnJoinQueue();
		}
	}
	
	zombiesKilled = 0;
	
	if(level.waveSize <= 100)
		intersections = 50;
	else if(level.waveSize > 100 && level.waveSize < 300)
		intersections = 70;
	else
		intersections = 100;
		
	while(zombiesKilled < level.waveSize){
		level waittill("bot_killed");
		zombiesKilled++;
		if(zombiesKilled % intersections == 0){
			// iprintln("Trying to spawn the queue!");
			spawnJoinQueue();
		}
	}
}

spawnPlayer(forceSpawn)
{
	if( !isDefined(forceSpawn) )
		forceSpawn = false;
		
	if(!forceSpawn){
		if ( level.gameEnded )
			return;
	//	self endon("disconnect");
		
		if( self.sessionteam == "spectator" || arrayContains(level.joinQueue, self) )
			return;
		
		if ( !level.intermission && level.activePlayers > 2 && level.dvar["game_enable_join_queue"] )
		{
			self addToJoinQueue();
			self iprintlnbold("You have been put into an automated joining queue.");
			self iprintlnbold("You will join soon! Just be patient ;)");
			return;
		}
	}
	self notify("spawned");
	
	
	// Setting neccessary variables
	self.team = self.pers["team"];
	self.sessionteam = self.team;
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.health = 100;
	self.headicon = "";
		
	self.isPlayer = true;
	if( self.persData.hasPlayed ){ // He played already, but disconnected during current map
		self.stats = self.persData.stats;
		self.hasPlayed = true;
	}
	else if( !self.hasPlayed ){ // Initiate first time stats
		self.persData.stats = self.stats;
		self.hasPlayed = true;
		self.persData.hasPlayed = true;
	}
	else{
		self.stats["playtimeStart"] = getTime() - 5500;
	}
	
	self.upgradeHudPoints = 0;
	
	self giveDelayedUpgradepoints();
	
	self.spawnProtectionTime = getTime();
	self.lastBossHit = undefined;
	self.fireCatchCount = 0;
	self.hasDoneCombat = false;
	self.canHaveStealth = true;
	self.visible = true;
	self.isTargetable = true;
	self.inTrance = false;
	self.trance = "";
	self.isDown = false;
	self.isZombie = false;
	self.isBot = false;
	self.isBusy = false;
	self.hasParachute = false;
	self.isObj = false;
	self.isParachuting = false;
	self.god = false;
	self.infected = false;
	self.isActive = true;
	self.canUse = true;
	self.entoxicated = false;
	self.onTurret = false;
	self.hasRadar = false;
 	self.tweaksOverride = 0;
	self.tweaksPermanent = 0;
	self.tweakBrightness = "0.25";
	self.tweakContrast = "1.4";
	self.tweakDarkTint = "1 1 1";
	self.tweakLightTint = "1 1 1";
	self.tweakDesaturation = "0";
	self.tweakInvert = "0";
	self.tweakFovScale = 1;
	self.canTeleport = true;
	self.canUseSpecial = true;
	self.lastHurtTime = getTime();
	self.incdammod = 1;
	self.c4Array = [];
	self setStatusIcon("icon_"+self.class);
	
	resettimeout();

	// Getting spawn loc and spawning
	if ( level.playerspawns == "" )
		spawn = getRandomTdmSpawn();
	else
		spawn = getRandomEntity(level.playerspawns);

	origin = spawn.origin;
	angles = spawn.angles;

	self spawn( origin, angles );
	
	self.curClass = self.class;
	
	if (self.persData.class != self.curClass){
		resetUnlocks();
		self.specialRecharge = 100; // Fully load the special on spawn when player has changed class
		self.persData.specialRecharge = self.specialRecharge;
	}

	self.persData.class = self.curClass;
	

	
	

	// Setting random player class model
	self scripts\players\_playermodels::setPlayerClassModel(self.curClass);
	
	self setclientdvars("cg_thirdperson", 0, "ui_upgradetext", "Upgrade Points: " + int(self.points), "ui_specialtext", "^1Special Unavailable", "ui_specialrecharge", 1, "ui_spawnqueue", "");
	
	self scripts\players\_abilities::loadClassAbilities(self.curClass);
	
	self SetMoveSpeedScale(self.speed);

	self.health = self.maxhealth;
	self updateHealthHud(1);
	
	
	waittillframeend;
	
	if (self.nighvision)
	self setActionSlot( 1, "nightvision" );

	
	// Give weapons
	self scripts\players\_weapons::initPlayerWeapons();
	self scripts\players\_weapons::givePlayerWeapons();

	self notify("spawned_player");
	level notify("spawned_player", self);
	
	self thread scripts\players\_usables::checkForUsableObjects();
	
	self thread scripts\players\_weapons::watchWeaponUsage();
	self thread scripts\players\_weapons::watchWeaponSwitching();
	self thread scripts\players\_weapons::watchThrowable();
	self thread scripts\players\_weapons::watchMonkey();
	self thread scripts\players\_claymore::init();
	self thread scripts\players\_rank::onPlayerSpawned();
	self thread scripts\players\_abilities::watchSpecialAbility();
	
	self thread scripts\server\_welcome::onPlayerSpawn();
	self thread scripts\players\_spree::onPlayerSpawn();
	
	self thread testloop();
	
	self thread watchHPandAmmo();
	if(level.flashlightEnabled)
		self thread flashlightOn(true);
		
	if( level.freezePlayers )
		self thread freezePlayerForRoundEnd();
		
	if( level.disableWeapons )
		self disableWeapons();
	
	self.isAlive = true;
	level notify("spawned", self);
	level notify("update_classcounts");
}

flashlightForAll(on){ // Whether it should be turned on or off
	if(!isDefined(on))
		return;

	players = getentarray("player", "classname");
	for (i = 0; i<players.size; i++)
	{
		if( !isReallyPlaying(players[i]) )
			continue;
		if(on)
			players[i] thread flashlightOn();
		else
			players[i] thread flashlightOff();
	}
}

flashlightOn(noWait)
{
	if(isDefined(self.flashlight) || self.sessionteam != "allies")
		return;
	if(!isDefined(noWait))
		wait randomfloat(6); // For some randomness
	else
		wait 0.1;
	self.flashlight = undefined;
	self.flashlight = spawn( "script_model", self getTagOrigin( "j_spinelower" ) );
	self.flashlight setModel( "tag_origin" );
	wait 0.05;
	PlayFXOnTag( level.flashlightGlow, self.flashlight, "tag_origin" );
	self.flashlight LinkTo( self );
	self playsound("flashlight_on");
	self thread removeLightOnDeath();
}

flashlightOff()
{
	if(!isDefined(self.flashlight))
		return;
	
	self.flashlight delete();
}

removeLightOnDeath()
{
	self endon( "disconnect" );
	self endon( "join_spectator" );
	self endon( "downed" );

	self waittill( "death" );
	
	if( isDefined( self.flashlight ) )
		self.flashlight delete();
}

reportMyCoordinates(){

	origin = self getOrigin();
	angle = self getPlayerAngles();
	
	mapname = getDvar("mapname");
	
	logPrint("GETENDVIEW;" + origin[0] + "," + origin[1] + "," + origin[2] + ";" + angle[0] + "," + angle[1] + "," + angle[2] + " for " + mapname + "\n");
	self iprintlnbold("Screenshot this for Luk:");
	self iprintlnbold(origin[0] + "," + origin[1] + "," + origin[2] + ";" + angle[0] + "," + angle[1] + "," + angle[2]);
	self iprintlnbold("Map: " + mapname);
}

resetUnlocks() {
	self.unlock["primary"] = 0;
	self.unlock["secondary"] = 0;
	self.unlock["extra"] = 0;
	self.persData.unlock["primary"] = 0;
	self.persData.unlock["secondary"] = 0;
	self.persData.unlock["extra"] = 0;
	
	self.persData.primary =  getdvar("surv_"+self.class+"_unlockprimary"+self.unlock["primary"]);
	self.persData.secondary = getdvar("surv_"+self.class+"_unlocksecondary"+self.unlock["secondary"]);
	self.persData.extra = getdvar( "surv_"+self.class+"_extra_unlock"+(self.unlock["extra"]+1) );

	
	self.persData.primaryAmmoClip = WeaponClipSize(self.persData.primary);
	self.persData.primaryAmmoStock = WeaponMaxAmmo(self.persData.primary);
	
	self.persData.secondaryAmmoClip = WeaponClipSize(self.persData.secondary);
	self.persData.secondaryAmmoStock = WeaponMaxAmmo(self.persData.secondary);
	
	self.persData.extraAmmoClip = 0;
	self.persData.extraAmmoStock = 0;
	
}


setStatusIcon(icon)
{
	self.statusicon = icon;
}

bounce(direction)
{
	self endon("disconnect");
	self endon("death");
	for (i=0; i<2; i++)
	{
		self.health = (self.health + 899);
		self finishPlayerDamage(self, self, 899, 0, "MOD_PROJECTILE", "rpg_mp", direction, direction, "none", 0);
		wait 0.05;
	}
}

fullHeal(speed)
{
	self endon("death");
	self endon("disconnect");
	self endon("downed");
	
	while (1)
	{
		self.health += speed;
		if(self.health >= self.maxhealth){
			self.health = self.maxhealth;
			updateHealthHud(1);
			break;
		}
		updateHealthHud(self.health/self.maxhealth);
		wait .1;
	}
}

healPlayer(amount){
	amount = int(amount);
	self.health += amount;
	if(self.health > self.maxhealth)
		self.health = self.maxhealth;
		
	self thread healthFeedback();
	updateHealthHud(self.health/self.maxhealth);
}

incUpgradePoints(inc)
{
	if ( !isdefined( inc ) || ( inc < 1 && inc > -1 ) )
		return;
		
	self.points += inc;
	self.persData.points += inc;
	//iprintlnbold(self.persData.points);
	if (inc > 0){
		self.score += inc;
		self.stats["score"] = self.score;
		self.stats["upgradepointsReceived"] += inc;
	}
	if(inc < 0)
		self.stats["upgradepointsSpent"] += (inc * -1);
	self setclientdvar("ui_upgradetext", "Upgrade Points: " + int(self.points) );
	thread upgradeHud(inc);
}

/* For each wave missed, we give the players more upgradepoints (if enabled) */
giveDelayedUpgradepoints(){

	if( ( level.currentWave - self.lastPlayedWave ) <= 1 )
		return;

	if( level.dvar["game_delayed_upgradepoints"] ){
		self incUpgradePoints( ((level.currentWave - self.lastPlayedWave - 1) * level.dvar["game_delayed_upgradepoints_amount"]) );
	}
}

getTotalUpgradePoints(){
	totalpoints = 0;
	for(i = 0; i < level.players.size; i++){
		player = level.players[i];
		if(player.isActive)
			totalpoints += player.stats["upgradepointsReceived"];
	}
	return totalpoints;
}

getAverageUpgradePoints(){
	total = 0;
	playercount = 0;
	for(i = 0; i < level.players.size; i++){
		player = level.players[i];
		if(player.isActive){
			total += player.points;
			playercount++;
		}
	}
	return int(total/playercount);
}

getRemainingUpgradePoints(){
	totalpoints = 0;
	for(i = 0; i < level.players.size; i++){
		player = level.players[i];
		if(player.isActive)
			totalpoints += player.points;
	}
	return totalpoints;
}

joinAllies()
{
	if (level.gameEnded)
	return;
	
	if (self.pers["team"] != "allies")
	{
		//if (isalive(self))
		//self suicide();
		
		self.sessionteam = "allies";

		self setclientdvars("g_scriptMainMenu", game["menu_class"]);
		
		self.pers["team"] = "allies";
		
		//self spawnPlayer();
	}
}

removeFromQueue(){
	self setclientdvars("cg_thirdperson", 0, "ui_spawnqueue", "");
	if( arrayContains(level.joinQueue, self) ){
		level.joinQueue = removeFromArray(level.joinQueue, self);
		self iprintlnbold("You have been removed from the queue!");

		self joinSpectator();
	}
}

joinSpectator()
{
	if (level.gameEnded)
	return;
	
	if (self.pers["team"] != "spectator")
	{
		if ( isalive(self) ){
			// logPrint("Updated your lastPlayedWave, " + self.name + ", it is " + level.currentWave + "\n");
			self.persData.stats = self.stats;
			self.lastPlayedWave = level.currentWave;
			self.persData.lastPlayedWave = self.lastPlayedWave;
			self suicide();
		}
			
		self cleanup();
		if ( isdefined(self.carryObj) )
			self.carryObj delete();
		
		self.isActive = false;
		self.isZombie = false;
		
		self notify("join_spectator");
		level notify("spawned_spectator", self);
		
		self.pers["team"] = "spectator";
		self.sessionteam = "spectator";
		self.sessionstate = "spectator";
		
		spawns = getentarray("mp_global_intermission", "classname");
		if(spawns.size > 0){
			spawn = spawns[randomint(spawns.size)];
			origin = spawn.origin;
			angles = spawn.angles;
		}
		else{
			origin = (0,50,50);
			angles = (0,0,0);
		}
		
		// new time = new time + (currentTime - timeAtWhichWeStarted)
		if(self.hasPlayed)
			self.stats["timeplayed"] += getTime() - self.stats["playtimeStart"];
		spawnSpectator(origin, angles);
	}
	if(self.hasPlayed)
		level notify("update_classcounts");
	self thread giveCoordinatesToSpec();
}

giveCoordinatesToSpec(){
	self notify("kill_coordinates");
	self endon("disconnect");
	self endon("spawned");
	self endon("kill_coordinates");
	
	wait .5;
	while(1){
		wait 1;
			if(self useButtonPressed()){
				wait 1;
				if(self useButtonPressed()){
					wait 1;
					if(self useButtonPressed()){
						self reportMyCoordinates();
						wait 3;
					}
				}
			}
				
	}

}

spawnSpectator(origin, angles)
{

	self notify("spawned");

	resettimeout();

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.friendlydamage = undefined;
	
	self allowSpectateTeam("axis", !level.dvar["game_disable_spectating_bots"]);
	
	level notify("spawned_spectator", self);

	self spawn( origin, angles );
}

revive(by)
{
	if (level.gameEnded)
	return;
	// Give me back my weapons!
	self.isAlive = true;
	weapons = self.lastStandWeapons;
	
	ammoClip = self.lastStandAmmoClip;
	ammoStock = self.lastStandAmmoStock;
	
	keptWeapons = self getweaponslist();
	keptAmmoStock = [];
	keptAmmoClip = [];
	for( i = 0; i < keptWeapons.size; i++ )
	{
		
		keptAmmoClip[i] = self getWeaponAmmoClip(keptWeapons[i]);
		keptAmmoStock[i] = self getWeaponAmmoStock(keptWeapons[i]);
	}
	
	self takeallweapons();


	if (self.lastStandWeapon == "none")
	{
		if (weapons.size == 0)
		{
			if (keptWeapons.size != 0)
			self.lastStandWeapon = keptWeapons[0];
		}
		else 
		self.lastStandWeapon = weapons[0];
	}
	
	self spawn( self.origin, self.angles );
	
	for( i = 0; i < keptWeapons.size; i++ )
	{
		self giveweapon(keptWeapons[i]);
		self setWeaponAmmoClip(keptWeapons[i], keptAmmoClip[i]);
		self setWeaponAmmoStock(keptWeapons[i],  keptAmmoStock[i]);
	}
	for( i = 0; i < weapons.size; i++ )
	{
		if (!self HasWeapon(weapons[i]))
		{
			self giveweapon(weapons[i]);
			self setWeaponAmmoClip(weapons[i], ammoClip[i]);
			self setWeaponAmmoStock(weapons[i],  ammoStock[i]);
		}
	}
	
	self setspawnweapon(self.lastStandWeapon);
	self switchtoweapon(self.lastStandWeapon);
	
	
	list = self getweaponslist();
	
	
	// RELOADING PLAYER!
	self setDown(false);
	self.stats["downtime"] += getTime() - self.stats["lastDowntime"];
	level scripts\players\_usables::removeUsable(self);
	self.isTargetable = true;
	self notify("revived");
	
	if (self.infected)
	// level scripts\players\_usables::addUsable(self, "infected", "Press [^3USE^7] to cure", 96);
	level scripts\players\_usables::addUsable(self, "infected", &"USE_CURE", 96);
	
	self scripts\players\_abilities::loadClassAbilities(self.curClass);
	
	self setMoveSpeedScale(self.speed);
	self.health = self.maxhealth;
	
	self updateHealthHud(1);
	// self scripts\players\_abilities::resetSpecial();
	self setclientdvar("ui_specialrecharge", self.specialRecharge/100);
	
	setStatusIcon("icon_"+self.class);
	
	self thread scripts\players\_usables::checkForUsableObjects();
	
	self thread scripts\players\_weapons::watchWeaponUsage();
	self thread scripts\players\_weapons::watchWeaponSwitching();
	self thread scripts\players\_abilities::watchSpecialAbility();
	// Properly start Monkey Bomb countdown again
	// if(self hasWeapon(level.weapons["flash"]) && self GetWeaponAmmoClip(level.weapons["flash"]) == 0)
		// self thread scripts\players\_abilities::restoreMonkey(level.special["monkey_bomb"]["recharge_time"]);
	// Setting the first-in-queue weapon to be the actionslot weapon
	if(self.actionslotweapons.size > 0)
		self setActionSlot( 4, "weapon", self.actionslotweapons[0] );
	
	if(isDefined(by)){
		self playsound("self_thanks_revived");
		self.spawnProtectionTime = getTime();
		if( isReallyPlaying(by) && by.curClass == "medic" )
			by scripts\players\_abilities::rechargeSpecial(8);
		by.stats["revives"]++;
	}
	wait .05;
	self switchtoweapon(self.lastStandWeapon);
}

flickeringHud(duration){
	self endon("disconnect");
	self endon("death");
	while(getTime() < duration){
		ran1 = randomint(2);
		
		if(ran1 == 0)
			self setclientdvar("cg_draw2d", 0);
		else
			self setclientdvar("cg_draw2d", 1);
			
		wait 0.05 + randomfloat(0.2);
	}
	self setclientdvar("cg_draw2d", 1);
}

/* Updates player counts twice a second because I'm too stupid to actually do this with kill/disconnect/spawn events */
updateActiveAliveCounts(){
	level endon("game_ended");
	level notify("update_active_alive_counts");
	level endon("update_active_alive_counts");
	while(1){
		level.activePlayers = 0;
		level.alivePlayers = 0;
		level.alivePlayersArray = undefined;
		level.activePlayersArray = undefined;
		level.alivePlayersArray = [];
		level.activePlayersArray = [];
		for(i = 0; i < level.players.size; i++){
			p = level.players[i];
			if( !isReallyPlaying ( p ) )
				continue;
			if( p.isActive ){
				level.activePlayers++;
				level.activePlayersArray[level.activePlayersArray.size] = p;
				if( p.isAlive ){
					level.alivePlayers++;
					level.alivePlayersArray[level.alivePlayersArray.size] = p;
				}
			}
		}
		wait 0.5;
		if( level.lastAlivePlayers > 1 && level.activePlayers > 2 && level.alivePlayers == 1 )
			level.alivePlayersArray[0] thread [[level.callbackLastManStanding]]();
		level.lastAlivePlayers = level.alivePlayers;
	}
}