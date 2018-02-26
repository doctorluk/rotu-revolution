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

init()
{
	precacheModel("com_barrel_metal");
	precacheModel("com_barrel_benzin");

	level.dynamic_barricades = [];
	level.barricades = [];

	level.barrels[0] = 0;
	level.barrels[1] = 0;
}

giveBarrel(type)
{
	if(!isDefined(type))
		type = 0;

	level.barrels[type]++;
	self.carryObj = spawn("script_model", (0,0,0));
	self.carryObj.origin = self.origin + AnglesToForward(self.angles)*48;
	self.carryObj.owner = self;
	// wait 0.05;
	self.carryObj linkto(self);
	self.carryObj.type = type;

	self.carryObj.maxhp = 100;
	if(self.carryObj.type == 1)
		self.carryObj setModel("com_barrel_benzin");
	else
		self.carryObj setModel("com_barrel_metal");
	self.carryObj.hp = self.carryObj.maxhp;

	self.canUse = false;
	self disableweapons();
	self thread placeBarrel();
}

makeBarricade()
{
	self.bar_type = 0;
	self.workingPart = 0;
	self.isUsable = 0;
}

placeBarrel()
{
	// self endon("downed");
	self endon("death");
	self endon("disconnect");

	wait 1;
	while(1)
	{
		if(self.isDown)
		{
			barrel = self.carryObj;
			barrel unlink();
			wait 0.1;
			
			level.barrels[barrel.type] -= 1;
			barrel delete();
			
			self.canUse = true;
			self enableWeapons();
			return;
		}

		if(self attackButtonPressed())
		{
			newpos = playerPhysicsTrace(self.carryObj.origin, self.carryObj.origin - (0,0,1000));
			if(self canPlaceBarrel(newpos))
			{
				self.carryObj unlink();
				wait .2;
				self.carryObj.bar_type = 1;
				self.carryObj.origin = newpos;
				self.carryObj.angles = self.angles;
				level.dynamic_barricades[level.dynamic_barricades.size] = self.carryObj;
				self.carryObj = undefined;
				self notify("used_usable");
				
				iPrintLn(self.name + " placed an ^2obstacle^7.");
				
				self.canUse = true;
				self enableWeapons();
				return;
			}
			else
			{
				self iPrintLnBold("^1Can not place barrel here!");
				wait 1;
			}
		}
		wait .05;
	}
	
}

canPlaceBarrel(newpos){
	return (bulletTracePassed(self GetEye(), newpos, false, self.carryObj) && 
			bulletTracePassed(self GetEye(), newpos + (0,0,48), false, self.carryObj) &&
			bulletTracePassed(newpos, newpos + (0,0,48), false, self.carryObj));
}

doBarricadeDamage(damage)
{
	if(self.bar_type == 0)
	{
		self.hp -= damage;
		if (self.hp < 0)
		self.hp = 0;
		
		newPart = self.partsSize -  int(((self.hp -1)  / self.maxhp) * self.partsSize + 1);
		
		while (self.workingPart != newPart)
		{
			if (isdefined(self.deathFx))
			PlayFX(self.deathFx, self.parts[self.workingPart].origin);
			
			if (!self.isUsable)
			{
				self.isUsable = true;
				// level scripts\players\_usables::addUsable(self, "barricade", "Hold [^3USE^7] to rebuild the barricade", 96);
				level scripts\players\_usables::addUsable(self, "barricade", &"USE_REBUILDBARRIER", 96);
			}
			
			self.parts[self.workingPart] thread removePart();
			self.workingPart ++ ;
		}
	}
	if(self.bar_type == 1)
	{
		self.hp -= damage;
		if(self.hp <= 0)
		{
			self thread barrelDeath();
		}
	}
}

restorePart()
{
	if (self.workingPart > 0)
	{
		self.workingPart -= 1;
		self.parts[self.workingPart].origin = self.parts[self.workingPart].startPosition;
		
		self.hp += self.maxhp / self.partsSize;
		
		if (isdefined(self.buildFx))
		PlayFX(self.buildFx, self.parts[self.workingPart].origin);
		
		if (self.workingPart == 0)
		{
			self.isUsable = false;
			level scripts\players\_usables::removeUsable(self);
		}
		
		return 1;
	}
	return 0;
}



removePart()
{
	self moveto(self.origin + (0, 0, -128), 1, .1, 0);
	wait 1;
} 


barrelDeath()
{
	level.barrels[self.type] -= 1;
	level.dynamic_barricades = removeFromArray(level.dynamic_barricades, self);

	if(self.type == 1)
	{
		playFX(level.explodeFX, self.origin);
		self playSound("explo_metal_rand");
		self thread scripts\players\_players::doAreaDamage(200, 1000, self.owner);
	}

	wait .01;
	self delete();
}


