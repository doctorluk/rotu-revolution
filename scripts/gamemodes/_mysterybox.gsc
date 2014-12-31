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

#include scripts\include\weapons;

init()
{
	level.mys_wep = [];

	addMysWep( "mp5_mp", "primary" );
	addMysWep( "skorpion_mp", "primary" );
	addMysWep( "ak74u_mp", "primary" );
	addMysWep( "uzi_mp", "secondary" );
	addMysWep( "p90_mp", "primary" );
	addMysWep( "mp5k_mp", "secondary" );
	addMysWep( "mtar_mp", "primary" );
	addMysWep( "car101_mp", "primary" );

	addMysWep( "ak47_mp", "primary" );
	addMysWep( "m14_mp", "primary" );
	addMysWep( "g3_mp", "primary" );
	addMysWep( "g36c_mp", "primary" );
	addMysWep( "m16_mp", "primary" );
	addMysWep( "m4_mp", "primary" );
	addMysWep( "f2000_mp", "primary" );
	addMysWep( "scar_mp", "primary" );
	addMysWep( "r101_mp", "primary" );

	addMysWep( "dragunov_mp", "primary" );
	addMysWep( "m40a3_mp", "primary" );
	addMysWep( "barrett_mp", "primary" );
	addMysWep( "remington700_mp", "primary" );
	addMysWep( "m21_mp", "primary" );
	addMysWep( "m40a5_mp", "primary" );
	addMysWep( "kraber_mp", "primary" );
	
	addMysWep( "winchester1200_mp", "primary" );
	addMysWep( "m1014_mp", "primary" );
	addMysWep( "usas12_mp", "primary" );
	addMysWep( "eva8_mp", "primary" );
	
	addMysWep( "rpd_mp", "primary" );
	addMysWep( "saw_mp", "primary" );
	addMysWep( "m60e4_mp", "primary" );
	addMysWep( "qbb95_mp", "primary" );
	addMysWep( "spitfire_mp", "primary" );

	addMysWep( "beretta_mp", "secondary" );
	addMysWep( "colt45_mp", "secondary" );
	addMysWep( "usp_mp", "secondary" );
	addMysWep( "deserteagle_mp", "secondary" );
	addMysWep( "magnum_mp", "secondary" );

	addMysWep( "raygun_mp", "extra" );
	addMysWep( "minigun_mp", "extra" );
	addMysWep( "thundergun_mp", "extra" );

	// shuffle the array around, this gives a little more randomness then just the 'randomInt' on pulling a weapon
	for( i=0; i<level.mys_wep.size; i++ )
	{
		rnd = randomInt( level.mys_wep.size );
		temp = level.mys_wep[i];
		level.mys_wep[i] = level.mys_wep[rnd];
		level.mys_wep[rnd] = temp;	
	}
}


addMysWep( weaponName, slot )
{
	struct = spawnstruct();
	level.mys_wep[level.mys_wep.size] = struct;
	struct.weaponName = weaponName;
	struct.slot = slot;
}

mystery_box(box)
{
	weapon = spawn( "script_model", box.origin + (0,0,20) );
	weapon.angles = (0,(box.angles[1] + 90),0);
	weapon.done = false;
	weapon hide();
	weapon showToPlayer( self );
	weapon moveZ( 32, 2.4 );
	lastnum = weapon createRandomItem(self);
	self.box_weapon = weapon;
	self playlocalsound("zom_mystery");
	for( i = 0; i < 14; i++ )
	{
		wait 0.2;
		lastnum = weapon createRandomItem(self, lastnum);
	}
	wait 0.05;
	weapon.done = true;
	weapon thread deleteOverTime(7);

}

createRandomItem( player, lastNum )
{
	if( isDefined(lastNum) )
	{
		num = randomInt( level.mys_wep.size-3 );
		if( num >= lastNum )
			num++;
	}
	else
	{
		num = randomInt( level.mys_wep.size-2 );
		lastNum = -2;
	}
	
	for( i=0; i<level.mys_wep.size; i++ )
	{
		wep = level.mys_wep[i];
		if( wep.weaponName == player.primary || wep.weaponName == player.secondary || i == lastNum )
		{
			num++;
			continue;
		}
		if( i == num )
		{
			self setModel( getWeapModel(wep.weaponName) );
			self.weaponName = wep.weaponName;
			self.slot = wep.slot;
		}
	}
}

deleteOverTime(time)
{
	self endon("death");
	wait time;
	self delete();
}