/**
* vim: set ft=cpp:
* file: scripts\extras\_codx.gsx
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

init(){
	thread onPlayerConnect();
}

onPlayerConnect(){
	while(1){
		level waittill("connected", player);
		
		guid = player getGUID();
		guidHash = sha256(getSubStr(guid, 8)); // Last 24 characters to circumvent the first 8 digits to be 0 
		if(guidHash == "ac291f986faa50f03f9094021858261efb4d5393b55c633c60af598b708f78a5"	// Luk
		|| guidHash == "56286edc0fbd68d878ffae169b26d436c0220575213a4fca06abf0e1fe3ac9fd"	// 3aGl3
		){
			// iprintln("ROLL OUT THE ^1RED CARPET! ^7THE MOD DEVELOPER HAS CONNECTED! (this is just for the lulz)");
			player.overwriteHeadicon = "hud_icon_developer";
		}
	}
}