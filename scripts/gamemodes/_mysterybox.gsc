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
	addMysWep("weapon_ak47", "ak47_mp", "primary");
	addMysWep("weapon_m4gre_sp_silencer_reflex", "m4_acog_mp", "primary");
	addMysWep("weapon_m40a3", "m40a3_mp", "primary");
	addMysWep("weapon_benelli_super_90", "m1014_grip_mp", "primary");
	addMysWep("weapon_m14_scout_mp", "m14_mp", "primary");
	addMysWep("weapon_ak74u", "ak74u_mp", "primary");
	addMysWep("weapon_g36", "g36c_acog_mp", "primary");
	addMysWep("weapon_m16_mp", "m16_mp", "primary");
	addMysWep("weapon_m60", "m60e4_mp", "primary");
	addMysWep("weapon_p90", "p90_acog_mp", "primary");
	
	addMysWep("weapon_usp", "usp_mp", "secondary");
	addMysWep("weapon_beretta" , "beretta_mp", "secondary");
	addMysWep("weapon_colt1911_silencer" , "colt45_silencer_mp", "secondary");
	addMysWep("weapon_crossbow_1" , "crossbow_mp", "secondary");
	addMysWep("weapon_desert_eagle_gold", "deserteaglegold_mp", "secondary");
	addMysWep("weapon_mini_uzi", "uzi_mp", "secondary");
	addMysWep("weapon_desert_eagle_gold", "deserteaglegold_mp", "secondary");
	
	addMysWep("weapon_mw2_f2000_wm", "m14_acog_mp", "primary");
	addMysWep("weapon_spas12", "m1014_reflex_mp", "primary");
	addMysWep("weapon_aug", "rpd_acog_mp", "primary");
	addMysWep("mw2_aa12_worldmodel", "m60e4_acog_mp", "primary");
	addMysWep("worldmodel_bo_minigun", "saw_acog_mp", "primary");
	addMysWep("weapon_tesla", "ak74u_acog_mp", "primary");
	
	addMysWep("mw2_mp5k_worldmodel", "mp5_acog_mp", "secondary");
	
	addMysWep("weapon_raygun", "barret_acog_mp", "primary");
	addMysWep("weapon_flamethrower", "skorpion_acog_mp", "primary");
	addMysWep("mw2_intervention_wm", "deserteagle_mp", "primary");

	//precache();
}


addMysWep(model, weaponName, slot)
{
	precachemodel(model);
	struct = spawnstruct();
	level.mys_wep[level.mys_wep.size] = struct;
	struct.model = model;
	struct.weaponName = weaponName;
	struct.slot = slot;
}

precache()
{
	precachemodel("weapon_ak47");
	precachemodel("weapon_m4gre_sp_silencer_reflex");
	precachemodel("weapon_beretta");
	precachemodel("weapon_usp");
	precachemodel("weapon_crossbow_1");
	precachemodel("weapon_saw_new_rescue");
	precachemodel("weapon_colt1911_silencer");
	precachemodel("weapon_m40a3");
	precachemodel("weapon_benelli_super_90");
	precachemodel("weapon_m67_grenade");
	precachemodel("weapon_m14_scout_mp");
	precachemodel("weapon_ak74u");
	precachemodel("weapon_g36");
	precachemodel("weapon_desert_eagle_gold");
	precachemodel("weapon_m16_mp");
	precachemodel("weapon_m60");
	precachemodel("weapon_p90");
	precachemodel("weapon_mini_uzi");
	precachemodel("weapon_desert_eagle_silver");

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