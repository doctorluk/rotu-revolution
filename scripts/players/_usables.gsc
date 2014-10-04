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
#include scripts\include\entities;

init()
{
	level.useObjects = [];
	thread spawnMoveprevention();
}

/* Idea by LEGX|Jeffskye */
spawnMoveprevention(){

	level.antimove = spawn( "script_origin", ( 0, 0, 0) );
	level.antimove hide();
}

addUsable(ent, type, hintstring, distance)
{
	self.useObjects[self.useObjects.size] = ent;
	ent.occupied = false;
	ent.type = type;
	ent.hintstring = hintstring;
	if (isdefined(distance))
	ent.distance = distance;
	else
	ent.distance = 96;
}

removeUsable(ent)
{
	for (i=0; i<level.players.size; i++)
	{
		player = level.players[i];
		if (isdefined(player.curEnt))
		{
			if (player.curEnt == ent)
			{
				player usableAbort();
				player.curEnt = undefined;
			
			}
		}
	}
	
	self.useObjects = removeFromArray(self.useObjects, ent);
	
}

checkForUsableObjects()
{
	self endon("death");
	self endon("disconnect");
	self endon("downed");
	level endon("game_ended");
	self.curEnt = undefined;
	hasPressedF = false;
	isUsing = false;

	while (1)
	{
		if (!self.canUse)
		{
			self usableAbort();	
			wait .1;
			continue;
		}
		if (!isdefined(self.curEnt))
		{
			if (self.isBusy)
			self.isBusy = false;
			
			if (getBetterUseObj(1024))
			continue;
			wait .2;
		}
		else
		{
			dis = distance(self.origin, self.curEnt.origin);
			if (!self.isBusy)
			{
				if (self.curEnt.occupied)
				{
					self.curEnt = undefined;
					// self setclientdvar("ui_hintstring", "" );
					self showHinttext(0);
					continue;
				}
				if (getBetterUseObj(dis))
				continue;
			}
			
			//if (isdefined(self.curEnt))
			//{

			
			if (dis <= self.curEnt.distance)
			{
				if (self useButtonPressed())
				{
					if (hasPressedF == false && self isOnGround() && !self.curEnt.occupied )
					{
						self thread usableUse();
						hasPressedF = true;
					}
				}
				else
				{
					if (hasPressedF == true)
					{
						self usableAbort();
						hasPressedF = false;
					}
				}
			}
			else
			{
				self usableAbort();		
			}
			wait .05;
		}
	}
}

getBetterUseObj(distance)
{
	foundEnt = 0;
	for (i=0; i<level.useObjects.size; i++)
	{
		ent = level.useObjects[i];
		if (!canUseObj(ent))
		continue;
		if (foundEnt==1&&!isplayer(ent))
		continue;
		dis = distance(self.origin, ent.origin);
		if (dis <= ent.distance && !ent.occupied  && dis < distance)
		{
			// self setclientdvar("ui_hintstring", ent.hintstring );
			self.hinttext setText(ent.hintstring);
			self showHinttext(1);
			self.curEnt = ent;
			foundEnt = 1;
		}
	}
	if (foundEnt)
	return 1;
	
	for (i=0; i<self.useObjects.size; i++)
	{
		ent = self.useObjects[i];
		dis = distance(self.origin, ent.origin);
		if (dis <= ent.distance && !ent.occupied && dis < distance )
		{
			// self setclientdvar("ui_hintstring",ent.hintstring );
			self.hinttext setText(ent.hintstring);
			self showHinttext(1);
			self.curEnt = ent;
			return 1;
		}
	}
	return 0;
}

canUseObj(obj)
{
	if (obj == self)
		return 0;
	if (obj.type == "infected" && !self.canCure)
		return 0;
	
	return 1;
}

