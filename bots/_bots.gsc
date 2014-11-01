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

#include scripts\include\waypoints;
#include scripts\include\entities;
#include scripts\include\physics;
#include scripts\include\hud;
init()
{
	precache();
	
	loadWaypoints();
	
	level.bots = [];
	level.botsAlive = 0;
	level.zomInterval = .2;
	level.zomSpeedScale = .2/level.zomInterval;
	level.zomPreference = 64 * 64;
	level.zombieSight = 2048;
	level.zomIdleBehavior = "";
	level.zomTarget = "player_closest";
	level.loadBots = 1;
	level.botsLoaded = false;
	level.zomTargets = [];
	level.slowBots = 1;
	level.lastBossJump = 0;
	level.nextBossJump = 0;
	level.freezeBots = false;
	level.silenceZombies = false;
	
	level.botsLookingForWaypoints = 0;
	
	if( getDvar("max_waypoint_bots") == "" )
		setDvar("max_waypoint_bots", 1);
	if( getDvar("debug_max_waypoint_bots") == "" )
		setDvar("debug_max_waypoint_bots", 0);
	
	
	wait 1;
	if (level.loadBots)
		loadBots(level.dvar["bot_count"]);
	
	scripts\bots\_types::initZomTypes();
	
	scripts\bots\_types::initZomModels();
	
	level.botsLoaded = true;
	
	thread onMonkeyExplosion();
	thread scripts\bots\_debug::init();
	
	//thread drawWP();
	
}


precache()
{
	precacheitem("bot_zombie_walk_mp");
	precacheitem("bot_zombie_stand_mp");
	precacheitem("bot_zombie_run_mp");
	precacheitem("bot_zombie_melee_mp");
	precacheitem("bot_dog_idle_mp");
	precacheitem("bot_dog_run_mp");
	precacheitem("brick_blaster_mp"); // Melee 1
	precacheitem("defaultweapon_mp");
	
	precachemodel("body_sp_russian_loyalist_a_dead");
	precachemodel("body_sp_russian_loyalist_b_dead");
	precachemodel("body_sp_russian_loyalist_c_dead");
	precachemodel("body_sp_russian_loyalist_d_dead");
	
	precachemodel("bo_quad");
	
	precachemodel("cyclops");
	
	precachemodel("head_sp_loyalist_alex_helmet_body_a_dead");
	precachemodel("head_sp_loyalist_mackey_hat_body_b_dead");
	precachemodel("head_sp_loyalist_josh_helmet_body_c_dead");
	precachemodel("head_sp_loyalist_tom_hat_body_d_dead");
	
	precachemodel("bo1_c_viet_zombie_napalm"); // LOD FIXED
	precachemodel("bo1_c_viet_zombie_napalm_head"); // LOD FIXED
	
	precachemodel("bo1_c_viet_zombie_female"); // LOD FIXED
	precachemodel("bo1_c_viet_zombie_female_head"); // LOD FIXED
	precachemodel("bo1_c_viet_zombie_nva1_body"); // LOD FIXED
	precachemodel("bo1_c_viet_zombie_nva1_head1"); // LOD FIXED
	precachemodel("bo1_c_zom_cosmo_cosmonaut_body"); // FIXED MAX. LOD DISTANCE
	precachemodel("bo1_c_zom_cosmo_head1"); // FIXED MAX. LOD DISTANCE
	precachemodel("bo1_c_zom_cosmo_head2"); // FIXED MAX. LOD DISTANCE
	precachemodel("bo1_c_zom_cosmo_head3"); // FIXED MAX. LOD DISTANCE
	precachemodel("bo1_c_zom_cosmo_head4"); // FIXED MAX. LOD DISTANCE
	precachemodel("bo1_c_usa_pent_zombie_officeworker_body"); // LOD FIXED
	precachemodel("bo1_c_zom_head_1"); // LOD FIXED
	precachemodel("bo1_c_zom_head_2"); // LOD FIXED
	precachemodel("bo1_c_zom_head_3"); // LOD FIXED
	precachemodel("bo1_c_zom_head_4"); // LOD FIXED
	precachemodel("bo1_c_ger_zombie_head1"); // LOD FIXED
	precachemodel("bo1_c_ger_zombie_head2"); // LOD FIXED
	precachemodel("bo1_c_ger_zombie_head3"); // LOD FIXED
	precachemodel("bo1_c_ger_zombie_head4"); // LOD FIXED
	precachemodel("bo1_c_usa_pent_zombie_scientist_body"); // LOD FIXED
	precachemodel("bo1_c_usa_pent_zombie_militarypolice_body"); // LOD FIXED
	precachemodel("bo1_c_zom_cosmo_spetznaz_body"); // FIXED MAX. LOD DISTANCE
	// precachemodel("bo1_c_zom_george_romero_zombiefied_fb");
	precachemodel("zom_george_romero");
	
	precachemodel("player_sp_rig_empty");
	// precachemodel("skeleton");
	// precachemodel("bo2_c_zom_avagadro_fb");
	
	
	precachemodel("char_ger_honorgd_bodyz1_1");
	precachemodel("char_ger_honorgd_bodyz2_1");
	precachemodel("char_ger_honorgd_bodyz2_2");
	precachemodel("char_ger_honorgd_zombiehead1_1");
	precachemodel("char_ger_honorgd_zombiehead1_2");
	precachemodel("char_ger_honorgd_zombiehead1_3");
	precachemodel("char_ger_honorgd_zombiehead1_4");
	
	precachemodel("zombie_wolf");
	precachemodel("cyclops");
	
	precachemodel("tag_origin");
	
	PreCacheShellShock("boss");
	precacheshellshock("toxic_gas_mp");
	// precacheshellshock("frag_grenade_mp");
	
	level.burningFX = loadfx("fire/firelp_med_pm_atspawn");
	// level.burningdogFX = loadfx("fire/dog_onfire");
	level.bossFireFX = loadfx("fire/boss_onfire");
	level.bossShockwaveFX = loadfx("zombies/boss_shockwave");
	level.splatterFX = loadfx("impacts/zombie_crit_splatter_nograv");
	level.napalmTummyGlowFX = loadfx("misc/napalm_zombie_tummyglow");
	// level.lightningdogFX = loadfx("light/dog_lightning");
	level.toxicFX = loadfx("misc/toxic_gas");
	level.explodeFX = Loadfx("explosions/pyromaniac");
	level.soulFX = loadfx("misc/soul");
	level.groundSpawnFX = loadfx("misc/ground_rising");
	// level.cloudSpawnFX = loadfx("zombies/thunderspawn");
	level.soulspawnFX = loadfx("misc/soulspawn");
	level.incendiary_FX = loadfx("misc/zombie_incendiary_effect");
	level.poisoned_FX = loadfx("misc/zombie_poison_effect");
	level.eye_le_fx = loadfx("zombies/eye_glow_le");
	level.eye_ri_fx = loadfx("zombies/eye_glow_ri");
}

// LOADING BOTS

loadBots(amount)
{
	for ( i = 0; i < amount; i++ )
	{

		bot = addtestclient();
	
		if (!isdefined(bot)) {
			println("Could not add bot");
			i = i -1;
			wait 1;
			continue;
		}
		
		bot loadBot(); // No thread, wanna do this one by one.
	}
	level notify("bots_loaded");
}

loadBot()
{
	level.bots[level.bots.size] = self;

	self.isBot = true;
	self.hasSpawned = false;
	self.spawnPoint  = undefined;
	
	while(!isdefined(self.pers["team"])) // Wait till properly connected
	wait .05;
	
	self botJoinAxis();
	
	wait .1;
	self setStat(512, 100); // Yes we are indeed a bot
	self setrank(255, 0);
	self.linkObj = spawn("script_model", (0,0,0));
}

