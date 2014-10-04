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

#include scripts\include\entities;
#include scripts\include\data;

init()
{
	level.onGiveWeapons = -1;
	level.spawnPrimary = "none";
	level.spawnSecondary = "none";
	level.monkeyEntitiesIndex = 0;
	
	level.specialWeps = [];
	
// assigns weapons with stat numbers from 0-149
	// attachments are now shown here, they are per weapon settings instead
	
	// generating weaponIDs array
	level.weaponIDs = [];
	max_weapon_num = 149;
	attachment_num = 150;
	for( i = 0; i <= max_weapon_num; i++ )
	{
		weapon_name = tablelookup( "mp/statstable.csv", 0, i, 4 );
		if( !isdefined( weapon_name ) || weapon_name == "" )
		{
			level.weaponIDs[i] = "";
			continue;
		}
		level.weaponIDs[i] = weapon_name + "_mp";
		
		// generating attachment combinations
		attachment = tablelookup( "mp/statstable.csv", 0, i, 8 );
		if( !isdefined( attachment ) || attachment == "" )
			continue;
			
		attachment_tokens = strtok( attachment, " " );
		if( !isdefined( attachment_tokens ) )
			continue;
		if( attachment_tokens.size == 0 )
		{
			level.weaponIDs[attachment_num] = weapon_name + "_" + attachment + "_mp";
			attachment_num++;
		}
		else
		{
			for( k = 0; k < attachment_tokens.size; k++ )
			{
				level.weaponIDs[attachment_num] = weapon_name + "_" + attachment_tokens[k] + "_mp";
				attachment_num++;
			}
		}
	}
	// generating weaponNames array
	level.weaponNames = [];
	for ( index = 0; index < max_weapon_num; index++ )
	{
		if ( !isdefined( level.weaponIDs[index] ) || level.weaponIDs[index] == "" )
			continue;
			
		level.weaponNames[level.weaponIDs[index]] = index;
	}
	
	// generating weaponlist array
	level.weaponlist = [];
	assertex( isdefined( level.weaponIDs.size ), "level.weaponIDs is corrupted" );
	for( i = 0; i < level.weaponIDs.size; i++ )
	{
		if( !isdefined( level.weaponIDs[i] ) || level.weaponIDs[i] == "" )
			continue;

		level.weaponlist[level.weaponlist.size] = level.weaponIDs[i];
	}

	// based on weaponList array, precache weapons in list
	for ( index = 0; index < level.weaponList.size; index++ )
	{
		precacheItem( level.weaponList[index] );
		println( "Precached weapon: " + level.weaponList[index] );	
	}

	//precacheItem("c4_mp");
	precacheItem( "at4_mp" );
	//precacheItem( "tnt_mp" );
	//precacheItem( "crossbow_mp" );
	precacheItem("helicopter_mp");
	
	precacheShellShock( "default" );
	precacheShellShock( "concussion_grenade_mp" );
	level.monkeyEffect = loadfx("monkey_grenade/monkey_grenade_onfloor");
	
	level.monkeyEntities = [];

	claymoreDetectionConeAngle = 70;
	level.claymoreDetectionDot = cos( claymoreDetectionConeAngle );
	level.claymoreDetectionMinDist = 20;
	level.claymoreDetectionGracePeriod = .75;
	level.claymoreDetonateRadius = 150;
	
	level.c4explodethisframe = false;
	level.C4FXid = loadfx( "bo_crossbow/light_crossbow_blink" );//For the new crossbow, we need to replace this
	//level.C4FXid = loadfx( "misc/light_c4_blink" ); //Old One
	level.claymoreFXid = loadfx( "misc/claymore_laser" );
}

isSpecialWeap(weap){
	for (i=0; i < level.specialWeps.size; i++) {
		if (level.specialWeps[i] == weap)
			return true;
	}
	return false;
}


initPlayerWeapons()
{
	self.primary = "none";
	self.secondary = "none";
	self.extra = "none";
}

checkWeaponFlash( weapon )
{
	if (isPistol(weapon))
		return false;
	if (weapon == "none")
		return false;
	if (weapon == "c4_mp" || weapon == "claymore_mp" || weapon == "rpg_mp" || weapon == "at4_mp" || weapon == "tnt_mp")
		return false;
	
	return true;
}

