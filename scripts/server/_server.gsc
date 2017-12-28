/**
* vim: set ft=cpp:
* file: scripts\server\_server.gsc
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

init()
{
	thread scripts\server\_versioning::init();
	thread scripts\extras\_codx::init();
	
	thread scripts\server\_settings::init();
	thread scripts\server\_welcome::init();
	thread scripts\server\_maps::init();
	thread scripts\server\_environment::init();
	thread scripts\server\_admin::init();
	thread scripts\server\_adminmenu::init();
	thread scripts\server\_scoreboard::init();
	thread scripts\server\_servername::init();
	thread scripts\security\_security::init();
	thread scripts\level\_tradespawns::init();
	
	thread scripts\extras\_antiafk::init();
	
	thread securityCheck();
	thread broadcastVersion();
}
// General information broadcast
broadcastVersion(){
	level endon("game_ended");
	
	switch(getDvar("net_ip")){
		case "185.4.149.11":
			while(1){
				iprintln("^2This Server is running ^1" + level.rotuVersion);
				iprintln("^2Please report bugs at ^1rotu-revolution.com");
				iprintln("^2Also note that this version ^3DOES ^2contain Bugs!");
				wait 60;
				iprintln("This Version of RotU-R has last been modified at " + level.lastModification);
				if(getDvarInt("developer_script")){
					wait 60;
					iprintln("^3XP GAIN HAS BEEN ^1DISABLED ^3DUE TO DEBUGGING MODE");
					wait 60;
				}
				else
					wait 120;
			}
			break;
		default:
			if(level.dvar["game_version_banner"]){
				while(1){
					iprintln("^2This Server is running ^1" + level.rotuVersion);
					iprintln("^2Please report bugs at ^3rotu-revolution.com");
					iprintln("^2Also note that this version ^3DOES ^2contain Bugs!");
					if(getDvarInt("developer_script")){
						wait 60;
						iprintln("^3XP GAIN HAS BEEN ^1DISABLED ^3DUE TO DEBUGGING MODE");
						wait 60;
					}
					else
						wait 120;
				}
			}
			break;
	}
	
}
// rcon_password being bugged out workaround
// rcon_password in console_mp.log workaround
securityCheck(){

	setdvar("logfile", 0);
	
	if(getDvar("rcon_password2") == "")
		setDvar("rcon_password2", getDvar("rcon_password"));
	else
		setDvar("rcon_password", getDvar("rcon_password2"));
		
	while(getDvarInt("logfile_2") > 2 || getDvar("logfile_2") == ""){
			// iprintlnbold("You have not set ^1logfile_2^7 in your Serverconfig^1!");
			// iprintlnbold("logfile_2 is invalid, value: " + getDvar("logfile_2"));
			logPrint("ERROR: Use logfile_2 as replacement for the dvar logfile!\n");
			wait 3;
		}

	setdvar("logfile", getDvar("logfile_2"));
}