botJoinAxis()
{
	self.sessionteam = "axis";
		
	self.pers["team"] = "axis";
}

//SPAWNING BOTS
getAvailableBot()
{
	for (i=0; i< level.bots.size; i++)
	{
		bot = level.bots[i];
		if (bot.hasSpawned == false)
		return bot;
	}
}

spawnPartner(spawnpoint, bot){
	type = "boss";
	bot.hasSpawned = true;
	bot.currentTarget = undefined;
	bot.targetPosition = undefined;
	bot.type = type;
	bot.head = undefined;
	
	bot.team = bot.pers["team"];
	
	assert( isDefined(bot.team) );
	
	if( !isDefined(bot.team) ){
		bot.hasSpawned = false;
		return undefined;
	}
	
	bot.sessionteam = bot.team;
	bot.sessionstate = "playing";
	bot.spectatorclient = -1;
	bot.killcamentity = -1;
	bot.archivetime = 0;
	bot.psoffsettime = 0;
	bot.statusicon = "";
	bot.untargetable = true;
	bot.isZombie = false;
	bot.wasInfluencedByMonkeyBomb = false;
	bot.influencedByMonkeyBomb = undefined;
	bot.suicided = undefined;
	bot.damagePerLoc = [];
	bot scripts\bots\_types::loadZomStats(type);
	bot.incdammod = 1;
	bot.maxHealth = int( bot.maxHealth * level.dif_zomHPMod );
	
	bot.health = bot.maxHealth;
	
	bot.damagedBy = [];
	bot.myWaypoint = undefined;
	bot.underway = false;
	bot.canTeleport = true;
	bot.quake = false;
	bot.isOnFire = false;
	bot.isPoisoned = false;
	bot.playIdleSound = true;
	if( randomfloat(1) > bot.sprintChance )
		bot.sprinting = false;
	else
		bot.sprinting = true;
	
	bot scripts\bots\_types::loadAnimTree(type);
	
	bot.animWeapon = bot.animation["stand"];
	bot TakeAllWeapons();
	bot.pers["weapon"] = bot.animWeapon;
	bot giveweapon(bot.pers["weapon"]);
	bot givemaxammo(bot.pers["weapon"]);
	bot setspawnweapon(bot.pers["weapon"]);
	bot switchtoweapon(bot.pers["weapon"]);

	if (isdefined(spawnpoint.angles))
		bot spawn( spawnpoint.origin, spawnpoint.angles );
	else
		bot spawn( spawnpoint.origin, (0,0,0) );
	
	level.botsAlive++;
	
	wait 0.05;
	
	bot detachall();
	bot.head = "";
	bot setmodel("player_sp_rig_empty");
	
	
	bot freezeControls(true);
	
	bot.linkObj.origin = bot.origin;
	bot.linkObj.angles = bot.angles;
	
	
	wait 0.05;
	bot linkto(bot.parent.attachment);
	bot setanim("stand");
	
	bot thread rotateWithParent();
}

rotateWithParent(){
	self        endon("death");
	self.parent endon("death");
	level endon("wave_finished");
	level endon("game_ended");
	while( isDefined(self.parent) ){
		self setPlayerAngles(self.parent.angles);
		wait 0.05;
	}
}

spawnZombie(type, spawnpoint, bot)
{
	if (!isdefined(bot))
	{
		bot = getAvailableBot();
		
		if (!isdefined(bot))
		return undefined;
	}

	bot.hasSpawned = true;
	bot.currentTarget = undefined;
	bot.targetPosition = undefined;
	bot.type = type;
	bot.head = undefined;
	
	bot.team = bot.pers["team"];
	
	assert( isDefined(bot.team) );
	
	if( !isDefined(bot.team) ){
		bot.hasSpawned = false;
		return undefined;
	}
	
	bot.sessionteam = bot.team;
	bot.sessionstate = "playing";
	bot.spectatorclient = -1;
	bot.killcamentity = -1;
	bot.archivetime = 0;
	bot.psoffsettime = 0;
	bot.statusicon = "";
	bot.untargetable = false;
	bot.isZombie = false;
	bot.wasInfluencedByMonkeyBomb = false;
	bot.influencedByMonkeyBomb = undefined;
	bot.suicided = undefined;
	bot.damagePerLoc = [];
	
	bot scripts\bots\_types::loadZomStats(type);
	bot.incdammod = 1;
	if (!isdefined(bot.meleeSpeed))
	{
		iprintlnbold("ERROR");
		setdvar("error_0", type);
		setdvar("error_1", bot.name);
		wait 5;
	}
	bot.maxHealth = int( bot.maxHealth * level.dif_zomHPMod );
	
	bot.health = bot.maxHealth;
	
	bot.isDoingMelee = false;
	
	bot.damagedBy = [];
	
	bot.alertLevel = 0; // Has this zombie been alerted? 
	bot.myWaypoint = undefined;
	bot.underway = false;
	bot.canTeleport = true;
	bot.quake = false;
	bot.isOnFire = false;
	bot.isPoisoned = false;
	bot.playIdleSound = true;
	if( randomfloat(1) > bot.sprintChance )
		bot.sprinting = false;
	else
		bot.sprinting = true;
	
	bot scripts\bots\_types::loadAnimTree(type);
	
	bot.animWeapon = bot.animation["stand"];
	bot TakeAllWeapons();
	bot.pers["weapon"] = bot.animWeapon;
	bot giveweapon(bot.pers["weapon"]);
	bot givemaxammo(bot.pers["weapon"]);
	bot setspawnweapon(bot.pers["weapon"]);
	bot switchtoweapon(bot.pers["weapon"]);
	
	if (isdefined(spawnpoint.angles))
		bot spawn( spawnpoint.origin, spawnpoint.angles );
	else
		bot spawn( spawnpoint.origin, (0,0,0) );
	
	if( bot.type == "halfboss" )
		level.bossBulletCount++;
	
	level.botsAlive++;
	
	wait 0.05;
	
	
	bot scripts\bots\_types::loadZomModel(type);
	
	
	bot freezeControls(true);
	
	bot.linkObj.origin = bot.origin;
	bot.linkObj.angles = bot.angles;
	
	if ((bot.type != "tank" && bot.type != "boss") || (level.dvar["zom_spawnprot_tank"]))
	{
		if (level.dvar["zom_spawnprot"])
		{
			bot.incdammod = 0;
			bot thread endSpawnProt(level.dvar["zom_spawnprot_time"], level.dvar["zom_spawnprot_decrease"]);
		}
	}
	
	wait 0.05;
	bot scripts\bots\_types::onSpawn(type);
	
	bot linkto(bot.linkObj);
	
	bot zomGoIdle();
	
	bot thread zomMain();
	
	bot thread zomGroan();
	
	bot thread freezeBotOnLC();
	bot thread freezeBot();
	
	bot thread monkeyOverride();
	
	/*if (level.zomTarget != "")
	{
		if (level.zomTarget == "player_closest")
		{
			ent = bot getClosestPlayer();
			if (isdefined(ent))
			bot zomSetTarget(ent.origin);
		}
		else
		bot zomSetTarget(bot getClosestEntity(level.zomTarget).origin);
	}*/
	//if (isdefined(spawnpoint.target))
	//bot zomSetTarget(bot getRandomEntity(spawnpoint.target).origin);
	
	return bot;
	
}

endSpawnProt(time, decrease)
{
	self endon("death");
	
	if (decrease)
	{
		for (i=0; i<10; i++)
		{
			wait time/10;
			self.incdammod += .1;
		}
	}
	else
	{
		wait time;
		self.incdammod = 1;
	}
}

