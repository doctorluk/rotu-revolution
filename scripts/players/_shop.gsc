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
#include scripts\include\useful;
playerSetupShop()
{
	self endon("disconnect");
	self.points = level.dvar["game_startpoints"];
	self.support_level = 0;
	self.upgrade_damMod = 1;
	wait 0.1; // Security wait to ensure that not too many clientdvars are set
	// for (i=0; i<7; i++)
	// {
		// self setclientdvar("ui_costs"+i, level.dvar["shop_item"+(i+1)+"_costs"]);
		// wait .05;
	// }
	// for (i=0; i<6; i++)
	// {
		// self setclientdvar("ui_itemcosts"+i, level.dvar["shop_defensive"+(i+1)+"_costs"]);
		// wait .05;
	// }
	// for (i=0; i<5; i++)
	// {
		// self setclientdvar("ui_supportcosts"+i, level.dvar["shop_support"+(i+1)+"_costs"]);
		// wait .05;
	// }
	self setclientdvars("ui_points", int(self.points), "ui_upgrade", 0, "ui_supupgrade", 0,
	
						"ui_costs"+0, level.dvar["shop_item"+(0+1)+"_costs"],
						"ui_costs"+1, level.dvar["shop_item"+(1+1)+"_costs"],
						"ui_costs"+2, level.dvar["shop_item"+(2+1)+"_costs"],
						"ui_costs"+3, level.dvar["shop_item"+(3+1)+"_costs"],
						"ui_costs"+4, level.dvar["shop_item"+(4+1)+"_costs"],
						"ui_costs"+5, level.dvar["shop_item"+(5+1)+"_costs"],
						"ui_costs"+6, level.dvar["shop_item"+(6+1)+"_costs"],
						
						"ui_itemcosts"+0, level.dvar["shop_defensive"+(0+1)+"_costs"],
						"ui_itemcosts"+1, level.dvar["shop_defensive"+(1+1)+"_costs"],
						"ui_itemcosts"+2, level.dvar["shop_defensive"+(2+1)+"_costs"],
						"ui_itemcosts"+3, level.dvar["shop_defensive"+(3+1)+"_costs"],
						"ui_itemcosts"+4, level.dvar["shop_defensive"+(4+1)+"_costs"],
						"ui_itemcosts"+5, level.dvar["shop_defensive"+(5+1)+"_costs"],
						
						"ui_supportcosts"+0, level.dvar["shop_support"+(0+1)+"_costs"],
						"ui_supportcosts"+1, level.dvar["shop_support"+(1+1)+"_costs"],
						"ui_supportcosts"+2, level.dvar["shop_support"+(2+1)+"_costs"],
						"ui_supportcosts"+3, level.dvar["shop_support"+(3+1)+"_costs"],
						"ui_supportcosts"+4, level.dvar["shop_support"+(4+1)+"_costs"]);
}

updateShopCosts(){
	raiseCosts();

	for (i = 0; i<level.players.size; i++)
	{
		level.players[i] thread updateCosts();
	}
	
}

raiseCosts(){
	for (i=1; i<7; i++)
	{
		level.dvar["shop_defensive"+i+"_costs"] += int(level.dvar["shop_defensive"+i+"_costs"]*(level.dvar["shop_multiply_costs_amount"]/100));
		level.dvar["shop_item"+i+"_costs"] += int(level.dvar["shop_item"+i+"_costs"]*(level.dvar["shop_multiply_costs_amount"]/100));
	}
	level.dvar["shop_support1_costs"] += int(level.dvar["shop_support1_costs"]*(level.dvar["shop_multiply_costs_amount"]/100));

}

