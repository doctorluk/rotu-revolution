//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.6 by Luk 
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

#include maps\mp\_utility;
#include common_scripts\utility;
#include scripts\include\data;
#include scripts\include\hud;

init()
{
	precacheModel( "bx_teleporter" );
	precacheShellShock( "teleporter" );
	level.portalFX = loadfx("misc/spirit");

	level.teleporter = [];
	level.teles = 0;
	level.teles_held = 0;
}

giveTeleporter()
{
	self.carryObj = spawn("script_model", (0,0,0));
	self.carryObj.origin = self.origin + (0,0,32) + AnglesToForward(self.angles)*48;
	self.carryObj.angles = (self.angles[0], self.angles[1], self.angles[2]);
	
	self.carryObj linkto(self);
	self.carryObj setmodel("tag_origin");
	self.carryObj setcontents(2);
	
	wait 0.05;
	
	playfxontag(level.portalFX, self.carryObj, "tag_origin");
	
	self.carryObj thread onDeath();
	
	level.teles_held ++;
		
	self.canUse = false;
	self disableweapons();
	self thread placeTele();
}


onDeath()
{
	self waittill("death");
	level.teles_held -= 1;
}


placeTele()
{
	self endon("downed");
	self endon("death");
	self endon("disconnect");
	wait 1;
	while (1)
	{
		if (self attackbuttonpressed())
		{
			if (self deploy())
			{
				self.carryObj unlink();
				wait .05;
				self.carryObj delete();
				
				self.canUse = true;
				self enableweapons();
				
				return ;
			}
		}
		wait .05;
	}
	
}

deploy()
{
	self endon("disconnect");
	self endon("death");

	angles =  self getPlayerAngles();
	start = self.origin + (0,0,40) + vectorscale(anglesToForward( angles ), 20);
	end = self.origin + (0,0,40) + vectorscale(anglesToForward( angles ), 38);

	left = vectorscale(anglesToRight( angles ), -10);
	right = vectorscale(anglesToRight( angles ), 10);
	back = vectorscale(anglesToForward( angles ), -6);

	canPlantThere1 = BulletTracePassed( start, end, true, self);
	canPlantThere2 = BulletTracePassed( start + (0,0,-7) + left, end + left + back, true, self);
	canPlantThere3 = BulletTracePassed( start + (0,0,-7) + right , end + right + back, true, self);
	if( !canPlantThere1 || !canPlantThere2 || !canPlantThere3 )
	{
		self iPrintlnBold("Can not summon ^2portal ^7here.");
		return false;
	}

	trace = bulletTrace( end + (0,0,100), end - (0,0,300), false, self );	
	self thread spawnTeleporter( self.origin, (0,angles[1]+90,0), 2 );

	return true;
}


/*
	spawnTeleporter( origin, angles, spawndelay )

	origin - place where teleporter will spawn
	angles - teleporter angles
	spawndelay - time to activate spawnpoint
*/
spawnTeleporter( origin, angles, spawndelay )
{
	if( !isDefined( angles ) )
		angles = (0,0,0);

	if( !isDefined( spawndelay ) )
		spawndelay = .05;
		
	level.teles ++;

	// Setup some variables
	teleporter = undefined;
	final_destination = undefined;

	// Spawn teleporter with trigger
	level.teleporter[level.teleporter.size] = spawn( "script_model", origin );
	teleporter = level.teleporter[level.teleporter.size -1];
	teleporter setModel( "bx_teleporter" );
	teleporter.angles = angles;
	teleporter.trigger = spawn( "trigger_radius", teleporter.origin, 0, 40, 128 );
	teleporter setcontents(2);

	// Loop sound
	teleporter playLoopSound( "teleporter_loop" );

	wait spawndelay;
	
	// level scripts\players\_usables::addUsable(teleporter, "teleporter", "Press [Use] to teleport", 128);
	level scripts\players\_usables::addUsable(teleporter, "teleporter", &"USE_PORTAL", 128);
	
	teleporter thread destroyInTime(level.dvar["game_portal_time"]);
	
	while( isDefined( teleporter ) )
	{
		// Wait until someone use Teleporter
		teleporter.trigger waittill( "trigger", user );

		// Show message to everyone, let they know what player did...
		//iPrintln( user.name + " ^7teleported." );

		// Get best destination away from enemies. We want to be safe there!
		//final_destination = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( destination );

		// Teleport user to destination
		if (user.isBot)
		{
			wp = level.wp[randomint(level.wp.size)];
			user thread teleOut( self,  wp.origin, user.angles );
		}
		//{
			//user finishPlayerDamage(user, user, 10, 0, "MOD_PROJECTILE", "rpg_mp", user.angles, user.angles, "none", 0);
			//user updateHealthHud(user.health/user.maxhealth);
		//}
		wait 1.5;

		
	}
}

destroyInTime(time)
{
	wait time;
	level scripts\players\_usables::removeUsable(self); 
	level.teleporter = removeFromArray(level.teleporter, self);
	level.teles -= 1;
	self delete();
}

teleOut( teleporter, origin, angles )
{
	self endon("disconnect");
	self endon("death");
	//self endon("teleported");
	
	//self notify("teleported");
	if (!self.canTeleport)
	return;
	
	self.canTeleport = false;
	self thread enableTele(4);
		
	// Play sound
	teleporter playSound( "telein" ); 

	self shellShock( "teleporter", 1.4);
	wait 0.18;
	
	self setPlayerAngles( angles );
	
	if (self.isBot)
	{
		self.myWaypoint = undefined;
		self.underway = false;
		self.linkObj.origin = origin;
	}
	else
	{
		self setorigin( origin);
	}
	
	wait 0.4;
	self playSound( "teleout" );
}

enableTele(time)
{
	wait time;
	self.canTeleport = true;
}