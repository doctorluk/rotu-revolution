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

#include scripts\include\hud;
#include scripts\include\data;
#include scripts\include\useful;
#include scripts\include\physics;
#include scripts\include\weapons;
#include common_scripts\utility;

init()
{
	precache();
	loadAbilityStats();
	level.weapons["flash"] = "usp_silencer_mp"; // We change the actual Flash Grenade to the Monkey Bomb, so we can use it as "Special Grenade" with instant-throw
	level.armoredDomes = [];
}

precache()
{
	level.heal_glow_body		= loadfx( "misc/heal_glow_body");
	level.heal_glow_effect 		= loadfx( "misc/heal_glow");
	level.healingEffect    		= loadfx( "misc/healing" );
	
	precacheModel( "armored_dome" );
	
	precacheShader( "icon_medkit_placed" );
	precacheShader( "icon_ammobox_placed" );
}

loadAbilityStats()
{
	level.special["fake_death"]["recharge_time"] = 55;
	level.special["fake_death"]["duration"] = 15;
	
	level.special["smoke_grenade"]["recharge_time"] = 5;		// TODO: This is for debugging, get a more realistic time
	
	level.special["rampage"]["recharge_time"] = 50;
	level.special["rampage"]["duration"] = 15;
	
	level.special["aura"]["recharge_time"] = 60;
	level.special["aura"]["duration"] = 20;
	
	level.special["armoredshield"]["radius"] = 500 / 2.54; // 500cm in Maya to inches
	level.special["armoredshield"]["recharge_time"] = 25;
	level.special["armoredshield"]["duration"] = 60;
	level.special["armoredshield"]["damagereduction"] = 0.6;
	
	level.special["invincible"]["recharge_time"] = 60;
	level.special["invincible"]["duration"] = 20;
	
	level.special["escape"]["recharge_time"] = 40;
	level.special["escape"]["duration"] = 10;
	
	level.special["ammo"]["recharge_time"] = 75;
	level.special["augmentation"]["recharge_time"] = 1;
	
	level.special["medkit"]["recharge_time"] = 60;
	
	level.special["monkey_bomb"]["recharge_time"] = 65;
	
	level.special_quickescape_duration = 6;
	level.special_quickescape_intermission = 15;
	level.special_stealthmove_intermission = 10;
}

stopActiveAbility()
{ // Makes sure to stop assassin/soldier/scout special when downed

	self playerFilmTweaksOff();
	self.trance = "";
	self.inTrance = false;
	self.visible = true;
	self setMoveSpeedScale( self.speed );
	self unSetPerk( "specialty_rof" );
	
	if ( !self.hasFastReload )
		self unSetPerk( "specialty_fastreload" );
		
	if( self.hud_streak.alpha != 0 ) // Removes the Killing Spree Number on the Screen
		self.hud_streak.alpha = 0;

}

resetAbilities()
{
	self notify( "reset_abilities" );
	
	self.stealthMp = 1;
	self.maxhealth = 100;
	self.speed = 1;
	self.revivetime = level.dvar["surv_revivetime"];
	
	self clearPerks();
	self setStableMissile( 0 );
	
	if( isDefined( self.armored_hud ) )
		self.armored_hud destroy();
	
	self.canAssasinate = false;
	self.isHitman = false;
	self.focus = -1;
	self.weaponMod = "";
	self.knifeMod = "";
	self.bulletMod = "";
	self.knifeDamageMP = 1;
	self.weaponNoiseMP = 1;
	self.immune = false;
	self.transfusion = false;
	self.lastTransfusion = false;
	self.canCure = false;
	self.hasMedicine = false;
	self.canSearchBodies = false;
	self.explosiveExpert = false;
	self.heavyArmor = false;
	self.specialtyReload = false;
	self.hasFastReload = false;
	self.hasRadar = false;
	self.damageDoneMP = 1;
	self.infectionMP = 1;
	self.canZoom = true;
	self.chargedGrenades = false;
	self.headshotMP = 1;
	self.medkitTime = 12;
	self.medkitHealing = 25;
	self.auraHealing = 35;
	
	if( !isDefined( self.specialRecharge ) )
		self.specialRecharge = 0;
		
	self.longerTurrets = false;
	self.reviveWill = false;
	self.toxicImmunity = false;
	self.accuracyOverwrite = 6;
	self.special["ability"] = "none";
	self.special["recharge_time"] = 60;
	self.special["duration"] = 10;
}


