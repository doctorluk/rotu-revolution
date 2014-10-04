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

onPlayerSpawn() {
	self.spree = 0;
	if (!isdefined(self.hud_streak))
	streakHud();
}

checkSpree() {
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "downed" );
	self.spree++;
	if (self.spree>1) {
		if (self.hud_streak.alpha==0) {
			self.hud_streak.alpha = 1;
		}
		self.hud_streak setvalue(self.spree);
		self.hud_streak fontPulse(self);
		switch (self.spree) {
			case 2:
				self playlocalsound("double_kill");
				self scripts\players\_rank::giveRankXP("spree", 5);
				if (self.curClass == "soldier")
					self scripts\players\_abilities::rechargeSpecial(5);
			break;
			case 3:
				self stoplocalsound("double_kill");
				self playlocalsound("triple_kill");
				self scripts\players\_rank::giveRankXP("spree", 10);
				self.laststreak = "Triple kill! ";
				if (self.curClass == "soldier")
					self scripts\players\_abilities::rechargeSpecial(10);
			break;
			case 4:
				self.laststreak = "Multi kill! ";
			break;
			case 5:
				self stoplocalsound("triple_kill");
				self playlocalsound("multikill");
				self scripts\players\_rank::giveRankXP("spree", 25);
				self.laststreak = "Multi kill! ";
				if (self.curClass == "soldier")
					self scripts\players\_abilities::rechargeSpecial(15);
			break;
			case 7:
				self stoplocalsound("multikill");
				self playlocalsound("killing_spree");
				self scripts\players\_rank::giveRankXP("spree", 50);
				self.laststreak = "Killing Spree! ";
				if (self.curClass == "soldier")
					self scripts\players\_abilities::rechargeSpecial(20);
			break;
			case 9:
				self stoplocalsound("killing_spree");
				self playlocalsound("ultrakill");
				self scripts\players\_rank::giveRankXP("spree", 100);
				self.laststreak = "Ultra kill! ";
				if (self.curClass == "soldier")
					self scripts\players\_abilities::rechargeSpecial(25);
			break;
			case 11:
				self stoplocalsound("ultrakill");
				self playlocalsound("megakill");
				self scripts\players\_rank::giveRankXP("spree", 250);
				self.laststreak = "Mega kill! ";
				if (self.curClass == "soldier")
					self scripts\players\_abilities::rechargeSpecial(30);
			break;
			case 13:
				self stoplocalsound("megakill");
				self playlocalsound("ludicrouskill");
				self scripts\players\_rank::giveRankXP("spree", 500);
				self.laststreak = "Ludicrous kill! ";
				if (self.curClass == "soldier")
					self scripts\players\_abilities::rechargeSpecial(35);
			break;
			case 15:
				self stoplocalsound("ludicrouskill");
				self playlocalsound("holyshit");
				self scripts\players\_rank::giveRankXP("spree", 1000);
				self.laststreak = "Holy Shit!!! ";
				if (self.curClass == "soldier")
					self scripts\players\_abilities::rechargeSpecial(40);
			break;
			case 20:
				self stoplocalsound("holyshit");
				self playlocalsound("wickedsick");
				self scripts\players\_rank::giveRankXP("spree", 2000);
				self.laststreak = "Wicked Sick!!! ";
				if (self.curClass == "soldier")
					self scripts\players\_abilities::rechargeSpecial(100);
			break;
		}
	} else {self.laststreak = "";}
	self notify("end_spree");
	self endon("end_spree");
	wait 1.25;
	if (self.laststreak!="") {
		iprintln(self.laststreak+self.name+"^7 killed "+self.spree+" enemies in a spree!");
	}
	self.spree = 0;
	self.laststreak = "";
	self.hud_streak fadeovertime(.5);
	self.hud_streak.alpha = 0;
}