/**********************************
	---- Reign of the Undead ----
			   v2.0
	
	(Do not copy without permission)
	
	Date: November 2010
	Version: 2.000
	Author: Bipo
		
	© Reign of the Undead Team
************************************/

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