getDamageModifier( weapon, means, target, damage )
{
	if( weapon == "none" || weapon == "turret_mp" )
		return 1;

	MP = 1;

	// class damage modifiers
	if( isSubStr( self.weaponMod, "soldier" ) )
	{
		if( scripts\players\_weapons::isRifle( weapon ) )
			MP += .1;
	}
	if( isSubStr( self.weaponMod, "assassin") )		// would a else if also do, or can you actually have multiple?
	{
		if( !WeaponIsBoltAction( weapon ) && !WeaponIsSemiAuto( weapon ) )
			MP -= .15;
		else
			MP += .05;
		if( !scripts\players\_weapons::isSilenced( weapon ) )
			MP -= .15;
		else
			MP += .05;
	}
	if( isSubStr( self.weaponMod, "hitman" ) )
	{
		if( !WeaponIsBoltAction( weapon ) && !WeaponIsSemiAuto( weapon ) && means == "MOD_HEAD_SHOT" )
			MP += .45;
		if( !target scripts\bots\_bots::zomSpot( self ) )
			MP += .15;
	}
	if( isSubStr( self.weaponMod, "strength" ) )
	{
		if( means == "MOD_MELEE" )
			MP += .35;
	}
	if( isSubStr( self.weaponMod, "engineer" ) )
	{
		if( means == "MOD_EXPLOSIVE" )
			MP += .1;
		if( scripts\players\_weapons::isLMG( weapon ) || scripts\players\_weapons::isRifle( weapon ) )
			MP += .05;
		if( scripts\players\_weapons::isShotgun( weapon ) )
			MP += .1;
	}
	if( isSubStr( self.weaponMod, "armored" ) )
	{
		if( scripts\players\_weapons::isLMG( weapon ) )
			MP += .15;
		if( scripts\players\_weapons::isSniper( weapon ) || scripts\players\_weapons::isPistol( weapon ) || scripts\players\_weapons::isSMG( weapon ) )
			MP -= .15;
	}
	if( isSubStr( self.weaponMod, "lmg") )
	{
		if ( scripts\players\_weapons::isLMG( weapon ) )
			MP += .5;
	}
	if( isSubStr( self.weaponMod, "scout" ) )
	{
		if( scripts\players\_weapons::isLMG( weapon ) || scripts\players\_weapons::isRifle( weapon ) )
			MP -= .15;
		if( scripts\players\_weapons::isSniper( weapon ) || scripts\players\_weapons::isPistol( weapon ) || scripts\players\_weapons::isSMG( weapon ) )
			MP += .1;
	}
	if( isSubStr( self.knifeMod, "assassin" ) )
	{
		if( means == "MOD_MELEE" )
			MP += 1;
	}
	if( isSubStr( self.knifeMod, "armored" ) )
	{
		if( means == "MOD_MELEE" )
			MP += 0.35;
	}
	
	// weapon upgrade damage modifiers
	wpnlvl = 1;
	if( weapon == self.primary )
		wpnlvl = self.unlock["primary"] + 1;
	else if( weapon == self.secondary )
		wpnlvl = self.unlock["secondary"] + 1;
	else if( weapon == self.extra )
		wpnlvl = self.unlock["extra"] + 1;

	if( isDefined( level.dvar["surv_unlock" + wpnlvl + "_multiplier"] ) )
		MP += ( level.dvar["surv_unlock" + wpnlvl + "_multiplier"] / 100 );

//	self iPrintLn( "MP = ", MP );
	return MP;
}

getAbilityAllowed( class, rank, type, ability )
{
	if ( type == "PR" )
	{
		if ( ability == "AB1" && rank >= 5 )
			return true;
			
		if ( ability == "AB2" && rank >= 15 )
			return true;
			
		if ( ability == "AB3" && rank >= 25 )
			return true;
	}
	if ( type == "PS" )
	{
		if ( ability == "AB1" )
			return true;
			
		if ( ability == "AB2" && rank >= 10 )
			return true;
			
		if ( ability == "AB3" && rank >= 20 )
			return true;
			
		if ( ability == "AB4" && rank >= 30 )
			return true;
	}
	if ( type == "SC" )
	{
		if ( ability == "AB1" && rank >= 5 )
			return true;
			
		if ( ability == "AB2" && rank >= 10 )
			return true;
			
		if ( ability == "AB3" && rank >= 20 )
			return true;
			
		if ( ability == "AB4" )
		{
			//return true;
		}
		if ( ability == "AB5" )
		{
			//return true;
		}
	}
	
	return false;
}

loadClassAbilities( class )
{
	self resetAbilities();
	
	self loadGeneralAbilities( class );
	
	rank = scripts\players\_classes::getClassRank( class ) + 1;
	
	// General Stats
	
	// Primary Abilities
	if ( getAbilityAllowed( class, rank, "PR", "AB1" ) )
		self loadAbility( class, "PR", "AB1" );
	
	if ( getAbilityAllowed( class, rank, "PR", "AB2" ) )
		self loadAbility( class, "PR", "AB2" );
	
	if ( getAbilityAllowed( class, rank, "PR", "AB3" ) )
		self loadAbility( class, "PR", "AB3" );
	
	// Passive Abilities
	
	if ( getAbilityAllowed( class, rank, "PS", "AB1" ) )
		self loadAbility( class, "PS", "AB1" );
	
	if ( getAbilityAllowed( class, rank, "PS", "AB2" ) )
		self loadAbility( class, "PS", "AB2" );
	
	if ( getAbilityAllowed( class, rank, "PS", "AB3" ) )
		self loadAbility( class, "PS", "AB3" );
	
	if ( getAbilityAllowed( class, rank, "PS", "AB4" ) )
		self loadAbility( class, "PS", "AB4" );
	
	// Secondary Ability
	
	if ( getAbilityAllowed( class, rank, "SC", self.secondaryAbility ) )
		self loadAbility( class, "SC", self.secondaryAbility );
}

loadGeneralAbilities( class )
{
	self setPerk( "specialty_pistoldeath" );
	
	switch ( class )
	{
		case "soldier":
			self.maxhealth = 115;
		break;
		
		case "stealth":
			self.maxhealth = 100;
			self setPerk( "specialty_quieter" );
			self.speed = 1.02;
		break;
		
		case "medic":
			self.maxhealth = 110;
		break;
		
		case "scout":
			self.maxhealth = 90;
			self setPerk( "specialty_longersprint" );
			self.speed = 1.08;
		break;
		
		case "amored":
			self.maxhealth = 140;
			self.speed = 0.95;
		break;
	}
}

loadSpecialAbility( special )
{
	self.special["ability"] = special;
	
	if ( isDefined( level.special[special]["recharge_time"] ) )
		self.special["recharge_time"] = level.special[special]["recharge_time"];
	
	if ( isDefined( level.special[special]["duration"] ) )
		self.special["duration"] = level.special[special]["duration"];

	if( self.canUseSpecial )
		self setClientDvar( "ui_specialtext", "^2Special Available" );
	else
		self setClientDvar( "ui_specialtext", "^1Special Recharging" );
}

loadAbility( class, type, ability )
{
	switch ( class )
	{
		case "soldier":
			loadSoldierAbility( type, ability );
		break;
		
		case "stealth":
			loadStealthAbility( type, ability );
		break;
		
		case "medic":
			loadMedicAbility( type, ability);
		break;
		
		case "armored":
			loadArmoredAbility( type, ability );
		break;
		
		case "engineer":
			loadEngineerAbility( type, ability );
		break;
		
		case "scout":
			loadScoutAbility( type, ability );
		break;
	}

}

loadSoldierAbility( type, ability )
{
	switch ( type )
	{
		case "PR":
			self thread SOLDIER_PRIMARY( ability );
		break;
		
		case "PS":
			self thread SOLDIER_PASSIVE( ability );
		break;
	}
}
///////////////
//	SOLDIER  //
///////////////

