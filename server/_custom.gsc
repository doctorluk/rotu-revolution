/**********************************
	---- Reign of the Undead ----
			   v2.0
	
	(Do not copy without permission)
	
	Date: November 2010
	Version: 2.000
	Author: Bipo
		
	© Reign of the Undead Team
************************************/

init()
{
	waittillframeend;
	if (level.dvar["game_use_custom"]) {
		thread custom_scripts\_admin::myRanks();
		thread custom_scripts\_admin::myCommands();
	}
}