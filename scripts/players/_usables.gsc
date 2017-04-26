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

/***
*
* 	_usables.gsc
*	Deals with updating the player's shop costs dvars and handles the menu's responses when players use the ingame shop
*	to get upgrades
*
*/

#include scripts\include\hud;
#include scripts\include\data;
#include scripts\include\entities;
#include scripts\include\weapons;

init()
{
	// Although we often use 'self.useObjects', the 'self' is often 'level'... this is a bit confusing
	level.useObjects = [];
	thread spawnMoveprevention();
}

/**
*	Spawns an entity at the 0,0,0 position and is later used to bind players to it during revival
*	Idea by LEGX|Jeffskye
*/
spawnMoveprevention()
{
	level.antimove = spawn("script_origin", (0, 0, 0));
	level.antimove hide();
}

/**
*	Adds a usable object on the field
*	@ent Entity, The entity that will become usable
*	@type String, The type that this usable will be
*	@hintstring String, The string that should be displayed
*	@distance Int, The range of the usable item from which it will be usable
*/
addUsable(ent, type, hintstring, distance)
{
	self.useObjects[self.useObjects.size] = ent;
	
	ent.occupied = false;
	ent.type = type;
	ent.hintstring = hintstring;
	
	if (isDefined(distance))
		ent.distance = distance;
	else
		ent.distance = 96;
}

/**
*	Removes the given entity from the usables list, thus making it unusable
*	@ent Entity, The entity to be removed from the usables list
*/
removeUsable(ent)
{
	for (i = 0; i < level.players.size; i++)
	{
		player = level.players[i];
		
		if (isDefined(player.curEnt) && player.curEnt == ent)
		{
			player usableAbort();
			player.curEnt = undefined;
		}
	}
	
	self.useObjects = removeFromArray(self.useObjects, ent);
}

/**
*	Threaded loop which is called by every player
*	It checks the surroundings of each player for usable objects and makes them usable if the
*	player is in range for it
*/
checkForUsableObjects()
{
	self endon("death");
	self endon("disconnect");
	self endon("downed");
	
	level endon("game_ended");
	
	self.curEnt = undefined;
	
	hasPressedF = false;
	isUsing = false;

	while(1)
	{
		wait 0.05;
		
		// We don't look for usable objects if the player isn't able to use any
		if (!self.canUse)
		{
			self usableAbort();	
			wait 0.1;
			continue;
		}
		
		// If the currently used entity has become unavailable, we stop the player from using it and
		// look for another
		if (!isDefined(self.curEnt))
		{
			if (self.isBusy)
				self.isBusy = false;
			
			if (self getBetterUseObj(1024))
				continue;
				
			wait 0.1;
		}
		// If the player has a valid close entity
		else
		{
			dis = distance(self.origin, self.curEnt.origin);
			
			// Check whether he is able to use the entity and check his surroundings
			if (!self.isBusy)
			{
				// The checked entity is already in use, abort mission!
				if (self.curEnt.occupied)
				{
					self.curEnt = undefined;
					self showHinttext(0);
					continue;
				}
				// Check for close usable entites
				if (self getBetterUseObj(dis))
					continue;
			}
			// If we're close enough to the entity, let's try using it
			if (dis <= self.curEnt.distance)
			{
				if (self useButtonPressed())
				{
					if (hasPressedF == false && self isOnGround() && !self.curEnt.occupied)
					{
						self thread usableUse();
						hasPressedF = true;
					}
				}
				else
				{
					if (hasPressedF == true)
					{
						// If we tried using the object and stopped holding F in the mean time, abort
						self usableAbort();
						hasPressedF = false;
					}
				}
			}
			// In case the entity has gotten out of range, abort using it
			else
			{
				self usableAbort();		
			}
		}
	}
}

