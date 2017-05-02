//
// vim: set ft=cpp:
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution by Luk and 3aGl3
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//


/***
*
* 	_environment.gsc
*	Processes zombie wave effects like Fog and global effects
*	as well as the ambient music
*
*/

#include scripts\include\entities;
#include scripts\include\data;

/**
*	Loads up the default values for the game
*/
init()
{
	precache();
	
	level.blur = level.dvar["env_blur"];
	
	wait 0.25;
	
	if (level.dvar["env_ambient"])
	{
		ambientStop(0);
	}
	if (level.dvar["env_fog"])
	{
		setExpFog(level.dvar["env_fog_start_distance"], level.dvar["env_fog_half_distance"], level.dvar["env_fog_red"] /255 , level.dvar["env_fog_green"] / 255, level.dvar["env_fog_blue"] / 255, 0);
		level.currentFog = [];
		level.currentFog[0] = level.dvar["env_fog_start_distance"];
		level.currentFog[1] = level.dvar["env_fog_half_distance"];
		level.currentFog[2] = level.dvar["env_fog_red"] / 255;
		level.currentFog[3] = level.dvar["env_fog_green"] / 255;
		level.currentFog[4] = level.dvar["env_fog_blue"] / 255;
	}
	else
		level.currentFog = [];
		
	resetVision(0);
}

/**
*	Loads all global FX
*/
precache()
{
	level.lighting_fx = loadFx("weather/lightning");
	level.ember_fx = loadFx("fire/emb_burst_a");
	level._effect["fog0"] = loadFx("zombies/fx_fog_zombie_amb");
	level._effect["fog1"] = loadFx("zombies/fx_zombie_fog_static_xlg");
	
	precacheShader("compass_waypoint_defend");
}

/**
*	Fog effects of the default normal waves
*/
normalWaveEffects()
{
	level endon("wave_finished");
	level endon("game_ended");
	
	// This loop is being run when the wave starts to 'push' several foggy clouds right away
	for(i = 0; i < 3; i++)
	{
		// The fog effects are reliant on the waypoint positioning on the map
		// If there are not enough, we shouldn't spam the same points over and over again with fog
		if(level.waypoints.size <= 3)
			break;
		
		// Find a random waypoint
		poses = level.waypoints;
		posent = poses[randomint(poses.size)];
		pos = posent.origin;
		poses = removeFromArray(poses, posent);
		
		// The first effect is not as strong as the second, so we look for 80% Effect #1 and 20% Effect #2
		ran = randomfloat(1);
		
		if(ran < 0.8)
			effect = 0;
		else
			effect = 1;
			
		fxToPlay = "fog" + effect;
		playfx(level._effect[fxToPlay], pos);
	}
	
	poses = undefined;
	posent = undefined;
	pos = undefined;
	ran = undefined;
	fxToPlay = undefined;
	
	// After the first push we keep spawning more until the wave is over
	while(level.waypoints.size > 3)
	{
	
		pos = level.waypoints[randomint(level.waypoints.size)].origin;
		
		ran = randomfloat(1);
		
		if(ran < 0.8)
			effect = 0;
		else
			effect = 1;
			
		fxToPlay = "fog" + effect;
		playfx(level._effect[fxToPlay], pos);
		
		wait 3.5;
	}
}

/**
*	@return String, Returns the default vision of the map
*/
getDefaultVision()
{
	if (level.dvar["env_override_vision"])
		return "rotu";
	else
		return getDvar("mapname");
}

/**
*	Sets the newly connected player's blur to the currently used amount 
*	TODO: Change this to a loop with waittill("connected", player);
*/
onPlayerConnect()
{
	self setClientDvar("r_blur", level.blur);
}

/**
*	Sets a blur amount for all players on the server
*	@blur Float, Amount of blur
*/
updateBlur(blur)
{
	level.blur = blur;
	for (i = 0; i < level.players.size; i++)
	{
		level.players[i] setClientDvar("r_blur", level.blur);
	}
}

/**
*	Gradually changes the amount of blur for the game
*	@blur Float, Target amount of blur to change to
*	@time Float, Duration of the change
*/
setBlur(blur, time)
{
	level notify("setting_blur");
	level endon("setting_blur");
	level endon("game_ended");
	
	change = (blur - level.blur) / (time + 1) / 2;
	while (blur != level.blur)
	{
		updateBlur(level.blur + change);
		wait 0.5;
	}
}

/**
*	Runs FX Threads depending on the type of FX per wave type
*	@fxtype String, Type of FX to start globally
*/
setGlobalFX(fxtype)
{
	switch (fxtype)
	{
		case "lightning":
			thread lightningFX();
			break;
		case "lightning_boss":
			thread lightningBossFX();
			break;
		case "ember":
			thread emberFX();
			break;
		case "finale":
			thread finaleFX();
			break;
	}
}

/**
*	Spawns glowing embers emerging from the ground and small earthquakes randomly all over the map
*/
emberFX()
{
	level endon("global_fx_end");
	
	while(1)
	{
		org = level.waypoints[randomInt(level.waypoints.size)].origin;
		
		playFx(level.ember_fx, org);
		earthquake(0.25, 2, org, 512);
		
		wait 0.2 + randomFloat(0.2);
	}
}

