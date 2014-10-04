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

damageEnt(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, damagepos, damagedir)
{
	if (self.isPlayer)
	{
		self.damageOrigin = damagepos;
		if(!isDefined(self.entity))
			self.entity = self;
		self.entity thread [[level.callbackPlayerDamage]](
			eInflictor, // eInflictor The entity that causes the damage.(e.g. a turret)
			eAttacker, // eAttacker The entity that is attacking.
			iDamage, // iDamage Integer specifying the amount of damage done
			0, // iDFlags Integer specifying flags that are to be applied to the damage
			sMeansOfDeath, // sMeansOfDeath Integer specifying the method of death
			sWeapon, // sWeapon The weapon number of the weapon used to inflict the damage
			damagepos, // vPoint The point the damage is from?
			damagedir, // vDir The direction of the damage
			"none", // sHitLoc The location of the hit
			0 // psOffsetTime The time offset for the damage
		);
	}
	else
	{
		// destructable walls and such can only be damaged in certain ways.
		if (self.isADestructable && (sWeapon == "artillery_mp" || sWeapon == "claymore_mp"))
			return;
		
		self.entity notify("damage", iDamage, eAttacker, (0,0,0), (0,0,0), "mod_explosive", "", "" );
	}
}

getClosestEntity(targetname, type)
{
	if (!isdefined(type))
	type = "targetname";
	
	ents = getentarray(targetname, type);
	nearestEnt = undefined;
	nearestDistance = 9999999999;
	for (i=0; i<ents.size; i++)
	{
		ent = ents[i];
		distance = Distance(self.origin, ent.origin);
		
		if(distance < nearestDistance)
		{
			nearestDistance = distance;
			nearestEnt = ent;
		}
  }
  
  return nearestEnt;
}

getClosestPlayer()
{
	ents = level.players;
	nearestEnt = undefined;
	nearestDistance = 9999999999;
	for (i=0; i<ents.size; i++)
	{
		ent = ents[i];
		distance = Distance(self.origin, ent.origin);
		
		if(distance < nearestDistance)
		{
			nearestDistance = distance;
			nearestEnt = ent;
		}
  }
  
  return nearestEnt;

}

getClosestPlayerArray()
{
	playerCount = level.players.size;
	
	nearPlayers = [];
	nearDistance = [];
	for (i=0; i<playerCount; i++)
	nearDistance[i] = 999999999;
	
	for (i=0; i<playerCount; i++)
	{
		player = level.players[i];
		if (player.isAlive)
		if (player.isTargetable)
		{
			distance = distanceSquared(self.origin, player.origin);
			for (ii=0; ii<playerCount; ii++)
			{
				if(distance < nearDistance[ii])
				{
					for (iii=i; iii>=ii; iii--)
					{
						nearDistance[iii+1] = nearDistance[iii];
						nearPlayers[iii+1] = nearPlayers[iii];
					}
					nearDistance[ii] = distance;
					nearPlayers[ii] = player;
				}
			}
		}
  }
  
  return nearPlayers;

}

getClosestTarget()
{
	ents = level.players;
	nearestEnt = undefined;
	nearestDistance = 9999999999;
	for (i=0; i<ents.size; i++)
	{
		ent = ents[i];
		distance = Distance(self.origin, ent.origin);
		if (ent.isAlive)
		{
			if (!ent.isTargetable )
			continue;
			if(distance < nearestDistance)
			{
				nearestDistance = distance;
				nearestEnt = ent;
			}
		}
  }
  
  return nearestEnt;
}

getRandomEntity(targetname)
{
	ents = getentarray(targetname,"targetname");
	if (ents.size > 0)
	{
		return ents[randomint(ents.size)];
	}
}

getRandomTdmSpawn()
{
	currentSpawns = getentarray("mp_tdm_spawn", "classname");
	return currentSpawns[randomint(currentSpawns.size)];
}