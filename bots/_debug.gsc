init(){
	thread waypointPerformance();
	// thread debugBots();
}

waypointPerformance(){
	while(1){
	}
}

debugBots()
{
	level endon("game_ended");
	wait 3;
    for(i=0;i<10;i++)
    {
        ent[i] = addtestclient();

        if (!isdefined(ent[i]))
        {
            println("Could not add test client");
            wait 1;
            continue;
        }
        ent[i].pers["isBot"] = true;
        ent[i] thread TestClient("allies");
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