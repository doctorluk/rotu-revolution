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
	if (getdvar("surv_unlock_mp") == "")
	setdvar("surv_unlock_mp", 10);
	
	if (getdvar("surv_soldier_unlockprimary0") == "")
	setdvar("surv_soldier_unlockprimary0", "m16_mp");
	
	if (getdvar("surv_soldier_unlockprimary1") == "")
	setdvar("surv_soldier_unlockprimary1", "ak47_mp");
	
	if (getdvar("surv_soldier_unlockprimary2") == "")
	setdvar("surv_soldier_unlockprimary2", "g3_mp");
	
	if (getdvar("surv_soldier_unlockprimary3") == "")
	setdvar("surv_soldier_unlockprimary3", "m14_acog_mp");
	
	if (getdvar("surv_soldier_unlockprimary4") == "")
	setdvar("surv_soldier_unlockprimary4", "m4_acog_mp");
		
	if (getdvar("surv_soldier_unlocksecondary0") == "")
	setdvar("surv_soldier_unlocksecondary0", "beretta_mp");
		
	if (getdvar("surv_soldier_unlocksecondary1") == "")
	setdvar("surv_soldier_unlocksecondary1", "usp_mp");
		
	if (getdvar("surv_soldier_unlocksecondary2") == "")
	setdvar("surv_soldier_unlocksecondary2", "colt45_mp");
		
	if (getdvar("surv_soldier_unlocksecondary3") == "")
	setdvar("surv_soldier_unlocksecondary3", "g36c_gl_mp");
	

	
		
	if (getdvar("surv_stealth_unlockprimary0") == "")
	setdvar("surv_stealth_unlockprimary0", "skorpion_silencer_mp");
		
	if (getdvar("surv_stealth_unlockprimary1") == "")
	setdvar("surv_stealth_unlockprimary1", "mp5_silencer_mp");
		
	if (getdvar("surv_stealth_unlockprimary2") == "")
	setdvar("surv_stealth_unlockprimary2", "ak74u_silencer_mp");
	
	if (getdvar("surv_stealth_unlockprimary3") == "")
	setdvar("surv_stealth_unlockprimary3", "p90_silencer_mp");
		
	if (getdvar("surv_stealth_unlockprimary4") == "")
	setdvar("surv_stealth_unlockprimary4", "m21_acog_mp");
		
	if (getdvar("surv_stealth_unlocksecondary0") == "")
	setdvar("surv_stealth_unlocksecondary0", "beretta_silencer_mp");
		
	if (getdvar("surv_stealth_unlocksecondary1") == "")
	setdvar("surv_stealth_unlocksecondary1", "usp_silencer_mp");
		
	if (getdvar("surv_stealth_unlocksecondary2") == "")
	setdvar("surv_stealth_unlocksecondary2", "colt45_silencer_mp");
		
	if (getdvar("surv_stealth_unlocksecondary3") == "")
	setdvar("surv_stealth_unlocksecondary3", "mp5_acog_mp");
	
		
	if (getdvar("surv_armored_unlockprimary0") == "")
	setdvar("surv_armored_unlockprimary0", "g36c_acog_mp");
		
	if (getdvar("surv_armored_unlockprimary1") == "")
	setdvar("surv_armored_unlockprimary1", "rpd_mp");
		
	if (getdvar("surv_armored_unlockprimary2") == "")
	setdvar("surv_armored_unlockprimary2", "m60e4_grip_mp");
		
	if (getdvar("surv_armored_unlockprimary3") == "")
	setdvar("surv_armored_unlockprimary3", "saw_reflex_mp");
	
	if (getdvar("surv_armored_unlockprimary4") == "")
	setdvar("surv_armored_unlockprimary4", "rpd_acog_mp");
		
	if (getdvar("surv_armored_unlocksecondary0") == "")
	setdvar("surv_armored_unlocksecondary0", "beretta_mp");
		
	if (getdvar("surv_armored_unlocksecondary1") == "")
	setdvar("surv_armored_unlocksecondary1", "usp_mp");
		
	if (getdvar("surv_armored_unlocksecondary2") == "")
	setdvar("surv_armored_unlocksecondary2", "colt45_mp");
		
	if (getdvar("surv_armored_unlocksecondary3") == "")
	setdvar("surv_armored_unlocksecondary3", "winchester1200_mp");
	
		
	if (getdvar("surv_engineer_unlockprimary0") == "")
	setdvar("surv_engineer_unlockprimary0", "mp44_mp");
		
	if (getdvar("surv_engineer_unlockprimary1") == "")
	setdvar("surv_engineer_unlockprimary1", "winchester1200_grip_mp");
		
	if (getdvar("surv_engineer_unlockprimary2") == "")
	setdvar("surv_engineer_unlockprimary2", "m1014_grip_mp");
		
	if (getdvar("surv_engineer_unlockprimary3") == "")
	setdvar("surv_engineer_unlockprimary3", "m1014_reflex_mp");
	
	if (getdvar("surv_engineer_unlockprimary4") == "")
	setdvar("surv_engineer_unlockprimary4", "m60e4_acog_mp");
		
	if (getdvar("surv_engineer_unlocksecondary0") == "")
	setdvar("surv_engineer_unlocksecondary0", "claymore_mp");
		
	if (getdvar("surv_engineer_unlocksecondary1") == "")
	setdvar("surv_engineer_unlocksecondary1", "c4_mp");
		
	if (getdvar("surv_engineer_unlocksecondary2") == "")
	setdvar("surv_engineer_unlocksecondary2", "rpg_mp");
		
	if (getdvar("surv_engineer_unlocksecondary3") == "")
	setdvar("surv_engineer_unlocksecondary3", "at4_mp");
	
		
	if (getdvar("surv_scout_unlockprimary0") == "")
	setdvar("surv_scout_unlockprimary0", "m40a3_mp");
		
	if (getdvar("surv_scout_unlockprimary1") == "")
	setdvar("surv_scout_unlockprimary1", "dragunov_mp");
		
	if (getdvar("surv_scout_unlockprimary2") == "")
	setdvar("surv_scout_unlockprimary2", "remington700_mp");
	
	if (getdvar("surv_scout_unlockprimary3") == "")
	setdvar("surv_scout_unlockprimary3", "barrett_mp");
		
	if (getdvar("surv_scout_unlockprimary4") == "")
	setdvar("surv_scout_unlockprimary4", "deserteagle_mp");
		
	if (getdvar("surv_scout_unlocksecondary0") == "")
	setdvar("surv_scout_unlocksecondary0", "beretta_mp");
		
	if (getdvar("surv_scout_unlocksecondary1") == "")
	setdvar("surv_scout_unlocksecondary1", "usp_mp");
		
	if (getdvar("surv_scout_unlocksecondary2") == "")
	setdvar("surv_scout_unlocksecondary2", "colt45_mp");
		
	if (getdvar("surv_scout_unlocksecondary3") == "")
	setdvar("surv_scout_unlocksecondary3", "mp5_acog_mp");
	
		
	if (getdvar("surv_medic_unlockprimary0") == "")
	setdvar("surv_medic_unlockprimary0", "skorpion_mp");
		
	if (getdvar("surv_medic_unlockprimary1") == "")
	setdvar("surv_medic_unlockprimary1", "uzi_mp");
		
	if (getdvar("surv_medic_unlockprimary2") == "")
	setdvar("surv_medic_unlockprimary2", "mp5_mp");
	
	if (getdvar("surv_medic_unlockprimary3") == "")
	setdvar("surv_medic_unlockprimary3", "ak74u_mp");
	
	if (getdvar("surv_medic_unlockprimary4") == "")
	setdvar("surv_medic_unlockprimary4", "p90_acog_mp");
		
	if (getdvar("surv_medic_unlocksecondary0") == "")
	setdvar("surv_medic_unlocksecondary0", "beretta_mp");
		
	if (getdvar("surv_medic_unlocksecondary1") == "")
	setdvar("surv_medic_unlocksecondary1", "usp_mp");
	
	if (getdvar("surv_medic_unlocksecondary2") == "")
	setdvar("surv_medic_unlocksecondary2", "colt45_mp");
		
	if (getdvar("surv_medic_unlocksecondary3") == "")
	setdvar("surv_medic_unlocksecondary3", "deserteaglegold_mp");
		
	if (getdvar("surv_unlockprimary1_points") == "")
	setdvar("surv_unlockprimary1_points", 500);
		
	if (getdvar("surv_unlockprimary2_points") == "")
	setdvar("surv_unlockprimary2_points", 750);
	
	if (getdvar("surv_unlockprimary3_points") == "")
	setdvar("surv_unlockprimary3_points", 1250);
	
	if (getdvar("surv_unlockprimary4_points") == "")
	setdvar("surv_unlockprimary4_points", 2000);
		
	if (getdvar("surv_unlocksecondary1_points") == "")
	setdvar("surv_unlocksecondary1_points", 250);
	
	if (getdvar("surv_unlocksecondary2_points") == "")
	setdvar("surv_unlocksecondary2_points", 500);
		
	if (getdvar("surv_unlocksecondary3_points") == "")
	setdvar("surv_unlocksecondary3_points", 750);
	
	if (getdvar("surv_unlocksecondary3_points") == "")
	setdvar("surv_unlocksecondary3_points", 750);
	
	if (getdvar("surv_unlockextra1_points") == "")
	setdvar("surv_unlockextra1_points", 2000);
	
	if (getdvar("surv_unlockextra2_points") == "")
	setdvar("surv_unlockextra2_points", 3000);
		
	if (getdvar("surv_unlockspecial3_points") == "")
	setdvar("surv_unlockspecial3_points", 4000);
	
	if (getdvar("surv_extra_unlock1") == "")
	setdvar("surv_extra_unlock1", "barrett_acog_mp");
		
	if (getdvar("surv_extra_unlock2") == "")
	setdvar("surv_extra_unlock2", "skorpion_acog_mp");
		
	if (getdvar("surv_extra_unlock3") == "")
	setdvar("surv_extra_unlock3", "ak74u_acog_mp");
	
	if (getdvar("surv_extra_unlock4") == "")
	setdvar("surv_extra_unlock4", "saw_acog_mp");

	i = 0;
	while (1) {
		newwep = getdvar("surv_extra_unlock" + (i+1));
		if (newwep=="")
		break;
		level.specialWeps[i] = newwep;
		i++;
	}
}

doUpgrade(type)
{
	newupgr = self.unlock[type] + 1;
	if (type=="extra")
	newwep = getdvar("surv_extra_unlock"+newupgr);
	else
	newwep = getdvar("surv_"+self.curClass+"_unlock"+type+newupgr);
	costs = getdvarint("surv_unlock"+type+newupgr+"_points")*getdvarint("surv_unlock_mp");
	if (newwep != "")
	{
		if (self.points >= costs)
		{
			self scripts\players\_players::incUpgradePoints(-1*costs);
			self scripts\players\_weapons::swapWeapons(type, newwep);
			if(type == "extra" && newupgr == 4)
				if(!isDefined(level.gotFirstMinigun))
					level.gotFirstMinigun = self;
			self.unlock[type] ++;
			self.persData.unlock[type]=self.unlock[type];
			self playsound("buy_upgradebox");
		}
		else
		{
			self iprintlnbold("You do not have enough points: "+costs);
		}
	}
	else
		self iprintlnbold("No more upgrades for this weapon!");
}