updateCosts(){
	self endon("disconnect");
	// for (i=0; i<7; i++)
		// {
			// self setclientdvar("ui_costs"+i, level.dvar["shop_item"+(i+1)+"_costs"]);
			// wait .05;
		// }
	// for (i=0; i<7; i++)
		// {
			// self setclientdvar("ui_itemcosts"+i, level.dvar["shop_defensive"+(i+1)+"_costs"]);
			// wait .05;
		// }
	// self setclientdvar("ui_supportcosts1", level.dvar["shop_support1_costs"]);
	// for (i=0; i<7; i++)
	// {
		// self setclientdvar("ui_costs"+i, level.dvar["shop_item"+(i+1)+"_costs"]);
		// wait .05;
	// }
	// for (i=0; i<6; i++)
	// {
		// self setclientdvar("ui_itemcosts"+i, level.dvar["shop_defensive"+(i+1)+"_costs"]);
		// wait .05;
	// }
	// for (i=0; i<5; i++)
	// {
		// self setclientdvar("ui_supportcosts"+i, level.dvar["shop_support"+(i+1)+"_costs"]);
		// wait .05;
	// }
	self setclientdvars("ui_costs"+0, level.dvar["shop_item"+(0+1)+"_costs"],
						"ui_costs"+1, level.dvar["shop_item"+(1+1)+"_costs"],
						"ui_costs"+2, level.dvar["shop_item"+(2+1)+"_costs"],
						"ui_costs"+3, level.dvar["shop_item"+(3+1)+"_costs"],
						"ui_costs"+4, level.dvar["shop_item"+(4+1)+"_costs"],
						"ui_costs"+5, level.dvar["shop_item"+(5+1)+"_costs"],
						"ui_costs"+6, level.dvar["shop_item"+(6+1)+"_costs"],
						
						"ui_itemcosts"+0, level.dvar["shop_defensive"+(0+1)+"_costs"],
						"ui_itemcosts"+1, level.dvar["shop_defensive"+(1+1)+"_costs"],
						"ui_itemcosts"+2, level.dvar["shop_defensive"+(2+1)+"_costs"],
						"ui_itemcosts"+3, level.dvar["shop_defensive"+(3+1)+"_costs"],
						"ui_itemcosts"+4, level.dvar["shop_defensive"+(4+1)+"_costs"],
						"ui_itemcosts"+5, level.dvar["shop_defensive"+(5+1)+"_costs"],
						
						"ui_supportcosts"+0, level.dvar["shop_support"+(1+1)+"_costs"],
						"ui_supportcosts"+1, level.dvar["shop_support"+(2+1)+"_costs"],
						"ui_supportcosts"+2, level.dvar["shop_support"+(3+1)+"_costs"],
						"ui_supportcosts"+3, level.dvar["shop_support"+(4+1)+"_costs"]);
}

