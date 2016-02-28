//
// vim: set ft=cpp:
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
#include scripts\include\weapons;
#include scripts\include\data;

init()
{
	level.onGiveWeapons = -1;
	level.spawnPrimary = "none";
	level.spawnSecondary = "none";
	level.monkeyEntitiesIndex = 0;
	
	level.specialWeps = [];
	
	// number of weapons for players
	max_weapon_num = 110;

	// generating weaponlist array
	level.weaponList = [];
	level.weaponKeyS2C = [];
	level.weaponKeyC2S = [];
	for( i = 0; i < max_weapon_num; i++ )
	{
		weapon_name = tableLookup( "mp/weaponTable.csv", 0, i, 2 );
		if( !isDefined(weapon_name) || weapon_name == "" )
			continue;
		
		console_name = tableLookup( "mp/weaponTable.csv", 0, i, 3 );
		// whenever we give a weapon, etc. we need the actual console name of the weapon
		// these two arrays hold the names for easy converting
		level.weaponKeyS2C[weapon_name] = console_name;
		level.weaponKeyC2S[console_name] = weapon_name;
		
		if( weapon_name == "none" )
			continue;
		
		// this array stores various infos about the weapons as tableLookup is a demanding function and we don't want to call it whenever
		// maybe we will need it later, for now we don't really bother
		level.weaponList[weapon_name] = [];
		level.weaponList[weapon_name]["class"] = tableLookup( "mp/weaponTable.csv", 0, i, 1 );
		
		precacheItem( console_name );
		print( "Precached weapon: " + weapon_name + " (" + console_name + ")\n" );	
	}

	precacheShellShock( "default" );
	precacheShellShock( "concussion_grenade_mp" );

	level.monkeyEffect = loadfx( "monkey_grenade/monkey_grenade_onfloor" );
	level.monkeyEntities = [];

	claymoreDetectionConeAngle = 70;
	level.claymoreDetectionDot = cos( claymoreDetectionConeAngle );
	level.claymoreDetectionMinDist = 20;
	level.claymoreDetectionGracePeriod = 0.75;
	level.claymoreDetonateRadius = 150;

	level.C4explodeThisFrame = false;
	level.C4FXid = loadfx( "bo_crossbow/light_crossbow_blink" );//For the new crossbow, we need to replace this
	//level.C4FXid = loadfx( "misc/light_c4_blink" ); //Old One
	level.claymoreFXid = loadfx( "misc/claymore_laser" );
}

isSpecialWeap( weap )
{
	for( i = 0; i < level.specialWeps.size; i++ )
	{
		if( level.specialWeps[i] == weap )
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

givePlayerWeapons()
{
	self.primary = self.persData.primary;
	self.secondary = self.persData.secondary;
	self.extra = self.persData.extra;

	if( self.secondary != "none" && self.secondary != "" )
	{
		self giveWeap( self.secondary );
		self setSpawnWeap( self.secondary );
		self setWeapAmmoStock( self.secondary, self.persData.secondaryAmmoStock );
		self setWeapAmmoClip( self.secondary, self.persData.secondaryAmmoClip );
	}

	if( self.primary != "none" && self.primary != "" )
	{
		self giveWeap( self.primary ); 
		self setSpawnWeap( self.primary );
		self setWeapAmmoStock( self.primary, self.persData.primaryAmmoStock );
		self setWeapAmmoClip( self.primary, self.persData.primaryAmmoClip );
	}

	if( self.extra != "none" && self.extra != "" )
	{
		self giveWeap( self.extra );
		self setWeapAmmoStock( self.extra, self.persData.extraAmmoStock );
		self setWeapAmmoClip( self.extra, self.persData.extraAmmoClip );
	}
}

canRestoreAmmo( wep )
{
	if( wep == "helicopter_mp" || scripts\players\_weapons::isSpecialWeap( wep ) || wep == "m14_reflex_mp" /* Ammobox */ || wep == "none" || wep == level.weapons["flash"] /* Monkey Bomb */)
		return false;
		
	return true;
}

watchWeaponUsage()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "downed" );
	//level endon ( "game_ended" );
	
	self.firingWeapon = false;
	
	while( 1 )
	{
		self waittill ( "begin_firing" );
		
		weap = self getCurrentWeap();
		
		self.hasDoneCombat = true;
		self.firingWeapon = true;	

		self waittill( "end_firing" );
		
		self.firingWeapon = false;
	}
}

