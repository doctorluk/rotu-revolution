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
#include scripts\include\entities;
#include scripts\include\useful;
init()
{
	level.cmd = [];
	thread watchCmd();
	
	addCmd("kill", ::kill);
	addCmd("change_map", ::changemap);
	addCmd("rename", ::rename);
	addCmd("restart_map", ::restartmap);
	addCmd("revive", ::revivecommand);
	addCmd("freezeplayer", ::freeze);
	addCmd("unfreezeplayer", ::unfreeze);
	addCmd("resetplayer", ::reset);
	addCmd("setspectator", ::setSpec);
	addCmd("getendview", ::getplayerangles);
	addCmd("saybold", ::saybold);
	addCmd("resetlevel", scripts\players\_rank::fullResetRcon);
	addCmd("setrank", scripts\players\_rank::overwriteRank);
	addCmd("setprestige", scripts\players\_rank::overwritePrestige);
	addCmd("restorerank", ::restoreRank);
	addCmd("getprestige", ::getPrestige);
	addCmd("readconfig", ::readconfig);
	// addCmd("slap", ::slap);
	addCmd("kill_zombies", ::killZombies);
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

restoreRank(args){
	if( args.size > 4 || args.size < 3 )
		return;
		
	if( args.size == 3 )
		args[3] = 0;
	
	// 0 = ID
	// 1 = Prestige
	// 2 = Rank
	// 3 = Force Overwrite if Prestige/Rank is lower
		
	prestige = [];
	prestige[0] = args[0];
	prestige[1] = args[1];
	prestige[2] = args[3];
		
	rank = [];
	rank[0] = args[0];
	rank[1] = args[2];
	rank[2] = args[3];
	
	scripts\players\_rank::overwritePrestige(prestige);
	scripts\players\_rank::overwriteRank(rank);
	
}
/* 	Prints out the entered text as iprintlnbold on the screen
	Syntax: rcon saybold <text>
 */
saybold(args){
	if( !isDefined( args[0] ) || args[0] == "" )
		return;
	
	iprintlnbold( args[0] );
}
/* 	Prints READCONFIG; to the games_mp.log . It is used in coorporation with a manu admin mod plugin to read the configs
	Syntax: rcon readconfig 1
 */
readconfig(args){
	logPrint( "READCONFIG;\n" );
}
/* 	Renames a player
	Syntax: rcon rename <player_id>&<new_name>
 */
rename(args)
{
	players = getentarray("player", "classname");
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]) && args.size > 1)
		{
			iprintln("Player ^3" + players[i].name + "^7 has been renamed to ^3" + args[1] + " ^7by an admin." );
			players[i] setClientDvar("name", args[1]);
		}
	}
}
/* 	Moves a player to spectator
	Syntax: rcon setspectator <player_id>
 */
setSpec(args)
{
	players = getentarray("player", "classname");
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]))
		{
			iprintln("Player ^3" + players[i].name + "^7 has been moved to Spectators." );
			players[i] thread scripts\players\_players::joinSpectator();
		}
	}
}
/* 	Prints out the prestige level of a player in the iprintln area
	Syntax: rcon getprestige <player_id>
 */
getPrestige(args)
{
	players = getentarray("player", "classname");
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]))
		{
			iprintln("^3" + players[i].name + "'s^7 Prestige level is " + players[i].pers["prestige"] );
		}
	}
}
/* 	Gives the player damage
	Syntax: rcon slap <player_id>&<damage>
 */
 /*
slap(args)
{
	players = getentarray("player", "classname");
	if( args.size < 2 )
		return;
	for (i = 0; i < players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]))
		{
			iprintln("Player ^3" + players[i].name + "^7 has been slapped with " + int(args[1]) + " damage!" );
			players[i] finishPlayerDamage(players[i], players[i], int(args[1]), 0, "MOD_PROJECTILE", "slap_mp", (0,0,0), (0,0,0), "none", 0);
		}
	}
}
*/
/* 	Kills a player (NOT RECOMMENDED TO DO THIS)
	Syntax: rcon kill <player_id>
 */
kill(args)
{
	players = getentarray("player", "classname");
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]))
		{
			players[i] suicide();
			iprintln("^3" + players[i].name + " ^7has been killed by an admin.");
		}
	}
}
/* 	Freezes player's controls
	Syntax: rcon freezeplayer <player_id>
 */
freeze(args)
{
	players = getentarray("player", "classname");
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]))
		{
			players[i] freezePlayerForRoundEnd();
			players[i] iprintlnbold("You have been ^5frozen ^7in place by an admin!");
		}
	}
}
/* 	Unfreezes player's controls
	Syntax: rcon unfreezeplayer <player_id>
 */
unfreeze(args)
{
	players = getentarray("player", "classname");
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]))
		{
			players[i] unFreezePlayerForRoundEnd();
			players[i] iprintlnbold("You have been ^2UN^7-^5frozen by an admin!");
		}
	}
}
/* 	Returns coordinates to be used for the _spectatecoords.gsc
	Syntax: rcon getendview <player_id>
 */
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
/* 	Revives a player
	Syntax: rcon revive <player_id>
 */
revivecommand(args)
{
	players = level.players;
	for (i = 0; i<players.size; i++)
	{
		if ( players[i] getEntityNumber() == int(args[0]) )
		{
			if(!players[i].isAlive && !players[i].isZombie && players[i].isActive)
			{
				players[i] scripts\players\_players::revive();
				iprintln("^3"+players[i].name + "^7 has been revived by an admin.");
			}
			else
			iprintln("^3"+players[i].name + "^7 has ^1NOT^7 been revived by an admin.");
		}
	}
}
/* 	Resets the player to one of the existing spawns. Helps unstucking them if they are stuck
	Syntax: rcon resetplayer <player_id>
 */
reset(args)
{
	players = level.players;
	for (i = 0; i<players.size; i++)
	{
		if (players[i] getEntityNumber() == int(args[0]) )
		{
			if(!players[i].isZombie && players[i].isActive)
			{
				iprintln("Resetting the position of " + players[i].name);
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
/* 	Kills the amount of bots if they are alive
	Syntax: rcon kill_zombies <number>
	Use 0 as number to kill all
 */
killZombies(args)
{
	max = int(args[0]);
	
	if (max == 0)
		max = level.bots.size;
		
	for ( i = 0; i < max; i++)
	{
		//if (isalive(level.bots[i]))
		level.bots[i] suicide();
		wait 0.05;
	}
	iprintln(max+" zombies have been killed by an admin.");
}

changemap(args)
{
	scripts\server\_maps::changeMap(args[0]);
}

restartmap(args)
{
	scripts\server\_maps::changeMap(getdvar("mapname"));
}
