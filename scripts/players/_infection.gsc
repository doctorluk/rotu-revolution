/**
* vim: set ft=cpp:
* file: scripts\players\_infection.gsc
*
* authors: Luk, 3aGl3, Bipo, Etheross
* team: SOG Modding
*
* project: RotU - Revolution
* website: http://survival-and-obliteration.com/
*
* Reign of the Undead - Revolution by Luk and 3aGl3
* You may modify this code to your liking or reuse it, as long as you give credit to those who wrote it
* Based on Reign of the Undead 2.1 created by Bipo and Etheross
*/

/***
*
*	_infection.gsc
*	Handles player infection, infection damage and curing.
*
*/

#include scripts\include\hud;
#include scripts\include\entities;
#include scripts\include\useful;

/**
* Precaches all assets for infection
*/
init()
{
	precacheShellShock( "infection" );
	precacheHeadIcon( "icon_infection" );
	
	precacheString( &"ZOMBIE_INFECTED" );
	precacheString( &"ZOMBIE_PLAYER_N_INFECTED" );
}	/* init */

/**
* Cures the players infection, resetting him to normal state
*/
cureInfection()
{
	// reset the infection flag
	self.infected = false;
	
	// kill infection logic
	self notify( "infection_cured" );
	
	// delete the hud overlay
	if( isDefined(self.infection_overlay) )
		self.infection_overlay destroy();
	
	// disable the headicon and the usable
	self.headicon = "";
	level scripts\players\_usables::removeUsable( self );	
}	/* cureInfection */

/**
* Starts the infection on the given player
*/
goInfected()
{
	self endon( "infection_cured" );
	self endon( "disconnect" );
	self endon( "death" );

	// don't run the logic twice, or when godmode is enabled
	if( self.infected || level.godmode )
		return;
	
	// notify the script that the player is infected
	self notify( "infected" );

	// add an usable to heal the player
	if( !self.isDown )
		level scripts\players\_usables::addUsable( self, "infected", &"USE_CURE", 96 );

	// set the players headicon to let medics see he needs help
	self.headicon = "icon_infection";
	self.headiconteam = "allies";
	
	// create a hud overlay
	self.infection_overlay = createHealthOverlay( (0,1,0) );
	self.infection_overlay.alpha = .5;
	self.infected = true;
	
	// print a message that the player has been infected
	iPrintLn( &"ZOMBIE_PLAYER_N_INFECTED", self );
	self glowMessage( &"ZOMBIE_INFECTED", "", (1, 0, 0), 6, 50, 2 );
	
	// calculate the time for the infection to kick in
	time = 1 + randomInt( int(level.dvar["zom_infectiontime"]*.5) );
	
	// fade the hud overlay in
	self.infection_overlay fadeOverTime( time );
	self.infection_overlay.alpha = 0.8;

	// self thread infectionTweaks(time);

	// wait for the infection to kick in
	wait time;
	
	// start the main logic of the infection
	self thread infectedThink();
}	/* goInfected */

/*infectionTweaks(time)
{
	darkR = 1;
	darkG = .7;
	darkB = .7;
	lightG = .7;
	lightB = .7;
	fovScale = 1;
	quality = 40;
	waittime = time/quality;
	for (i=0; i<quality; i++)
	{
		darkR = 0.2 + .8 * (1- i/(quality-1));
		darkG = 0.1 + .9 * (1- i/(quality-1));
		darkB = 0.1 + .9 * (1- i/(quality-1));
		lightG = 1- i/(quality-1);
		lightB = 1- i/(quality-1);
		fovScale = 1 + .2 * (1- i/(quality-1));
		playerSetPermanentTweaks(0, 0, darkR + " " + darkG + " " + darkB, "1 " + lightG + " " + lightB, 0.25, 1.4, fovScale);
		wait waittime;
	}
}*/

/**
* Main infection logic, damages the player until he goes down
*/
infectedThink()
{
	self endon( "infection_cured" );
	self endon( "disconnect" );
	self endon( "downed" );
	self endon( "death" );

	interval = 3;
	damage = 4;

	while(1)
	{
		// damage the player
		self damageEnt( self, self, damage, "MOD_EXPLOSIVE", "none", self.origin, (0,0,0) );
		
		// apply shell shock effect
		self shellShock( "infection", 1 );
		
		// pulse the HUD overlay to full opacity
		self.infection_overlay fadeOverTime( 0.2 );
		self.infection_overlay.alpha = 1.0;
		
		// wait for the pulse
		wait 0.2;
		
		// pulse the HUD overlay back to semi opaque
		self.infection_overlay fadeOverTime( 0.2 );
		self.infection_overlay.alpha = 0.8;
		
		// wait the rest of the interval
		wait interval-0.2;
		
		// decrease the intervall time
		if( interval > 1 )
			interval = interval - .1;
	}
}	/* infectedThink */