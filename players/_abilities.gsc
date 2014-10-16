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

#include scripts\include\hud;
#include scripts\include\data;
#include scripts\include\useful;
#include common_scripts\utility;
init()
{
	precache();
	thread loadAbilityStats();
	level.weapons["flash"] = "usp_silencer_mp"; // We change the actual Flash Grenade to the Monkey Bomb, so we can use it as "Special Grenade" with instant-throw
}

precache()
{
	level.heal_glow_body		= loadfx( "misc/heal_glow_body");
	level.heal_glow_effect 		= loadfx( "misc/heal_glow");
	level.healingEffect    		= loadfx( "misc/healing" );
	precacheShader("icon_medkit_placed");
	precacheShader("icon_ammobox_placed");
}

loadAbilityStats()
{
	level.special["fake_death"]["recharge_time"] = 55;
	level.special["fake_death"]["duration"] = 15;
	
	level.special["rampage"]["recharge_time"] = 50;
	level.special["rampage"]["duration"] = 15;
	
	level.special["aura"]["recharge_time"] = 60;
	level.special["aura"]["duration"] = 20;
	
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
	self SetMoveSpeedScale(self.speed);
	self unSetPerk("specialty_rof");
	if (!self.hasFastReload)
		self unSetPerk("specialty_fastreload");
	if(self.hud_streak.alpha != 0) // Removes the Killing Spree Number on the Screen
		self.hud_streak.alpha = 0;

}