processResponse(response)
{
	switch (response)
	{
		case "item0":
			if (self.points >= level.dvar["shop_item1_costs"])
			{
				if(self.health < self.maxhealth){
					self thread scripts\players\_players::fullHeal(3);
					self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item1_costs"]);
					self iprintlnbold("Restoring ^2health^7!");
					self playsound("buy_upgradebox");
				}
				else
					self iprintlnbold("^2You are already at max. health");	
			}
		break;
		case "item1":
			if (self.points >= level.dvar["shop_item2_costs"])
			{
				if(!self scripts\players\_players::hasFullAmmo()){
					self scripts\players\_players::restoreAmmo();
					self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item2_costs"]);
					self iprintlnbold("^3Ammo ^7restored");
					self playsound("buy_upgradebox");
				}
				else
					self iprintlnbold("Your ^3ammo ^7is already full!");
			}
		break;
		case "item2":
		if (self.points >= level.dvar["shop_item3_costs"])
		{
			if(self.infected){
				self scripts\players\_infection::cureInfection();
				self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item3_costs"]);
				iprintln("^2"+self.name+" is no longer infected!");
				self iprintlnbold("^2Your infection has been cured!");
				self playsound("buy_upgradebox");
			}
			else
				self iprintlnbold("^2You are not infected");
		}
		break;
		case "item3":
		if (self.points >= level.dvar["shop_item4_costs"])
		{
			self scripts\players\_weapons::swapWeapons("grenade", "frag_grenade_mp");
			self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item4_costs"]);
			self playsound("buy_upgradebox");
		}
		break;
		case "item4":
		if (self.points >= level.dvar["shop_item5_costs"])
		{
			self giveweapon("c4_mp");
			self givemaxammo("c4_mp");
			if(self.actionslotweapons.size == 0)
				self setActionSlot( 4, "weapon", "c4_mp" );
			if(!self scripts\players\_weapons::isActionslotWeapon("c4_mp") )
				self.actionslotweapons[self.actionslotweapons.size] = "c4_mp";
			self switchtoweapon("c4_mp");
			//iprintlnbold(self.c4Array.size);
			self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item5_costs"]);
			self playsound("buy_upgradebox");
		}
		break;
		
		case "item5":
			if (self.points >= level.dvar["shop_item6_costs"])
			{
				self GiveWeapon("claymore_mp");
				self giveMaxAmmo("claymore_mp");
				if(self.actionslotweapons.size == 0)
					self setActionSlot( 4, "weapon", "claymore_mp" );
				if(!self scripts\players\_weapons::isActionslotWeapon("claymore_mp") )
					self.actionslotweapons[self.actionslotweapons.size] = "claymore_mp";
				self switchToWeapon("claymore_mp");
				self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item6_costs"]);
				self playsound("buy_upgradebox");
			}
		break;
		
		case "item6":
			if (self.points >= level.dvar["shop_item7_costs"])
			{
				if (self.unlock["extra"]==0) {
					self.extra = getdvar("surv_extra_unlock1");
					self.persData.extra = self.extra;
					
					self.unlock["extra"] ++;
					self.persData.unlock["extra"] ++;
					
					self giveweapon(self.extra);
					self givemaxammo(self.extra);
					self switchtoweapon(self.extra);
					self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item7_costs"]);
					self playsound("buy_upgradebox");
				}
			}	
		break;
		
		case "item10":
			if (self.points >= level.dvar["shop_defensive1_costs"])
			{
				/*self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_item4_costs"]);
				self.upgrade_damMod = 1.05;
				self.upgrade_level ++;
				self setclientdvar("ui_upgrade", upgrade_level);
				self glowMessage(&"ZOMBIE_DAMMOD", self.damMod, (1,0,0), 3, 100, 2);*/
				if (level.barrels[0] + level.barrels[2] < level.dvar["game_max_barrels"])
				{
					self scripts\players\_barricades::giveBarrel();
					self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_defensive1_costs"]);
					self playsound("buy_upgradebox");
				}
				else
				{
					self iprintlnbold("Sorry! Maximum of " + level.dvar["game_max_barrels"] + " barrels");
				}
			}
		break;
		
		case "item11":
			if (self.points >= level.dvar["shop_defensive2_costs"])
			{
				if (level.barrels[0] + level.barrels[2] < level.dvar["game_max_barrels"])
				{
					self scripts\players\_barricades::giveBarrel(2);
					self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_defensive2_costs"]);
					self playsound("buy_upgradebox");
				}
				else
				{
					self iprintlnbold("Sorry! Maximum of " + level.dvar["game_max_barrels"] + " barrels");
				}
			}
		break;
		
		case "item12":
		if (self.points >= level.dvar["shop_defensive3_costs"] && !level.turretsDisabled)
		{
			if ( (level.turrets + level.turrets_held < level.dvar["game_max_turrets"]) && (self getTurretCount() < level.dvar["game_max_turrets_perplayer"]) )
			{
				self scripts\players\_turrets::giveTurret("minigun");
				self scripts\players\_players::incUpgradePoints(-1 * level.dvar["shop_defensive3_costs"]);
				self playsound("buy_upgradebox");
			}
			else if( !(self getTurretCount() < level.dvar["game_max_turrets_perplayer"]) )
			{
				self iprintlnbold("Sorry! Maximum of " + level.dvar["game_max_turrets_perplayer"] + " turrets per player!");
			}
			else
			{
				self iprintlnbold("Sorry! Maximum of " + level.dvar["game_max_turrets"] + " total turrets!");
			}
		}
		break;
		
		case "item13":
		if (self.points >= level.dvar["shop_defensive4_costs"] && !level.turretsDisabled)
		{
			if (level.turrets + level.turrets_held < level.dvar["game_max_turrets"] && (self getTurretCount() < level.dvar["game_max_turrets_perplayer"]) ){
			
				self scripts\players\_turrets::giveTurret("gl");
				self scripts\players\_players::incUpgradePoints(-1 * level.dvar["shop_defensive4_costs"]);
				self playsound("buy_upgradebox");
			}
			else if( !(self getTurretCount() < level.dvar["game_max_turrets_perplayer"]) )
			{
				self iprintlnbold("Sorry! Maximum of " + level.dvar["game_max_turrets_perplayer"] + " turrets per player!");
			}
			else
			{
				self iprintlnbold("Sorry! Maximum of " + level.dvar["game_max_turrets"] + " total turrets!");
			}
		}
		break;
		
		case "item14":
			
			if (self.points >= level.dvar["shop_defensive5_costs"])
			{
				if (level.barrels[1] < level.dvar["game_max_mg_barrels"])
				{
					self scripts\players\_barricades::giveBarrel(1);
					self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_defensive5_costs"]);
					self playsound("buy_upgradebox");
				}
				else
				{
					self iprintlnbold("Sorry! Maximum of " + level.dvar["game_max_mg_barrels"] + " MG barrels");
				}
			}
		break;
		case "item15":
			if (self.points >= level.dvar["shop_defensive6_costs"]){
				// Teleporter was here
			}
		break;
		
		case "item20":
			if (self.points >= level.dvar["shop_support1_costs"] && self.support_level == 0)
			{
				self scripts\players\_players::incUpgradePoints(-1*level.dvar["shop_support1_costs"]);
				self.support_level++;
				self setclientdvar("ui_supupgrade", self.support_level);
				self setActionSlot( 1, "nightvision" );
				self.nighvision = true;
				self playsound("buy_upgradebox");
			}
		
		break;

	}
}

disableTurrets(disable){
	for(i = 0; i < level.players.size; i++)
		level.players[i] setclientdvar("ui_turretsDisabled", disable);
	if(disable)
		level notify("turrets_disabled");
	else
		level notify("turrets_enabled");
}