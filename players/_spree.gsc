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
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon, Dunciboy and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

#include scripts\include\hud; //Required for spree hud

/**
 * Initialzing per player that spawns.
 */

onPlayerSpawn()
{
	self.spree = 0;
	if ( !isdefined( self.hud_streak ) ) //Check if hud is already loaded for the spree's
		streakHud();
}

/**
 * Main function
 * We check how big the spree already is and play the sound required for that spree.
 * After that we start the reset spree timer function
 * @see spreetimer
 */

checkSpree() 
{
	self endon( "disconnect" );
	self endon( "death" );
	self notify("end_spree");
	
	self.spree++;
	if ( self.spree > 1 ) 
	{
		if ( self.hud_streak.alpha==0 ) 
		{
			self.hud_streak.alpha = 1;
		}
		self.hud_streak setvalue(self.spree);
		self.hud_streak fontPulse(self);
		switch (self.spree) 
		{
			case 0:
			case 1:
				break; 
			// The above is just in case somthing goes wrong with the if
			case 2:
				self playlocalsound( "double_kill" );
			break;
			case 3:
				self.laststreak = "Triple kill! ";
				self stoplocalsound( "double_kill" );
				self playlocalsound( "triple_kill" );
				break;
			case 4:
			case 5:
			case 6:
				if( self.laststreak != "Multi kill! " )
				{
					self.laststreak = "Multi kill! ";
					self stoplocalsound( "triple_kill" );
					self playlocalsound( "multikill" );
				}
				break;
			case 7:
			case 8:
				if( self.laststreak != "Killing Spree! " )
				{
					self.laststreak = "Killing Spree! ";
					self stoplocalsound( "multikill" );
					self playlocalsound( "killing_spree" );
				}
				break;
			case 9:
			case 10:
				if( self.laststreak != "Ultra kill! " )
				{
					self.laststreak = "Ultra kill! ";
					self stoplocalsound( "killing_spree" );
					self playlocalsound( "ultrakill" );

				}
				break;
			case 11:
			case 12:
				if( self.laststreak != "Mega kill! " )
				{
					self.laststreak = "Mega kill! ";
					self stoplocalsound( "ultrakill" );
					self playlocalsound( "megakill" );
				}
				break;
			case 13:
			case 14:
				if( self.laststreak != "Ludicrous kill! " )
				{
					self.laststreak = "Ludicrous kill! ";
					self stoplocalsound( "megakill" );
					self playlocalsound( "ludicrouskill" );
				}
				break;
			case 15:
			case 16:
			case 17:
			case 18:
			case 19:
				if( self.laststreak != "Holy Shit!!! " )
				{
					self.laststreak = "Holy Shit!!! ";
					self stoplocalsound("ludicrouskill");
					self playlocalsound("holyshit");
				}
				break;
			default:
				if( self.laststreak != "Wicked Sick!!! " )
				{
					self.laststreak = "Wicked Sick!!! ";
					self stoplocalsound("holyshit");
					self playlocalsound("wickedsick");
				}
				break;
		}
	} 
	else 
	{
		self.laststreak = "";
	}
	self thread spreetimer();
}

/**
 * This function will wait 1,25 seconds or reset if called again before processing the spree
 * @see processspree
 */

spreetimer()
{
	self endon( "disconnect" );
	self endon( "death" );
	self notify( "end_spree" );
	self endon( "end_spree" );
	
	wait 1.25;
	self thread processspree(self.laststreak, self.spree);
}

/**
 * This function will process the end spree and grant the required xp
 * @param streak We send in the current streakname so its data won't get lost when it gets reset during the procesing
 * @param spree We send in the current intger amount of the spree so it's data won't get lost when it gets reset during the procesing
 */

processspree( streak, spree )
{
	self endon( "disconnect" );
	self endon( "death" );
	
	if( !isdefined( streak ) || !isdefined( spree ) )
		return;
	
	self.spree = 0;
	self.laststreak = "";
	self.hud_streak fadeovertime(.5);
	self.hud_streak.alpha = 0;
	if ( streak != "" && spree != 0 ) 
	{
		iprintln( streak + self.name + "^7 killed " + spree + " enemies in a spree!" );
	}
	
	if( spree == 2 )
	{
		self scripts\players\_rank::giveRankXP( "spree", 5 );
		if ( self.curClass == "soldier" )
			self scripts\players\_abilities::rechargeSpecial( 5 );
	}
	else if( streak == "Triple kill! " )
	{
		self scripts\players\_rank::giveRankXP( "spree", 15);
		if ( self.curClass == "soldier" )
			self scripts\players\_abilities::rechargeSpecial( 15 );
	}
	else if( streak == "Multi kill! " )
	{
		self scripts\players\_rank::giveRankXP( "spree", 40 );
		if (self.curClass == "soldier")
			self scripts\players\_abilities::rechargeSpecial( 30 );
	}
	else if( streak == "Killing Spree! " )
	{
		self scripts\players\_rank::giveRankXP( "spree", 90 );
		if (self.curClass == "soldier")
			self scripts\players\_abilities::rechargeSpecial( 70 );
	}
	else if( streak == "Ultra kill! " )
	{
		self scripts\players\_rank::giveRankXP( "spree", 190 );
		if (self.curClass == "soldier")
			self scripts\players\_abilities::rechargeSpecial( 95 );
	}
	else if( streak == "Mega kill! " )
	{
		self scripts\players\_rank::giveRankXP( "spree", 440 );
		if (self.curClass == "soldier")
			self scripts\players\_abilities::rechargeSpecial( 125 );
	}
	else if( streak == "Ludicrous kill! " )
	{
		self scripts\players\_rank::giveRankXP( "spree", 940 );
		if (self.curClass == "soldier")
			self scripts\players\_abilities::rechargeSpecial( 160 );
	}
	else if( streak == "Holy Shit!!! " )
	{
		self scripts\players\_rank::giveRankXP( "spree", 1940 );
		if ( self.curClass == "soldier" )
			self scripts\players\_abilities::rechargeSpecial( 200 );
	}
	else if( streak == "Wicked Sick!!! " )
	{
		self scripts\players\_rank::giveRankXP( "spree", 3940 );
		if ( self.curClass == "soldier" )
			self scripts\players\_abilities::rechargeSpecial( 300 );
	}
}
