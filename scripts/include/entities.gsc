/**
* vim: set ft=cpp:
* file: scripts\include\entities.gsc
*
* authors: Luk, 3aGl3, Bipo, Etheross
* team: SOG Modding
*
* project: RotU - Revolution
* website: http://survival-and-obliteration.com/
*
* Reign of the Undead - Revolution ALPHA 0.7 by Luk and 3aGl3
* You may modify this code to your liking or reuse it, as long as you give credit to those who wrote it
* Based on Reign of the Undead 2.1 created by Bipo and Etheross
*/

/**
* Inflicts damage to an entity.
*
*	@eInflictor: Entity, that causes the damage (e.g. a turret)
*	@eAttacker: Entity, that is attacking (e.g. a player)
*	@iDamage: Integer, specifying the amount of damage done
*	@sMeansOfDeath: String, specifying the method of death
*	@sWeapon: String, name of the weapon used to inflict the damage
*	@vPoint: Vector3, Origin the damage is from
*	@vDir: Vector3, Direction the damage is from
*/ 
damageEnt(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir)
{
	if(self.isPlayer)		// if the entity is a player
	{						// call the script callback to take note of abilities and such
		// save the point of damage
		self.damageOrigin = vPoint;
		
		// execute the playerDamage callback
		self thread [[level.callbackPlayerDamage]](eInflictor, eAttacker, iDamage, 0, sMeansOfDeath, sWeapon, vPoint, vDir, "none", 0);
	}
	else
	{
		// destructable walls and such can only be damaged in certain ways.
		if(self.isADestructable && (sWeapon == "artillery_mp" || sWeapon == "claymore_mp"))
			return;
		
		// notify the damage to the entity
		self.entity notify("damage", iDamage, eAttacker, (0, 0, 0), (0, 0, 0), "mod_explosive", "", "");
	}
}

/**
* Returns the closest entity with the given key value pair or targetname.
*
*	@value: String, value to look for
*	@key: String, key to look in
*/
getClosestEntity(value, key)
{
	// make sure the key is defined
	if(!isDefined(key))
		key = "targetname";

	// get an array with all entities of the given type
	ents = getEntArray(value, key);

	closestEntity = undefined;
	closestDistance = undefined;
	
	for(i = 0; i < ents.size; i++)
	{
		// define a var for ease of access
		ent = ents[i];
		
		// get the distance to the ent
		dist = distance(self.origin, ent.origin);
		
		if(!isDefined(closestDistance) || dist < closestDistance)		// if the distance of the current entity is below the distance of the last
		{																// make the current entity the closest entity
			// save the distance and the current entity
			closestDistance = dist;
			closestEntity = ent;
		}
	}

	return closestEntity;
}

/**
* Returns the player closest to the entity.
*/
getClosestPlayer()
{
	closestPlayer = undefined;
	closestDistance = undefined;

	for(i = 0; i < level.players.size; i++)
	{
		// define a var for ease of access
		player = level.players[i];
		
		// get the distance to the player
		dist = Distance(self.origin, player.origin);
		
		if(!isDefined(closestDistance) || dist < closestDistance)		// if the distance of the current player is below the distance of the last
		{																// make the current player the closest player
			// save the distance and the current player
			closestDistance = dist;
			closestPlayer = player;
		}
  }
  
  return closestPlayer;

}

/**
* Returns an array of players who are alive and targetable, sorted by distance.
*/
getClosestPlayerArray()
{
	// create an array with alive and targetable players
	players = [];
	for(i = 0; i < level.players.size; i++)
	{
		// create a var for ease of access
		player = level.players[i];
		
		// add the player only if he is indeed alive and targetable
		if(player.isAlive && player.isTargetable)
		{
			players[players.size] = player;
		}
	}

	// do a bubblesort on the players
	n = players.size;
	while(n > 1)
	{
		newn = 1;
		
		// loop through the players
		for(i = 0; i < players; i++)
		{
			// create a var for ease of access
			player = players[i];
			
			// if this player is further away then the next one in the array
			if(isDefined(players[i + 1]) && distance(self.origin, player.origin) > distance(self.origin, players[i + 1].origin))
			{
				// put the next player into the spot of the current player
				players[i] = players[i + 1];
				
				// put the current player into the spot of the next player
				players[i + 1] = player;
				
				// next time the sort will only have to go this far
				newn = i + 1;
			}
		}
		n = newn;
	}

	return players;
}

/**
* Returns the closest target for the zombie.
*	NOTE: Alias of function getClosestPlayer.
*/
getClosestTarget()
{
	// return the closest player
	return self getClosestPlayer();
}

/**
* Returns a random entity with the given targetname.
*
*	@targetname: String, value of the entities targetname
*/
getRandomEntity(targetname)
{
	// get an array with all the entities with the targetname
	ents = getEntArray(targetname, "targetname");

	if(ents.size > 0)		// if any entities were found
	{						// return a random entity from the array
		return ents[randomInt(ents.size)];
	}
}

/**
* Returns a random entity of the classname "mp_tdm_spawn".
*/
getRandomTdmSpawn()
{
	// get an array with spawnpoints
	spawns = getEntArray("mp_tdm_spawn", "classname");
	
	if(spawns.size > 0)		// if any spawnpoints were found
	{							// return a random spawnpoint form the array
		return spawns[randomint(spawns.size)];
	}
}
