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

giveWeap( weap, var )
{
	if( !isDefined(var) )
		var = 0;

	self giveWeapon( level.weaponKeyS2C[weap], var );
}

takeWeap( weap )
{
	self takeWeapon( level.weaponKeyS2C[weap] );	
}

setSpawnWeap( weap )
{
	self setSpawnWeapon( level.weaponKeyS2C[weap] );
}

switchToWeap( weap )
{
	self switchToWeapon( level.weaponKeyS2C[weap] );	
}

giveWeapMaxAmmo( weap )
{
	self giveMaxAmmo( level.weaponKeyS2C[weap] );
}

setWeapAmmoStock( weap, ammo )
{
	self setWeaponAmmoStock( level.weaponKeyS2C[weap], ammo );
}

setWeapAmmoClip( weap, ammo )
{
	self setWeaponAmmoClip( level.weaponKeyS2C[weap], ammo );
}

getWeapAmmoStock( weap )
{
	return self getWeaponAmmoStock( level.weaponKeyS2C[weap] );
}

getWeapAmmoClip( weap )
{
	return self getWeaponAmmoClip( level.weaponKeyS2C[weap] );
}

getCurrentWeap()
{
	return level.weaponKeyC2S[self getCurrentWeapon()];	
}

hasWeap( weap )
{
	return self hasWeapon( level.weaponKeyS2C[weap] );
}

weapClipSize( weap )
{
	return weaponClipSize( level.weaponKeyS2C[weap] );
}

weapMaxAmmo( weap )
{
	return weaponMaxAmmo( level.weaponKeyS2C[weap] );
}