/**
*	Searches around the player for a usable object
*	@distance Float, Maximum range around the player we should scan for usable entities
*	@return Boolean, Whether we found a usable object around us or not
*/
getBetterUseObj(distance)
{
	foundEnt = 0;
	
	for (i = 0; i < level.useObjects.size; i++)
	{
		ent = level.useObjects[i];
		
		if (!canUseObj(ent))
			continue;
		
		// Continue searching if the given entity is not a player
		// This ensures that we prioritize reviving and curing players
		if (foundEnt == 1 && !isPlayer(ent))
			continue;
			
		dis = distance(self.origin, ent.origin);
		
		// If an object was in range, we update the player's hinttext and make it usable for him
		if (dis <= ent.distance && !ent.occupied && dis < distance)
		{
			self.hinttext setText(ent.hintstring);
			self showHinttext(1);
			self.curEnt = ent;
			
			foundEnt = 1;
		}
	}
	
	// After looping through all objects, return true when we found one
	if (foundEnt)
		return true;
	
	// Now we scan for personal objects, like Turrets and other personally placed items
	for (i = 0; i < self.useObjects.size; i++)
	{
		ent = self.useObjects[i];
		
		dis = distance(self.origin, ent.origin);
		
		if (dis <= ent.distance && !ent.occupied && dis < distance)
		{
			self.hinttext setText(ent.hintstring);
			self showHinttext(1);
			self.curEnt = ent;
			
			return true;
		}
	}
	return false;
}

/**
*	Checks whether the entity can be used or not
*	@obj Entity, The entity to be checked if it can be used by the calling entity
*	@return Boolean, Whether the given @obj can be used or not
*/
canUseObj(obj)
{
	if (obj == self)
		return false;
		
	if (obj.type == "infected" && !self.canCure)
		return false;
	
	return true;
}

/**
*	Handler of any usable items
*/
usableUse()
{
	self showHinttext(0);
	if(isDefined(self.curEnt))
	{
		// Abort if usable object can't be used
		if (!canUseObj(self.curEnt))
		{
			self usableAbort();
			return;
		}
		
		// Notify the player's threads that he is using something
		self notify("used_usable");
		
		// Handle the different usable types
		switch (self.curEnt.type)
		{
			case "revive":
				self.curEnt.occupied = true;
				self.isBusy = true;
				
				self.curEnt setclientdvar("ui_infostring", "You are being revived by: " + self.name);
				
				if(self.reviveWill)
					self setclientdvar("ui_damagereduced", 1); // Medic Passive
				
				// Instead of freezing reviving players, we just link them to a global object and keep them rotatable
				self linkTo(level.antimove);
				self disableWeapons();
				self progressBar(self.revivetime);
				
				self thread reviveInTime(self.revivetime, self.curEnt);
			break;
			
			case "infected":
				if (!self.curEnt.isDown)
				{
					// TODO: Find better means of reporting cured players?
					iprintln("^2" + self.curEnt.name + "^2's infection has been cured by " + self.name + ".");
					
					self.curEnt scripts\players\_infection::cureInfection();
					// TODO: Create one file/script that handles all rewards for all usables?
					self scripts\players\_players::incUpgradePoints(20 * level.dvar["game_rewardscale"]);
					
					self thread scripts\players\_rank::giveRankXP("revive");
				}
			
			break;
			
			case "weaponpickup":
				self scripts\players\_weapons::swapWeapons(self.curEnt.wep_type, self.curEnt.myWeapon);
			break;
			
			case "objective":
				level notify("obj_used" + self.curEnt.usable_obj_id);
			break;
			
			case "extras":
				self setclientdvar("ui_points", int(self.points));
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
				// Weapon Upgrading Machine
				if (level.ammoStockType == "upgrade")
				{
					wep = self getCurrentWeap();
					
					if(wep == self.primary)
						scripts\gamemodes\_upgradables::doUpgrade("primary");
						
					if(wep == self.secondary)
						scripts\gamemodes\_upgradables::doUpgrade("secondary");
						
					if(wep == self.extra)
						scripts\gamemodes\_upgradables::doUpgrade("extra");
				}
				// CoD WaW Mystery Box
				if (level.ammoStockType == "weapon")
				{
					if(!isDefined(self.box_weapon))
					{
						if(self.points >= level.dvar["surv_waw_costs"])
						{
							if (level.dvar["surv_waw_alwayspay"])
							self scripts\players\_players::incUpgradePoints(-1 * level.dvar["surv_waw_costs"]);
							scripts\gamemodes\_mysterybox::mystery_box(self.curEnt);
						}
					}
					else
					{
						if(self.box_weapon.done && (!level.dvar["surv_waw_alwayspay"] || self.points >= level.dvar["surv_waw_costs"]))
						{
							self scripts\players\_weapons::swapWeapons(self.box_weapon.slot, self.box_weapon.weaponName);
							self.box_weapon delete();
							if(!level.dvar["surv_waw_alwayspay"])
								self scripts\players\_players::incUpgradePoints(-1 * level.dvar["surv_waw_costs"]);
						}
					}
					
				}
			break;
			
			case "barricade":
				self.isBusy = true;
				self linkTo(level.antimove);
				self disableWeapons();
				self progressBar(1);
				self thread restoreBarricadeInTime(1);
			break;
			
			case "turret":
				turret_type = self.curEnt.turret_type;
				augmented = self.curEnt.isAugmented;
				timepassed = self.curEnt.timePassed + (gettime() - self.curEnt.spawnTime) / 1000;
				self scripts\players\_turrets::deleteTurret(self.curEnt, self.curEnt.bipod);
				self scripts\players\_turrets::giveTurret(turret_type, timepassed, augmented);
			break;
		}
	}
}