SOLDIER_PRIMARY( ability )
{
	switch ( ability )
	{
		case "AB1":
			self setPerk( "specialty_bulletpenetration" );
			self setPerk( "specialty_bulletdamage" );
		break;
		
		case "AB2":
			self loadSpecialAbility( "rampage" );
		break;
		
		case "AB3":
			self setStableMissile( 1 );
		break;
	}
}

SOLDIER_PASSIVE( ability )
{
	switch ( ability )
	{
		case "AB1":
			self.weaponMod += "soldier";
		break;
		
		case "AB2":
			self.hasFastReload = true;
			self SetPerk( "specialty_fastreload" );
		break;
		
		case "AB3":
			self thread regenerate( 1, 1 );
		break;
		
		case "AB4":
			self.maxhealth += 5;
			self.immune = true;
			self.infectionMP = 0;
		break;
	}
}

loadStealthAbility( type, ability )
{
	switch ( type )
	{
		case "PR":
			self thread STEALTH_PRIMARY( ability );
		break;
		
		case "PS":
			self thread STEALTH_PASSIVE( ability );
		break;
	}
}

///////////////
//	STEALTH  //
///////////////

STEALTH_PRIMARY( ability )
{
	switch ( ability )
	{
		case "AB1":
			self giveWeap( "smoke_grenade_mp" );
			self setWeapAmmoClip( "smoke_grenade_mp", 0 );
			self setOffhandSecondaryClass( "smoke" );
			self thread watchSmokeGrenades();
			self thread restoreSmokeGrenade( level.special["smoke_grenade"]["recharge_time"] );
		break;
		
		case "AB2":
			self loadSpecialAbility( "fake_death" );
		break;
		
		case "AB3":
			self thread quickEscape();
			self SetMoveSpeedScale( self.speed + .2 );
		break;
	}
}

STEALTH_PASSIVE( ability )
{
	switch ( ability )
	{
		case "AB1":
			self.weaponMod += "assassin";
		break;
		
		case "AB2":
			self.knifeMod += "assassin";
		break;
		
		case "AB3":
			self thread stealthMovement();
		break;
		
		case "AB4":
			// The explosive crossbow was here
		break;
	}
}

loadMedicAbility( type, ability )
{
	switch ( type )
	{
		case "PR":
			self thread MEDIC_PRIMARY( ability );
		break;
		
		case "PS":
			self thread MEDIC_PASSIVE( ability );
		break;
	}
}

///////////////
//	MEDIC    //
///////////////

MEDIC_PRIMARY( ability )
{
	switch ( ability )
	{
		case "AB1":
			self giveWeap( "medic_mp" );
			self setWeapAmmoClip( "medic_mp", 0 );
			self setActionSlot( 3, "weapon", level.weaponKeyS2C["medic_mp"] ); // Actionslot [5]
			self thread watchMedkits();
			self thread restoreMedkit( level.special["medkit"]["recharge_time"] );
			self thread restoreMedkit( level.special["medkit"]["recharge_time"] );
		break;
		
		case "AB2":
			self loadSpecialAbility( "aura" );
		break;
		
		case "AB3":
			self.transfusion = true;
		break;
	}
}

MEDIC_PASSIVE( ability )
{
	switch ( ability )
	{
		case "AB1":
			self.revivetime -= 1.5;
		break;
		
		case "AB2":
			self.canCure = true;
			self.speed *= 1.10;
		break;
		
		case "AB3":
			self.reviveWill = true;
		break;
		
		case "AB4":
			self.bulletMod = "poison";
		break;
	}
}

loadArmoredAbility( type, ability )
{
	switch ( type )
	{
		case "PR":
			self thread ARMORED_PRIMARY( ability );
		break;
		
		case "PS":
			self thread ARMORED_PASSIVE( ability );
		break;
	}
}

///////////////
//	ARMORED  //
///////////////

ARMORED_PRIMARY( ability )
{
	switch ( ability )
	{
		case "AB1":
			// self giveWeapon( "m60e4_reflex_mp" );
			// self giveMaxAmmo( "m60e4_reflex_mp" );
			// self setActionSlot( 3, "weapon", "m60e4_reflex_mp" );
			self giveWeapon( "c4_mp" );
			self giveMaxAmmo( "c4_mp" );
			self setActionSlot( 3, "weapon", "c4_mp" );
			self thread watchArmoredDome();
			// self.actionslotweapons[self.actionslotweapons.size] = "m60e4_reflex_mp";
		break;
		
		case "AB2":
			self loadSpecialAbility("invincible");
		break;
		
		case "AB3":
			// self.heavyArmor = true;
			// self giveArmoredHud();
		break;
	}
}

ARMORED_PASSIVE( ability )
{
	switch ( ability )
	{
		case "AB1":
			self.weaponMod += "armored";
			// self setclientdvar("ui_armored", 1 );
		break;
		
		case "AB2":
			self setPerk( "specialty_bulletaccuracy" );
			self.knifeMod += "armored";
		break;
		
		case "AB3":
			self reloadForArmored();
		break;
		
		case "AB4":
			self.damageDoneMP = .9;
			self.infectionMP = .65;
		break;
	}
}

loadEngineerAbility( type, ability )
{
	switch ( type )
	{
		case "PR":
			self thread ENGINEER_PRIMARY( ability );
		break;
		
		case "PS":
			self thread ENGINEER_PASSIVE( ability );
		break;
	}
}

///////////////
//	ENGINEER //
///////////////

ENGINEER_PRIMARY( ability )
{
	switch ( ability )
	{
		case "AB1":
			self giveWeap( "supply_mp" );
			self setWeapAmmoClip( "supply_mp", 0 );
			self setActionSlot( 3, "weapon", level.weaponKeyS2C["supply_mp"] ); // Actionslot [5]
			self.ammoboxTime = 15;
			self.ammoboxRestoration = 25;
			self thread watchAmmobox();
			self thread restoreAmmobox( level.special["ammo"]["recharge_time"] );
		break;
		
		case "AB2":
			self loadSpecialAbility( "augmentation" );
		break;
		
		case "AB3":
			self.longerTurrets = true;
		break;
	}
}