givePlayerWeapons()
{
	//return;
	//switch (level.onGiveWeapons)
	//{
		//case 0:
			self.primary = self.persData.primary;
			self.secondary = self.persData.secondary;
			self.extra = self.persData.extra;
			
			//iprintlnbold(self.primary);
			
			if (self.secondary != "none")
			{
				self giveWeapon( self.secondary );
				self setSpawnWeapon( self.secondary );
				self SwitchToWeapon( self.secondary);
				//self giveMaxAmmo( self.secondary );
				self setWeaponAmmoStock(self.secondary , self.persData.secondaryAmmoStock);
				self setWeaponAmmoClip(self.secondary , self.persData.secondaryAmmoClip);
			}
			if (self.primary != "none")
			{
				self giveWeapon( self.primary ); 
				self setSpawnWeapon( self.primary );
				self SwitchToWeapon( self.primary );
				//self giveMaxAmmo( self.primary );
//				iprintlnbold(self.persData.primaryAmmoStock);
				self setWeaponAmmoStock(self.primary, self.persData.primaryAmmoStock);
				self setWeaponAmmoClip(self.primary, self.persData.primaryAmmoClip);
			}
			if (self.extra != "none")
			{
				self giveWeapon( self.extra );
				self setWeaponAmmoStock(self.extra , self.persData.extraAmmoStock);
				self setWeaponAmmoClip(self.extra , self.persData.extraAmmoClip);
			}
		/*break;
		case 1:
			self.primary =  getdvar("surv_"+self.class+"_unlockprimary"+self.unlock["primary"]);
			self.secondary = getdvar("surv_"+self.class+"_unlocksecondary"+self.unlock["secondary"]);
			if (self.unlock["primary"]) {
			}
			
			if (self.secondary != "")
			{
				self giveWeapon( self.secondary );
				self setSpawnWeapon( self.secondary );
				self SwitchToWeapon( self.secondary);
				self giveMaxAmmo( self.secondary );
			}
			if (self.primary != "")
			{
				self giveWeapon( self.primary ); 
				self setSpawnWeapon( self.primary );
				self SwitchToWeapon( self.primary );
				self giveMaxAmmo( self.primary );
				
			}
		
		break;
		default:
			iprintlnbold("^1ERROR: ^7 no weapon handling");
		break;
	}*/
}

canRestoreAmmo(wep) {
	if (wep=="helicopter_mp" || scripts\players\_weapons::isSpecialWeap(wep) || wep=="m14_reflex_mp" /* Ammobox */ || wep=="none" || wep == level.weapons["flash"] /* Monkey Bomb */)
		return false;
	return true;
}

watchWeaponUsage()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon("downed");
	//level endon ( "game_ended" );
	
	self.firingWeapon = false;
	
	for ( ;; )
	{	
		self waittill ( "begin_firing" );
		
		weap = self getcurrentweapon();
		
		ent = undefined;
		
		self.hasDoneCombat = true;
		self.firingWeapon = true;	
		
		if (weap=="saw_acog_mp") {
			self stoplocalsound("weap_minigun_spin_over_plr");
			self thread minigunQuake();
		} else if (weap=="skorpion_acog_mp") {
			self stoplocalsound("flamethrower_cooldown_plr");
			ent = spawn("script_model", self.origin);
			ent linkto(self);
			ent playLoopSound("flamethrower_fire_npc");
			self thread removeEntOnDeath(ent);
			self thread removeEntOnDisconnect(ent);
			self thread removeEntOnDowned(ent);
			
			self playsound("flamethrower_fire_npc");
			self playlocalsound("flamethrower_ignite_plr");
		} 
		/*
		else if (weap=="g3_acog_mp") // thundergun aka "huge bug weapon"
		{
			for (i=0; i<level.bots.size; i++) {
				bot = level.bots[i];
				if (!isdefined(bot))
				continue;
				
				if (isalive(bot)) {
					dis = distance(bot.origin, self.origin);
					if (dis < 768) {
						dam = int((600-600*dis/768));
						realdam = int(200 * (1 - (dis/521)));
						if (realdam < 0)
						realdam = 0;
						
						if (DistanceSquared(anglestoforward(self getplayerangles()), vectornormalize(bot.origin-self.origin)) < .7)
						self thread thunderBlast(dam, realdam, bot);
						
						// iprintlnbold(DistanceSquared(self.angles, vectortoangles(player.origin-self.origin)));
						// iprintlnbold(realdam);

					}
				}
				// PhysicsExplosionSphere(self gettagorigin("tag_weapon"), 1768, 1512, 100);
				
			}
		}
		*/
		
		/*if (!self.isDown)
		self alertTillEndFiring();
		else*/
		self waittill ( "end_firing" );
		
		if (weap=="saw_acog_mp") {
			self playlocalsound("weap_minigun_spin_over_plr");
		} else if (weap=="skorpion_acog_mp") {
			self stoplocalsound("flamethrower_ignite_plr");
			self playlocalsound("flamethrower_cooldown_plr");
			ent stopLoopSound("flamethrower_fire_npc");
			ent delete();
		}
		
		if (weap == self.primary){
			self.persData.primaryAmmoClip = self getweaponammoclip(self.primary);
			self.persData.primaryAmmoStock = self getweaponammostock(self.primary);
		}
		else if (weap == self.secondary){
			self.persData.secondaryAmmoClip = self getweaponammoclip(self.secondary);
			self.persData.secondaryAmmoStock = self getweaponammostock(self.secondary);
		}
		else if (weap == self.extra){
			self.persData.extraAmmoClip = self getweaponammoclip(self.extra);
			self.persData.extraAmmoStock = self getweaponammostock(self.extra);
		}
		
		self.firingWeapon = false;
	}
}

