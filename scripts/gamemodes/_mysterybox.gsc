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

init()
{
	level.mys_wep = [];
	addMysWep( "ak47_mp", "primary");
	addMysWep( "m4_acog_mp", "primary");
	addMysWep( "m40a3_mp", "primary");
	addMysWep( "m1014_grip_mp", "primary");
	addMysWep( "m14_mp", "primary");
	addMysWep( "ak74u_mp", "primary");
	addMysWep( "g36c_acog_mp", "primary");
	addMysWep( "m16_mp", "primary");
	addMysWep( "m60e4_mp", "primary");
	addMysWep( "p90_acog_mp", "primary");
	
	addMysWep( "usp_mp", "secondary");
	addMysWep( "beretta_mp", "secondary");
	addMysWep( "colt45_silencer_mp", "secondary");
	addMysWep( "crossbow_mp", "secondary");
	addMysWep( "deserteaglegold_mp", "secondary");
	addMysWep( "uzi_mp", "secondary");
	addMysWep( "deserteaglegold_mp", "secondary");
	
	addMysWep( "m14_acog_mp", "primary");
	addMysWep( "m1014_reflex_mp", "primary");
	addMysWep( "rpd_acog_mp", "primary");
	addMysWep( "m60e4_acog_mp", "primary");
	addMysWep( "saw_acog_mp", "primary");
	addMysWep( "ak74u_acog_mp", "primary");
	
	addMysWep( "mp5_acog_mp", "secondary");
	
	addMysWep( "barret_acog_mp", "primary");
	addMysWep( "skorpion_acog_mp", "primary");
	addMysWep( "deserteagle_mp", "primary");
}


addMysWep( weaponName, slot )
{
	struct = spawnstruct();
	level.mys_wep[level.mys_wep.size] = struct;
	struct.model = getWeaponModel( weaponName, 0 );
	struct.weaponName = weaponName;
	struct.slot = slot;

	precacheModel( struct.model );
}

mystery_box(box)
{
	weapon = spawn( "script_model", box.origin + (0,0,20) );
	weapon.angles = (0,(box.angles[1] + 90),0);
	weapon.done = false;
	weapon hide();
	weapon showtoplayer(self);
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

createRandomItem(player, lastNum)
{
	if (isdefined(lastNum))
	{
		num = randomInt( level.mys_wep.size-3 );
		if (num >= lastNum)
		num++;
	}
	else
	{
		num = randomInt( level.mys_wep.size-2 );
		lastNum = -2;
	}
	
	for (i=0; i<level.mys_wep.size; i++)
	{
		wep = level.mys_wep[i];
		if (wep.weaponName == player.primary || wep.weaponName == player.secondary || i == lastNum)
		{
			num++;
			continue;
		}
		if (i == num)
		{
			self setmodel(wep.model);
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