//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.2 by Luk 
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (3 lines above)
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