thunderBlast(dam, realdam, player) {
						
	direction = (0,0,0);
	oldhealth = player.health;
	player unlink();
	for (ii=0; ii<4; ii++)
	{
		if (ii==0) { direction = (0,0,1); }
		if (ii==1) { direction = vectorNormalize(player.origin+(0,0,20)-self.origin); }
		player.health = player.health + dam;		
		if (isalive(player)) {
		player finishPlayerDamage(self, self, dam, 0, "MOD_PROJECTILE", "thundergun_mp", direction, direction, "none", 0);
		}
		wait 0.05;
	}
	wait .05;
	player.health = oldhealth;
	//iprintlnbold(oldhealth);
	if (realdam >= player.health) {
		player finishPlayerDamage(self, self, dam, 0, "MOD_PROJECTILE", "thundergun_mp", direction, direction, "none", 0);
	}
	else {
		
		player thread [[level.callbackPlayerDamage]](
			self, // eInflictor The entity that causes the damage.(e.g. a turret)
			self, // eAttacker The entity that is attacking.
			realdam, // iDamage Integer specifying the amount of damage done
			0, // iDFlags Integer specifying flags that are to be applied to the damage
			"MOD_EXPLOSIVE", // sMeansOfDeath Integer specifying the method of death
			"g3_acog_mp", // sWeapon The weapon number of the weapon used to inflict the damage
			self.origin, // vPoint The point the damage is from?
			direction, // vDir The direction of the damage
			"none", // sHitLoc The location of the hit
			0 // psOffsetTime The time offset for the damage
		);
	}
	//player mod\_mod::PlayerDamage(self, self, realdam, 0, "MOD_PROJECTILE", "thundergun_mp", direction, direction, "none", 0);
}

removeEntOnDowned(ent) {
	self endon( "end_firing" );
	self waittill("downed");
	ent stopLoopSound("flamethrower_fire_npc");
	ent delete();
}


removeEntOnDeath(ent) {
	self endon( "end_firing" );
	self waittill("death");
	ent stopLoopSound("flamethrower_fire_npc");
	ent delete();
}

removeEntOnDisconnect(ent) {
	self endon( "end_firing" );
	self waittill("death");
	ent delete();
}

minigunQuake() {
	self endon( "death" );
	self endon( "downed" );
	self endon( "disconnect" );
	self endon( "end_firing" );
	
	while (1) {
		Earthquake( 0.2, .2, self.origin, 240);
		wait .1;
	}
}

alertTillEndFiring()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "end_firing" );
	
	while (1)
	{
		curWeapon = self getCurrentWeapon();
		if (curWeapon == "none")
		return;
		
		if (weaponIsBoltAction(curWeapon))
		scripts\bots\_bots::alertZombies(self.origin, 1024, 200, undefined);
		else if (WeaponIsSemiAuto(curWeapon))
		scripts\bots\_bots::alertZombies(self.origin, 1024, 100, undefined);
		else
		scripts\bots\_bots::alertZombies(self.origin, 1024, 100, undefined);
		wait .5;
		
	}
}