followTarget(target, arealDifference){
	self endon("death");
	target endon("death");
	
	if( !isDefined( arealDifference ) )
		arealDifference = (0,0,0);
	
	while( isDefined( self ) && isAlive( target ) ){
		self.origin = (target.origin + arealDifference);
		wait 0.05;
	}
}


// BOTS MAIN

Callback_BotDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if(!isAlive(self) || isDefined(self.damageoff) )
		return;
		
	if(!self scripts\bots\_types::onDamage(self.type, sMeansOfDeath, sWeapon, iDamage, eAttacker))
		return;
	if( isDefined( self.alertLevel )) self.alertLevel += 200;
	
	if (isdefined(eAttacker))
		if (isplayer(eAttacker))
		{
			// Check for insta-explosive grenades
			if( eAttacker.chargedGrenades ){
				if( sMeansofDeath == "MOD_IMPACT" && sWeapon == "frag_grenade_mp" ){
					eInflictor detonate();
					return;
				}
			}
			
			// Explosive Crossbow sticking to the zombie
			if( sMeansofDeath == "MOD_IMPACT" && sWeapon == "dragunov_acog_mp" ){
				eInflictor followTarget(self, ( eInflictor.origin - self.origin ) );
				return;
			}
			
			// Special Recharge Armored -> KNIFE
			if ( eAttacker.curClass == "armored" && !eAttacker.isDown ) {
				if ( sMeansOfDeath == "MOD_MELEE" ) {
					if (iDamage>self.health)
						eAttacker scripts\players\_abilities::rechargeSpecial(self.health/25);
					else
						eAttacker scripts\players\_abilities::rechargeSpecial(iDamage/25);
				}
			}
			
			if( !isDefined( iDamage ) || !isDefined( eAttacker scripts\players\_abilities::getDamageModifier(sWeapon, sMeansOfDeath, self, iDamage) ) || !isDefined( self.incdammod ) ){
				logPrint( "LUK_DEBUG; Definition: iDamage: " + isDefined(iDamage) + ", getDamageModifier: " + isDefined( eAttacker scripts\players\_abilities::getDamageModifier(sWeapon, sMeansOfDeath, self, iDamage) ) + ", self.incdammod: " + isDefined(self.incdammod) + ", weapon: " + sWeapon + "\n" );
				return;
			}
			
			iDamage = int( iDamage * eAttacker scripts\players\_abilities::getDamageModifier(sWeapon, sMeansOfDeath, self, iDamage) * self.incdammod);
			
			eAttacker notify("damaged_bot", self);
			
			if( isDefined( eInflictor.isTurret ) && eInflictor.isTurret && isDefined( eInflictor.owner ) )
				eAttacker scripts\players\_damagefeedback::updateTurretDamageFeedback();
			else
				eAttacker scripts\players\_damagefeedback::updateDamageFeedback();
				
			if (self.isBot)
				self addToAssist(eAttacker, iDamage);
		}
	
	if(self.sessionteam == "spectator")
		return;
		
	//Check for Incendiary/Poisonous Ammo
	if( isDefined(eAttacker.bulletMod) && randomfloat(1) <= 0.05){
		if( self.type != "burning" && self.type != "napalm" && self.type != "hellhound" && self.type != "boss" && self.type != "halfboss" )
				if( eAttacker.bulletMod == "incendiary" )
					if( isDefined(self.isOnFire) && isDefined(self.isPoisoned) )
						if( !self.isPoisoned && !self.isOnFire )
							if( !self.isZombie )
								if( (sWeapon == eAttacker.primary || sWeapon == eAttacker.secondary) )
									if( !scripts\players\_weapons::isExplosive(sWeapon) ){
											self igniteBot(eAttacker);
											eAttacker.stats["ignitions"]++;
										}
		if( self.type != "toxic" && self.type != "boss" && self.type != "halfboss" )
				if( eAttacker.bulletMod == "poison" )
					if( isDefined(self.isOnFire) && isDefined(self.isPoisoned) )
						if( !self.isPoisoned && !self.isOnFire )
							if( !self.isZombie )
								if( (sWeapon == eAttacker.primary || sWeapon == eAttacker.secondary) )
									if( !scripts\players\_weapons::isExplosive(sWeapon) ){
											self poisonBot(eAttacker);
											eAttacker.stats["poisons"]++;
										}
	}

	if(!isDefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		if(iDamage < 1)
			iDamage = 1;
		
		// Total Damage Stats
		if( isDefined( eAttacker.stats["damageDealt"] ) )
			eAttacker.stats["damageDealt"] += iDamage;
			
		// Medic Transfusion
		if( eInflictor == eAttacker && !eAttacker.isDown && eAttacker.health < eAttacker.maxhealth && eAttacker.transfusion && (eAttacker.lastTransfusion + 1000 < getTime()) && randomfloat(1) <= 0.2 ){
			eAttacker.lastTransfusion = getTime();
			eAttacker scripts\players\_players::healPlayer(self.maxhealth * 0.03);
		}
		
		// if(isDefined(self.head) && (sHitLoc == "head" || sHitLoc == "neck") )
			// self detach(self.head);
		// self scripts\bots\_types::loadZomModel(self.type);
		if( isDefined( self.damagePerLoc ) && isDefined (sHitLoc) ){
			if(!isDefined(self.damagePerLoc[sHitLoc]))
				self.damagePerLoc[sHitLoc] = iDamage;
			else
				self.damagePerLoc[sHitLoc] += iDamage;
		}

		// iprintln("Current damage at " + sHitLoc + " of bot " + self.name + " is " + self.damagePerLoc[sHitLoc]);
		self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);
	}
}

igniteBot(eAttacker){
	self.isOnFire = true;
	self thread damageOverTime(eAttacker, (self.maxhealth * 0.05), 1, "fire");
	if(self.type != "dog" && self.type != "helldog")
		self thread scripts\bots\_types::createEffectEntity(level.incendiary_FX, "j_spinelower");
	else
		self thread scripts\bots\_types::createEffectEntity(level.incendiary_FX, "j_head", (0,0,-35)); // Prevent effect from being too far up above the head
}

poisonBot(eAttacker){
	self.isPoisoned = true;
	self thread damageOverTime(eAttacker, (self.maxhealth * 0.05), 1, "poison");
	if(self.type != "dog" && self.type != "helldog")
		self thread scripts\bots\_types::createEffectEntity(level.poisoned_FX, "j_spinelower");
	else
		self thread scripts\bots\_types::createEffectEntity(level.poisoned_FX, "j_head", (0,0,-35)); // Prevent effect from being too far up above the head
}

damageOverTime(eAttacker, damage, time, type){
	self endon("disconnect");
	self endon("death");
	while(isDefined(eAttacker)){
		wait time + randomfloat(2);
		self Callback_BotDamage(eAttacker, eAttacker, int(damage), 0, "MOD_RIFLE_BULLET", "none", eAttacker.origin, vectornormalize(self.origin - eAttacker.origin), "none", 0);

		if (type == "poison")
			eAttacker thread bulletModFeedback("poison");
		if(type == "fire")
			eAttacker thread bulletModFeedback("fire");
	}
}

addToAssist(player, damage)
{
	if(!isDefined(self.damagedBy))
		return;
	
	for (i=0; i<self.damagedBy.size; i++)
	{
		if (self.damagedBy[i].player == player)
		{
			self.damagedBy[i].damage += damage;
			return;
		}
	}
	struct = spawnstruct();
	self.damagedBy[self.damagedBy.size] = struct;
	struct.player = player;
	struct.damage = damage;
}

