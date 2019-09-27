/**
* vim: set ft=cpp:
* file: scripts\players\_barricades.gsc
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
*	TODO: Add file description
*
*/

#include scripts\include\data;
#include scripts\include\hud;
#include scripts\include\useful;

/**
* Initializes all barricade data
*/
init()
{
	// precache models for dynamic barricades
	precacheModel( "com_barrel_metal" );
	precacheModel( "com_barrel_benzin" );

	// precache strings
	precacheString( &"ZOMBIE_N_PLACED_OBSTACLE" );
	precacheString( &"ZOMBIE_CANT_PLACE_OBSTACLE" );

	// create array for all barricades
	level.barricades = [];
	level.dynamic_barricades = [];

	// create counter for barrels by type
	level.barrels[0] = 0;
	level.barrels[1] = 0;
}	/* init */

/**
* Starts to deploy a barrel barricade
*/
giveBarrel( type )
{
	// make sure a type is defined
	if( !isDefined(type) )
		type = 0;

	// increase the counter for this barrel type
	level.barrels[type]++;
	
	// spawn a model for the barricade
	self.carryObj = spawn("script_model", (0,0,0));
	self.carryObj.origin = self.origin + AnglesToForward(self.angles)*48;
	self.carryObj.owner = self;
	self.carryObj.type = type;
	
	// link the barrel to the owner
	self.carryObj linkTo( self );

	// setup barricade health
	self.carryObj.maxhp = 100;
	self.carryObj.hp = self.carryObj.maxhp;
	
	// apply the model, depending on the varrel type
	if(self.carryObj.type == 1)
		self.carryObj setModel("com_barrel_benzin");
	else
		self.carryObj setModel("com_barrel_metal");

	// disable weapons and useables
	self.canUse = false;
	self disableWeapons();
	
	// allow the player to place the barrel down
	self thread placeBarrel();
}	/* giveBarrel */

/**
* Handles placing barrel barricades
*/
placeBarrel()
{
	// self endon("downed");
	self endon( "death" );
	self endon( "disconnect" );

	// delay, to prevent instant barrel spamming
	wait 1;

	// wait for the player to go down or place the barrel
	while(1)
	{
		// check if the player is down
		if( self.isDown )
		{
			// unlink the barrel from the player
			barrel = self.carryObj;
			barrel unlink();
			wait 0.1;
			
			// decrease the count of the barrel type
			level.barrels[barrel.type] -= 1;
			barrel delete();
			
			// reenable useables and weapons for the player
			self.canUse = true;
			self enableWeapons();
			return;
		}

		// check if the player is pressing the attack button, to place the barrel
		if( self attackButtonPressed() )
		{
			// run a tracer down, to drop the barrel
			newpos = playerPhysicsTrace(self.carryObj.origin, self.carryObj.origin - (0,0,1000));
			// check if the barrel can be placed on the ground
			if( self canPlaceBarrel(newpos) )
			{
				// unlink the barrel
				self.carryObj unlink();
				wait .2;
				
				// setup the barrel at the ground position
				self.carryObj.bar_type = 1;
				self.carryObj.origin = newpos;
				self.carryObj.angles = self.angles;
				
				// save the barrel in the dynamic_barricades array and clear the players carry object
				level.dynamic_barricades[level.dynamic_barricades.size] = self.carryObj;
				self.carryObj = undefined;
				self notify("used_usable");
				
				iPrintLn( &"ZOMBIE_N_PLACED_OBSTACLE", self );
				
				self.canUse = true;
				self enableWeapons();
				return;
			}
			else
			{
				self iPrintLnBold( &"ZOMBIE_CANT_PLACE_OBSTACLE" );
				wait 1;
			}
		}
		wait .05;
	}
}	/* placeBarrel */

/**
* Checks if a barrel can be placed at the given origin
*/
canPlaceBarrel( newpos )
{
	// run a triangle of traces, to check if the player hasa line of sight and if there is space
	return (bulletTracePassed(self GetEye(), newpos, false, self.carryObj) && 
			bulletTracePassed(self GetEye(), newpos + (0,0,48), false, self.carryObj) &&
			bulletTracePassed(newpos, newpos + (0,0,48), false, self.carryObj));
}	/* canPlaceBarrel */

/**
* Handles the death of barrel barricades
*/
barrelDeath()
{
	// remove the barrel from the global variables
	level.barrels[self.type] -= 1;
	level.dynamic_barricades = removeFromArray(level.dynamic_barricades, self);

	// make the barrel explode, if it's explosive
	if( self.type == 1 )
	{
		// pla yexplosion effects
		playFX( level.explodeFX, self.origin );
		self playSound("explo_metal_rand");
		
		// apply area damage, if the owner is still valid
		if( isReallyPlaying(self.owner) )
			self thread scripts\players\_players::doAreaDamage(200, 1000, self.owner);
	}

	wait 0.05;
	self delete();
}	/* barrelDeath */

/**
* Applies teh given amount of damage to the barricade
*/
doBarricadeDamage( damage )
{
	// apply damage to map barricades
	if( self.bar_type == 0 )
	{
		// substract the damage from the barricades health
		self.hp -= damage;
		// make sure the health doesn't go below 0
		if( self.hp < 0 )
			self.hp = 0;
		
		// get the number of parts that are up
		newPart = self.partsSize - int(((self.hp -1)  / self.maxhp) * self.partsSize + 1);
		
		// drop any parts that aren't up
		while( self.workingPart != newPart )
		{
			// play a death effect
			if( isDefined(self.deathFx) )
				playFX(self.deathFx, self.parts[self.workingPart].origin);
			
			// make the barricade repairable
			if( !self.isUsable )
			{
				self.isUsable = true;
				level scripts\players\_usables::addUsable( self, "barricade", &"USE_REBUILDBARRIER", 96 );
			}
			
			// drop the part
			self.parts[self.workingPart] thread removePart();
			self.workingPart++;
		}
	}
	// apply damage to barrel barricades
	else if( self.bar_type == 1 )
	{
		// substract the damage from the health
		self.hp -= damage;
		// destroy the barrel when it's out of hitpoints
		if( self.hp <= 0 )
		{
			self thread barrelDeath();
		}
	}
}	/* doBarricadeDamage */

/**
* Sets up variables for map barricades
*/
makeBarricade()
{
	self.bar_type = 0;
	self.workingPart = 0;
	self.isUsable = 0;
}	/* makeBarricade */

/**
* Restores a part to the barricade
*/
restorePart()
{
	// check if any parts are dropped
	if( self.workingPart > 0 )
	{
		// decrease the number of destroyed part
		self.workingPart -= 1;
		
		// move the part back into position
		self.parts[self.workingPart].origin = self.parts[self.workingPart].startPosition;
		
		// heal the barricade for a part of it's health
		self.hp += self.maxhp / self.partsSize;
		
		// play a rebuild effect
		if( isDefined(self.buildFx) )
			playFX(self.buildFx, self.parts[self.workingPart].origin);
		
		// make the barricade non usable, when fully restored
		if( self.workingPart == 0 )
		{
			self.isUsable = false;
			level scripts\players\_usables::removeUsable(self);
		}
		
		// return that a part was successfully restored
		return 1;
	}
	
	// return that no part could be restored
	return 0;
}	/* restorePart */

/**
* Removes a part from the barricade
*/
removePart()
{
	// move the part out of the way
	self moveTo( self.origin + (0, 0, -128), 1, .1, 0 );
}	/* removePart */