alertTillEndFiring()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "end_firing" );
	
	while( 1 )
	{
		curWeapon = self getCurrentWeapon();
		
		if ( curWeapon == "none" )
			return;
		
		if ( weaponIsBoltAction( curWeapon ) )
			scripts\bots\_bots::alertZombies( self.origin, 1024, 200, undefined );
		else if ( weaponIsSemiAuto( curWeapon ) )
			scripts\bots\_bots::alertZombies( self.origin, 1024, 100, undefined );
		else
			scripts\bots\_bots::alertZombies( self.origin, 1024, 100, undefined );
			
		wait .5;
		
	}
}

watchWeaponSwitching()
{	
	self endon( "death" );
	self endon( "disconnect" );

	lastWeapon = self getCurrentWeap();
	while( 1 )
	{
		self waittill( "weapon_change", weapon );
		
		if( weapon == "none" )
			continue;
		
		self thread watchWeaponUsageSingle();
		self thread watchWeaponReload();
		
		weapon = level.weaponKeyC2S[weapon];
		if( lastWeapon != weapon )
			self thread rotateActionslotWeapons( weapon );
		
		lastWeapon = weapon;
	}
}

/**
* Keeps track of the ammo in the magazine of the gun.
*/
watchWeaponUsageSingle()
{
	self endon( "weapon_change" );
	self endon( "disconnect" );
	self endon( "death" );
	
	weap = self getCurrentWeap();
	if( weap == self.primary )
	{
		self setClientDvars( "ui_ammo_clip", self.persData.primaryAmmoClip, "ui_ammo_stock", self.persData.primaryAmmoStock, "ui_ammo_show", 1);
	}
	else if( weap == self.secondary )
	{
		self setClientDvars( "ui_ammo_clip", self.persData.secondaryAmmoClip, "ui_ammo_stock", self.persData.secondaryAmmoStock, "ui_ammo_show", 1 );
	}
	else if( weap == self.extra )
	{
		self setClientDvars( "ui_ammo_clip", self.persData.extraAmmoClip, "ui_ammo_stock", self.persData.extraAmmoStock, "ui_ammo_show", 1 );
	}
	else
	{
		ammoClip = self getWeapAmmoClip( weap );
		ammoStock = self getWeapAmmoStock( weap );
		self setClientDvars( "ui_ammo_clip", ammoClip, "ui_ammo_stock", ammoStock, "ui_ammo_show", 1 );
	}

	for(;;)
	{
		self waittill( "weapon_fired" );
		
		if( weap == self.primary )
		{
			self.persData.primaryAmmoClip--;
			
			self setClientDvar( "ui_ammo_clip", self.persData.primaryAmmoClip );
		}
		else if( weap == self.secondary )
		{
			self.persData.secondaryAmmoClip--;
			
			self setClientDvar( "ui_ammo_clip", self.persData.secondaryAmmoClip );
		}
		else if( weap == self.extra )
		{
			self.persData.extraAmmoClip--;
			
			self setClientDvar( "ui_ammo_clip", self.persData.extraAmmoClip );
		}
		else
		{
			ammoClip = self getWeapAmmoClip( weap );
			
			self setClientDvar( "ui_ammo_clip", ammoClip );
		}
	}
}

watchWeaponReload()
{
	self endon( "weapon_change" );
	self endon( "disconnect" );
	self endon( "death" );
	
	weap = self getCurrentWeap();
	
	for(;;)
	{
		self waittill( "reload" );
		
		if( weap == self.primary )
		{
			self.persData.primaryAmmoClip = self getWeapAmmoClip( self.primary );
			self.persData.primaryAmmoStock = self getWeapAmmoStock( self.primary );
			
			self setClientDvars( "ui_ammo_clip", self.persData.primaryAmmoClip, "ui_ammo_stock", self.persData.primaryAmmoStock );
		}
		else if( weap == self.secondary )
		{
			self.persData.secondaryAmmoClip = self getWeapAmmoClip( self.secondary );
			self.persData.secondaryAmmoStock = self getWeapAmmoStock( self.secondary );
			
			self setClientDvars( "ui_ammo_clip", self.persData.secondaryAmmoClip, "ui_ammo_stock", self.persData.secondaryAmmoStock );
		}
		else if( weap == self.extra )
		{
			self.persData.extraAmmoClip = self getWeapAmmoClip( self.extra );
			self.persData.extraAmmoStock = self getWeapAmmoStock( self.extra );
			
			self setClientDvars( "ui_ammo_clip", self.persData.extraAmmoClip, "ui_ammo_stock", self.persData.extraAmmoStock );
		}
		else
		{
			ammoClip = self getWeapAmmoClip( weap );
			ammoStock = self getWeapAmmoStock( weap );
			self setClientDvars( "ui_ammo_clip", ammoClip, "ui_ammo_stock", ammoStock );
		}
	}
}

