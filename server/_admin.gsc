/**********************************
	---- Reign of the Undead ----
			   v2.0
	
	(Do not copy without permission)
	
	Date: November 2010
	Version: 2.000
	Author: Bipo
		
	© Reign of the Undead Team
************************************/
#include scripts\include\data;
#include scripts\include\entities;
init()
{
	level.cmd = [];
	thread watchCmd();
	
	addCmd("kill", ::kill);
	addCmd("boom", ::boom);
	addCmd("change_map", ::changemap);
	addCmd("restart_map", ::restartmap);
	addCmd("revive", ::revivecommand);
	addCmd("resetplayer", ::reset);
	addCmd("getendview", ::getplayerangles);
	addCmd("saybold", ::saybold);
	addCmd("kill_zombies", ::killZombies);
	precache();
}

precache()
{
	level._boom = Loadfx("explosions/pyromaniac");
}

addCmd(dvar, script)
{
	cmd = spawnstruct();
	level.cmd[level.cmd.size] = cmd;
	cmd.dvar = dvar;
	cmd.script = script;
	setdvar(dvar, "");
}

watchCmd()
{
	while(1) {
		for (i=0; i<level.cmd.size; i++) {
			cmd = level.cmd[i];
			val = getdvar(cmd.dvar);
			if (val!="") {
				
				setdvar(cmd.dvar, "" );
				[[cmd.script]](StrTok(val, "&"));
			}
		}
		wait 0.25;
	}
}

saybold(args){
	if( !isDefined( args[0] ) || args[0] == "" )
		return;
	
	iprintlnbold( args[0] );
}


kill(args)
{
	players = getentarray("player", "classname");
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]))
		{
			players[i] suicide();
			iprintln(players[i].name + " has been killed by the admin");
		}
	}
}

// getplayerangles(args)
// {
	// players = getentarray("player", "classname");
	// for (i = 0; i<players.size; i++)
	// {
		// if (players[i] getEntityNumber() == int(args[0]))
		// {
			// players[i] iprintlnbold("before_origin");
			// origin = players[i] getOrigin();
			// originxyz = strTok(origin, ",");
			// originx = strTok(originxyz[0], "(");
			// originx = int(originx[0]);
			// originy = int(originxyz[1]);
			// originz = strTok(originxyz[2], ")");
			// originz = int(originz[0]);
			// players[i] iprintlnbold("after_origin, before angle");
			// angle = players[i] getPlayerAngles();
			// anglexyz = strTok(angle, ",");
			// anglex = strTok(anglexyz[0], "(");
			// anglex = int(anglex[0]);
			// angley = int(anglexyz[1]);
			// anglez = strTok(anglexyz[2], ")");
			// anglez = int(anglez[0]);
			// players[i] iprintlnbold("after_angle");
			// mapname = getDvar("mapname");
			// logPrint(originx + "," + originy + "," + originz + ";" + anglex + "," + angley + "," + anglez + " for " + mapname + "\n");
			// origin = strTok(players[i] getOrigin()+" ", ",");
			// players[i] iprintlnbold("Vector 0: " + origin[0]);
			// logprint("Vector 0: " + origin[0]);
			// angle = strTok(players[i] getPlayerAngles(), ",");
			// logPrint("SPECTATE_POS;" + players[i] getOrigin() + ";" + players[i] GetPlayerAngles() + "\n");
			// origin = players[i] getOrigin();
			// if(isDefined(origin))
				// players[i] iprintlnbold("Origin: " + players[i] getOrigin());
			// else
				// players[i] iprintlnbold("Origin is undefined!");
				
			// angles = players[i] getPlayerAngles();
			// if(isDefined(angles))
				// players[i] iprintlnbold("Angles: " + players[i] getOrigin());
			// else
				// players[i] iprintlnbold("Angles are undefined!");
		// }
	// }
// }

getplayerangles(args)
{
	players = getentarray("player", "classname");
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]))
		{
			players[i] thread scripts\players\_players::reportMyCoordinates();
		}
	}
}

revivecommand(args)
{
	players = level.players;
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]) )
		{
			if(!players[i].isAlive && !players[i].isZombie && players[i].isActive)
			{
				players[i] scripts\players\_players::revive();
				iprintln("^7"+players[i].name + "^7 has been revived by the admin");
			}
			else
			iprintln("^7"+players[i].name + "^7 has ^1NOT^7 been revived by the admin");
		}
	}
}

reset(args)
{
	players = level.players;
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]) )
		{
			if(!players[i].isZombie && players[i].isActive)
			{
				iprintln("Trying to resetpos " + players[i].name);
				if (level.playerspawns == "")
					spawn = getRandomTdmSpawn();
				else
					spawn = getRandomEntity(level.playerspawns);
				players[i] setOrigin(spawn.origin);
				players[i] setPlayerAngles(spawn.angles);
			}
		}
	}
}

killZombies(args)
{
	max = int(args[0]);
	if (max == 0)
	max = level.bots.size;
	for (i=0; i<max; i++)
	{
		//if (isalive(level.bots[i]))
		level.bots[i] suicide();
		wait 0.05;
	}
	iprintlnbold(max+" zombies have been killed by the admin");
}

boom(args)
{
	players = getentarray("player", "classname");
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]))
		{
			PlayFX(level._boom, players[i].origin);
			players[i] PlaySound("explo_metal_rand");
			players[i] suicide();
			iprintln(players[i].name + " has been blown up by the admin");
		}
	}
}

changemap(args)
{
	scripts\server\_maps::changeMap(args[0]);
}

restartmap(args)
{
	scripts\server\_maps::changeMap(getdvar("mapname"));
}
