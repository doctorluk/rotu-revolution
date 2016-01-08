/**
* vim: set ft=cpp:
* file: maps\mp\_zombiescript.gsc
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

#include scripts\include\hud;
#include scripts\include\entities;
// GENERAL SCRIPTS
setGameMode(mode)
{
	level.gameMode = mode;

	waittillframeend;
}

setPlayerSpawns(targetname)
{
	level.playerspawns = targetname;
}

setWorldVision(vision, transitiontime)
{
	visionSetNaked( vision, transitiontime );
	level.vision = vision;
}

buildParachutePickup(targetname)
{
	ents = getentarray(targetname, "targetname");
	//for (i=0; i<ents.size; i++)
	//ents[i] thread scripts\players\_parachute::parachutePickup();
}

buildWeaponPickup(targetname, itemtext, weapon, type)
{
	/*
	ents = getentarray(targetname, "targetname");
	for (i=0; i<ents.size; i++)
	{
		ent = ents[i];
		ent.myWeapon = weapon;
		ent.wep_type = type;
		level scripts\players\_usables::addUsable(ent, "weaponpickup", "Press [^3USE^7] to pick up " + itemtext, 96);
	}
	*/
}

buildAmmoStock(targetname, loadtime)
{
	ents = getentarray(targetname, "targetname");
	for (i=0; i<ents.size; i++)
	{
		ent = ents[i];
		ent.loadtime = loadtime;
		if (level.ammoStockType == "weapon")
		{
			// level scripts\players\_usables::addUsable(ent, "ammobox", "Press [^3USE^7] for a weapon! (^1"+level.dvar["surv_waw_costs"]+"^7)", 96);
			level scripts\players\_usables::addUsable(ent, "ammobox", &"USE_GETWEAPON", 96);
			createTeamObjpoint(ent.origin+(0,0,72), "hud_weapons", 1);
		}
		if (level.ammoStockType == "upgrade")
		{
			// level scripts\players\_usables::addUsable(ent, "ammobox", "Press [^3USE^7] to upgrade your weapon!", 96);
			level scripts\players\_usables::addUsable(ent, "ammobox", &"USE_UPGRADEWEAPON", 96);
			createTeamObjpoint(ent.origin+(0,0,72), "hud_weapons", 1);
		}
		if (level.ammoStockType == "ammo"){
			// level scripts\players\_usables::addUsable(ent, "ammobox", "Hold [^3USE^7] to restock ammo", 96);
			level scripts\players\_usables::addUsable(ent, "ammobox", &"USE_GETAMMO", 96);
		}
	}
}

setWeaponHandling(id)
{
	level.onGiveWeapons = id;
}

setSpawnWeapons(primary, secondary)
{
	level.spawnPrimary = primary;
	level.spawnSecondary = secondary;
}

// ONSLAUGHT MODE
beginZomSpawning()
{
	//scripts\gamemodes\_onslaught::startSpawning();
}

//SURVIVAL MODE
buildSurvSpawn(targetname, priority) // Loading spawns for survival mode (incoming waves)
{
	scripts\gamemodes\_survival::addSpawn(targetname, priority);
}

//SURVIVAL MODE
removeSurvSpawn(targetname) // Removing spawns for survival mode (incoming waves)
{
	scripts\gamemodes\_survival::removeSpawn(targetname);
}

buildSurvSpawnByClassname(classname, priority)
{
	ent = getEntArray(classname, "classname");
	for( i = 0; i < ent.size; i++ ){
		ent[i].targetname = classname;
	}
	scripts\gamemodes\_survival::addSpawn(classname, priority);
}

prepareMap(){
	ent = getEntArray("oldschool_pickup", "targetname");
	for( i = 0; i < ent.size; i++ ){
		ent[i] delete();
	}
	
	allowed = [];
	// allowed[0] = "bombzone";
	// allowed[1] = "blocker";
	// allowed[2] = "hq";
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	// buildAmmoStock("bombzone");
	// buildWeaponUpgrade("hq_hardpoint");
}
/*
prepareMap(){
	ent = getEntArray("oldschool_pickup", "targetname");
	for( i = 0; i < ent.size; i++ ){
		ent[i] delete();
	}
	
	allowed[0] = "bombzone";
	allowed[1] = "blocker";
	allowed[2] = "hq";
	allowed[3] = "sd";
	allowed[4] = "koth";
	maps\mp\gametypes\_gameobjects::main(allowed);
}
*/
buildWeaponUpgrade( targetname ) // Weaponshop actually
{
	ents = getentarray(targetname, "targetname");
	for (i=0; i<ents.size; i++)
	{
		ent = ents[i];
		// level scripts\players\_usables::addUsable(ent, "extras", "Press [^3USE^7] to buy upgrades!", 96);
		level scripts\players\_usables::addUsable(ent, "extras", &"USE_BUYUPGRADES", 96);
		createTeamObjpoint(ent.origin+(0,0,72), "hud_ammo", 1);
	}
}

startSurvWaves() 
{
	scripts\gamemodes\_survival::beginGame();
}

//GENERAL SCRIPTS
waittillStart()
{
	wait .5;
	prepareMap();
	scripts\level\_tradespawns::buildTradespawns();
	scripts\gamemodes\_gamemodes::initGameMode();
	
	while( level.activePlayers == 0 )
		wait .5;
}

buildBarricade(targetname, parts, health, deathFx, buildFx, dropAll)
{
	if (!isdefined(dropAll))
	dropAll = false;
	ents = getentarray(targetname, "targetname");
	for (i=0; i<ents.size; i++)
	{
		ent = ents[i];
		level.barricades[level.barricades.size] = ent;
		for (ii=0; ii<parts; ii++)
		{
			ent.parts[ii] =  ent getClosestEntity(ent.target + ii);
			ent.parts[ii].startPosition = ent.parts[ii].origin;
		}
		ent.hp = int(health);
		ent.maxhp = int(health);;
		ent.partsSize = parts;
		ent.deathFx = deathFx;
		ent.buildFx = buildFx;
		ent.occupied = false;
		ent.dropAll = dropAll;
		ent thread scripts\players\_barricades::makeBarricade();
	}
}