/* Look if the current weapon is in your actionslot.
When switching the weapon, the actionslot should be replaced with another actionslot item in order
to make rotating easier for the player */
rotateActionSlotWeapons( weapon )
{
	if( isActionslotWeapon( weapon ) && self.actionslotweapons.size > 1 )
	{
		for( i = 0; i < self.actionslotweapons.size; i++ )
		{
			if( !self hasWeap( self.actionslotweapons[i] ) )
			{
				self.actionslotweapons = removeFromArray( self.actionslotweapons, self.actionslotweapons[i] );
				i = 0;
			}
		}
		
		if( self.actionslotweapons.size > 1 )
			self.actionslotweapons = removeFromArray( self.actionslotweapons, weapon );
		
		self setActionSlot( 4, "weapon", level.weaponKeyS2C[self.actionslotweapons[0]] );
		self.actionslotweapons[self.actionslotweapons.size] = weapon;
	}
}

isActionslotWeapon( weapon )
{
	for( i = 0; i < self.actionslotweapons.size; i++ )
	{
		if( weapon == self.actionslotweapons[i] )
			return true;
	}

	return false;
}

swapWeapons( type, weapon )
{
	switch ( type )
	{
	case "primary":
		if( self.primary != "none" && self.primary != "" )
			self takeWeap( self.primary );
		
		self giveWeap( weapon ); 
		self giveWeapMaxAmmo( weapon );
		self switchToWeap( weapon );
		
		self.primary = weapon;
		self.persData.primary = self.primary;
		self.persData.primaryAmmoClip = self getWeapAmmoClip( self.primary );
		self.persData.primaryAmmoStock = self getWeapAmmoStock( self.primary );
		break;
	case "secondary":
		if( self.secondary != "none" && self.secondary != "" )
			self takeWeap( self.secondary );
		
		self giveWeap( weapon ); 
		self giveWeapMaxAmmo( weapon );
		self switchToWeap( weapon );
		
		self.secondary = weapon;
		self.persData.secondary = self.secondary;
		self.persData.secondaryAmmoClip = self getWeapAmmoClip( self.secondary );
		self.persData.secondaryAmmoStock = self getWeapAmmoStock( self.secondary );
		break;
	case "extra":
		if( self.extra != "none" && self.extra != "" )
			self takeWeap( self.extra );
		
		self giveWeap( weapon ); 
		self giveWeapMaxAmmo( weapon );
		self switchToWeap( weapon );
		
		self.extra = weapon;
		self.persData.extra = self.extra;
		self.persData.extraAmmoClip = self getWeapAmmoClip( self.extra );
		self.persData.extraAmmoStock = self getWeapAmmoStock( self.extra );
		break;
	case "grenade":
		self giveWeap( weapon ); 
		self giveWeapMaxAmmo( weapon );
		break;
	}
}

isSniper( weapon )
{
	if( level.weaponList[weapon]["class"] == "weapon_sniper" )
		return true;

	return false;
}

isRifle( weapon )
{
	if( level.weaponList[weapon]["class"] == "weapon_assault" )
		return true;

	return false;
}

isShotgun( weapon )
{
	if( level.weaponList[weapon]["class"] == "weapon_shotgun" )
		return true;

	return false;
}

isLMG( weapon )
{
	if( level.weaponList[weapon]["class"] == "weapon_lmg" )
		return true;

	return false;
}

isSMG( weapon )
{
	if( level.weaponList[weapon]["class"] == "weapon_smg" )
		return true;

	return false;
}

isExplosive( weapon )
{
	if( level.weaponList[weapon]["class"] == "weapon_explosive" )
		return true;

	return false;
}

isPistol( weapon )
{
	if( level.weaponList[weapon]["class"] == "weapon_pistol" )
		return true;

	return false;
}

isSilenced( weapon )
{
	return isSubStr( weapon, "_silencer_" );
}

