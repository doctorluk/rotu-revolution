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

#include scripts\include\hud;
#include scripts\include\data;
#include scripts\include\strings;
init()
{
	loadSettings();
}

loadSettings()
{
	level.welcomeMessages = [];
	index = 1;
	get = getdvar("message_welcome"+index);
	while (get!="")
	{
		level.welcomeMessages[index-1] = get;
		index ++;
		get = getdvar("message_welcome"+index);
	}
	
}

onPlayerSpawn()
{
	self endon("disconnect");
	if (!level.dvar["game_welcomemessages"])
	return;
	
	wait 2;
	
	if (!isdefined(self.hasBeenWelcomed))
	{
		self.hasBeenWelcomed = true;
		for (i=0; i<level.welcomeMessages.size; i++)
		{
			duration = getTimeForString(getStrLength(level.welcomeMessages[i]), 3);
			self thread scripts\gamemodes\_hud::welcomeMessage(&"", level.welcomeMessages[i], (1,1,1), duration, 100, 1.4, undefined, 120);
			wait duration;
		}
		if(isDefined(self.welcome_message))
			self.welcome_message destroy();
	}
}