Callback_BotKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self unlink();
	
	if(self.sessionteam == "spectator")
		return;

	if( ( sHitLoc == "head" || sHitLoc == "helmet" ) && sMeansOfDeath != "MOD_MELEE" )
		sMeansOfDeath = "MOD_HEAD_SHOT";
	
	if(sMeansOfDeath == "MOD_HEAD_SHOT")
		attacker.stats["headshotKills"]++;

	if (level.dvar["zom_orbituary"])
		obituary(self, attacker, sWeapon, sMeansOfDeath);

	self.sessionstate = "dead";
	self notify("killed");

	if (isplayer(attacker) && attacker != self)
	{
		attacker.kills++;
		attacker.stats["kills"]++;
		
		if( isDefined( attacker.stats["killedZombieTypes"][self.type] ) ){
			attacker.stats["killedZombieTypes"][self.type]++;
		}
		else
			logPrint("LUK_DEBUG;killedZombieTypes for " + self.type + " aint defined, bro\n");
			
		attacker thread scripts\players\_rank::giveRankXP("kill");
		attacker thread scripts\players\_spree::checkSpree();
		
		if (attacker.curClass=="stealth" && !attacker.isDown) {
			attacker scripts\players\_abilities::rechargeSpecial(5);
		}
		// if (attacker.curClass == "medic" && !attacker.isDown)
			// attacker scripts\players\_abilities::heal(5);
		//attacker.score+=10;
		assert( isDefined( self.rewardMultiplier ) );
		attacker scripts\players\_players::incUpgradePoints( int( 10 * level.rewardScale * self.rewardMultiplier ) );
		giveAssists(attacker);
		
		/* STATS MONITOR */
		if(isDefined(eInflictor.isTurret))
			attacker.stats["turretKills"]++;
			
		if( scripts\players\_weapons::isExplosive(sWeapon) && sMeansOfDeath != "MOD_MELEE" && !attacker.isDown)
			attacker.stats["explosiveKills"]++;
			
		if(sMeansOfDeath == "MOD_MELEE")
			attacker.stats["knifeKills"]++;
			
		if (attacker.curClass=="scout" && sMeansOfDeath == "MOD_HEAD_SHOT" && !attacker.isDown) {
				attacker scripts\players\_abilities::rechargeSpecial(10);
			}
		// if(sWeapon == "bulletmod_poison")
			// attacker iprintlnbold("Killed with POISON!");
			// attacker.poisonKills++;
		// else if(sWeapon == "bulletmod_fire")
			// attacker iprintlnbold("Killed with FIRE!");
			// attacker.incendiaryKills++;
		/*          */
		
	}
	
	corpse = self scripts\bots\_types::onCorpse(self.type);
	
	if (self.soundType == "zombie")
		self playsound("zom_death");
	else if(self.soundType == "dog")
		self playsound("dog_death");
		
	if(!self doSplatter(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)){
		if (corpse > 0)
		{
			body = self clonePlayer( deathAnimDuration );
			
			if (corpse > 1)
			{
				thread delayStartRagdoll( body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath );
			}
		}
	}
	self setorigin((0,0,-10000));
	self.untargetable = true;
	
	if(self.type == "halfboss")
		level.bossBulletCount--;
	
	level.dif_killedLast5Sec++;
	level.killedZombies++;

	// Remove effect on death
	if(isDefined(self.effect))
		self.effect delete();
		
	wait 0.1;
	self.hasSpawned = false;
	self.parent = undefined;
	self.number = undefined;
	level.botsAlive -= 1;
	
	//level.zom_deaths ++;
	level notify("bot_killed");

}
/* Checks if the zombie has taken critical damage to the head, thus resulting in it's bodyparts to be blown up as seen with the FX */
doSplatter(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration){
	if(!isDefined(attacker))
		return false;
	if(!isDefined(attacker.primary) || !isDefined(attacker.secondary))
		return false;
		
	damage = 0;
	if(isDefined(self.damagePerLoc["head"]))
		damage += self.damagePerLoc["head"];
	
	if(isDefined(self.damagePerLoc["neck"]))
		damage += self.damagePerLoc["neck"];
	
	if(isDefined(self.damagePerLoc["helmet"]))
		damage += self.damagePerLoc["helmet"];
		
	if(damage > self.maxhealth)
		damage = self.maxhealth;
	// if(isDefined(attacker) && self.type != "dog")
	// if((sWeapon == attacker.primary || sWeapon == attacker.secondary))
	// if(	( (iDamage > self.maxhealth * 0.6 && randomfloat(1) < 0.3) || (iDamage > self.maxhealth && randomfloat(1) < 0.9)))
	// if((sHitLoc == "head" || sHitLoc == "neck") && sMeansOfDeath != "MOD_MELEE"){
		// self playsound("zom_splatter");
		// playfx(level.splatterFX, self getTagOrigin("j_spinelower") );
		// attacker iprintln("^1CRITICAL HIT ON " + self.name);
		// return true;
	// }	
	if( self.type != "dog" && self.type != "helldog" && self.type != "burning" && self.type != "napalm" )
		if( ( sWeapon == attacker.primary || sWeapon == attacker.secondary ) )
			if( ( damage/self.maxhealth ) > 0.8 && sMeansOfDeath != "MOD_MELEE" && ( sHitLoc == "head" || sHitLoc == "neck" || sHitLoc == "helmet" ) ){
				self playsound("zom_splatter");
				playfx(level.splatterFX, self getTagOrigin("j_spinelower") );
		// attacker iprintln("^1CRITICAL HIT ON " + self.name);
		return true;
	}
	return false;
}

giveAssists(killer)
{
	// for (i=0; i<self.damagedBy.size; i++)
	// {
		// struct = self.damagedBy[i];
		// if (isdefined(struct.player))
		// {
			// if (struct.player.isActive && struct.player != killer)
			// {
				// struct.player.assists ++;
				// if (struct.damage > 400)
				// {
					// struct.player thread scripts\players\_rank::giveRankXP("assist5");
					// struct.player thread scripts\players\_players::incUpgradePoints(10*level.rewardScale);
				// }
				// else if (struct.damage > 200)
				// {
					// struct.player thread scripts\players\_rank::giveRankXP("assist4");
					// struct.player thread scripts\players\_players::incUpgradePoints(7*level.rewardScale);
				// }
				// else if (struct.damage > 100)
				// {
					// struct.player thread scripts\players\_rank::giveRankXP("assist3");
					// struct.player thread scripts\players\_players::incUpgradePoints(5*level.rewardScale);
				// }
				// else if (struct.damage > 50)
				// {
					// struct.player thread scripts\players\_rank::giveRankXP("assist2");
					// struct.player thread scripts\players\_players::incUpgradePoints(3*level.rewardScale);
				// }
				// else if (struct.damage > 25)
				// {
					// struct.player thread scripts\players\_rank::giveRankXP("assist1");
					// struct.player thread scripts\players\_players::incUpgradePoints(3*level.rewardScale);
				// }
				// else if (struct.damage > 0)
				// {
					// struct.player thread scripts\players\_rank::giveRankXP("assist0");
					// struct.player thread scripts\players\_players::incUpgradePoints(2*level.rewardScale);
				// }
			// }
		// }
	// }
	for (i=0; i<self.damagedBy.size; i++)
	{
		struct = self.damagedBy[i];
		health = self.maxhealth;
		// Make it so that people get a percentage of upgradepoints for the same percentage that they dealt damage with
		if (isdefined(struct.player))
		{
			if (struct.player.isActive && struct.player != killer)
			{
				struct.player.assists ++;
				struct.player.stats["assists"]++;
				damagePercentage = struct.damage/self.maxhealth;
				rewardMP = 1;
				if( !isDefined(self.rewardMultiplier) ){
					iprintln("Reward Multiplier is not defined for " + self.type);
				}
				else
					rewardMP = self.rewardMultiplier;
				// if(damagePercentage > 1)
					// iprintlnbold("More than 100 percent damage by " + struct.player.name + " on " + self.name + ".... wtf?");
				// iprintln(struct.player.name + " got an assist with " + int(damagePercentage*100) + " Percent damage!");
				
				struct.player thread scripts\players\_players::incUpgradePoints( int( ( 10 * level.rewardScale * rewardMP ) * damagePercentage ) );
				if (damagePercentage*100 > 85)
				{
					struct.player thread scripts\players\_rank::giveRankXP("assist5");
				}
				else if (damagePercentage*100 > 75)
				{
					struct.player thread scripts\players\_rank::giveRankXP("assist4");
				}
				else if (damagePercentage*100 > 50)
				{
					struct.player thread scripts\players\_rank::giveRankXP("assist3");
				}
				else if (damagePercentage*100 > 30)
				{
					struct.player thread scripts\players\_rank::giveRankXP("assist2");
				}
				else if (damagePercentage*100 > 15)
				{
					struct.player thread scripts\players\_rank::giveRankXP("assist1");
				}
				else if (damagePercentage*100 > 0)
				{
					struct.player thread scripts\players\_rank::giveRankXP("assist0");
				}
			}
		}
	}
	self.damagedBy = undefined;
}

