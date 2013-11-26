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
#include scripts\include\useful;
init()
{
	level.cmd = [];
	thread watchCmd();
	
	addCmd("kill", ::kill);
	addCmd("wtf", ::wtf);
	addCmd("change_map", ::changemap);
	addCmd("restart_map", ::restartmap);
	addCmd("revive", ::revivecommand);
	addCmd("freezeplayer", ::freeze);
	addCmd("unfreezeplayer", ::unfreeze);
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

freeze(args)
{
	players = getentarray("player", "classname");
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]))
		{
			players[i] freezePlayerForRoundEnd();
			players[i] iprintlnbold("You have been ^5frozen ^7in place by an ^1ADMIN^7!");
		}
	}
}

unfreeze(args)
{
	players = getentarray("player", "classname");
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]))
		{
			players[i] unFreezePlayerForRoundEnd();
			players[i] iprintlnbold("You have been ^2UN^7-^5frozen by an ^1ADMIN^7!");
		}
	}
}

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
