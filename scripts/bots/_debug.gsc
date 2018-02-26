/**
* vim: set ft=cpp:
* file: scripts\bots\_debug.gsc
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
	thread waypointPerformance();
	// thread debugBots();
}

waypointPerformance(){
	max = 0;
	while(1){
	/*
		if(max < level.waypointLoops){
			logPrint("Max was below level.waypointLoops -> " + max + " previous max, " + level.waypointLoops + " level.waypointLoops on map " + getdvar("mapname") + "\n");
			max = level.waypointLoops;
			iprintln("^1PERFORMANCEDEBUG: ^3" + max + " ^7waypoint calculations were made this frame! (New max value)");
			if(max >= 500000){
				// iprintlnbold("^1LAG?! ^3If ^2YES^3, then we actually found the cause of lag!");
				// iprintlnbold("^1REPORT TO PUFFYFORUM.COM / LUK IMMEDIATELY");
				logPrint("OVER HALF A MILLION! " + max + " previous max, " + level.waypointLoops + " level.waypointLoops on map " + getdvar("mapname") + "\n");
			}
		}
	*/
		level.botsLookingForWaypoints = 0;
		level.waypointLoops = 0;
		wait 0.05;
	}
}

reportUndefined(var, varstring){
	if(!isDefined(var))
		iprintlnbold("Var " + varstring + " is undefined!");
}

debugBots()
{
	level endon("game_ended");
	wait 3;
    for(i = 0; i < 10; i++)
    {
        bot = addtestclient();

        if (!isdefined(bot))
        {
            println("Could not add test client");
            wait 1;
            continue;
        }
        bot.pers["isBot"] = true;
        bot thread TestClient("allies");
		wait 0.05;
    }
    // thread init();
}

TestClient(team)
{
    self endon("disconnect");
    while(!isdefined(self.pers["team"]))
        wait .05;
        
    self scripts\players\_players::joinAllies();
	thread scripts\players\_classes::pickClass("specialist");
	wait 0.1;
	self closeMenu();
	self closeInGameMenu();
	self thread scripts\players\_classes::acceptClass();
    // self notify("menuresponse", game["menu_changeclass_allies"], "soldier");
	
	
    // wait 0.5;
}