/**
*	Controls the alpha amount of the bottom-centered hinttext
*	@alpha Float 0-1, How much the hinttext should be seen (usually either 1 or 0)
*/
showHinttext(alpha)
{
	if(isDefined(self.hinttext) && self.hinttext.alpha != alpha)
		self.hinttext.alpha = alpha;
}

/**
*	The calling player aborts using an entity
*/
usableAbort()
{
	self notify("usable_abort");
	
	self showHinttext(0);

	if (isDefined(self.curEnt))
	{
		switch (self.curEnt.type)
		{
				case "revive":
					self.isBusy = false;
					self.curEnt setClientDvar("ui_infostring", "");
					
					if(self.reviveWill)
						self setclientdvar("ui_damagereduced", 0);
						
					self.curEnt.occupied = false;
					self unlink(level.antimove	);
					self enableWeapons();
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
					self unlink(level.antimove	);
					self enableWeapons();
					self destroyProgressBar();
				break;
		}
		self.curEnt = undefined;
	}
}

/**
*	Waiter function to restore a barricade
*	@time Float, Time it takes to restore it
*/
restoreBarricadeInTime(time)
{
	self endon("death");
	self endon("disconnect");
	self endon("usable_abort");
	
	wait time;

	self thread restoreBarricade();
	
	self thread usableAbort();
}

/**
*	Restores a barricade from the currently used usable entity
*/
restoreBarricade()
{
	if (self.curEnt scripts\players\_barricades::restorePart())
	{
		self scripts\players\_players::incUpgradePoints(3 * level.dvar["game_rewardscale"]);
		self.stats["barriersRestored"]++;
	}
}

/**
*	Waiter function for reviving another player
*	@time Float, Time it takes to revive the player
*	@player Entity, The player that is going to be revived
*/
reviveInTime(time, player)
{
	self endon("death");
	self endon("disconnect");
	self endon("usable_abort");
	
	wait time;

	self thread finishRevive(player);
}

/**
*	Finally revives the given player
*	@player Entity, The player that is being revived
*/
finishRevive(player)
{
	self endon("death");
	self endon("disconnect");
	
	self destroyProgressBar();
	self freezecontrols(0);
	
	// Check whether the player is still valid
	if (isDefined(player) && isAlive(player))
	{
		player thread scripts\players\_players::revive(self);
		
		// TODO: Why do we notify the player of taking damage?
		player notify("damage", 0);
		iprintln(player.name + " was revived by " + self.name + ".");
		player setClientDvar("ui_infostring", "");
		
		self thread scripts\players\_rank::giveRankXP("revive");
		self scripts\players\_players::incUpgradePoints(40 * level.dvar["game_rewardscale"]);
	}
	
	wait 0.5;
	
	self.stats["revives"]++;
	self enableWeapons();
	
	self thread usableAbort();
}

/**
*	Waiter function for retrieving ammo
*	@time Float, Time it takes to retrieve ammo (retreive or retrieve?)
*	TODO: This function is outdated and the weapon names are, too!
*/
ammoInTime(time)
{
	self endon("death");
	self endon("disconnect");
	self endon("usable_abort");
	
	wait time;

	self destroyProgressBar();
	self freezecontrols(0);
	weaponsList = self GetWeaponsList();
	
	for(idx = 0; idx < weaponsList.size; idx++)
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
	wait 0.5;
	self enableWeapons();

}