onMonkeyExplosion(){
	self endon("death");
	self endon("disconnect");
	while(1){
		level waittill("monkey_bomb_exploded"); // Wait until a monkey bomb exploded somewhere on the map
		for(i = 0; i < level.bots.size; i++){ // Check bot one by one
			bot = level.bots[i];
			
			foundMonkey = false;
			if(isDefined(bot.targetedMonkey)){ // see if the bot has been targeting a monkey
				for(ii = 0; ii < level.monkeyEntities.size; ii++){ // Find out if the zombie has targeted one of the monkey entities that have exploded and are no longer existant
					if(level.monkeyEntities[ii].index == bot.targetedMonkeyEntIndex){ // Stop the loop if the zombie actually targets a monkey bomb that still exists
						foundMonkey = true;
						break;
					}
					
				}
			}
			if(!foundMonkey){
				bot.targetedMonkey = undefined;
				bot.targetedMonkeyEntIndex = undefined;
				if(isAlive(bot) && isDefined(bot getClosestTarget())) // Giving the zombie a new target, preventing "onSight"-checks in case the zombie is stuck inside a wall
					bot zomSetTarget(bot getClosestTarget().origin);
			}
		}

	}
}

monkeyOverride(){
	self endon("death");
	self endon("disconnect");
	while(1){
		if(level.monkeyEntities.size == 0)
			level waittill("monkey_bomb");
		else
			wait .05;
		while(level.monkeyEntities.size > 0 && self.type != "boss" && self.type != "halfboss"){
			nearestEnt = undefined;
			nearestDistance = 9999999999;
			for ( i = 0; i < level.monkeyEntities.size; i++ )
			{
				ent = level.monkeyEntities[i];
				if(!isDefined(self.origin) || !isDefined(ent.origin))
					continue;
					
				distance = Distance(self.origin, ent.origin);
			
				if(distance < nearestDistance && distance < 800)
				{
					nearestDistance = distance;
					nearestEnt = ent;
				}
			}
			if(isDefined(nearestEnt)){
				self zomSetTarget(nearestEnt.origin);
				self.targetedMonkey = true;
				self.targetedMonkeyEntIndex = nearestEnt.index;
				self.sprinting = true;
				if ( distance(nearestEnt.origin, self.origin) < (self.meleeRange - 40) ){
					self zomGoIdle();
				}
			}
			wait .05;
		}
	}
}

freezeBotOnLC(){
	self endon("death");
	self endon("disconnect");
	level waittill("last_chance_start");
	// self notify("stop_main");
	
	self.lastMemorizedPos = undefined;
	self.playIdleSound = false;
	self zomGoIdle();
	level waittill("last_chance_succeeded");
	self.playIdleSound = true;
	wait 3;
	
	// self thread zomMain();
	if(isAlive(self) && isDefined(self getClosestTarget())) // Giving the zombie a new target, preventing "onSight"-checks in case the zombie is stuck inside a wall
		self zomSetTarget(self getClosestTarget().origin);
}

freezeBot(){
	self endon("death");
	self endon("disconnect");
	while(1){
		while(1){
			if( level.freezeBots )
				break;
			else
				wait 0.5;
		}
		self notify("kill_main");
		self.lastMemorizedPos = undefined;
		self.playIdleSound = false;
		self zomGoIdle();
		
		while(level.freezeBots){
			wait 0.05;
		}
			
		self.playIdleSound = true;
		
		
		if( isDefined( self getClosestTarget() ) ) // Giving the zombie a new target, preventing "onSight"-checks in case the zombie is stuck inside a wall
			self zomSetTarget(self getClosestTarget().origin);
		self thread zomMain();
	}
}


zomMain()
{
	self endon("disconnect");
	self endon("death");
	self endon("kill_main");
	
	self.lastTargetWp = -2;
	self.nextWp = -2;
	//self.intervalScale = 1;
	update = 0;
	
	while (1)
	{
		switch (self.status)
		{
			case "idle":
				zomWaitToBeTriggered();
				switch(level.zomIdleBehavior)
				{
					case "magic":
						if (update==5) {
							if (level.zomTarget != "")
							{
								if (level.zomTarget == "player_closest")
								{
									ent = self getClosestTarget();
									if (isdefined(ent))
									{
										self zomSetTarget(ent.origin);
									}
								}
								else
								self zomSetTarget(getRandomEntity(level.zomTarget).origin);
							}
							else
							{
								ent = self getClosestTarget();
								if (isdefined(ent))
								self zomSetTarget(ent.origin);
							}
							update = 0;
						}
						else
							update++;
					break;
				}
				break;
			case "triggered":
				if (update==10){
					self.bestTarget = zomGetBestTarget();
					update = 0;
				}
				else 
					update++;
				if (isdefined(self.bestTarget))
					if(self.bestTarget.isTargetable && self.bestTarget.visible)
					{
						self.lastMemorizedPos = self.bestTarget.origin;
						if ( !checkForBarricade(self.bestTarget.origin) )
						{
							if (distance(self.bestTarget.origin, self.origin) < self.meleeRange)
							{
								self thread zomMoveLockon(self.bestTarget, self.meleeTime, self.meleeSpeed);
								switch(self.type){
									case "napalm": self zomExplode(); break;
									case "boss": self bossAttack(); break;
									default: self zomMelee(); break;
								}
								//doWait = false;
							}
							else
							{
								zomMovement();
								self zomMoveTowards(self.bestTarget.origin);
								//doWait = false;
							}
						}
						else
							self zomMelee();
					}
					else
						self zomGoSearch();
				else
					self zomGoSearch();
				break;
			
			case "searching":
			zomWaitToBeTriggered();
				if (isdefined(self.lastMemorizedPos))
				{
					if (!checkForBarricade(self.lastMemorizedPos))
					{
						if (distance(self.lastMemorizedPos, self.origin) > 48)
						{
							zomMovement();
							self zomMoveTowards(self.lastMemorizedPos);
							//doWait = false;
						}
						else
							self.lastMemorizedPos = undefined;
					}
					else
						self zomMelee();
				}
				else
					zomGoIdle();
					
				break;
			}
		//if (doWait)
		wait level.zomInterval;
	}
}

