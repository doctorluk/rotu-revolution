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

#include scripts\include\strings;

init(){
	if( !level.dvar["game_lan_mode"] )
		thread onPlayerConnect();
}

onPlayerConnect(){
	while(1){
		level waittill("connected", player);
		player thread check();
	}
}

check(){
	self thread checkValidGuid();
	self thread watchName();
}

checkValidGuid(){
	self endon( "disconnect" );
	lpGuidChar = "";
	lpGuid = self getGuid();
	while(1){
		lpGuid = self getGuid();
		for(i = 0; i < 32; i++){
			lpGuidChar = GetSubStr(lpGuid, i, i+1);
			
			if( lpGuid == "" || !isHexadecimal(lpGuidChar) || lpGuidChar == "" || lpGuidChar == " " ){
				self sayAll("I'm a hacking idiot, for which I now get kicked!");
				Kick(self getEntityNumber());
			}
			wait 0.1;
		}
		wait 4+randomfloat(2);
	}
}

watchName(){
	self endon("disconnect");
	violations = 0;
	while(1){
		name = self.name;
		name = GetSubStr(name, 0, 3);
		name = toLower(name);
		if(name == "bot"){
			self iprintlnbold("^1Warning: bot is not allowed as name/prefix!");
			violations++;
		}
		else if( violations > 0 && false /*level.dvar["admin_decay_namedbot"] TODO: ADD CONFIG VAR*/)
			violations--;
		
		if(violations >= 10)
			Kick(self getEntityNumber());
		wait 2;
	}
}