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

#include scripts\include\useful;

saveGameStats(win){
	if( !level.dvar["surv_rotu_stats"] )
		return;
		
	if( isDefined( level.rotuStats ) )
		return;
		
	level.rotuStats = true;
		
	iprintln("Writing RotU-STATS to disk!");
	
	printGameStats(win);
	
	for( i = 0; i < level.playersThatPlayed.size; i++ )
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

	if( !struct.hasPlayed )
		return;
		
	if( isOnServer(guid) ){
		name 			= getNameByGUID(guid);
		struct = getPlayerEntityByGUID(guid);
	}
	else
		name			= struct.stats["name"];
		
	if( 1 /*TODO: REMOVE DEBUGGING */){
		hasStats = "no";
		wasOnServer = "no";
		if( isDefined( struct.stats ) )
			hasStats = "yes";
		if( isOnServer(guid) )
			wasOnServer = "yes";
		logPrint("ROTU_STATS_DEBUG;defined struct.stats=" + hasStats + ", isOnServer: " + wasOnServer + " for " + name + "\n");
	}
	
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