ENGINEER_PASSIVE( ability )
{
	switch ( ability )
	{
		case "AB1":
			self.weaponMod += "engineer";
		break;
		
		case "AB2":
			self.toxicImmunity = true;
		break;
		
		case "AB3":
		break;
		
		case "AB4":
			self.bulletMod = "incendiary";
		break;
	}
}

loadScoutAbility( type, ability )
{
	switch ( type )
	{
		case "PR":
			self thread SCOUT_PRIMARY( ability );
		break;
		
		case "PS":
			self thread SCOUT_PASSIVE( ability );
		break;
	}
}

///////////////
//	SCOUT    //
///////////////

SCOUT_PRIMARY( ability )
{
	switch ( ability )
	{
		case "AB1":
			self loadSpecialAbility( "escape" );
		break;
		
		case "AB2":
			self setPerk( "specialty_holdbreath" );
		break;
		
		case "AB3":
			self giveWeapon( "usp_silencer_mp" );
			self setOffhandSecondaryClass( "flash" );
			self setWeaponAmmoClip( "usp_silencer_mp", 0 );
			self thread restoreMonkey( level.special["monkey_bomb"]["recharge_time"] );
		break;
	}
}

SCOUT_PASSIVE( ability )
{
	switch ( ability )
	{
		case "AB1":
			self.weaponMod += "scout";
		break;
		
		case "AB2":
			self.headshotMP = 2;
		break;
		
		case "AB3":
			self.chargedGrenades = true;
		break;
		
		case "AB4":
			self.hasRadar = true;
		break;
	}
}

// Abilities
rechargeSpecial( delta )
{
	if ( self.special["ability"] == "none" || self.inTrance || self.god || self hasPerk( "specialty_rof" ) || delta < 0 )
		return;
		
	if( self.canUseSpecial )
	{
		self.specialRecharge = 100;
		self setclientdvars( "ui_specialtext", "^2Special Available" );
		self setclientdvar( "ui_specialrecharge", 1 );
		self.persData.specialRecharge = self.specialRecharge;
		return;
	}
	
	self.specialRecharge += delta;
	
	if ( self.specialRecharge > 100 )
		self.specialRecharge = 100;
		
	if ( self.specialRecharge == 100 )
	{
		self.canUseSpecial = true;
		self setClientDvars( "ui_specialtext", "^2Special Available" );
	}
	
	self setClientDvar( "ui_specialrecharge", self.specialRecharge / 100 );
	self thread specialRechargeFeedback();
	self.persData.specialRecharge = self.specialRecharge;
}

giveArmoredHud()
{
	self.armored_hud = NewClientHudElem ( self );
	self.armored_hud.horzalign = "fullscreen";
	self.armored_hud.vertalign = "fullscreen";
	self.armored_hud.sort = -3;
	self.armored_hud.alpha = 1;
	self.armored_hud setShader( "overlay_armored", 640, 480 );
}

watchArmoredDome()
{
	self endon( "reset_abilities" );
	self endon( "downed" );
	self endon( "death" );
	self endon( "disconnect" );
	while( 1 )
	{
		self waittill( "grenade_fire", shield, weaponName );
		if( weaponName == "c4_mp" ) /* TODO: INSERT PROPER WEAPON */ 
		{
			shield.owner = self;
			shield thread beArmoredDome( level.special["armoredshield"]["duration"] );
			self thread restoreArmoredDome( level.special["armoredshield"]["recharge_time"] );
			// self playsound("take_medkit"); /* TODO: INSERT PROPER "DEPLOYING SHIELD" SOUND */
		}
	}
}

watchSmokeGrenades()
{
	self endon( "reset_abilities" );
	self endon( "downed" );
	self endon( "death" );
	self endon( "disconnect" );

	while( 1 )
	{
		self waittill ( "grenade_fire", nade, weaponName );
		
		if( weaponName == level.weaponKeyS2C["smoke_grenade_mp"] )
		{
			nade.owner = self;
			nade thread beSmokeGrenade( self.smokeTime );
			self thread restoreSmokeGrenade( level.special["smoke_grenade"]["recharge_time"] );
			self playSound( "throw_smoke" );
		}
	}
}

watchMedkits()
{
	self endon( "reset_abilities" );
	self endon( "downed" );
	self endon( "death" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill ( "grenade_fire", kit, weaponName );
		if( weaponName == level.weaponKeyS2C["medic_mp"] )		// weaponName might be none
		{
			kit.owner = self;
			kit thread beMedkit( self.medkitTime, self.medkitHealing );
			self thread restoreMedkit( level.special["medkit"]["recharge_time"] );
			self playSound( "take_medkit" );
		}
	}
}

watchAmmobox()
{
	self endon( "reset_abilities" );
	self endon( "downed" );
	self endon( "death" );
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill ( "grenade_fire", kit, weaponName );
		if( weaponName == level.weaponKeyS2C["supply_mp"] )
		{
			kit.owner = self;
			kit thread beAmmobox( self.ammoboxTime );
			self thread restoreAmmobox( level.special["ammo"]["recharge_time"] );
			self playSound( "take_ammo" );
		}
	}
}

restoreArmoredDome( time )
{
	self endon( "reset_abilities" );
	self endon( "downed" );
	self endon( "death" );
	self endon( "disconnect" );

	self addTimer( &"ZOMBIE_ARMOREDDOME_IN", "", time );
	wait time;

	self setWeapAmmoClip( "c4_mp", self getWeapAmmoClip( "c4_mp" ) + 1 );
}

restoreSmokeGrenade( time )
{
	self endon( "reset_abilities" );
	self endon( "downed" );
	self endon( "death" );
	self endon( "disconnect" );

	self addTimer( &"ZOMBIE_SMOKEGRENADE_IN", "", time );
	wait time;

	self setWeapAmmoClip( "smoke_grenade_mp", self getWeapAmmoClip( "smoke_grenade_mp" ) + 1 );
}