zomGetBestTarget()
{
	if (!isdefined(self.currentTarget))
	{
		for (i=0; i<level.players.size; i++)
		{
			player = level.players[i];
			if (zomSpot(player))
			{
				self.currentTarget = player;
				return player;
			}
			wait 0.05;
		}
		/*for (i=0; i<level.zomTargets.size; i++)
		{
			obj = level.zomTargets[i];
			if (zomSpot(obj))
			{
				self.currentTarget = obj;
				return obj;
			}
		}*/
	}
	else
	{
		if (!zomSpot(self.currentTarget))
		{
			self.currentTarget = undefined;
			return undefined;
		}
		
		
		targetdis = distancesquared(self.origin, self.currentTarget.origin) - level.zomPreference;
		for (i=0; i<level.players.size; i++)
		{
			player = level.players[i];
			if (distancesquared(self.origin, player.origin) < targetdis)
			{
				if (zomSpot(player))
				{
					self.currentTarget = player;
					return player;
				}
			}
		}
		/*for (i=0; i<level.zomTargets.size; i++)
		{
			obj = level.zomTargets.size[i];
			if (distancesquared(self.origin, obj.origin) - obj.zomPreference < targetdis)
			{
				if (zomSpot(obj))
				{
					self.currentTarget = obj;
					return obj;
				}
			}
		}*/
		return self.currentTarget;
		
	}
}

zomMovement()
{
	self.cur_speed = 0;
	
	if ((self.alertLevel >= 200 && (!self.walkOnly || self.quake)) || self.sprinting ) //GO RUNNING... AAHH
	{
		self setanim("sprint");
		self.cur_speed = self.runSpeed;
		if (self.quake)
		{
			Earthquake( 0.25, .3, self.origin, 380);
		}
		
		if (level.dvar["zom_dominoeffect"])
			thread alertZombies(self.origin, 480, 5, self); 
	}
	else
	{
		self setanim("walk");
		self.cur_speed = self.walkSpeed;
		if (self.quake)
		{
			Earthquake( 0.17, .3, self.origin, 320);
		}
	}
}


zomGoIdle()
{
	self setanim("stand");
	self.cur_speed = 0;
	self.alertLevel = 0;
	self.status = "idle";
	//iprintlnbold("IDLE!");
}

zomGoTriggered()
{
	self.status = "triggered";
	//self.update = 10;
	self.bestTarget = zomGetBestTarget();
	//iprintlnbold("TRIGGERED!");
}

zomGoSearch()
{
	self.status = "searching";
	//iprintlnbold("SEARCHING!");
}

zomWaitToBeTriggered()
{
	for (i=0; i<level.players.size; i++)
	{
		player = level.players[i];
		if(self zomSpot(player))
		{
			self zomGoTriggered();
			break;
		}
	}
}

zomSpot(target)
{
  if (!target.isObj)
  {
	  if (!target.isAlive)
	  return false;
	  
	  if (!target.isTargetable)
	  return false;
  }
  
  if (!target.visible)
	return false;
  
  distance = distance(self.origin, target.origin);
  
  if (distance > level.zombieSight)
  return false;
  
  /*switch (target getStance())
  {
	case "stand":
	if (distance < 256)
	return 1;
	break;
	case "crouch":
	if (distance < 148)
	return 1;
	break;
	case "prone":
	if (distance < 96)
	return 1;
	break;
  }*/
  
  /*speed = Length(target GetVelocity());
  
  if (speed > 80 && distance < 256)
  return 1;
  if (speed > 160 && distance < 416)
  return 1;
  if (speed > 240 && distance < 672)
  return 1;*/
  
  dot = 1.0;
  
  //if nearest target hasn't attacked me, check to see if it's in front of me
   fwdDir = anglestoforward(self getplayerangles());
   dirToTarget = vectorNormalize(target.origin-self.origin);
   dot = vectorDot(fwdDir, dirToTarget);
  

  //try see through smoke
  /*if(!SmokeTrace(self GetEyePos(), self.bestTarget GetEyePos()))
  {
    return false;
  }*/
  
  //in front of us and is being obvious
  if(dot > -0.2)
  {
    //do a ray to see if we can see the target
	if (!target.isObj)
	{
		visTrace = bullettrace(self.origin + (0,0,68), target getPlayerHeight(), false, self);
	}
	else
	{
	 visTrace = bullettrace(self.origin + (0,0,68), target.origin +(0,0,20), false, self);
	}
	if(visTrace["fraction"] == 1)
	{
		   //line(self.origin + (0,0,68), visTrace["position"], (0,1.0,0));
		return true;
	}
	else
	{
		if (isdefined(visTrace["entity"]))
		if (visTrace["entity"] == target)
		return true;
		//line(self.origin + (0,0,68), visTrace["position"], (1,0,0));            
		return false;
	}

  }
  
  return false;
}

zomGoToClosestWaypoint(){
	self endon("death");
	self zomMovement();
	self zomMoveTowards(level.waypoints[getNearestWp(self.origin)].origin);
	wait 0.5;
	self zomGoSearch();
	self thread zomMain();
}

setAnim(animation)
{
	if (isdefined(self.animation[animation]))
	{
		self.animWeapon = self.animation[animation];
		self TakeAllWeapons();
		self.pers["weapon"] = self.animWeapon;
		self giveweapon(self.pers["weapon"]);
		self givemaxammo(self.pers["weapon"]);
		//self SetWeaponAmmoClip(self.pers["weapon"], 30);
		//self SetWeaponAmmoStock(self.pers["weapon"], 0);
		self setspawnweapon(self.pers["weapon"]);
		self switchtoweapon(self.pers["weapon"]);
	}
}

getPlayerHeight()
{
	  switch (self getStance())
	  {
		case "stand":
		return self.origin + (0,0,68);
		case "crouch":
		return self.origin + (0,0,40);
		case "prone":
		return self.origin + (0,0,22);
	  }
}

