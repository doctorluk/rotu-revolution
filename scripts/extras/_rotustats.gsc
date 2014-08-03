//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.6 by Luk 
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

saveGameStats(win){
	if( !level.dvar["surv_rotu_stats"] )
		return;
		
	if( isDefined( level.rotuStats ) )
		return;
		
	level.rotuStats = true;
		
	iprintln("Writing RotU-STATS to disk!");
	
	printGameStats(win);
	
	for( i = 0; i < level.players.size; i++ )
		level.players[i] printPlayerStats();
		
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

printPlayerStats(){

	if( isDefined( self ) && !self.hasPlayed )
		return;

	kills 				= int(self.kills);
	assists 			= int(self.assists);
	deaths 				= int(self.deaths);
	downtime 			= int(self.downtime);
	revives				= int(self.revives);
	healsGiven 			= int(self.healsGiven);
	ammoGiven 			= int(self.ammoGiven);
	damagedealt 		= int(self.damagedealt);
	damagedealtToBoss 	= int(self.damagedealtToBoss);
	turretKills 		= int(self.turretKills);
	points 				= int(self.points);
	upgradepointsspent 	= int(self.upgradepointsspent);
	explosivekills 		= int(self.explosivekills);
	knifeKills 			= int(self.knifeKills);
	timesZombie 		= int(self.timesZombie);
	ignitions 			= int(self.ignitions);
	poisons 			= int(self.poisons);
	headshotKills 		= int(self.headshotKills);
	barriersRestored 	= int(self.barriersRestored);
	
	role 				= self.class;
	name 				= self.name;
	guid 				= self getGuid();
	
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