watchWeaponSwitching()
{	
	self endon("death");
	self endon("disconnect");
	lastWeapon = "none";
	for ( ;; )
	{
		lastWeapon = self getCurrentWeapon();
		self waittill( "weapon_change" );
		
		currentWeapon = self getCurrentWeapon();
		if(lastWeapon != currentWeapon && currentWeapon != "none")
			self thread rotateActionslotWeapons(currentWeapon);
		switch( currentWeapon )
		{
			// case "saw_acog_mp":
			// break;
			case "helicopter_mp":
				//self thread scripts\players\_parachute::parachute();
				
				//if ( lastWeapon != "none" )
				//	self switchToWeapon( lastWeapon );
				break;
			case "none":
				break;

			default:
				lastWeapon = self getCurrentWeapon();
				break;
		}

	}
}

/* Look if the current weapon is in your actionslot.
When switching the weapon, the actionslot should be replaced with another actionslot item in order
to make rotating easier for the player */
rotateActionSlotWeapons(weapon){
	if(isActionslotWeapon(weapon) && self.actionslotweapons.size > 1){
		for(i = 0; i < self.actionslotweapons.size; i++){
			if(!self hasWeapon(self.actionslotweapons[i])){
				self.actionslotweapons = removeFromArray(self.actionslotweapons, self.actionslotweapons[i]);
				i = 0;
			}
		}
		if(self.actionslotweapons.size > 1)
			self.actionslotweapons = removeFromArray(self.actionslotweapons, weapon);
		self setActionSlot( 4, "weapon", self.actionslotweapons[0] );
		self.actionslotweapons[self.actionslotweapons.size] = weapon;
	}
}

isActionslotWeapon(weapon){
	for(i = 0; i < self.actionslotweapons.size; i++)
		if(weapon == self.actionslotweapons[i])
			return true;
	return false;
}

swapWeapons(type, weapon)
{
	switch (type)
	{
	case "primary":
		if (self.primary != "none")
			self takeweapon(self.primary);
		self giveWeapon( weapon ); 
		self giveMaxAmmo( weapon );
		self SwitchToWeapon( weapon );
		self.primary = weapon;
		self.persData.primary = self.primary;
		self.persData.primaryAmmoClip = self getWeaponAmmoClip(self.primary);
		self.persData.primaryAmmoStock = self GetWeaponAmmoStock(self.primary);
		break;
		case "secondary":
		if (self.secondary != "none")
			self takeweapon(self.secondary);
		self giveWeapon( weapon ); 
		self giveMaxAmmo( weapon );
		self SwitchToWeapon( weapon );
		self.secondary = weapon;
		self.persData.secondary = self.secondary;
		self.persData.secondaryAmmoClip = self getWeaponAmmoClip(self.secondary);
		self.persData.secondaryAmmoStock = self GetWeaponAmmoStock(self.secondary);
		break;
		case "extra":
			if (self.extra != "none")
				self takeweapon(self.extra);
			self giveWeapon( weapon ); 
			self giveMaxAmmo( weapon );
			self SwitchToWeapon( weapon );
			self.extra = weapon;
			self.persData.extra = self.extra;
			self.persData.extraAmmoClip = self getWeaponAmmoClip(self.extra);
			self.persData.extraAmmoStock = self GetWeaponAmmoStock(self.extra);
		break;
		case "grenade":
			self giveWeapon( weapon ); 
			self giveMaxAmmo( weapon );
		break;
	}
}

isSniper(weapon)
{
	if ( weapon == "m21_mp" )
		return true;
	if ( weapon == "barrett_mp" )
		return true;
	if ( weapon == "m40a3_mp" )
		return true;
	if ( weapon == "remington700_mp" )
		return true;
	if ( weapon == "remington700_acog_mp" )
		return true;
	if (weapon == "deserteagle_mp" )
		return true;
	return false;
}