zomMoveTowards(target_position)
{
	self endon("disconnect");
	self endon("death");
	self notify("zomMoveTowards");
	self endon("zomMoveTowards");
	
	//self thread pushOutOfPlayers();
	
	if (!isdefined(self.myWaypoint))
	{
		self.myWaypoint = getNearestWp(self.origin);
	}
	
	targetWp = getNearestWp(target_position);
	
	nextWp = self.nextWp;
	
	direct = false;
	//
	//if (distancesquared(target_position, self.origin) <= distancesquared(level.waypoints[targetWp].origin, self.origin) || targetWp == self.myWaypoint)
	if (self.underway)
	{
	
	//if (targetWp == self.myWaypoint)
	//
		//if (distancesquared(target_position, self.origin) >= distancesquared(level.waypoints[nextWp].origin, self.origin))
		//direct = true;
		
		if (targetWp == self.myWaypoint) //|| distancesquared(target_position, self.origin) <= distancesquared(level.waypoints[nextWp].origin, self.origin)
		{
			direct = true;
			self.underway = false;
			self.myWaypoint = undefined;
		}
		else
		{
			if (!isdefined(nextWp))
			return ;
			if (targetWp == nextWp)
			{

				if (distancesquared(target_position, self.origin) <= distancesquared(level.waypoints[nextWp].origin, self.origin))
				{
					direct = true;
					self.underway = false;
					self.myWaypoint = undefined;
				}
			}
		}
	}
	else
	{
		//if (self.lastTargetWp != targetWp || self.myWaypoint == nextWp )
		if (targetWp == self.myWaypoint)
		{
			//iprintln(level.waypoints[getNearestWp(self.origin)].origin+":"+level.waypoints[getNearestWp(target_position)].origin);
			direct = true;
			self.underway = false;
			self.myWaypoint = undefined;
		}
		else
		{
			//time = GetTime();
			/* This way may not be the safest and most reliable */
			if( level.waypointLoops > 100000 && level.dvar["zom_antilagmonitor"] ){
				// logPrint("DEBUG: Caught > 200000 loops in level.waypointLoops!\n");
				// logPrint("DEBUG: Caught " + level.waypointLoops + " loops in level.waypointLoops!\n");
				// iprintln("Caught > 200000 loops, mitigating load to more frames...");
				// iprintln("DEBUG: Caught " + level.waypointLoops + " loops in level.waypointLoops!\n");
				wait 0.05;
				if( isDefined(target_position) )
					self thread zomMoveTowards(target_position);
				return;
			}
			if( level.botsLookingForWaypoints > getDvarInt("max_waypoint_bots") ){
				if( getDvarInt("debug_max_waypoint_bots") )
					iprintln("Caught > " + getDvarInt("max_waypoint_bots") + " bots looking for waypoints!");
				wait 0.05;
				if( isDefined(target_position) )
					self thread zomMoveTowards(target_position);
				return;
			}
			level.botsLookingForWaypoints++;
			nextWp = AStarSearch(self.myWaypoint, targetWp);
			//newtime = GetTime()-time;
			//iprintlnbold("MILISEC:" + newtime);
			self.nextWp = nextWp;
			self.underway = true;
		}
	}
	
	//self.lastTargetWp = targetWp;
	
	//TARGET SET! MOVING!
	//line(self.origin, target_position, (0,0,1));
	if (direct)
	{
		moveToPoint(target_position, self.cur_speed);
		/*lineCol = (1,0,0);
		line(level.waypoints[self.myWaypoint].origin, target_position, lineCol);*/
	}
	else
	{
		/*lineCol = (1,0,0);
		line(level.waypoints[self.myWaypoint].origin, level.waypoints[nextWp].origin, lineCol);*/
		if (isdefined(nextWp))
		{
			moveToPoint(level.waypoints[nextWp].origin, self.cur_speed);
			if (distance(level.waypoints[nextWp].origin, self.origin) <  64)
			{
				self.underway = false;
				self.myWaypoint = nextWp;
				//if (self.myWaypoint != nextWp)
				//nextWp = AStarSearch(self.myWaypoint, targetWp);
				//else
				//break;
			}
		}
		/*else
		
			self zomGoIdle();
		*/
		
	}
}

zomMoveLockon(player, time, speed)
{
	intervals = int(time / level.zomInterval);
	for (i=0; i<intervals; i++)
	{
		if( !isDefined( player ) )
			break;
		dis = distance(self.origin, player.origin);
		if (dis > 48)
		{
			pushOutDir = VectorNormalize((self.origin[0], self.origin[1], 0)-(player.origin[0], player.origin[1], 0));
			self moveToPoint(player.origin + pushOutDir * 32, speed);
			self pushOutOfPlayers();
		}
		targetDirection = vectorToAngles(VectorNormalize(player.origin - self.origin));		
		self SetPlayerAngles(targetDirection);
		wait level.zomInterval;
	}
}

pushOutOfPlayers() // ON SELF
{
  //push out of other players
  //players = level.players;
  players = getentarray("player", "classname");
  for(i = 0; i < players.size; i++)
  {
    player = players[i];
    
    if(player == self || !isalive(player))
      continue;
    self thread pushout(player.origin);

  }
  for (i=0; i <level.dynamic_barricades.size; i++)
  {
	if (isdefined(level.dynamic_barricades[i]))
	{
		if (level.dynamic_barricades[i].hp > 0)
		self thread pushout(level.dynamic_barricades[i].origin);
	}
  }
   /*for (i=0; i <level.barricades.size; i++)
  {
	if (isdefined(level.barricades[i]))
	{
		if (level.barricades[i].hp > 0)
		self thread pushout(level.barricades[i].parts[0].startPosition);
	}
  }*/
}

pushout(org)
{
	linkObj = self.linkObj;
    distance = distance(org, linkObj.origin);
    minDistance = 28;
    if(distance < minDistance) //push out
    {
      pushOutDir = VectorNormalize((linkObj.origin[0], linkObj.origin[1], 0)-(org[0], org[1], 0));
      pushoutPos = linkObj.origin + (pushOutDir * (minDistance-distance));
      linkObj.origin = (pushoutPos[0], pushoutPos[1], self.origin[2]);
    }
}

zomExplode(){
	self endon("disconnect");
	self endon("death");
	
	self setAnim("melee");
	wait 0.5;
	
	PlayFX(level.explodeFX, self.origin);
	self PlaySound("explo_metal_rand");
	self scripts\bots\_bots::zomAreaDamage(self.damage);
	
	self setorigin((0,0,-10000));
	self.untargetable = true;
	self.suicided = true;
	
	self suicide();
}

getMeleePreTime(){
	switch( self getCurrentWeapon() ){
		case "bot_zombie_melee_mp": return 0.5;
		case "brick_blaster_mp":	return 0.3;
		default: 					return 0.5;
	}
}

getMeleePostTime(){
	switch( self getCurrentWeapon() ){
		case "bot_zombie_melee_mp": return 1.2;
		case "brick_blaster_mp":	return 0.6;
		default: 					return 1.2;
	}
}

zomMelee(bDoDamage)
{
	if(!isDefined( bDoDamage ) )
		bDoDamage = true;
	self endon("disconnect");
	self endon("death");
	self.movementType = "melee";
	/*if (self hasAnim("run"))
	{
		self setAnim("run2melee");
		wait .4;
	}
	else
	{
		self setAnim("stand2melee");
		wait .6;
	}*/
	self setAnim("melee");
	wait self getMeleePreTime();
	// wait .5;
	if (self.quake)
		Earthquake( 0.25, .2, self.origin, 380);
	if (isalive(self))
	{
		if( bDoDamage )
			self zomDoDamage( self.meleeRange );
		if(self.type != "dog" && self.type != "helldog")
		self zomSound(0, "zom_attack");
		else
		self zomSound(0, "dog_attack");
	}
	// wait .6;
	wait self getMeleePostTime();
	// wait 1.1;
	/*wait .5;
	if (isalive(self))
	{
		self zombieDoDamage(90, 30);
		self zombieSound(0, "zom_attack", randomint(10));
	}
	wait .5;
	if (isalive(self))
	{
		self zombieDoDamage(90, 30);
		self zombieSound(0, "zom_attack", randomint(10));
	}
	wait .7;*/
	self setAnim("stand");
	//self.movementType = "walk";

	//self setAnim("run");
	//self thread zombieMelee();
}

bossAttack()
{
	self endon("disconnect");
	self endon("death");
		
	if( level.nextBossJump < getTime() && randomfloat(1) < 0.15 ){
		self setAnim("jump");
		playFX(level.bossShockwaveFX, self.origin);
		self playsound("boss_charge");
		wait 1.1;
		Earthquake( 0.8, 1, self.origin, 600);
		
		if (isalive(self))
		{
			self zomAreaDamage(360);
			self playsound("detpack_explo_main");
		}
		
		wait .2;
		self setAnim("stand");
		level.lastBossJump = getTime();
		level.nextBossJump = level.lastBossJump + ( 10000 + randomint(10000) );
	}
	else
		self zomMelee();

}

infection(chance)
{
	if (self.infected)
	return;
	
	chance = self.infectionMP * chance;
	if (randomfloat(1)<chance)
	{
		self thread scripts\players\_infection::goInfected();
	}
	
}