restoreMedkit( time )
{
	self endon( "reset_abilities" );
	self endon( "downed" );
	self endon( "death" );
	self endon( "disconnect" );

	self addTimer( &"ZOMBIE_MEDKIT_IN", "", time );
	wait time;

	self setWeapAmmoClip( "medic_mp", self getWeapAmmoClip( "medic_mp" ) + 1 );
}

restoreAmmobox( time )
{
	self endon( "reset_abilities" );
	self endon( "downed" );
	self endon( "death" );
	self endon( "disconnect" );

	self addTimer( &"ZOMBIE_AMMOBOX_IN", "", time );
	wait time;

	self setWeapAmmoClip( "supply_mp", self getWeapAmmoClip( "supply_mp" ) + 1 );
}

restoreMonkey( time )
{
	self endon( "reset_abilities" );
	self endon( "downed" );
	self endon( "death" );
	self endon( "disconnect" );

	self addTimer( &"ZOMBIE_MONKEY_IN", "", time );
	wait time;

	// Why not just give one...?
	self takeWeapon( "usp_silencer_mp" );
	self giveWeapon( "usp_silencer_mp" );
}

restoreInvisibility( time )
{
	self endon( "reset_abilities" );
	// self endon("downed");
	self endon( "death" );
	self endon( "disconnect" );
	
	if( isDefined( self.invisibiltyTimer ) )
		self removeTimer( self.invisibiltyTimer );

	self.invisibiltyTimer = self addTimer( &"ZOMBIE_INVISIBILITY_IN", "", time );
}

beAmmobox( time )
{
	self endon( "death" );
	
	self waitTillNotMoving();
	
	if( !isDefined( self ) )
		return;
	
	self thread scripts\gamemodes\_hud::createHeadiconKits( self.origin+( 0, 0, 15 ), "icon_ammobox_placed", 0.5 ); // 2D Icon above the ammobox
	self thread scripts\gamemodes\_hud::createRadarIcon( "icon_ammobox_radar" ); // Radar Icon
	
	wait 1;
	for ( i = 0; i < time; i++ )
	{
		if( !isDefined( self.owner ) )
			break;
		
		for ( ii = 0; ii < level.players.size; ii++ )
		{
			player = level.players[ii];
			
			if( !isReallyPlaying( player ) )
				continue;
			
			if ( distance( self.origin, player.origin ) < 120 )
			{
				if ( !player.isDown )
					self.owner thread restoreAmmoClip( player );
			}
		}
		wait 1;
	}
	self delete();
}

beSmokeGrenade( time )
{
//	self waittill( "explode" );		this will not work...
	origin = self.origin;
	while( isDefined( self ) )
	{
		// so we work around by grabbing the origin while the grenade exists
		if( origin != self.origin )
			origin = self.origin;
			
		wait 0.05;
	}

	// these should match the fx values
	radius = 250;
	height = 150;
	duration = 30;
	
	// TODO: Make the trigger grow over time
	trigger = spawn( "trigger_radius", origin, 0, radius, height );
	trigger setContents( 2 ); // so zombies can't see through

	wait duration;
	trigger delete();
}

beMedkit( time, heal )
{
	self endon( "death" );
	
	self waitTillNotMoving();
	
	if( !isDefined( self ) ) return;
	
	self thread scripts\gamemodes\_hud::createHeadiconKits( self.origin + ( 0, 0, 15 ), "icon_medkit_placed", 0.5 ); // 2D Icon above the medkit
	self thread scripts\gamemodes\_hud::createRadarIcon( "icon_medkit_radar" ); // Radar Icon
	
	wait 1;
	for ( i = 0; i < time; i++ )
	{
		if( !isDefined( self.owner ) || !isReallyPlaying( self.owner ) )
			break;
		
		for ( ii = 0; ii < level.players.size; ii++ )
		{
			player = level.players[ii];
			
			if( !isReallyPlaying( player ) )
				continue;
			
			if ( distance( self.origin, player.origin ) < 120 )
			{
				if ( player.health < player.maxhealth && !player.isDown )
					self.owner thread healPlayer( player, heal );
			}
		}
		wait 1;
	}
	self delete();
}

/* TODO: MODIFY TO BE USED WITHOUT A THROWABLE OBJECT */
beArmoredDome( duration )
{	
	self waitTillNotMoving();
	
	if( !isDefined( self ) )
		return;
		
	if( !isDefined( self.owner ) || !isReallyPlaying( self.owner ) )
	{
		self delete();
		return;
	}
	
	targetDestination = self.origin;
	
	self hide();
	dome = spawn( "script_model", targetDestination );
	dome.owner = self.owner;
	wait 0.05;
	dome setModel( "armored_dome" );
	dome notSolid();
	
	if( isDefined( self ) )
		self delete();
	
	level.armoredDomes[level.armoredDomes.size] = dome;
	
	wait duration;
	
	level.armoredDomes = removeFromArray( level.armoredDomes, dome );
	dome delete();
}

//For assassin = makes ur screen 24/7 green, zombies can't see u
stealthMovement()
{
	self thread interruptStealthMovement();
	self thread stealthMovementWait();
	self thread restoreInvisibility( level.special_stealthmove_intermission );
}

interruptStealthMovement()
{
	self endon( "reset_abilities" );
	self endon( "death" );
	self endon( "disconnect" );
	while( 1 )
	{
		self waittill_any( "weapon_fired", "grenade_fire", "detonated", "used_usable" );
		self notify( "end_trance" );
		self.canHaveStealth = false;
		wait 0.05;
	}
}

stealthMovementWait()
{
	self endon( "reset_abilities" );
	self endon( "death" );
	self endon( "disconnect" );
	i = 0;
	while( 1 )
	{
		if( !self.canHaveStealth || self.isDown )
		{
			i = 0;
			self.canHaveStealth = true;
			
			if( !self.isDown )
				self thread restoreInvisibility( level.special_stealthmove_intermission );
		}
		else if( i >= level.special_stealthmove_intermission && !self.inTrance && self.visible )
		{
			self thread trance_stealthmove();
			self thread trance_stealthmove_end();
		}
		i += 0.1;
		wait 0.1;
	}

}

