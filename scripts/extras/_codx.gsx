//
// vim: set ft=cpp:
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution by Luk and 3aGl3
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

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