/**
*	The FX during the Final Wave
*/
finaleFX()
{
	level endon("global_fx_end");
	
	limit = RandomIntRange(20, 45);
	
	for(i = 0; i < limit; i++)
	{
		org = level.waypoints[randomInt(level.waypoints.size)].origin;
		playFx(level.burningFX, org);
	}
	
	while(1)
	{
		org = level.waypoints[randomInt(level.waypoints.size)].origin;
		playfx(level.ember_fx, org);
		Earthquake(0.25, 2, org, 512);
		wait 0.2 + randomfloat(0.2);
	}
}

/**
*	The Lightning FX during a Hell Wave
*/
lightningFX()
{
	level endon("global_fx_end");
	
	while(1)
	{
		if (level.playerspawns == "")
			spawn = getRandomTdmSpawn();
		else
			spawn = getRandomEntity(level.playerspawns);
			
		playFx(level.lighting_fx, spawn.origin);
		
		r = randomInt(2);
		if (r == 0)
			for (i = 0; i < level.players.size; i++)
				level.players[i] playlocalsound("amb_thunder");

		wait 1 + randomfloat(2);
	}
	
}

/**
*	The Lightning FX during a Boss Wave
*/
lightningBossFX()
{
	level endon("global_fx_end");
	
	wait 15;
	
	while(1)
	{
		if (level.playerspawns == "")
			spawn = getRandomTdmSpawn();
		else
			spawn = getRandomEntity(level.playerspawns);
			
		playfx(level.lighting_fx, spawn.origin);
		
		wait 0.2;
		
		setVision("thunder", 0.2);
		setExpFog(999999, 9999999, 0, 0, 0, .2);
		
		r = randomint(2);
		for (i = 0; i < level.players.size; i++)
		{
			if (r == 0)
				level.players[i] playlocalsound("amb_thunder");
		}
		
		wait 0.2;
		
		setVision("boss", 0.1);
		setExpFog(512, 1024, 0, 0, 0, .1);
		
		wait 2 + randomfloat(2);
	}
}

/**
*	Sets the global fog colors depending on the given zombie wave type
*	@name String, Name of the currently running wave
*	@time Float, Duration of the transition (Note: This is buggy as soon as several players are playing, it is actually ineffective)
*/
setFog(name, time)
{
	switch (name)
	{
		case "toxic":
			setExpFog(256, 1024, 0.2, 0.4, 0.2, time);
			break;
			
		case "boss":
			setExpFog(512, 1024, 0, 0, 0, time);
			break;
			
		case "scary":
			setExpFog(128, 200, 0, 0, 0, time);
			break;
			
		case "grouped":
			setExpFog(300, 700, .4, 0, 0, time);
			break;
			
		case "tank":
			setExpFog(300, 700, .5, .5, .5, time);
			break;
			
		case "finale":
			setExpFog(128, 2048, .5, .1, .1, time);
			break;
			
		default:
			if (level.dvar["env_fog"])
			{
				setExpFog(
					level.dvar["env_fog_start_distance"],
					level.dvar["env_fog_half_distance"],
					level.dvar["env_fog_red"] / 255,
					level.dvar["env_fog_green"] / 255,
					level.dvar["env_fog_blue"] / 255,
					time
					);
			}
			else
				setExpFog(999999, 9999999, 0, 0, 0, time);
			break;
	}
}

/**
*	Sets the given vision for everyone
*	@name String, Name of the vision effect
*	@time Float, Duration for the change of vision
*/
setVision(name, time)
{		
	level.vision = name;
	visionSetNaked(name, time);
}

/**
*	Resets everyone's vision to the default vision
*/
resetVision(time)
{
	level.vision = getDefaultVision();
	visionSetNaked(level.vision, time);
}

/**
*	Changes the ambient music of the currently running wave
*	@ambient String, Soundalias of the new music that should be played
*	@delaystart Float, Time it takes for the new song to fade in
*	@delaystop Float, Time it takes for the old song to fade out
*/
setAmbient(ambient, delaystart, delaystop)
{
	if(!isDefined(delaystop))
		delaystop = 0;
	if(!isDefined(delaystart))
		delaystart = 7;
		
	if (level.dvar["env_ambient"])
	{
		ambientStop(delaystop);
		ambientPlay(ambient, delaystart);
	}
}

/**
*	Stops the currently running ambient music with a fadeout
*	@time Float, Time it takes for the old ambient music to fade out
*/
stopAmbient(time)
{
	if (!isDefined(time))
		time = 10;
		
	ambientStop(time);
}

/**
*	TODO: Move into a more HUD based script?
*	Flashes every player's screen with the given color
*	@color RGB, The color of the flash effect
*	@time Float, Duration of the flash effect on screen
*	@alpha Float 0-1, The maximum alpha of the flash on screen
*/
flashViewAll(color, time, alpha)
{
	for(i = 0; i < level.players.size; i++)
		level.players[i] thread scripts\include\hud::screenFlash(color, time, alpha);
}