usableUse()
{
	// self setclientdvar("ui_hintstring", "");
	self showHinttext(0);
	if (isdefined(self.curEnt))
	{
		if (!canUseObj(self.curEnt))
		{
			self usableAbort();
			return;
		}
		self notify("used_usable");
		switch ( self.curEnt.type )
		{
			case "revive":
				self.curEnt.occupied = true;
				self.isBusy = true;
				self.curEnt setclientdvar("ui_infostring", "You are being revived by: " + self.name);
				if( self.reviveWill ) self setclientdvar("ui_damagereduced", 1); // Medic Passive
				self linkTo( level.antimove );
				self disableWeapons();
				self progressBar(self.revivetime);
				self thread reviveInTime(self.revivetime, self.curEnt);
			break;
			case "infected":
				if (!self.curEnt.isDown)
				{
					iprintln("^2"+self.curEnt.name+"^2's infection has been cured by " + self.name + ".");
					self.curEnt scripts\players\_infection::cureInfection();
					self scripts\players\_players::incUpgradePoints(20*level.dvar["game_rewardscale"]);
					self thread scripts\players\_rank::giveRankXP("revive");
					
				}
			
			break;
			case "weaponpickup":
				self scripts\players\_weapons::swapWeapons(self.curEnt.wep_type, self.curEnt.myWeapon);
			break;
			case "objective":
				level notify("obj_used"+self.curEnt.usable_obj_id);
			break;
			case "extras":
				self setclientdvar("ui_points", int(self.points) );
				self closeMenu();
				self closeInGameMenu();
				self openMenu(game["menu_extras"]);
			break;
			case "ammobox":
				if (level.ammoStockType == "ammo")
				{
					self.isBusy = true;
					self freezecontrols(1);
					self disableWeapons();
					self progressBar(self.curEnt.loadtime);
					self thread ammoInTime(self.curEnt.loadtime);
				}
				if (level.ammoStockType == "upgrade")
				{
					wep = self getcurrentWeapon();
					if (wep == self.primary)
					scripts\gamemodes\_upgradables::doUpgrade("primary");
					if (wep == self.secondary)
					scripts\gamemodes\_upgradables::doUpgrade("secondary");
					if (wep == self.extra)
					scripts\gamemodes\_upgradables::doUpgrade("extra");
				}
				if (level.ammoStockType == "weapon")
				{
					if (!isdefined( self.box_weapon))
					{
						if (self.points >= level.dvar["surv_waw_costs"])
						{
							if (level.dvar["surv_waw_alwayspay"])
							self scripts\players\_players::incUpgradePoints(-1*level.dvar["surv_waw_costs"]);
							scripts\gamemodes\_mysterybox::mystery_box(self.curEnt);
						}
					}
					else
					{
						if (self.box_weapon.done)
						{
							self scripts\players\_weapons::swapWeapons(self.box_weapon.slot, self.box_weapon.weaponName);
							self.box_weapon delete();
							if (!level.dvar["surv_waw_alwayspay"])
							self scripts\players\_players::incUpgradePoints(-1*level.dvar["surv_waw_costs"]);
							
						}
					}
					
				}
			break;
			case "barricade":
				self.isBusy = true;
				self linkTo( level.antimove );
				self disableWeapons();
				self progressBar(1);
				self thread restoreBarricadeInTime(1);
			break;
			case "turret":
				turret_type = self.curEnt.turret_type;
				augmented = self.curEnt.isAugmented;
				timepassed = self.curEnt.timePassed + (gettime() - self.curEnt.spawnTime)/1000;
				self scripts\players\_turrets::deleteTurret(self.curEnt, self.curEnt.bipod);
				self scripts\players\_turrets::giveTurret(turret_type, timepassed, augmented);
			break;
		}
	}
}

showHinttext(alpha){
	if(isDefined(self.hinttext) && self.hinttext.alpha != alpha){
		self.hinttext.alpha = alpha;
	}
}


usableAbort()
{
	self notify("usable_abort");
	// self setclientdvar("ui_hintstring", "");
	self showHinttext(0);

	if (isdefined(self.curEnt))
	{
		switch ( self.curEnt.type )
		{
				case "revive":
					self.isBusy = false;
					self.curEnt setclientdvar("ui_infostring", "");
					if( self.reviveWill ) self setclientdvar("ui_damagereduced", 0); // Medic Passive
					self.curEnt.occupied = false;
					self unlink( level.antimove	);
					self EnableWeapons();
					self destroyProgressBar();
				break;
				case "ammobox":
					if (level.ammoStockType == "ammo")
					{
						self.isBusy = false;
						self freezecontrols(0);
						self EnableWeapons();
						self destroyProgressBar();
					}
				break;
				case "barricade":
					self.isBusy = false;
					self unlink( level.antimove	);
					self EnableWeapons();
					self destroyProgressBar();
				break;
		}
		self.curEnt = undefined;
	}
}

// USABLE FUNCTIONS!
restoreBarricadeInTime(time)
{
	self endon("death");
	self endon("disconnect");
	self endon("usable_abort");
	wait time;

	self thread restoreBarricade();
	
	self thread usableAbort();
}

restoreBarricade()
{
	if (self.curEnt scripts\players\_barricades::restorePart()){
		self scripts\players\_players::incUpgradePoints(3*level.dvar["game_rewardscale"]);
		self.stats["barriersRestored"]++;
	}
}

reviveInTime(time, player)
{
	self endon("death");
	self endon("disconnect");
	self endon("usable_abort");
	wait time;

	self thread finishRevive(player);

}

finishRevive(player)
{
	self endon("death");
	self endon("disconnect");
	self destroyProgressBar();
	self freezecontrols(0);
	if (isdefined(player) && isalive(player))
	{
		player thread scripts\players\_players::revive(self);
		player notify ("damage", 0);
		iprintln(player.name + " was revived by " + self.name + ".");
		player setclientdvar("ui_infostring", "");
		
		self  thread scripts\players\_rank::giveRankXP("revive");
		self scripts\players\_players::incUpgradePoints(40*level.dvar["game_rewardscale"]);
	}
	wait .5;
	self.stats["revives"]++;
	self EnableWeapons();
	self thread usableAbort();
}

ammoInTime(time)
{
	self endon("death");
	self endon("disconnect");
	self endon("usable_abort");
	wait time;

	self destroyProgressBar();
	self freezecontrols(0);
	weaponsList = self GetWeaponsList();
	for( idx = 0; idx < weaponsList.size; idx++ )
	{
		if (weaponsList[idx] == "claymore_mp")
			continue;
		if (weaponsList[idx] == "tnt_mp")
			continue;
		if (weaponsList[idx] == "c4_mp")
			continue;
		if (weaponsList[idx] == "frag_grenade_mp")
			continue;
		if (weaponsList[idx] == "usp_silencer_mp")
			continue;
		if (weaponsList[idx] == "saw_acog_mp")
			continue;
		self giveMaxAmmo(weaponsList[idx]);
	}
	wait .5;
	self EnableWeapons();

}