moveToPoint(origin, speed)
{
	dis = distance(self.linkObj.origin, origin);
	if (dis < speed)
	speed = dis;
	else
	speed = speed * level.zomSpeedScale;
	targetDirection = vectorToAngles(VectorNormalize(origin - self.linkObj.origin));
	step = anglesToForward(targetDirection) * speed ;
					
	self SetPlayerAngles(targetDirection);
	
	/*self.mover zomMove(step, time);
	//wait time * 0.05;
	self.mover dropToGround();*/
	newPos = self.linkObj.origin + step + (0,0,40);
	dropNewPos = dropPlayer(newPos, 200);
	if (isdefined(dropNewPos))
	{
		newPos = (dropNewPos[0], dropNewPos[1], self compareZ(origin[2], dropNewPos[2]));
	}
	self.linkObj moveto(newPos, level.zomInterval , 0, 0);
}

compareZ(z1, z2)
{
	dif_z2 = z2 - self.origin[2];
	if (dif_z2 > 30) // Heavy rise in Z
	{
		if (z1 > z2) // z1 is even higher, np
		{
			if (dif_z2 > 20)
			z2 = self.origin[2] + 20;
			return z2;
		}
		else
		return self.origin[2];
		
	}
	if (dif_z2 < -30)// Heavy fall in Z
	{
		if (z1 < z2) // z2 is even lower, np
		{
			return z2;
		}
		else
		return self.origin[2];
	}
	return z2;
	
}

zomAreaDamage(range)
{
	for (i=0; i<=level.players.size; i++)
	{
					target = level.players[i];
					if (isdefined(target) && isalive(target) )
					{
						distance = distance(self.origin, target.origin);
						if (distance < range )
						{
							target.isPlayer = true;
							//target.damageCenter = self.Mover.origin;
							target.entity = target;
							target damageEnt(
								self, // eInflictor = the entity that causes the damage (e.g. a claymore)
								self, // eAttacker = the player that is attacking
								int(self.damage*level.dif_zomDamMod), // iDamage = the amount of damage to do
								"MOD_EXPLOSIVE", // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
								self.pers["weapon"], // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
								self.origin, // damagepos = the position damage is coming from
								//(0,self GetPlayerAngles()[1],0) // damagedir = the direction damage is moving in      
								vectorNormalize(target.origin-self.origin)
							);
							self scripts\bots\_types::onAttack(self.type, target);
						}
					}
	}
}

zomDoDamage(range)
{
	meleeRange = range;
	closest = getClosestPlayerArray();
	for (i=0; i<=closest.size; i++)
	{
					target = closest[i];
					if (isdefined(target))
					{
						distance = distance(self.origin, target.origin);
						if (distance <meleeRange )
						{
							fwdDir = anglestoforward(self getplayerangles());
							dirToTarget = vectorNormalize(target.origin-self.origin);
							dot = vectorDot(fwdDir, dirToTarget);
							if (dot > .5)
							{
							target.isPlayer = true;
							//target.damageCenter = self.Mover.origin;
							target.entity = target;
							target damageEnt(
									self, // eInflictor = the entity that causes the damage (e.g. a claymore)
									self, // eAttacker = the player that is attacking
									int(self.damage*level.dif_zomDamMod), // iDamage = the amount of damage to do
									"MOD_MELEE", // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
									self.pers["weapon"], // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
									self.origin, // damagepos = the position damage is coming from
									//(0,self GetPlayerAngles()[1],0) // damagedir = the direction damage is moving in      
									vectorNormalize(target.origin-self.origin)
								);
							self scripts\bots\_types::onAttack(self.type, target);
							if (level.dvar["zom_infection"])
							target infection(self.infectionChance);
							//target shellshock("zombiedamage", 1);
							break;
							}
						}
					}
	}
	/*for (i=0; i<level.attackable_obj.size; i++)
	{
		obj = level.attackable_obj[i];
		distance = distance2d(self.origin, obj.origin);
		if (distance <meleeRange )
		{
			fwdDir = anglestoforward(self getplayerangles());
			dirToTarget = vectorNormalize(obj.origin-self.origin);
			dot = vectorDot(fwdDir, dirToTarget);
			if (dot > .5)
			{
				obj notify("damage", self.damage);
			}
		}
		
		
	}*/
	for (i=0; i<level.barricades.size; i++)
	{
		ent = level.barricades[i];
		distance = distance2d(self.origin, ent.origin);
		if (distance <meleeRange*2 )
		{
			ent thread scripts\players\_barricades::doBarricadeDamage(self.damage*level.dif_zomDamMod);
			break;
		}
	}
	for (i=0; i<level.dynamic_barricades.size; i++)
	{
		ent = level.dynamic_barricades[i];
		distance = distance2d(self.origin, ent.origin);
		if (distance <meleeRange )
		{
			ent thread scripts\players\_barricades::doBarricadeDamage(self.damage*level.dif_zomDamMod);
			break;
		}
	}
	

}

zomGroan()
{
	self endon("death");
	self endon("disconnect");
	
	soundtype = "";
	
	if (self.soundType == "dog")
		soundtype = "dog";
	else if(self.soundType == "zombie")
		soundtype = "zom";
	
	for (;;)
	{
		wait 3 + randomfloat(3);
		
		//self zombieSound(randomfloat(.5), "zom_run", 0);
		if (self.isDoingMelee == false && self.playIdleSound)
		{
			if (self.alertLevel == 0 && soundtype == "dog")
			{
				self zomSound(randomfloat(.5), soundtype + "_" + "idle");
			}
			else if (self.alertLevel < 200)
			{
				if(soundtype == "zom")
					self zomSound(randomfloat(.5), soundtype + "_" + "walk");
			}
			else if(soundtype == "zom")
			{
				self zomSound(randomfloat(.5), "zom_run");
			}
		}
	}
}

zomSound(delay, sound)
{
	if (delay > 0) {
		self endon("death");
		wait delay;
	}
	if( level.silenceZombies )
		return;
	if (isalive(self))
	self playSound( sound );
}

zomSetTarget(target)
{
	//wait .5;
	//self.targetPosition = getentarray(target, "targetname")[0].origin;
	//self.alertLevel = 1;
	self zomGoSearch();
	self.lastMemorizedPos = target;
}


checkForBarricade(targetposition)
{
	for (i=0; i<level.barricades.size; i++)
	{
		ent = level.barricades[i];
		if (isDefined(ent) && self istouching(ent) && ent.hp > 0)
		{
			fwdDir = vectorNormalize(targetposition-self.origin);
			dirToTarget = vectorNormalize(ent.origin-self.origin);
			dot = vectorDot(fwdDir, dirToTarget);
			if (dot > 0 && dot < 1)
			{
				return 1;
			}
		}
	}
	for (i=0; i<level.dynamic_barricades.size; i++)
	{
		ent = level.dynamic_barricades[i];
		if (isDefined(ent) && distance(self.origin, ent.origin) < 48 && ent.hp > 0)
		{
			fwdDir = vectorNormalize(targetposition-self.origin);
			dirToTarget = vectorNormalize(ent.origin-self.origin);
			dot = vectorDot(fwdDir, dirToTarget);
			if (dot > 0 && dot < 1)
			{
				return 1;
			}
		}
	}
	return 0;
}

alertZombies( origin, distance, alertPower, ignoreEnt)
{
	for (i=0; i < level.bots.size; i++)
	{
		if (isdefined(ignoreEnt))
		{
			if (level.bots[i] == ignoreEnt)
			continue;
		}
		dist = distance(origin, level.bots[i].origin);
		if (dist < distance)
		{
			zombie = level.bots[i];
			if (isalive(zombie) && isdefined(zombie.status))
			{
				zombie.alertLevel += alertPower;
				//if (!isdefined(zombie.
				//zombie.lastMemorizedPos = origin;
				if (zombie.status == "idle")
				zombie zomGoSearch();
			}
		}
	}
}


