/**
* vim: set ft=cpp:
* file: scripts\level\_spectatecoords.gsc
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
*	_spectatecoords.gsc
*	This file embeds the function that returns the existing coordinates for the endgame view when all players have died.
*
*/


getSpectateCoords(){

	map = getDvar("mapname");
	id = tableLookup("mp/endgameCoordinates.csv", 1, map, 0);
	
	if(id != "")
		return tableLookup("mp/endgameCoordinates.csv", 0, id, 2);

	// In case you want to add a map, do it here
	// Format:
	//
	// case "the_name_of_your_map":
	// 		return "x,y,z;x2,y2,z2";
	//
	// You get these coordinates by holding F as spectator
	
	
	
	switch(getDvar("mapname")){
		case "mp_fnrp_cube":
			return "739,-990,1999;46,124,0";
			
		default:
			return undefined;
	}

}

/**
*	Debug function that shows a spectator's coordinates when holding F for 3 Seconds
*/
giveCoordinatesToSpec()
{
	self notify("kill_coordinates");
	self endon("disconnect");
	self endon("spawned");
	self endon("kill_coordinates");
	
	i = 0;
	
	wait .5;
	// Check if a player's holding the USE button for 3 Seconds, show the coordinates, reset it otherwise
	while(1)
	{
		if(i == 2)
		{
			self reportMyCoordinates();
			i = 0;
		}
		else if(self useButtonPressed())
		{
			i++;
		}
		else
			i = 0;
			
		wait 1;				
	}
}

/**
*	Done for debugging purposes. Shows the player the current mapname and his location and angles
*/
reportMyCoordinates()
{

	origin = self getOrigin();
	angle = self getPlayerAngles();
	
	mapname = getDvar("mapname");
	
	logPrint("GETENDVIEW;" + int(origin[0]) + "," + int(origin[1]) + "," + int(origin[2]) + ";" + int(angle[0]) + "," + int(angle[1]) + "," + int(angle[2]) + " for " + mapname + "\n");
	self iprintlnbold("Screenshot this:");
	self iprintlnbold(int(origin[0]) + "," + int(origin[1]) + "," + int(origin[2]) + ";" + int(angle[0]) + "," + int(angle[1]) + "," + int(angle[2]));
	self iprintlnbold("Map: " + mapname);
}