resetAbilities()
{
	self notify("reset_abilities");
	self.stealthMp = 1;
	self.maxhealth = 100;
	self.speed = 1;
	self.revivetime = level.dvar["surv_revivetime"];
	
	self clearPerks();
	self setStableMissile(0);
	
	if( isDefined(self.armored_hud) )
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


getDamageModifier(weapon, means, target, damage)
{
	if(weapon == "none" || weapon == "turret_mp")
		return 1;
	MP = 1;
	if (issubstr(self.weaponMod, "soldier"))
	{
		if (scripts\players\_weapons::isRifle(weapon))
			MP += .1;
	}
	if (issubstr(self.weaponMod, "assassin"))
	{
		if (!WeaponIsBoltAction(weapon) && !WeaponIsSemiAuto(weapon))
			MP -= .15;
		else
			MP += .05;
		if (!scripts\players\_weapons::isSilenced(weapon))
			MP -= .15;
		else
			MP += .05;
	}
	if (issubstr(self.weaponMod, "hitman"))
	{
		if (!WeaponIsBoltAction(weapon) && !WeaponIsSemiAuto(weapon) && means == "MOD_HEAD_SHOT")
			MP += .45;
		if (!target scripts\bots\_bots::zomSpot(self))
			MP += .15;
	}
	if (issubstr(self.weaponMod, "strength"))
	{
		if (means == "MOD_MELEE")
			MP += .35;
	}
	if (issubstr(self.weaponMod, "engineer"))
	{
		if (means == "MOD_EXPLOSIVE")
			MP += .1;
		if (scripts\players\_weapons::isLMG(weapon) || scripts\players\_weapons::isRifle(weapon))
			MP += .05;
		if (scripts\players\_weapons::isShotgun(weapon))
			MP += .1;
	}
	if (issubstr(self.weaponMod, "armored"))
	{
		if (scripts\players\_weapons::isLMG(weapon))
			MP += .15;
		if (scripts\players\_weapons::isSniper(weapon) || scripts\players\_weapons::isPistol(weapon) || scripts\players\_weapons::isSMG(weapon))
			MP -= .15;
	}
	if (issubstr(self.weaponMod, "lmg"))
	{
		if (scripts\players\_weapons::isLMG(weapon))
			MP += .5;
	}
	if (issubstr(self.weaponMod, "scout"))
	{
		if (scripts\players\_weapons::isLMG(weapon) || scripts\players\_weapons::isRifle(weapon))
			MP -= .15;
		if (scripts\players\_weapons::isSniper(weapon) || scripts\players\_weapons::isPistol(weapon) || scripts\players\_weapons::isSMG(weapon))
			MP += .1;
	}
	if (issubstr(self.knifeMod, "assassin"))
	{
		if (means == "MOD_MELEE")
			MP += 1;
	}
	if (issubstr(self.knifeMod, "armored"))
	{
		if (means == "MOD_MELEE")
			MP += 0.35;
	}
	//self.upgrade_damMod = 1;
	MP = MP * self.upgrade_damMod;
	return MP;
}

getAbilityAllowed(class, rank, type, ability)
{
	if (type == "PR")
	{
		if (ability == "AB1")
		{
			if (rank >= 5)
			return true;
		}
		if (ability == "AB2")
		{
			if (rank >= 15)
			return true;
		}
		if (ability == "AB3")
		{
			if (rank >= 25)
			return true;
		}
	}
	if (type == "PS")
	{
		if (ability == "AB1")
		{
			return true;
		}
		if (ability == "AB2")
		{
			if (rank >= 10)
			return true;
		}
		if (ability == "AB3")
		{
			if (rank >= 20)
			return true;
		}
		if (ability == "AB4")
		{
			if (rank >= 30)
			return true;
		}
	}
	if (type == "SC")
	{
		if (ability == "AB1")
		{
			if (rank >= 5)
			return true;
		}
		if (ability == "AB2")
		{
			if (rank >= 10)
			return true;
		}
		if (ability == "AB3")
		{
			if (rank >= 20)
			return true;
		}
		if (ability == "AB4")
		{
			//return true;
		}
		if (ability == "AB5")
		{
			//return true;
		}
	}
	return false;
}

loadClassAbilities(class)
{
	self resetAbilities();
	
	self loadGeneralAbilities(class);
	
	rank = scripts\players\_classes::getClassRank(class) + 1;
	
	// General Stats
	
	// Primary Abilities
	if (getAbilityAllowed(class, rank, "PR", "AB1"))
		self loadAbility(class, "PR", "AB1");
	
	if (getAbilityAllowed(class, rank, "PR", "AB2"))
		self loadAbility(class, "PR", "AB2");
	
	if (getAbilityAllowed(class, rank, "PR", "AB3"))
		self loadAbility(class, "PR", "AB3");
	
	// Passive Abilities
	
	if (getAbilityAllowed(class, rank, "PS", "AB1"))
		self loadAbility(class, "PS", "AB1");
	
	if (getAbilityAllowed(class, rank, "PS", "AB2"))
		self loadAbility(class, "PS", "AB2");
	
	if (getAbilityAllowed(class, rank, "PS", "AB3"))
		self loadAbility(class, "PS", "AB3");
	
	if (getAbilityAllowed(class, rank, "PS", "AB4"))
		self loadAbility(class, "PS", "AB4");
	
	// Secondary Ability
	
	if (getAbilityAllowed(class, rank, "SC", self.secondaryAbility))
		self loadAbility(class, "SC", self.secondaryAbility);
}

loadGeneralAbilities(class)
{
	self setperk("specialty_pistoldeath");
	switch (class)
	{
		case "soldier":
			self.maxhealth = 115;
		break;
		case "stealth":
			self.maxhealth = 100;
			self setperk("specialty_quieter");
			self.speed = 1.02;
		break;
		case "medic":
			self.maxhealth = 110;
		break;
		case "scout":
			self.maxhealth = 90;
			self setperk("specialty_longersprint");
			self.speed = 1.08;
		break;
		case "amored":
			self.maxhealth = 140;
			self.speed = 0.95;
		break;
	}
}

loadSpecialAbility(special)
{
	self.special["ability"] = special;
	
	if (isdefined(level.special[special]["recharge_time"]))
		self.special["recharge_time"] = level.special[special]["recharge_time"];
	
	if (isdefined(level.special[special]["duration"]))
		self.special["duration"] = level.special[special]["duration"];

	if(self.canUseSpecial)
		self setclientdvar("ui_specialtext", "^2Special Available");
	else
		self setclientdvar("ui_specialtext", "^1Special Recharging");
}

loadAbility(class, type, ability)
{
	switch (class)
	{
		case "soldier":
			loadSoldierAbility(type,ability);
		break;
		case "stealth":
			loadStealthAbility(type,ability);
		break;
		case "medic":
			loadMedicAbility(type,ability);
		break;
		case "armored":
			loadArmoredAbility(type,ability);
		break;
		case "engineer":
			loadEngineerAbility(type,ability);
		break;
		case "scout":
			loadScoutAbility(type,ability);
		break;
	}

}

loadSoldierAbility(type, ability)
{
	switch (type)
	{
		case "PR":
			self thread SOLDIER_PRIMARY(ability);
		break;
		case "PS":
			self thread SOLDIER_PASSIVE(ability);
		break;
	}
}
///////////////
//	SOLDIER  //
///////////////

SOLDIER_PRIMARY(ability)
{
	switch (ability)
	{
		case "AB1":
			self setPerk("specialty_bulletpenetration");
			self setPerk("specialty_bulletdamage");
		break;
		case "AB2":
			self loadSpecialAbility("rampage");
		break;
		case "AB3":
			self setStableMissile(1);
		break;
	}
}

SOLDIER_PASSIVE(ability)
{
	switch (ability)
	{
		case "AB1":
			self.weaponMod += "soldier";
		break;
		case "AB2":
			self.hasFastReload = true;
			self SetPerk("specialty_fastreload");
		break;
		case "AB3":
			self thread regenerate(1, 1);
		break;
		case "AB4":
			self.maxhealth += 5;
			self.immune = true;
			self.infectionMP = 0;
		break;
	}
}

loadStealthAbility(type, ability)
{
	switch (type)
	{
		case "PR":
			self thread STEALTH_PRIMARY(ability);
		break;
		case "PS":
			self thread STEALTH_PASSIVE(ability);
		break;
	}
}

///////////////
//	STEALTH  //
///////////////

STEALTH_PRIMARY(ability)
{
	switch (ability)
	{
		case "AB1":
			if( !self hasWeapon("dragunov_mp") ){
				self giveWeapon( "dragunov_mp" );
				self giveMaxAmmo( "dragunov_mp" );
			}
			self setActionSlot( 3, "weapon", "dragunov_mp" );
			// self.actionslotweapons[self.actionslotweapons.size] = "dragunov_mp";
		break;
		case "AB2":
			self loadSpecialAbility("fake_death");
		break;
		case "AB3":
			self thread quickEscape();
			self SetMoveSpeedScale(self.speed+.2);
			
			// self.actionslotweapons[self.actionslotweapons.size] = "dragunov_acog_mp";
		break;
	}
}

STEALTH_PASSIVE(ability)
{
	switch (ability)
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
			if(self hasWeapon("dragunov_mp")){
				self takeWeapon("dragunov_mp");
				// self.actionslotweapons = removeFromArray(self.actionslotweapons, "dragunov_mp"); // Removing previously given dragunov_mp (bad crossbow)
			}
			if(!self hasWeapon("dragunov_acog_mp")){
				self giveWeapon( "dragunov_acog_mp" );
				self giveMaxAmmo( "dragunov_acog_mp" );
			}
			self setActionSlot( 3, "weapon", "dragunov_acog_mp" );
		break;
	}
}