isRifle(weapon)
{
	if ( isSubStr( weapon, "ak47_" ) )
		return true;
	if ( isSubStr( weapon, "m16_" ) )
		return true;
	if ( isSubStr( weapon, "g3_" ) )
		return true;
	if ( isSubStr( weapon, "g36c_" ) )
		return true;
	if ( isSubStr( weapon, "m4_" ) )
		return true;
	if ( isSubStr( weapon, "m14" ) )
		return true;
	if ( isSubStr( weapon, "mp44" ) )
		return true;
	if (weapon == "uzi_acog_mp" )
		return true;
	if (weapon == "rpd_acog_mp" )
		return true;
	return false;
}

isShotgun(weapon)
{
	if ( weapon == "m60e4_acog_mp" )
		return true;
	if ( weapon == "m1014_grip_mp" )
		return true;
	if ( weapon == "m1014_reflex_mp" )
		return true;
	if ( weapon == "winchester1200_grip_mp" )
		return true;
	
	return false;
}

isLMG(weapon)
{
	if ( weapon == "rpd_reflex_mp" )
		return true;
	if ( weapon == "saw_reflex_mp" )
		return true;
	if ( weapon == "saw_mp" )
		return true;
		
	return false;
}

isSMG(weapon)
{
	if ( isSubStr( weapon, "mp5" ) )
		return true;
	if ( isSubStr( weapon, "ak74u" ) )
		return true;
	if ( isSubStr( weapon, "p90" ) )
		return true;
	if ( isSubStr( weapon, "uzi" ) )
		return true;
	if ( isSubStr( weapon, "skorpion" ) )
		return true;
		
	return false;
}

isExplosive(weapon)
{
	if ( weapon == "c4_mp" )
		return true;
	if ( weapon == "claymore_mp" )
		return true;
	if ( weapon == "rpg_mp" )
		return true;
	if ( weapon == "at4_mp" )
		return true;
	if ( weapon == "usp_silencer_mp" )
		return true;
	if ( weapon == "dragunov_acog_mp" )
		return true;

	return false;
}

isPistol(weapon)
{
	if ( isSubStr( weapon, "beretta" ) )
		return true;
	if ( isSubStr( weapon, "usp" ) )
		return true;
	if ( isSubStr( weapon, "colt45" ) )
		return true;
	if ( isSubStr( weapon, "deserteaglegold" ) )
		return true;
		
	return false;
}

isSilenced( weapon)
{
	if ( weapon == "colt45_silencer_mp" )
		return true;
	if ( weapon == "p90_silencer_mp" )
		return true;
	if ( weapon == "skorpion_silencer_mp" )
		return true;
	if ( weapon == "uzi_silencer_mp" )
		return true;
	if ( weapon == "g36c_silencer_mp" )
		return true;
	return false;
}

watchThrowable()
{
	self endon("death");
	self endon("disconnect");
	self endon("zombify");
	self thread triggerThrowable();
	
	while(1)
	{
		self waittill( "grenade_fire", c4, weapname );
		if ( weapname == "c4" || weapname == "c4_mp" )
		{
			//if ( !self.c4array.size )
			//	self thread watchC4AltDetonate();
			if( self.c4array.size >= level.dvar["game_max_c4"] ){
				for(i = 0; i < self.c4array.size; i++)
					if( !isDefined( self.c4array[i] ) )
						self.c4array = removeFromArray( self.c4array, self.c4array[i] );
			}
			if( self.c4array.size >= level.dvar["game_max_c4"] ){
				c4 delete();
				self iprintlnbold("You can only put down " + level.dvar["game_max_c4"] + " C4 max.!");
				self setWeaponAmmoClip( self getCurrentWeapon(), self getWeaponAmmoClip(self getCurrentWeapon()) + 1 );
				continue;
			}
			self.c4array[self.c4array.size] = c4;
			c4.owner = self;
			c4.activated = false;
			
			c4 thread maps\mp\gametypes\_shellshock::c4_earthQuake();
			//c4 thread c4Activate();
			c4 thread c4Damage();
			c4 thread playC4Effects();
		}
		else if(weapname == "frag_grenade_mp")
			self playsound("throw_grenade");
	}
}