trance_stealthmove()
{
	self endon( "end_trance" );
	self endon( "death" );
	self endon( "disconnect" );
	
	while( self.inTrance )
		wait .5;
	
	self.trance = "stealthmove";
	self.inTrance = true;
	self.visible = false;
	self playerFilmTweaks( 1, 0, 0, "0 1 0",  "0 1 2", 0, 1.1, 1 );//1, 0, .75, ".25 1 .5",  "25 1 .7", .20, 1.4, 1
		
	self waittill( "end_trance" );
}

trance_stealthmove_end()
{
	self endon( "death" );
	self endon( "disconnect" );
	self waittill( "end_trance" );
	self.inTrance = false;
	self.trance = "";
	self playerFilmTweaksOff();
	self.visible = true;
}

quickEscape() // When health gets below 25% we give ourselves a speedboost - for Assassin class
{
	self endon( "reset_abilities" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "downed" );
	while( 1 )
	{
		self waittill( "damage", idamage );
		if( idamage != 0 )
		{
			if( self.health <= self.maxhealth / 4 && !self.inTrance )
			{
				self trance_quickescape();
				wait level.special_quickescape_intermission;
			}
		}
	}
}

trance_quickescape()
{
	// kill all previous threads
	self notify( "end_trance" );
	self endon( "end_trance" );

	self.trance = "quick_escape";
	self.inTrance = true;

	self setMoveSpeedScale( self.speed + 0.2 );
	self.visible = false;
	self playerFilmTweaks( 1, 0, .75, ".25 1 .5",  "25 1 .7", .20, 1.4, 1.25 );
	
	self thread trance_quickescape_end();
	
	wait level.special_quickescape_duration;// 6 seconds
	
	self notify( "end_trance" );
}

trance_quickescape_end()
{
	self waittill( "end_trance" );
	self.inTrance = false;
	self.trance = "";
	self playerFilmTweaksOff();
	self.visible = true;
	self SetMoveSpeedScale( self.speed );
}

regenerate( health, interval, limit )
{
	self endon( "reset_abilities" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "downed" );
	if ( !isDefined( limit ) )
	{
		while ( 1 )
		{
			if ( self.health < self.maxhealth )
				self heal( health );
				
			wait interval;
		}
	}
	else
	{
		for ( i = 0; i < limit; i++ )
		{
			if ( self.health < self.maxhealth )
				self heal( health );
				
			wait interval;
		}
	}
}

heal( x )
{
	self.health += x;
	if ( self.health > self.maxhealth )
		self.health = self.maxhealth;
		
	self updateHealthHud( self.health / self.maxhealth );
}

reloadForArmored()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	while( 1 )
	{
		if ( self.curClass != "armored" || self.sessionstate == "spectator" )
			return;
			
		self waittill( "weapon_change" );
		
		wep = self getCurrentWeapon();
		
		if ( scripts\players\_weapons::isLMG( wep ) )
			self setPerk( "specialty_fastreload" );
		else
			self unsetPerk( "specialty_fastreload" );
	}
}

dynamicAccuracy()
{
	// self.accuracyOverwrite = 6;
	self endon( "reset_abilities" );
	self endon( "death" );
	self endon( "disconnect" );
	while( 1 )
	{
		self waittill( "begin_firing" );
		self thread accuracyChangeUp();
		
		self waittill( "end_firing" );
		self thread accuracyChangeDown();
	}
}

accuracyChangeUp()
{
	self endon( "reset_abilities" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "end_firing" );
	while( isReallyPlaying( self ) && isAlive( self ) )
	{
		self setSpreadOverride( self.accuracyOverwrite );
		self.accuracyOverwrite--;
		
		if( self.accuracyOverwrite < 1 )
			self.accuracyOverwrite = 1;
			
		wait 0.4;
	}
}

accuracyChangeDown()
{
	self endon( "reset_abilities" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "begin_firing" );
	while( isReallyPlaying( self ) && isAlive( self ) )
	{
		self setSpreadOverride( self.accuracyOverwrite );
		self.accuracyOverwrite++;
		
		if( self.accuracyOverwrite == 6 )
			break;
			
		wait 0.4;
	}
}

watchSpecialAbility()
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	self endon( "join_spectator" );
	self endon( "death" );
	self notify( "watch_special" );
	self endon( "watch_special" );
	
	wait 1;
	
	if ( !isDefined( self.special["ability"] ) || self.special["ability"] == "none" )
		return;
	
	i = 0;
	/* Will trigger the special when holding the F button for 1 second */
	while( 1 )
	{
		if( !self.isDown && !self.isBusy && self useButtonPressed() )
			i++;
		else
			i = 0;
			
		if( i >= 10 )
		{
			self thread onSpecialAbility();
			i = 0;
		}
			
		wait 0.1;
	}
}

onSpecialAbility()
{
	if ( !self.canUseSpecial )
	{
		return;
	}
	
	self notify( "special_ability" );
	
	switch ( self.special["ability"] )
	{
		case "aura":
			self thread specialAura( self.special["duration"] );
			iprintln( self.name + "^7 has placed a ^2Healing Aura^7!" );
			self resetSpecial();
		break;
		
		case "rampage":
			self doRampage( self.special["duration"] );
			iprintln( self.name + "^7 activated their ^1Rampage^7!" );
			self resetSpecial();
		break;
		
		case "invincible":
			self doInvincible( self.special["duration"] );
			iprintln( self.name + "^7 has become ^3Invincible^7!");
			self resetSpecial();
		break;
		
		case "augmentation":
			if ( self doAugmentation() )
			{
				iprintln( self.name + "^7 ^3augmented ^7their ^3Turrets^7!" );
				self resetSpecial();
			}
		break;
		
		case "escape":
			self doEscape( self.special["duration"] );
			iprintln( self.name + "^7 ^5sped ^7themself up^7!" );
			self resetSpecial();
		break;
		
		case "fake_death":
			self doNinja( self.special["duration"] );
			iprintln( self.name + "^7 is temporarily ^5untargetable^7!" );
			self resetSpecial();
		break;
	}
}

