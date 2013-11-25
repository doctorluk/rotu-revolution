init(){
	thread waypointPerformance();
	// thread debugBots();
}

waypointPerformance(){
	max = 0;
	while(1){
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
		level.waypointLoops = 0;
		wait 0.05;
	}
}

debugBots()
{
	level endon("game_ended");
	wait 3;
    for(i = 0; i < 10; i++)
    {
        bot = addtestclient();

        if ( !isdefined(bot) )
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
    self endon( "disconnect" );
    while(!isdefined(self.pers["team"]))
        wait .05;
        
    self scripts\players\_players::joinAllies();
	thread scripts\players\_classes::pickClass("stealth");
	wait 0.1;
	self closeMenu();
	self closeInGameMenu();
	self thread scripts\players\_classes::acceptClass();
    // self notify("menuresponse", game["menu_changeclass_allies"], "soldier");
	
	
    // wait 0.5;
}