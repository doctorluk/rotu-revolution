/**********************************
	---- Reign of the Undead ----
			   v2.0
	
	(Do not copy without permission)
	
	Date: November 2010
	Version: 2.000
	Author: Bipo
		
	© Reign of the Undead Team
************************************/

#include scripts\include\hud;
#include scripts\include\entities;
init()
{
	precache();
}

precache()
{
	PreCacheShellShock("infection");
	precacheHeadIcon("icon_infection");
	
	precachemodel("ch_tombstone3");
}

cureInfection()
{
	self.infected = false;
	self notify("infection_cured");
	if (isdefined(self.infection_overlay))
	self.infection_overlay destroy();
	self.headicon = "";
	level scripts\players\_usables::removeUsable(self);
	
}

goInfected()
{
	self endon("infection_cured");
	self endon("disconnect");
	self endon("death");
	if (self.infected || level.godmode)
	return;
	
	if (!self.isDown)
	// level scripts\players\_usables::addUsable(self, "infected", "Press USE to cure", 96);
		level scripts\players\_usables::addUsable(self, "infected", &"USE_CURE", 96);
	
	self.headicon = "icon_infection";
	self.headiconteam = "allies";
	self.infection_overlay = createHealthOverlay((0,1,0));
	self.infection_overlay.alpha = .5;
	self.infected = true;
	iprintln("^1" + self.name + "^1 has been infected!");
	self glowMessage(&"ZOMBIE_INFECTED", "", (1, 0, 0), 6, 50, 2);
	
	wait level.dvar["zom_infectiontime"];
	time = 1 + randomint(int(level.dvar["zom_infectiontime"]*.5));
	
	self.infection_overlay fadeovertime(time);
	self.infection_overlay.alpha = 1;
	
	//self thread infectionTweaks(time);

	//playerFilmTweaks
	wait time;
	
	self thread startDamaging();
	self thread waitGoZombie();
}

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

startDamaging()
{
	self endon("infection_cured");
	self endon("disconnect");
	self endon("death");
	self endon("zombify");
	interval = 3;
	damage = 4;
	while (1)
	{
		self damageEnt(
			self, // eInflictor = the entity that causes the damage (e.g. a claymore)
			self, // eAttacker = the player that is attacking
			damage, // iDamage = the amount of damage to do
			"MOD_EXPLOSIVE", // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
			"none", // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
			self.origin, // damagepos = the position damage is coming from
			//(0,self GetPlayerAngles()[1],0) // damagedir = the direction damage is moving in      
			(0,0,0)
			);
		self shellShock("infection",1);
		if (interval > 1)
		interval = interval - .1;
		
		wait interval;
	}
}

waitGoZombie()
{
	self endon("disconnect");
	self endon("death");
	self endon("revived");
	self endon("infection_cured");
	while (!self.isDown)
	{
		wait .1;
	}
	wait 5;
	self thread playerGoZombie();
}

playerGoZombie()
{
	self endon("disconnect");
	self endon("death");
	if (self.sessionteam=="spectator")
	return;
	
	self.tombEnt = spawn( "script_model", self.origin );
	self.tombEnt setmodel( "ch_tombstone3" );
	self.tombEnt.origin = self.origin;
	self.tombEnt.angles = self.angles;
	self.tombEnt.targetname = "tombstone";
	self.tombEnt.player = self;
	
	//self.isDown = false;
	self.infected = false;
	level scripts\players\_usables::removeUsable(self);
	self.isZombie = true;
	self notify("zombify");
	type = "tank";
	self.type = "tank";
	self playerSetPermanentTweaks(0, 0, ".2 .1 .1", "1 0 0", 0.25, 1.4, 1.2);
	self.headicon = "";
	if (isdefined(self.infection_overlay))
	self.infection_overlay destroy();
	
	self scripts\bots\_types::loadZomStats(type);
	self.maxHealth = int( self.maxHealth * level.dif_zomHPMod );
	
	self.health = self.maxHealth;
	
	self.isDoingMelee = false;
	
	self.alertLevel = 0; // Has this zombie been alerted? 
	self.myWaypoint = undefined;
	self.underway = false;
	self.quake = false;
	
	self takeallweapons();
	
	self spawn( self.origin, self.angles );
	
	self detachall();
	// self setmodel("skeleton");
	self.timesZombie++;
	self setclientdvar("cg_thirdperson", 1);
	
	wait 0.05;
	
	self scripts\bots\_types::loadAnimTree(type);
	
	self scripts\bots\_types::loadZomModel(type);
	// self detachall();
	// self setmodel("skeleton");
	
	
	self FreezeControls(true);
	
	self.linkObj = spawn("script_origin", self.origin);
	self.linkObj.origin = self.origin;
	self.linkObj.angles = self.angles;
	
	self updateHealthHud(1);
	
	wait 0.05;
	
	self linkto(self.linkObj);
	
	self scripts\bots\_bots::zomGoIdle();
	
	self thread scripts\bots\_bots::zomMain();
	

	ent = self getClosestTarget();
	if (isdefined(ent))
	self scripts\bots\_bots::zomSetTarget(ent.origin);
}