resetSpecial()
{
	self.canUseSpecial = false;
	self.specialRecharge = 0;
	self setClientDvars( "ui_specialtext", "^1Special Recharging", "ui_specialrecharge", 0 );
}

//*****************************************************************************************
// 										 Aura Special
//*****************************************************************************************

specialAura( time )
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	
	origin = self.origin;
	trace = bulletTrace( self.origin + ( 0, 0, 50 ), self.origin + ( 0, 0, -200 ), false, self );
  
    if( trace["fraction"] < 1 )
       origin = trace["position"];

	healObject = spawnHealFX( origin, level.healingEffect );
	healObject.healing = self.auraHealing;
	healObject.owner = self;	
	healObject thread healObjectHeal( time );
	self playsound( "aura_spawn" );
}

spawnHealFX( groundpoint, fx )
{
	effect = spawnFx( fx, groundpoint, getGroundTilt( groundpoint ) );
	triggerFx( effect );
	
	return effect;
}

healObjectHeal( time )
{
	wait 2;
	timePassed = 0;
	while ( timePassed < time )
	{
		for ( i = 0; i <= level.players.size; i++ )
		{
			player = level.players[i];
			
			if ( isDefined( player ) && player.isAlive && distance( self.origin, player.origin ) <= 240 && player.health < player.maxhealth )
				self thread healThread( player );				
		}
		timePassed += 2;
		wait 2;
	}
	
	self delete();
}

healThread( player )
{
	player endon( "disconnect" );

	// send out a glowing ball that follows the player around
	self thread glow_heal_ball_out( player );

	// once the ball reached him we heal him
	player waittill( "glow_ball_reached" );
	self.owner thread healPlayer( player, self.healing );
}

healPlayer( player, heal )
{
	if ( player.health == player.maxhealth || !isDefined( heal ) )
	return;
	
	player.health += heal;
	healed = heal;
	
	if ( player.health > player.maxhealth )
	{
		healed -= player.health - player.maxhealth;
		player.health = player.maxhealth;	
	}
	
	player thread screenFlash( ( 0, 0.65, 0 ), 0.5, 0.4 );
	player thread healthFeedback();
	player updateHealthHud( player.health / player.maxhealth );
	
	if ( player != self )
	{
		self scripts\players\_players::incUpgradePoints( getRewardForHeal( healed ) * level.dvar["game_rewardscale"] );
		self.stats["healsGiven"] += healed;
	}
	
	if ( self.curClass == "medic" && player != self )
	{
		self rechargeSpecial( healed / 4 );
	}
	
	return healed;
}

restoreAmmoClip( player )
{
	wep = player getCurrentWeapon();//gets the name of the current weapon of the player holding
	
	if ( !scripts\players\_weapons::canRestoreAmmo( wep ) )//if it's a special weapon, it won't restore it's ammo E.g = raygun,tesla...
		return;
	
	stockAmmo = player getWeaponAmmoStock( wep );//gets the total ammount of ammo it has at the moment, not the clip but the stock like 95
	stockMax = weaponMaxAmmo( wep );//gets the total ammount of ammo the certain weapon has ( not clip ) E.g = MaxAmmo of ak47 is 180
	
	tenthOfMax = int( stockMax / 10 );//E.g AK47= 180/10 = 18, 18 is an int so no need to round the number( 17.5>18 )
	
	if ( tenthOfMax < 1 )
		tenthOfMax = 1;

	perc = ( stockMax - stockAmmo ) / tenthOfMax;

	if ( perc > 1 )
		perc = 1;

	if ( stockAmmo < stockMax )
	{
		if( ( stockAmmo + tenthOfMax ) > stockMax )
			tenthOfMax = stockMax - stockAmmo;
			
		stockAmmo += tenthOfMax;
		if ( stockAmmo > stockMax )
			stockAmmo = stockMax;
		
		player setWeaponAmmoStock( wep, stockAmmo );
		player thread screenFlash( ( 0, 0, 0.65 ), 0.5, 0.4 );
		player playLocalSound( "weap_pickup" );
		
		if ( player != self && self.curClass == "engineer" )
		{
			self scripts\players\_players::incUpgradePoints( int( 2 * perc ) * level.dvar["game_rewardscale"] );
			self.stats["ammoGiven"] += tenthOfMax;
			self scripts\players\_abilities::rechargeSpecial( 8 * perc );
		}
		
	}
}

getRewardForHeal( heal )
{
	if ( heal > 0 )
		return int( ( heal + 10 ) / 5 );
	else
		return 0;
}

//*****************************************************************************************
// 										 Moving glow ball
//*****************************************************************************************

glow_heal_ball_out( p )
{
	offset = ( 0,0,40 );
	ball_tag = spawn( "script_model", self.origin + offset );
	ball_tag setModel( "tag_origin" );
	while( 1 )
	{
		wait 0.05;
		// check if the player is still defined or disconnected
		if( !isDefined( p ) )
		{
			// the player disconnected, end this
			ball_tag delete();
			break;
		}
		
		// get the players head origin
		head_tag_org = p getTagOrigin( "j_head" );
		if( distance( ball_tag.origin,head_tag_org ) > 30 )
		{
			// we are still away from the player, let's move to him
			movespeed = 1.3;
			num = 10;
			if( distance( ball_tag.origin,head_tag_org ) < 64 )
			{
				// we are pretty close, move faster ( movespeed ist actually the movetime )
				movespeed = 0.55;
				num = 5;
			}
			
			ball_tag moveTo( head_tag_org, movespeed );
			for( i = 0; i < num; i++ )
			{
				// play the effect the desired amount and at the same time wait
				playFXOnTag( level.heal_glow_effect, ball_tag, "tag_origin" );
				wait 0.1;
			}
		}
		else
		{
			// we are close to the player, now heal him
			p thread player_glow_up();
			p notify( "glow_ball_reached" );
			ball_tag delete();
			break;
		}
	}
}

player_glow_up()
{
	tag = "j_head";
	playFXOnTag( level.heal_glow_body, self,tag );
}


//*****************************************************************************************
// 										 Rampage Special
//*****************************************************************************************

