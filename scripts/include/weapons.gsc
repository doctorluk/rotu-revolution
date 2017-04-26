/**
* vim: set ft=cpp:
* file: scripts\include\weapons.gsc
*
* authors: Luk, 3aGl3, Bipo, Etheross
* team: SOG Modding
*
* project: RotU - Revolution
* website: http://survival-and-obliteration.com/
*
* Reign of the Undead - Revolution ALPHA 0.7 by Luk and 3aGl3
* You may modify this code to your liking or reuse it, as long as you give credit to those who wrote it
* Based on Reign of the Undead 2.1 created by Bipo and Etheross
*/

/**
* The functions in this file make use of the weaponKey that is generated uppon loading the map. Said weapon key
* will translate a weapons script name to the assigned console name before sending it to the engine. These
* functions do nothing more then providing a quick way of accessing the weapon key.
*/

/**
* Gives the player the given weapon.
*
*	@weap: Script name of the weapon to give
*	@var: Integer value from 0-16 to use a different weapon model
*/
giveWeap(weap, var)
{
	// var is usually the camo, so set it to 0 if undefined
	if(!isDefined(var))
		var = 0;

	// give the weapon taking the weapon key into account
	self giveWeapon(level.weaponKeyS2C[weap], var);
}

/**
* Takes away the given weapon from the player.
*
*	@weap: Script name of the weapon to take
*/
takeWeap(weap)
{
	self takeWeapon(level.weaponKeyS2C[weap]);	
}

/**
* Instantly changes the players weapon.
*
*	@weap: Script name of the weapon to change to
*/
setSpawnWeap(weap)
{
	self setSpawnWeapon(level.weaponKeyS2C[weap]);
}

/**
* Changes the players weapon, playing the putaway and pullout animations.
*
*	@weap: Script name of the weapon to change to
*/
switchToWeap(weap)
{
	self switchToWeapon(level.weaponKeyS2C[weap]);	
}

/**
* Give the max amount of ammo for the weapon.
*
*	@weap: Script name of the weapon the ammo will be refilled
*/
giveWeapMaxAmmo(weap)
{
	self giveMaxAmmo(level.weaponKeyS2C[weap]);
}

/**
* Sets the given amount of ammo into the players weapon ammo stock.
*
*	@weap: Script name of the weapon
*	@ammo: Integer value of the ammo
*/
setWeapAmmoStock(weap, ammo)
{
	self setWeaponAmmoStock(level.weaponKeyS2C[weap], ammo);
}

/**
* Sets the given amount of ammo into the players weapon clip.
*
*	@weap: Script name of the weapon
*	@ammo: Integer value of the ammo
*/
setWeapAmmoClip(weap, ammo)
{
	self setWeaponAmmoClip(level.weaponKeyS2C[weap], ammo);
}

/**
* Returns the current ammount of ammo in the players weapon stock.
*/
getWeapAmmoStock(weap)
{
	return self getWeaponAmmoStock(level.weaponKeyS2C[weap]);
}

/**
* Returns the current ammount of ammo in the players weapon clip.
*/
getWeapAmmoClip(weap)
{
	return self getWeaponAmmoClip(level.weaponKeyS2C[weap]);
}

/**
* Returns the script name of the current player weapon.
*/
getCurrentWeap()
{
	return level.weaponKeyC2S[self getCurrentWeapon()];	
}

/**
* Returns true if the player has the given weapon, false otherwise.
*/
hasWeap(weap)
{
	return self hasWeapon(level.weaponKeyS2C[weap]);
}

/**
* Returns the clip size of the given weapon.
*/
weapClipSize(weap)
{
	return weaponClipSize(level.weaponKeyS2C[weap]);
}

/**
* Returns the ammount of max ammo of the given weapon.
*/
weapMaxAmmo(weap)
{
	return weaponMaxAmmo(level.weaponKeyS2C[weap]);
}

/**
* Returns the worldmodelname of a given weapon.
*
*	@weap: Script name of the weapon
*	@var: Integer value from 0-16 to distinguish the different weapon models
*/
getWeapModel(weap, var)
{
	// make sure the camo value is set
	if(!isDefined(var))
		var = 0;
	
	return getWeaponModel(level.weaponKeyS2C[weap], var);	
}