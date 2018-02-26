/**
* vim: set ft=cpp:
* file: scripts\server\_welcome.gsc
*
* authors: Luk, 3aGl3, Bipo, Etheross
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
			duration = getTimeForString(level.welcomeMessages[i].size, 3);
			self thread scripts\gamemodes\_hud::welcomeMessage(&"", level.welcomeMessages[i], (1,1,1), duration, 100, 1.4, undefined, 120);
			wait duration;
		}
		if(isDefined(self.welcome_message))
			self.welcome_message destroy();
	}
}