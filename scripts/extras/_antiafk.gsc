/**
* vim: set ft=cpp:
* file: scripts\extras\_antiafk.gsc
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
* 	_antiafk.gsc
*	This small script monitors the player's behaviour. If the player either moves, aims, shoots or uses an item the counter is not increased.
*	Upon being inactive for too long, the player is kicked or put to spec depending on the config.
*
*/

#include scripts\include\useful;

/**
*	Initialize
*/
init(){
	if(level.dvar["game_afk_enabled"])
		thread onPlayerSpawn();
}

/**
*	Monitor player spawning and start anti-afk if enabled
*/
onPlayerSpawn(){
	while(1){
		level waittill("spawned", player);
		player.antiAFK = 0;
		player thread antiAFK();
	}
}

/**
*	Monitor the player and kick/spec him when the counter is reached
*/
antiAFK(){

	self endon("death");
	self endon("disconnect");
	self endon("join_spectator");
	
	// We change the displayed text depending on the chosen handle type
	// game_afk_type 0 = KICK
	// game_afk_type 1 = MOVE TO SPECTATOR
	if(level.dvar["game_afk_type"] == 0)
		handleTypeText = "KICKED";
	else
		handleTypeText = "PUT TO SPECTATOR";
	
	// Save current position before starting loop
	oldpos = self getOrigin();
	oldstance = self getStance();
	oldangles = self getPlayerAngles();
	
	// Keep checking the players attributes and actions
	// Checks Weapon, Angles, Stance, Button-use, Movement
	while(1){
		// self iprintln(self.antiAFK);
		oldweapon = self getCurrentWeapon();
		
		wait 0.05;
		
		// Ignore players that are down or zombified
		if(self.isDown || self.isZombie){ wait 1; continue; }
		
		// Big inactivity check
		if(oldangles != self getPlayerAngles() || // Check if his perspective changed
		oldstance != self getStance() || // Check if he's standing, crouching or prone
		self pressesAnyButton() || // Check if he pressed USE, AIM, FIRE etc.
		oldweapon != self getCurrentWeapon() || // Check if he switched weapons
		(self.antiAFK % 100 == 0 && self.antiAFK && distance(oldpos, self getOrigin()) > 200)){ // Check if he has rather far in the last 5 seconds
			
			// If any of those things matched, we save his current state and start over
			oldpos = self getOrigin();
			oldstance = self getStance();
			oldangles = self getPlayerAngles();
			self.antiAFK = 0;
			wait 1;
			
			continue;
		}
		else
			self.antiAFK++; // Increase AFK-counter if he hasn't been active
		
		// Print out warning messages when his AFK-counter has reached high enough
		if(self.antiAFK >= (level.dvar["game_afk_time_warn"] * 20) && 
		self.antiAFK % 20 == 0 && 
		self.antiAFK < ((level.dvar["game_afk_time_warn"] + level.dvar["game_afk_warn_amount"]) * 20))
			self iprintlnbold("^1WARNING: ^7DO NOT BE AFK OR YOU WILL BE " + handleTypeText + "!");
		
		// After warning him, check if the AFK-counter is high enough to act
		if(self.antiAFK >= (level.dvar["game_afk_time"] * 20))
			switch(level.dvar["game_afk_type"]){
				case 0: kick(self getEntityNumber()); break;
				case 1: self thread scripts\players\_players::joinSpectator(); break;
			}
	}

}