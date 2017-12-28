/**
* vim: set ft=cpp:
* file: scripts\extras\_rotustats.gsc
*
* authors: Luk, 3aGl3
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

#include scripts\include\useful;

saveGameStats(win){
	if(!level.dvar["surv_rotu_stats"])
		return;
		
	if(isDefined(level.rotuStats))
		return;
		
	level.rotuStats = true;
		
	iprintln("Writing RotU-STATS to disk!");
	
	printGameStats(win);
	
	for(i = 0; i < level.playersThatPlayed.size; i++)
		printPlayerStats(level.persPlayerData[ level.playersThatPlayed[i] ], level.playersThatPlayed[i]);
		
	logPrint("ROTU_STATS_DONE;\n");
}

printGameStats(win){
	logPrint("ROTU_STATS_GAME;" 
	+ level.rotuVersion 					+ ";" 
	+ win 									+ ";" 
	+ level.killedZombies 					+ ";" 
	+ (level.gameEndTime - level.startTime) + ";" 
	+ level.currentWave 					+ ";"
	+ getDvar("mapname") 					+ "\n" 
	);
}

printPlayerStats(struct, guid){

	if(!struct.hasPlayed)
		return;
		
	if(isOnServer(guid)){
		name 			= getNameByGUID(guid);
		struct = getPlayerEntityByGUID(guid);
	}
	else
		name			= struct.stats["name"];
	
	kills 				= int(struct.stats["kills"]);
	assists 			= int(struct.stats["assists"]);
	deaths 				= int(struct.stats["deaths"]);
	downtime 			= int(struct.stats["downtime"]);
	revives				= int(struct.stats["revives"]);
	healsGiven 			= int(struct.stats["healsGiven"]);
	ammoGiven 			= int(struct.stats["ammoGiven"]);
	damagedealt 		= int(struct.stats["damageDealt"]);
	damagedealtToBoss 	= int(struct.stats["damageDealtToBoss"]);
	turretKills 		= int(struct.stats["turretKills"]);
	points 				= int(struct.points);
	upgradepointsspent 	= int(struct.stats["upgradepointsSpent"]);
	explosivekills 		= int(struct.stats["explosiveKills"]);
	knifeKills 			= int(struct.stats["knifeKills"]);
	timesZombie 		= int(struct.stats["timesZombie"]);
	ignitions 			= int(struct.stats["ignitions"]);
	poisons 			= int(struct.stats["poisons"]);
	headshotKills 		= int(struct.stats["headshotKills"]);
	barriersRestored 	= int(struct.stats["barriersRestored"]);
	
	role 				= struct.class;
	
	logPrint("ROTU_STATS_PLAYER;"
	+ guid + ";"
	+ name + ";"
	+ role + ";"
	+ kills + ";"
	+ assists + ";"
	+ deaths + ";"
	+ downtime + ";"
	+ revives + ";"
	+ healsGiven + ";"
	+ ammoGiven + ";"
	+ damagedealt + ";"
	+ damagedealtToBoss + ";"
	+ turretKills + ";"
	+ points + ";"
	+ upgradepointsspent + ";"
	+ explosivekills + ";"
	+ knifeKills + ";"
	+ timesZombie + ";"
	+ ignitions + ";"
	+ poisons + ";"
	+ headshotKills + ";"
	+ barriersRestored + "\n"
	);

}