watchMonkey()
{
	self endon("death");
	self endon("disconnect");	
	while(1)
	{
		self waittill( "grenade_fire", monkey, weapname );
		if ( weapname == "usp_silencer_mp")//monkey bomb
		{		
			level.monkeyEntities[level.monkeyEntities.size] = monkey;
			monkey.index = level.monkeyEntitiesIndex;
			monkey.isMonkey = true;
			monkey.isTargetable = true;
			if(!self.isDown)
				self thread scripts\players\_abilities::restoreMonkey(level.special["monkey_bomb"]["recharge_time"]);
			monkey waitTillNotMoving();
			monkey thread ExplodeTime();
			level.monkeyEntitiesIndex++;
			level notify("monkey_bomb");
		}
	}
}

waitTillNotMoving()
{
	self endon("death");

	prevorigin = self.origin;
	while(1)
	{
		wait .1;
		if ( self.origin == prevorigin )
			break;
		prevorigin = self.origin;
	}
}

ExplodeTime()
{
	PlayFx(level.monkeyEffect, self.origin, (0,0,90));

	wait 3.5;
	level.monkeyEntities = removeFromArray(level.monkeyEntities, self);
	self.isTargetable = false;
	self detonate();
	level notify("monkey_bomb_exploded");
}

triggerThrowable()
{
	self endon("death");
	self endon("disconnect");
	self endon("zombify");
	while (1)
	{
		self waittill( "detonate" );
		weap = self getCurrentWeapon();
		if ( weap == "c4_mp" )
		{
			for ( i = 0; i < self.c4Array.size; i++ )
			{
				c4 = self.c4Array[i];
				if ( isdefined(self.c4Array[i]) )
				{
						c4 thread waitAndDetonate( 0.1 );
				}
			}
			self.c4array = [];
			self notify ( "detonated" );
		}
	}
}

waitAndDetonate( delay )
{
	self endon("death");
	wait delay;

	self detonate();
}

playC4Effects()
{
	self endon("death");
	self waittill("activated");
	
	while(1)
	{
		org = self getTagOrigin( "tag_fx" );
		ang = self getTagAngles( "tag_fx" );
		
		fx = spawnFx( level.C4FXid, org, anglesToForward( ang ), anglesToUp( ang ) );
		triggerfx( fx );
		
		self thread clearFXOnDeath( fx );
		
		originalOrigin = self.origin;
		
		while(1)
		{
			wait .25;
			if ( self.origin != originalOrigin )
				break;
		}
		
		fx delete();
		//self waittillNotMoving();
	}
}

c4Damage()
{
	self endon( "death" );
	self setcandamage(true);
	self.maxhealth = 100000;
	self.health = self.maxhealth;
	
	attacker = undefined;
	
	while(1)
	{
		self waittill ( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags );
		if ( !isplayer(attacker) )
			continue;
		
		// don't allow people to destroy C4 on their team if FF is off
		if ( self.owner != attacker && !level.dvar["game_friendlyfire"] )
			continue;
		
		if ( damage < 5 ) // ignore concussion grenades
			continue;
		
		break;
	}
	
	if ( level.c4explodethisframe )
		wait .1 + randomfloat(.4);
	else
		wait .05;
	
	if (!isdefined(self))
		return;
	
	level.c4explodethisframe = true;
	
	thread resetC4ExplodeThisFrame();
	
	if ( isDefined( type ) && (isSubStr( type, "MOD_GRENADE" ) || isSubStr( type, "MOD_EXPLOSIVE" )) )
		self.wasChained = true;
	
	if ( isDefined( iDFlags ) && (iDFlags & level.iDFLAGS_PENETRATION) )
		self.wasDamagedFromBulletPenetration = true;
	
	self.wasDamaged = true;
	
	// "destroyed_explosive" notify, for challenges
	if ( isdefined( attacker ) && isdefined( attacker.pers["team"] ) && isdefined( self.owner ) && isdefined( self.owner.pers["team"] ) )
	{
		if ( attacker.pers["team"] != self.owner.pers["team"] )
			attacker notify("destroyed_explosive");
	}
	/* Make sure to remove the c4 from the owner's array to fix faildetection of already exploded c4 */
	if( isDefined( self.owner ) ){
		self.owner.c4array = removeFromArray( self.owner.c4array, self );
	}
	self detonate( attacker );
	// won't get here; got death notify.
}

resetC4ExplodeThisFrame()
{
	wait .05;
	level.c4explodethisframe = false;
}

clearFXOnDeath( fx )
{
	fx endon("death");
	self waittill("death");
	fx delete();
}