loadMedicAbility(type, ability)
{
	switch (type)
	{
		case "PR":
			self thread MEDIC_PRIMARY(ability);
		break;
		case "PS":
			self thread MEDIC_PASSIVE(ability);
		break;
	}
}

///////////////
//	MEDIC    //
///////////////

MEDIC_PRIMARY(ability)
{
	switch (ability)
	{
		case "AB1":
			self giveWeapon( "helicopter_mp" );
			self setWeaponAmmoClip( "helicopter_mp", 0 );
			self setActionSlot( 3, "weapon", "helicopter_mp" ); // Actionslot [5]
			self thread watchMedkits();
			self thread restoreKit(level.special["medkit"]["recharge_time"]);
			self thread restoreKit(level.special["medkit"]["recharge_time"]);
		break;
		case "AB2":
			self loadSpecialAbility("aura");
		break;
		case "AB3":
			self.transfusion = true;
		break;
	}
}

MEDIC_PASSIVE(ability)
{
	switch (ability)
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

loadArmoredAbility(type, ability)
{
	switch (type)
	{
		case "PR":
			self thread ARMORED_PRIMARY(ability);
		break;
		case "PS":
			self thread ARMORED_PASSIVE(ability);
		break;
	}
}

///////////////
//	ARMORED  //
///////////////

ARMORED_PRIMARY(ability)
{
	switch (ability)
	{
		case "AB1":
			self giveWeapon( "m60e4_reflex_mp" );
			self giveMaxAmmo( "m60e4_reflex_mp" );
			self setActionSlot( 3, "weapon", "m60e4_reflex_mp" );
			// self.actionslotweapons[self.actionslotweapons.size] = "m60e4_reflex_mp";
		break;
		case "AB2":
			self loadSpecialAbility("invincible");
		break;
		case "AB3":
			self.heavyArmor = true;
			self giveArmoredHud();
		break;
	}
}

ARMORED_PASSIVE(ability)
{
	switch (ability)
	{
		case "AB1":
			self.weaponMod += "armored";
			// self setclientdvar("ui_armored", 1);
		break;
		case "AB2":
			self setperk("specialty_bulletaccuracy");
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

loadEngineerAbility(type, ability)
{
	switch (type)
	{
		case "PR":
			self thread ENGINEER_PRIMARY(ability);
		break;
		case "PS":
			self thread ENGINEER_PASSIVE(ability);
		break;
	}
}

///////////////
//	ENGINEER //
///////////////

ENGINEER_PRIMARY(ability)
{
	switch (ability)
	{
		case "AB1":
			self giveWeapon( "m14_reflex_mp" );
			self setWeaponAmmoClip( "m14_reflex_mp", 0 );
			self setActionSlot( 3, "weapon", "m14_reflex_mp" ); // Actionslot [5]
			self.ammoboxTime = 15;
			self.ammoboxRestoration = 25;
			self thread watchAmmobox();
			self thread restoreAmmobox(level.special["ammo"]["recharge_time"]);
		break;
		case "AB2":
			self loadSpecialAbility("augmentation");
		break;
		case "AB3":
			self.longerTurrets = true;
		break;
	}
}

ENGINEER_PASSIVE(ability)
{
	switch (ability)
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

loadScoutAbility(type, ability)
{
	switch (type)
	{
		case "PR":
			self thread SCOUT_PRIMARY(ability);
		break;
		case "PS":
			self thread SCOUT_PASSIVE(ability);
		break;
	}
}

///////////////
//	SCOUT    //
///////////////

SCOUT_PRIMARY(ability)
{
	switch (ability)
	{
		case "AB1":
			self loadSpecialAbility("escape");
		break;
		case "AB2":
			self setperk("specialty_holdbreath");
		break;
		case "AB3":
			self giveWeapon( "usp_silencer_mp" );
			self setOffhandSecondaryClass("flash");
			self setWeaponAmmoClip( "usp_silencer_mp", 0);
			self thread restoreMonkey(level.special["monkey_bomb"]["recharge_time"]);
		break;
	}
}

SCOUT_PASSIVE(ability)
{
	switch (ability)
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
rechargeSpecial(delta)
{
	if (self.special["ability"] == "none" || self.inTrance || self.god || self hasPerk("specialty_rof") || delta < 0)
		return;
	if(self.canUseSpecial){
		self.specialRecharge = 100;
		self setclientdvars("ui_specialtext", "^2Special Available");
		self setclientdvar("ui_specialrecharge", 1);
		self.persData.specialRecharge = self.specialRecharge;
		return;
	}
	
	self.specialRecharge += delta;
	
	if (self.specialRecharge > 100)
		self.specialRecharge = 100;
		
	if (self.specialRecharge == 100)
	{
		self.canUseSpecial = true;
		self setclientdvars("ui_specialtext", "^2Special Available");
	}
	
	self setclientdvar("ui_specialrecharge", self.specialRecharge/100);
	self thread specialRechargeFeedback();
	self.persData.specialRecharge = self.specialRecharge;
}

giveArmoredHud(){
	self.armored_hud = NewClientHudElem ( self );
	self.armored_hud.horzalign = "fullscreen";
	self.armored_hud.vertalign = "fullscreen";
	self.armored_hud.sort = -3;
	self.armored_hud.alpha = 1;
	self.armored_hud setShader( "overlay_armored", 640, 480 );
}


watchMedkits()
{
	self endon("reset_abilities");
	self endon("downed");
	self endon("death");
	self endon("disconnect");
	while (1)
	{
		self waittill ( "grenade_fire", kit, weaponName );
		if (weaponName == "helicopter_mp")
		{
			kit.master = self;
			kit thread beMedkit( self.medkitTime, self.medkitHealing);
			self thread restoreKit(level.special["medkit"]["recharge_time"]);
			self playsound("take_medkit");
			//self thread watchMedkits();
		}
	}
}

watchAmmobox()
{
	self endon("reset_abilities");
	self endon("downed");
	self endon("death");
	self endon("disconnect");
	while (1)
	{
		self waittill ( "grenade_fire", kit, weaponName );
		if (weaponName == "m14_reflex_mp")
		{
			kit.master = self;
			kit thread beAmmobox( self.ammoboxTime );
			self thread restoreAmmobox(level.special["ammo"]["recharge_time"]);
			self playsound("take_ammo");
		}
	}
}

restoreKit(time)
{
	self endon("reset_abilities");
	self endon("downed");
	self endon("death");
	self endon("disconnect");
	self addTimer(&"ZOMBIE_MEDKIT_IN", "", time);
	wait time;
	self setWeaponAmmoClip("helicopter_mp", self getweaponammoclip("helicopter_mp") + 1);
}

restoreAmmobox(time)
{
	self endon("reset_abilities");
	self endon("downed");
	self endon("death");
	self endon("disconnect");
	self addTimer(&"ZOMBIE_AMMOBOX_IN", "", time);
	wait time;
	self setWeaponAmmoClip("m14_reflex_mp", self getweaponammoclip("m14_reflex_mp") + 1);
}

restoreMonkey(time)
{
	self endon("reset_abilities");
	self endon("downed");
	self endon("death");
	self endon("disconnect");
	self addTimer(&"ZOMBIE_MONKEY_IN", "", time);
	wait time;
	self takeWeapon( "usp_silencer_mp" );
	self giveWeapon( "usp_silencer_mp" );
}

restoreInvisibility(time)
{
	self notify("remove_invis_timer");
	self endon("reset_abilities");
	self endon("remove_invis_timer");
	self removeTimers();
	// self endon("downed");
	self endon("death");
	self endon("disconnect");
	self addTimer(&"ZOMBIE_INVISIBILITY_IN", "", time);
}

beAmmobox(time)
{
	self endon("death");
	old = self.origin;
	wait 0.1;
	while( isDefined(self) ){
		if(old != self.origin){
			old = self.origin;
			wait 0.1;
		}
		else
			break;
	}
	if( !isDefined(self) ) return;
	
	self thread scripts\gamemodes\_hud::createHeadiconKits(self.origin+(0,0,15), "icon_ammobox_placed", 0.5); // 2D Icon above the ammobox
	self thread scripts\gamemodes\_hud::createRadarIcon("icon_ammobox_radar"); // Radar Icon
	
	wait 1;
	for (i=0; i<time; i++)
	{
		if( !isDefined(self.master) || !isReallyPlaying(self.master) ) break;
		
		for (ii=0; ii<level.players.size; ii++)
		{
			player = level.players[ii];
			if( !isReallyPlaying(player) ) continue;
			if (distance(self.origin, player.origin) < 120)
			{
				if (!player.isDown)
				{
					self.master thread restoreAmmoClip(player);
				}
			}
		}
		wait 1;
	}
	self delete();
}

beMedkit(time, heal)
{
	self endon("death");
	old = self.origin;
	wait 0.1;
	while( 1 ){
		if(old != self.origin){
			old = self.origin;
			wait 0.1;
		}
		else
			break;
	}
	if( !isDefined(self) || !isDefined(self.master) ) return;
	
	self thread scripts\gamemodes\_hud::createHeadiconKits(self.origin+(0,0,15), "icon_medkit_placed", 0.5); // 2D Icon above the medkit
	self thread scripts\gamemodes\_hud::createRadarIcon("icon_medkit_radar"); // Radar Icon
	
	wait 1;
	for ( i = 0; i < time; i++ )
	{
		if( !isDefined(self.master) || !isReallyPlaying(self.master) ) break;
		for ( ii = 0; ii < level.players.size; ii++ )
		{
			player = level.players[ii];
			if( !isReallyPlaying(player) ) continue;
			if (distance(self.origin, player.origin) < 120)
			{
				if (player.health < player.maxhealth && !player.isDown)
				{
					self.master thread healPlayer(player, heal);
				}
			}
		}
		wait 1;
	}
	self delete();
}

// stealthMovement()//For assassin = makes ur screen 24/7 green, zombies can't see u blah blah, until u die or shot ur weapon or open the shop
// {
	// self endon("reset_abilities");
	// self endon("downed");
	// self endon("death");
	// self endon("disconnect");
	// while (1)
	// {
		// self trance_stealthmove();
		// wait level.special_stealthmove_intermission;// 10 seconds
	// }
// }
stealthMovement()//For assassin = makes ur screen 24/7 green, zombies can't see u
{
	self thread interruptStealthMovement();
	self thread stealthMovementWait();
	self thread restoreInvisibility(level.special_stealthmove_intermission);
}

interruptStealthMovement(){
	self endon("reset_abilities");
	self endon("death");
	self endon("disconnect");
	while(1){
		self waittill_any("weapon_fired", "grenade_fire", "detonated", "used_usable");
		self notify("end_trance");
		self.canHaveStealth = false;
		wait 0.05;
	}
}

stealthMovementWait(){
	self endon("reset_abilities");
	self endon("death");
	self endon("disconnect");
	i = 0;
	while(1){
		if(!self.canHaveStealth || self.isDown){
			i = 0;
			self.canHaveStealth = true;
			if(!self.isDown)
				self thread restoreInvisibility(level.special_stealthmove_intermission);
		}
		else if(i >= level.special_stealthmove_intermission && !self.inTrance && self.visible){
			self thread trance_stealthmove();
			self thread trance_stealthmove_end();
		}
		i += 0.1;
		wait 0.1;
	}

}

trance_stealthmove()
{
	self endon("end_trance");
	self endon("death");
	self endon("disconnect");
	while (self.inTrance)
	wait .5;
	
	self.trance = "stealthmove";
	self.inTrance = true;
	self.visible = false;
	self playerFilmTweaks(1, 0, 0, "0 1 0",  "0 1 2", 0, 1.1, 1);//1, 0, .75, ".25 1 .5",  "25 1 .7", .20, 1.4, 1
	
	self endon("death");	
	self waittill("end_trance");
}

trance_stealthmove_end()
{
	self endon("death");
	self endon("disconnect");
	self waittill("end_trance");
	self.inTrance = false;
	self.trance = "";
	self playerFilmTweaksOff();
	self.visible = true;
}

quickEscape() // When health gets below 25% we give ourselves a speedboost - for Assassin class
{
	self endon("reset_abilities");
	self endon("death");
	self endon("disconnect");
	self endon("downed");
	while (1)
	{
		self waittill("damage", idamage);
		if (idamage != 0)
		{
			if (self.health <= self.maxhealth / 4 && !self.inTrance)
			{
				self trance_quickescape();
				wait level.special_quickescape_intermission;//15 seconds
			}
		}
	}
}

trance_quickescape()
{
	if (self.inTrance) 	// OVERRIDE!
	self notify("end_trance");
	
	self endon("end_trance");
	
	self.trance = "quick_escape";
	self.inTrance = true;
	
	self SetMoveSpeedScale(self.speed+.2);
	self.visible = false;
	self playerFilmTweaks(1, 0, .75, ".25 1 .5",  "25 1 .7", .20, 1.4, 1.25);
	
	self thread trance_quickescape_end();
	
	wait level.special_quickescape_duration;// 6 seconds
	
	self notify("end_trance");
}

trance_quickescape_end()
{
	self waittill("end_trance");
	self.inTrance = false;
	self.trance = "";
	self playerFilmTweaksOff();
	self.visible = true;
	self SetMoveSpeedScale(self.speed);
}

regenerate(health, interval, limit)
{
	self endon("reset_abilities");
	self endon("death");
	self endon("disconnect");
	self endon("downed");
	if (!isdefined(limit))
	{
		while (1)
		{
			if (self.health < self.maxhealth)
			{
				self heal(health);
			}
			wait interval;
		}
	}
	else
	{
		for (i=0; i<limit; i++)
		{
			if (self.health < self.maxhealth)
			{
				self heal(health);
			}
			wait interval;
		}
	}
}

heal(x)
{
	self.health += x;
	if (self.health > self.maxhealth)
	self.health = self.maxhealth;
	self updateHealthHud(self.health/self.maxhealth);
}

reloadForArmored()
{
	self endon("disconnect");
	self endon("death");
	
	while(1)
	{
		if (self.curClass != "armored" || self.sessionstate == "spectator")
		return;
		self waittill( "weapon_change" );
		wep = self getcurrentweapon();
		if (scripts\players\_weapons::isLMG(wep))
			self SetPerk("specialty_fastreload");
		else
			self unSetPerk("specialty_fastreload");
	}
}

dynamicAccuracy(){
	// self.accuracyOverwrite = 6;
	self endon( "reset_abilities" );
	self endon( "death" );
	self endon( "disconnect" );
	while(1){
		self waittill( "begin_firing" );
		self thread accuracyChangeUp();
		self waittill( "end_firing" );
		self thread accuracyChangeDown();
	}
}

accuracyChangeUp(){
	self endon( "reset_abilities" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "end_firing" );
	while( isReallyPlaying(self) && isAlive(self) ){
		// self iprintlnbold( "Up: " + self.accuracyOverwrite );
		self setSpreadOverride( self.accuracyOverwrite );
		self.accuracyOverwrite--;
		if(self.accuracyOverwrite < 1)
			self.accuracyOverwrite = 1;
		wait 0.4;
	}
}

accuracyChangeDown(){
	self endon( "reset_abilities" );
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "begin_firing" );
	while( isReallyPlaying(self) && isAlive(self) ){
		// self iprintlnbold( "Down: " + self.accuracyOverwrite );
		self setSpreadOverride( self.accuracyOverwrite );
		self.accuracyOverwrite++;
		if(self.accuracyOverwrite == 6)
			break;
		wait 0.4;
	}
}

watchSpecialAbility()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("join_spectator");
	self endon("death");
	self notify("watch_special");
	self endon("watch_special");
	
	wait 1;
	
	if ( !isdefined(self.special["ability"]) || self.special["ability"] == "none" )
		return;
	
	i = 0;
	/* Will trigger the special when holding the F button for 1 second */
	while(1){
		if(!self.isDown && !self.isBusy && self UseButtonPressed())
			i++;
		else
			i = 0;
			
		if(i >= 10){
			self thread onSpecialAbility();
			i = 0;
		}
			
		wait 0.1;
	}
}

onSpecialAbility()
{
	if (!self.canUseSpecial){
		// self iprintln("^1DEBUG: ^7You can't use your special! self.canUseSpecial == false !");
		return;
	}
	
	self notify("special_ability");
	
	switch (self.special["ability"])
	{
		case "aura":
			self thread specialAura(self.special["duration"]);
			iprintln(self.name + "^7 has placed a ^2Healing Aura^7!");
			self resetSpecial();
		break;
		case "rampage":
			self doRampage(self.special["duration"]);
			iprintln(self.name + "^7 activated their ^1Rampage^7!");
			self resetSpecial();
		break;
		case "invincible":
			self doInvincible(self.special["duration"]);
			iprintln(self.name + "^7 has become ^3Invincible^7!");
			self resetSpecial();
		break;
		case "augmentation":
			if (self doAugmentation()){
				iprintln(self.name + "^7 ^3augmented ^7their ^3Turrets^7!");
				self resetSpecial();
			}
		break;
		case "escape":
			self doEscape(self.special["duration"]);
			iprintln(self.name + "^7 ^5sped ^7themself up^7!");
			self resetSpecial();
		break;
		case "fake_death":
			self doNinja(self.special["duration"]);
			iprintln(self.name + "^7 is temporarily ^5untargetable^7!");
			self resetSpecial();
		break;
	}
}

resetSpecial()
{
	self.canUseSpecial = false;
	self.specialRecharge = 0;
	self setclientdvars("ui_specialtext", "^1Special Recharging", "ui_specialrecharge", 0);
	//time = self.special["recharge_time"];							/*This was used
	//self addTimer(&"", "Special In:", time);						 	in rotu
	//wait time;													      1.15
	//self.canUseSpecial = true;									 	   or
	//self setclientdvar("ui_specialtext", "^2Special Available");	 	   2.0		*/
}

//*****************************************************************************************
// 										 Aura Special
//*****************************************************************************************

specialAura(time)
{
	self endon("disconnect");
	self endon("killed_player");
	
	origin = self.origin;
	trace = bulletTrace(self.origin + (0,0,50), self.origin + (0,0,-200), false, self);
  
    if(trace["fraction"] < 1 )
    {
        //smooth clamp
//        self SetOrigin(trace["position"]);
       origin = trace["position"];// + (0.0, 5.0, 0.0);
   }

	
	healObject = spawnHealFX(origin, level.healingEffect);
	healObject.healing = self.auraHealing;
	healObject.master = self;	
	healObject thread healObjectHeal(time);
	self playsound("aura_spawn");
}

spawnHealFX( groundpoint, fx )
{
	effect = spawnFx( fx, groundpoint, (0,0,1), (1,0,0) );
	triggerFx( effect );
	
	return effect;
}

healObjectHeal(time)
{
	wait 2;
	timePassed = 0;
	while (timePassed < time)
	{
		for (i=0; i<=level.players.size; i++)
		{
			player = level.players[i];
			if (isdefined(player))
			{
				if (player.isAlive)
				{
					if (distance(self.origin, player.origin) <= 240) 
					{
						if (player.health < player.maxhealth)
						{
							self thread healThread(player);
						}
					}
				}
			}
				
		}
		timePassed += 2;
		wait 2;
	}
	self delete();
}

healThread(player)
{
	master = self.master;
	// JeyS aangepaste heal functie
	// Wacht tot dat afstand kleiner is dan 20 en dan pas helen
	self thread glow_heal_ball_out(player);
	player waittill("glow_ball_reached");
	master thread healPlayer(player, self.healing);
	// 							

}

healPlayer(player, heal)
{
	if (player.health == player.maxhealth || !isDefined(heal))
	return;
	
	player.health += heal;
	healed = heal;
	if (player.health > player.maxhealth)
	{
		healed -= player.health - player.maxhealth;
		player.health = player.maxhealth;	
	}
	player thread screenFlash((0,.65,0), .5, .4);
	player thread healthFeedback();
	player updateHealthHud(player.health/player.maxhealth);
	if (player != self){
		self scripts\players\_players::incUpgradePoints(getRewardForHeal(healed) * level.dvar["game_rewardscale"]);
		self.stats["healsGiven"] += healed;
	}
	if (self.curClass == "medic" && player != self)
	{
		self rechargeSpecial(healed/4);
	}
	return healed;
}

restoreAmmoClip(player)
{
	wep = player getcurrentweapon();//gets the name of the current weapon of the player holding
	
	if (!scripts\players\_weapons::canRestoreAmmo(wep))//if it's a special weapon, it won't restore it's ammo E.g = raygun,tesla...
	return;
	
	stockAmmo = player GetWeaponAmmoStock( wep );//gets the total ammount of ammo it has at the moment, not the clip but the stock like 95
	stockMax = WeaponMaxAmmo( wep );//gets the total ammount of ammo the certain weapon has (not clip) E.g = MaxAmmo of ak47 is 180
	
	tenthOfMax = int( stockMax/10 );//E.g AK47= 180/10 = 18, 18 is an int so no need to round the number(17.5>18)
	
	if (tenthOfMax < 1)
		tenthOfMax = 1;

	perc = ( stockMax - stockAmmo ) / tenthOfMax; // 

	if (perc > 1)
		perc = 1;

	if ( stockAmmo < stockMax )
	{
		if( (stockAmmo + tenthOfMax) > stockMax)
			tenthOfMax = stockMax - stockAmmo;
			
		stockAmmo += tenthOfMax;
		if ( stockAmmo > stockMax )
			stockAmmo = stockMax;
		
		player setWeaponAmmoStock( wep, stockAmmo );
		player thread screenFlash((0,0,0.65), .5, .4);
		player playlocalsound("weap_pickup");
		if (player != self && self.curClass == "engineer"){
			self scripts\players\_players::incUpgradePoints( int( 2 * perc ) * level.dvar["game_rewardscale"] );
			self.stats["ammoGiven"] += tenthOfMax;
			self scripts\players\_abilities::rechargeSpecial( 8 * perc );
		}
		
	}
}

getRewardForHeal(heal)
{
	if (heal > 0)
		return int((heal+10)/5);
	else
		return 0;
}

//*****************************************************************************************
// 										 Moving glow ball
//*****************************************************************************************

glow_heal_ball_out(p)
{
	offset = (0,0,40);
	ball_tag = spawn("script_model",self.origin + offset);
	ball_tag setModel("tag_origin");
	while(1)
	{
		wait 0.05;
		head_tag_org = p getTagOrigin("j_head");
		
		if(distance(ball_tag.origin,head_tag_org) > 30)
		{
			movespeed = 1.3;
			num = 10;
			
			if(distance(ball_tag.origin,head_tag_org) > 30 && distance(ball_tag.origin,head_tag_org) < 64)
				movespeed = 0.55;num = 5;
			
			head_tag_org = p getTagOrigin("j_head");
			ball_tag moveTo(head_tag_org,movespeed);

			for(i=0;i<num;i++)
			{
				playFXOnTag(level.heal_glow_effect,ball_tag,"tag_origin");
				wait 0.1;
			}
		}
		else
		{
			p thread player_glow_up();
			p notify("glow_ball_reached");
			ball_tag delete();
			break;
		}
	}
}

player_glow_up()
{
	tag = "j_head";
	playFXOnTag(level.heal_glow_body,self,tag);
}
//self playerFilmTweaks(1, 0, 0, "1 1 1",  "1 1 1", 0, 1, 1); - Default FilmTweaks for Rotu
//*****************************************************************************************
// 										 Rampage Special
//*****************************************************************************************

doRampage(time)
{
	self endon("death");
	self endon("downed");
	self endon("disconnect");
	
	self setclientdvar("ui_specialtext", "^5Special Activated!");
	self.canUseSpecial = false;
	self setPerk("specialty_rof");
	self setPerk("specialty_fastreload");
	self thread screenFlash((.65, .1, .1), .5, .6);
	self playerFilmTweaks(1, 0, 0, "1 0 0",  "1 0 2", 0, 1, 1.2);//1, 0, .8, "0.9 0.4 0.3",  "1 0.5 0.5", .25, 1.4, 1.2
	self thread regenerate(2, time/40, 40);

	wait time;

	self playerFilmTweaksOff();
	self thread screenFlash((.65, .1, .1), .5, .6);
	self unSetPerk("specialty_rof");
	if (!self.hasFastReload)
	self unSetPerk("specialty_fastreload");
}

//*****************************************************************************************
// 										 Fake Death Special
//*****************************************************************************************

doNinja(time)
{
	self endon("death");
	self endon("downed");
	self endon("disconnect");
	self notify("end_trance");
	
	wait 0.1;
	
	self setclientdvar("ui_specialtext", "^5Special Activated!");
	self.canUseSpecial = false;
	self.trance = "stealthmove";
	self.inTrance = true;
	self.visible = false;
	self thread screenFlash((.1, .1, .65), .5, .6);
	//(enable, invert, desaturation, darktint,  lighttint, brightness, contrast, fovscale)
	self playerFilmTweaks(1, 0, 0, "2 2 0",  "1 2 2", 0, 1.1, 1);//original this time lol
	
	wait time;
	
	self.trance = "";
	self.inTrance = false;
	self.visible = true;
	self playerFilmTweaksOff();
	self thread screenFlash((.1, .1, .65), .5, .6);
	
	wait 0.1;
	
	self notify("end_trance");

}

//*****************************************************************************************
// 										 Invincible Special
//*****************************************************************************************

doInvincible(time)
{
	self endon("death");
	self endon("downed");
	self endon("disconnect");
	
	self setclientdvar("ui_specialtext", "^5Special Activated!");
	self.canUseSpecial = false;
	self.god = true;
	self.immune = true;
	self.infectionMP = 0;
	self thread doInvincibleHud();
	self thread screenFlash((.1, .1, .65), .5, .6);
	// self playerFilmTweaks(1, 0, 0, "0 0 1",  "0 1 1", 0, 0.9, 1);//1, 0, .4, "0.4 0.4 0.8",  "0.5 0.5 1", .25, 1.4, 1
	
	wait time;
	self.god = false;
	self.immune = false;
	self notify("stop_armored_hud");
	self updateArmorHud();
	self.infectionMP = 1;
	self playerFilmTweaksOff();
	self thread screenFlash((.1, .1, .65), .5, .6);
}

doInvincibleHud(){
	self endon("death");
	self endon("downed");
	self endon("disconnect");
	self endon("stop_armored_hud");
	
	if(!isDefined(self.armored_hud))
		self giveArmoredHud();
		
	self.armored_hud.color = (0.6,0.6,1);
	self.armored_hud.alpha = 1;
	
	while(1){
		self.armored_hud fadeOverTime(0.3);
		self.armored_hud.alpha = 0;
		wait 0.3;
		self.armored_hud fadeOverTime(0.5);
		self.armored_hud.alpha = 1;
		wait 0.5;
	}
}

//*****************************************************************************************
// 										 Escape Special
//*****************************************************************************************

doEscape(time)
{
	self endon("downed");
	self endon("death");
	self endon("disconnect");
	
	if (self.inTrance) 	// OVERRIDE!
	self notify("end_trance");
	
	self endon("end_trance");
	
	self setclientdvar("ui_specialtext", "^5Special Activated!");
	self.canUseSpecial = false;
	self.trance = "quick_escape";
	self.inTrance = true;
	self.visible = true;
	
	self SetMoveSpeedScale(self.speed+.25);
	
	self thread screenFlash((.1, .1, .65), .5, .6);
	self playerFilmTweaks(1, 0, 0, "0 1 2",  "2 2 1", 0, 1, 1);//1, 0, .75, ".25 .5 1",  ".25 .7 1", .20, 1.4, 1.25
	
	wait time;
	
	self.inTrance = false;
	self playerFilmTweaksOff();
	self thread screenFlash((.1, .1, .65), .5, .6);
	self SetMoveSpeedScale(self.speed);
	self notify("end_trance");
}

//*****************************************************************************************
// 									Augmented Turrets
//*****************************************************************************************

doAugmentation(){
	if( level.turretsDisabled ){
		self iprintlnbold("Turrets are disabled! You can't use your Special!");
		return false;
	}
	
	turrets = [];
	for(i = 0; i < self.useObjects.size; i++){
		o = self.useObjects[i];
		if( o.type == "turret" && o.owner == self && !o.occupied )
			turrets[turrets.size] = o;
	}
	
	if(turrets.size == 0){
		self iprintlnbold("You need at least one turret to activate your Special!");
		return false;
	}
	
	for(i = 0; i < turrets.size; i++)
		turrets[i] scripts\players\_turrets::goAugmented();
	return true;
}


// doAmmoSpecial()
// {
	// weapon = self GetCurrentWeapon();
	// if (weapon == self.primary || weapon == self.secondary )
	// {
		// self playlocalsound("weap_pickup");
		// self GiveMaxAmmo(weapon);
		// return 1;
	// }
	// self iprintln("^1Invalid weapon!");
	// return 0;
// }