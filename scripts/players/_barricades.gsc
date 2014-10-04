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

#include scripts\include\data;
#include scripts\include\hud;
#include scripts\include\useful;

init()
{
	precachemodel("com_barrel_metal");
	precachemodel("com_barrel_biohazard");
	precachemodel("com_barrel_benzin");
	level.dynamic_barricades = [];
	
	PreCacheTurret("saw_bipod_stand_mp");
	precachemodel("weapon_saw_MG_setup");
	level.barrels[0] = 0;
	level.barrels[1] = 0;
	level.barrels[2] = 0;
	level.barricades = [];
}

giveBarrel(type){
	if (!isdefined(type))
	type = 0;
	
	level.barrels[type] ++;
	self.carryObj = spawn("script_model", (0,0,0));
	self.carryObj.origin = self.origin + AnglesToForward(self.angles)*48;
	self.carryObj.master = self;
	// wait 0.05;
	self.carryObj linkto(self);
	self.carryObj.type = type;

	self.carryObj.maxhp = 100;
	if (self.carryObj.type == 1)
	{
		self.carryObj setmodel("com_barrel_biohazard");
		self.carryObj.maxhp = 60;
	}
	else if (self.carryObj.type == 2)
		self.carryObj setmodel("com_barrel_benzin");
	else
		self.carryObj setmodel("com_barrel_metal");
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
	while (1)
	{
		if( self.isDown ){
			barrel = self.carryObj;
			barrel unlink();
			wait 0.2;
			barrel delete();
			self.canUse = true;
			self enableweapons();
			return;
		}
		if (self attackbuttonpressed())
		{
			newpos = PlayerPhysicsTrace(self.carryObj.origin, self.carryObj.origin - (0,0,1000));
			
			if ( self canPlaceBarrel(newpos) )
			{
				self.carryObj unlink();
				wait .2;
				self.carryObj.bar_type = 1;
				self.carryObj.origin = newpos;
				self.carryObj.angles = self.angles;
				level.dynamic_barricades[level.dynamic_barricades.size] = self.carryObj;
				if (self.carryObj.type == 1)
					self.carryObj addMG();
				self.carryObj = undefined;
				self notify("used_usable");
				
				iprintln( self.name + " placed an ^2obstacle^7." );
				
				self.canUse = true;
				self enableweapons();
				return;
			}
			else
			{
				self iprintlnbold("^1Can not place barrel here!");
				wait 1;
			}
		}
		wait .05;
	}
	
}

canPlaceBarrel(newpos){
	return (BulletTrace(self GetEye(), newpos, false, self.carryObj)["fraction"] == 1 && 
				BulletTrace(self GetEye(), newpos + (0,0,48), false, self.carryObj)["fraction"] == 1 &&
				BulletTrace(newpos, newpos + (0,0,48), false, self.carryObj)["fraction"] == 1 );
}

addMG()
{
	self.turret = SpawnTurret("turret_mp", self.origin + (0,0,48) + anglestoforward(self.angles)*-6, "saw_bipod_stand_mp");
	self.turret setmodel("weapon_saw_MG_setup");
	self.turret.angles = self.angles;
	if (level.dvar["game_mg_overheat"])
	self.turret thread MGOverheat();
	self thread deleteMG(level.dvar["game_mg_barrel_time"]);
}

MGOverheat()
{
	self endon("death");
	self thread MGDeath();
	self.overheat = 0;
	self.cooldown = 0;
	while (1)
	{
		self waittill ("trigger", player);
		self.myPlayer = player;
		player.onTurret = true;
		player.canUse  = false;
		heldUseButton = false;
		player bar((0,1,0), 0, 128);
		wait 0.1;
		if(player useButtonPressed())
			heldUseButton = true;
		while (isdefined(player))
		{
			player notify("used_usable");
			if(!player useButtonPressed())
				heldUseButton = false;
			if (player attackButtonPressed())
			{
		
				if (self.overheat >= 100 || self.cooldown)
				{
					player execClientCommand("-attack");
					self.cooldown = true;
				}
				else
				{
					self.overheat += level.dvar["game_mg_cooldown_speed"] + level.dvar["game_mg_overheat_speed"];
				}
			}
			if (self.cooldown)
			{
				if (self.overheat < 60)
				self.cooldown = false;
			}
			if (self.overheat > 0)
			{
				self.overheat -= level.dvar["game_mg_cooldown_speed"];
				delta = self.overheat / 100;
				player bar_setscale(delta, (delta,1-delta,0));
			}
			
			if (player useButtonPressed() && !heldUseButton)
			{
				self.myPlayer = undefined;
				player.onTurret = false;
				player.canUse  = true;
				player destroyProgressBar();
				self thread cooldown();
				break;
			}
			
			wait 0.05;
		}
		
	}
}

MGDeath()
{
	self waittill("death");
	level.barrels[1] -= 1;
	if (isdefined(self.myPlayer))
	{
		if (self.myPlayer.onTurret)
		{
			self.myPlayer.canUse = true;
			self.myPlayer.onTurret = false;
			self.myPlayer destroyProgressBar();
		}
	}
}


cooldown()
{
	self endon("trigger");
	self endon("death");
	while (1)
	{
		if (self.overheat > 0)
		self.overheat -= level.dvar["game_mg_cooldown_speed"];
		wait 0.05;
	}
}

deleteMG(time)
{
	wait time;
	if (isDefined(self.turret))
	self.turret delete();
	if(isDefined(self))
	self delete();
}

doBarricadeDamage(damage)
{
	if (self.bar_type == 0)
	{
		self.hp -= damage;
		if (self.hp < 0)
		self.hp = 0;
		
		newPart = self.partsSize -  int(((self.hp -1)  / self.maxhp) * self.partsSize + 1);
		
		while (self.workingPart != newPart )
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
	if (self.bar_type == 1)
	{
		self.hp -= damage;
		if (self.hp <= 0)
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
	if (self.type != 1)
	level.barrels[self.type] -= 1;
	if (isdefined(self.turret))
	self.turret delete();
	
	level.dynamic_barricades = removeFromArray(level.dynamic_barricades, self);
	if (self.type == 2)
	{
		PlayFX(level.explodeFX, self.origin);
		self PlaySound("explo_metal_rand");
		self thread scripts\players\_players::doAreaDamage(200, 1000, self.master);
	}
	wait .01;
	self delete();
}