doRampage( time )
{
	self endon( "death" );
	self endon( "downed" );
	self endon( "disconnect" );
	
	self setClientDvar( "ui_specialtext", "^5Special Activated!" );
	self.canUseSpecial = false;
	
	self setPerk( "specialty_rof" );
	self setPerk( "specialty_fastreload" );
	
	self thread screenFlash( ( 0.65, 0.1, 0.1 ), 0.5, 0.6 );
	self playerFilmTweaks( 1, 0, 0, "1 0 0",  "1 0 2", 0, 1, 1.2 );//1, 0, .8, "0.9 0.4 0.3",  "1 0.5 0.5", .25, 1.4, 1.2
	self thread regenerate( 2, time / 40, 40 );

	wait time;

	self playerFilmTweaksOff();
	self thread screenFlash( ( 0.65, 0.1, 0.1 ), 0.5, 0.6 );
	self unSetPerk( "specialty_rof" );
	
	if ( !self.hasFastReload )
		self unSetPerk( "specialty_fastreload" );
}

//*****************************************************************************************
// 										 Fake Death Special
//*****************************************************************************************

doNinja( time )
{
	self endon( "death" );
	self endon( "downed" );
	self endon( "disconnect" );
	self notify( "end_trance" );
	
	wait 0.1;
	
	self setClientDvar( "ui_specialtext", "^5Special Activated!" );
	self.canUseSpecial = false;
	self.trance = "stealthmove";
	self.inTrance = true;
	self.visible = false;
	self thread screenFlash( ( 0.1, 0.1, 0.65 ), 0.5, 0.6 );
	//( enable, invert, desaturation, darktint,  lighttint, brightness, contrast, fovscale )
	self playerFilmTweaks( 1, 0, 0, "2 2 0",  "1 2 2", 0, 1.1, 1 );
	
	wait time;
	
	self.trance = "";
	self.inTrance = false;
	self.visible = true;
	self playerFilmTweaksOff();
	self thread screenFlash( ( 0.1, 0.1, 0.65 ), 0.5, 0.6 );
	
	wait 0.1;
	
	self notify( "end_trance" );

}

//*****************************************************************************************
// 										 Invincible Special
//*****************************************************************************************

doInvincible( time )
{
	self endon( "death" );
	self endon( "downed" );
	self endon( "disconnect" );
	
	self setClientDvar( "ui_specialtext", "^5Special Activated!" );
	self.canUseSpecial = false;
	self.god = true;
	self.immune = true;
	self.infectionMP = 0;
	self thread doInvincibleHud();
	self thread screenFlash( ( 0.1, 0.1, 0.65 ), 0.5, 0.6 );
	// self playerFilmTweaks( 1, 0, 0, "0 0 1",  "0 1 1", 0, 0.9, 1 );//1, 0, .4, "0.4 0.4 0.8",  "0.5 0.5 1", .25, 1.4, 1
	
	wait time;
	self.god = false;
	self.immune = false;
	self notify( "stop_armored_hud" );
	self updateArmorHud();
	self.infectionMP = 1;
	self playerFilmTweaksOff();
	self thread screenFlash( ( 0.1, 0.1, 0.65 ), 0.5, 0.6 );
}

doInvincibleHud()
{
	self endon( "death" );
	self endon( "downed" );
	self endon( "disconnect" );
	self endon( "stop_armored_hud" );
	
	if( !isDefined( self.armored_hud ) )
		self giveArmoredHud();
		
	self.armored_hud.color = ( 0.6, 0.6, 1 );
	self.armored_hud.alpha = 1;
	
	while( 1 )
	{
		self.armored_hud fadeOverTime( 0.3 );
		self.armored_hud.alpha = 0;
		wait 0.3;
		
		self.armored_hud fadeOverTime( 0.5 );
		self.armored_hud.alpha = 1;
		wait 0.5;
	}
}

//*****************************************************************************************
// 										 Escape Special
//*****************************************************************************************

doEscape( time )
{
	self endon( "downed" );
	self endon( "death" );
	self endon( "disconnect" );
	
	if( self.inTrance )
		self notify( "end_trance" );
	
	self endon( "end_trance" );
	
	self setClientDvar( "ui_specialtext", "^5Special Activated!" );
	self.canUseSpecial = false;
	self.trance = "quick_escape";
	self.inTrance = true;
	self.visible = true;
	
	self setMoveSpeedScale( self.speed + 0.25 );
	
	self thread screenFlash( ( 0.1, 0.1, 0.65 ), 0.5, 0.6 );
	self playerFilmTweaks( 1, 0, 0, "0 1 2",  "2 2 1", 0, 1, 1 );//1, 0, .75, ".25 .5 1",  ".25 .7 1", .20, 1.4, 1.25
	
	wait time;
	
	self.inTrance = false;
	self playerFilmTweaksOff();
	self thread screenFlash( ( 0.1, 0.1, 0.65 ), 0.5, 0.6 );
	self setMoveSpeedScale( self.speed );
	self notify( "end_trance" );
}

//*****************************************************************************************
// 									Augmented Turrets
//*****************************************************************************************

doAugmentation()
{
	if( level.turretsDisabled )
	{
		self iprintlnbold( "Turrets are disabled! You can't use your Special!" );
		return false;
	}
	
	turrets = [];
	for( i = 0; i < self.useObjects.size; i++ )
	{
		o = self.useObjects[i];
		if( o.type == "turret" && o.owner == self && !o.occupied )
			turrets[turrets.size] = o;
	}
	
	if( turrets.size == 0 )
	{
		self iprintlnbold( "You need at least one turret to activate your Special!" );
		return false;
	}
	
	for( i = 0; i < turrets.size; i++ )
		turrets[i] scripts\players\_turrets::goAugmented();
		
	return true;
}


// doAmmoSpecial()
// {
	// weapon = self GetCurrentWeapon();
	// if ( weapon == self.primary || weapon == self.secondary )
	// {
		// self playlocalsound("weap_pickup");
		// self GiveMaxAmmo( weapon );
		// return 1;
	// }
	// self iprintln("^1Invalid weapon!");
	// return 0;
// }