watchThrowable()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "zombify" );
	self thread triggerThrowable();
	
	while(1)
	{
		self waittill( "grenade_fire", c4, weapname );
		if( weapname == "c4" || weapname == "c4_mp" )
		{
			//if ( !self.c4array.size )
			//	self thread watchC4AltDetonate();
			if( self.c4array.size >= level.dvar["game_max_c4"] )
			{
				for( i = 0; i < self.c4array.size; i++ )
					if( !isDefined( self.c4array[i] ) )
						self.c4array = removeFromArray( self.c4array, self.c4array[i] );
			}
			if( self.c4array.size >= level.dvar["game_max_c4"] )
			{
				c4 delete();
				self iprintlnbold( "You can only put down " + level.dvar["game_max_c4"] + " C4 max.!" );
				self setWeaponAmmoClip( self getCurrentWeapon(), self getWeaponAmmoClip( self getCurrentWeapon() ) + 1 );
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
		else if( weapname == "frag_grenade_mp" )
			self playsound( "throw_grenade" );
	}
}

watchMonkey()
{
	self endon( "death" );
	self endon( "disconnect" );	
	
	while( 1 )
	{
		self waittill( "grenade_fire", monkey, weapname );
		weapname = level.weaponKeyS2C[weapname];
		
		if( weapname == "monkey_mp" )	// monkey bomb
		{
			level.monkeyEntities[level.monkeyEntities.size] = monkey;
			
			monkey.index = level.monkeyEntitiesIndex;
			monkey.isMonkey = true;
			monkey.isTargetable = true;
			
			if( !self.isDown )
				self thread scripts\players\_abilities::restoreMonkey( level.special["monkey_bomb"]["recharge_time"] );
				
			monkey waitTillNotMoving();
			
			monkey thread explodeTime();
			
			level.monkeyEntitiesIndex++;
			level notify( "monkey_bomb" );
		}
	}
}

waitTillNotMoving()
{
	self endon( "death" );

	prevorigin = self.origin;
	while( 1 )
	{
		wait 0.1;
		if( self.origin == prevorigin )
			break;
		prevorigin = self.origin;
	}
}

explodeTime()
{
	PlayFx( level.monkeyEffect, self.origin, ( 0, 0, 90 ) );

	wait 3.5;
	level.monkeyEntities = removeFromArray( level.monkeyEntities, self );
	self.isTargetable = false;
	self detonate();
	level notify( "monkey_bomb_exploded" );
}

triggerThrowable()
{
	self endon( "death");
	self endon( "disconnect" );
	self endon( "zombify" );
	while( 1 )
	{
		self waittill( "detonate" );
		weap = self getCurrentWeap();
		
		if( weap == "c4_mp" )
		{
			for( i=0; i<self.c4Array.size; i++ )
			{
				c4 = self.c4Array[i];
				if( isdefined( c4 ) )
					c4 thread waitAndDetonate( 0.1 );
			}
			self.c4array = [];
			self notify ( "detonated" );
		}
	}
}

waitAndDetonate( delay )
{
	self endon( "death" );
	wait delay;

	self detonate();
}

playC4Effects()
{
	self endon( "death" );
	self waittill( "activated" );
	
	while( 1 )
	{
		org = self getTagOrigin( "tag_fx" );
		ang = self getTagAngles( "tag_fx" );
		
		fx = spawnFx( level.C4FXid, org, anglesToForward( ang ), anglesToUp( ang ) );
		triggerfx( fx );
		
		self thread clearFXOnDeath( fx );
		
		originalOrigin = self.origin;
		
		while( 1 )
		{
			wait 0.25;
			if( self.origin != originalOrigin )
				break;
		}
		
		fx delete();
		//self waittillNotMoving();
	}
}

c4Damage()
{
	self endon( "death" );
	self setCanDamage( true );
	self.maxhealth = 100000;
	self.health = self.maxhealth;
	
	attacker = undefined;
	
	while( 1 )
	{
		self waittill ( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags );
		if ( !isPlayer( attacker ) )
			continue;
		
		// don't allow people to destroy C4 on their team if FF is off
		if ( self.owner != attacker && !level.dvar["game_friendlyfire"] )
			continue;
		
		if ( damage < 5 ) // ignore concussion grenades
			continue;
		
		break;
	}
	
	if( level.c4explodethisframe )
		wait 0.1 + randomFloat( 0.4 );
	else
		wait 0.05;
	
	if( !isDefined( self ) )
		return;
	
	level.c4explodethisframe = true;
	
	thread resetC4ExplodeThisFrame();
	
	if( isDefined( type ) && ( isSubStr( type, "MOD_GRENADE" ) || isSubStr( type, "MOD_EXPLOSIVE" ) ) )
		self.wasChained = true;
	
	if( isDefined( iDFlags ) && ( iDFlags & level.iDFLAGS_PENETRATION ) )
		self.wasDamagedFromBulletPenetration = true;
	
	self.wasDamaged = true;
	
	// "destroyed_explosive" notify, for challenges
	if( isdefined( attacker ) && isdefined( attacker.pers["team"] ) && isdefined( self.owner ) && isdefined( self.owner.pers["team"] ) )
	{
		if ( attacker.pers["team"] != self.owner.pers["team"] )
			attacker notify( "destroyed_explosive" );
	}
	/* Make sure to remove the c4 from the owner's array to fix faildetection of already exploded c4 */
	if( isDefined( self.owner ) )
	{
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
	fx endon( "death" );
	self waittill( "death" );
	fx delete();
}
