//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.7 by Luk and 3aGl3
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

#include scripts\include\entities;
#include scripts\include\data;
init()
{
	precache();
	
	level.blur = level.dvar["env_blur"];
	
	wait .25;
	if (level.dvar["env_ambient"])
	{
		AmbientStop(0);
	}
	if (level.dvar["env_fog"])
	{
		setExpFog( level.dvar["env_fog_start_distance"], level.dvar["env_fog_half_distance"], level.dvar["env_fog_red"]/255, level.dvar["env_fog_green"]/255, level.dvar["env_fog_blue"]/255, 0);
		level.currentFog = [];
		level.currentFog[0] = level.dvar["env_fog_start_distance"];
		level.currentFog[1] = level.dvar["env_fog_half_distance"];
		level.currentFog[2] = level.dvar["env_fog_red"]/255;
		level.currentFog[3] = level.dvar["env_fog_green"]/255;
		level.currentFog[4] = level.dvar["env_fog_blue"]/255;
	}
	else
		level.currentFog = [];
	resetVision(0);
}

precache()
{
	level.lighting_fx = loadfx("weather/lightning");
	level.ember_fx = loadfx("fire/emb_burst_a");
	level._effect["fog0"] = loadfx("zombies/fx_fog_zombie_amb");
	level._effect["fog1"] = loadfx("zombies/fx_zombie_fog_static_xlg");
	
	precacheShader("compass_waypoint_defend");
}

normalWaveEffects(){
	level endon("wave_finished");
	level endon("game_ended");
	
	for( i = 0; i < 3; i++ ){
		if(level.waypoints.size <= 3)
			break;
			
		poses = level.waypoints;
		posent = poses[randomint(poses.size)];
		pos = posent.origin;
		poses = removeFromArray(poses, posent);
		
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
	
	while(level.waypoints.size > 3){
	
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

getDefaultVision()
{
	if ( level.dvar["env_override_vision"] )
		return "rotu";
	else
		return getDvar( "mapname" );
}

onPlayerConnect()
{
	self setclientdvar("r_blur", level.blur);
}

updateBlur(blur)
{
	level.blur = blur;
	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[i] setclientdvar( "r_blur", level.blur );
	}
}

setBlur(blur, time, player)
{
	level notify("setting_blur");
	level endon("setting_blur");
	level endon("game_ended");
	
	change = ( blur - level.blur ) / ( time + 1 ) / 2;
	while ( blur != level.blur )
	{
		updateBlur(level.blur + change);
		wait 0.5;
	}
}

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

emberFX()
{
	level endon("global_fx_end");
	while(1)
	{
		org = level.waypoints[randomint(level.waypoints.size)].origin;
		playfx(level.ember_fx, org);
		Earthquake( 0.25, 2, org, 512);
		wait .2 + randomfloat(.2);
	}
}

finaleFX(){
	level endon("global_fx_end");
	
	limit = RandomIntRange( 20, 45 );
	
	for( i = 0; i < limit; i++ ){
		org = level.waypoints[randomint(level.waypoints.size)].origin;
		playfx(level.burningFX, org);
	}
	
	while( 1 ){
		org = level.waypoints[randomint(level.waypoints.size)].origin;
		playfx( level.ember_fx, org );
		Earthquake( 0.25, 2, org, 512);
		wait .2 + randomfloat(.2);
	}
}

lightningFX()
{
	level endon("global_fx_end");
	while(1)
	{
		if (level.playerspawns == "")
			spawn = getRandomTdmSpawn();
		else
			spawn = getRandomEntity(level.playerspawns);
		playfx(level.lighting_fx, spawn.origin);
		r = randomint(2);
		if ( r == 0 )
			for (i=0; i<level.players.size; i++)
				level.players[i] playlocalsound("amb_thunder");

		wait 1 + randomfloat(2);
	}
	
}

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
		wait .2;
		setVision("thunder", .2);
		setExpFog( 999999, 9999999, 0, 0, 0, .2);
		r = randomint( 2 );
		for (i = 0; i<level.players.size; i++)
		{
			if ( r == 0 )
			level.players[i] playlocalsound( "amb_thunder" );
		}
		wait .2;
		setVision("boss", .1);
		setExpFog( 512, 1024, 0, 0, 0, .1);
		wait 2 + randomfloat(2);
	}
}

setFog(name, time)
{
	switch (name)
	{
		case "toxic":
			setExpFog( 256, 1024, 0.2, 0.4, 0.2, time);
			break;
		case "boss":
			setExpFog( 512, 1024, 0, 0, 0, time);
			break;
		case "scary":
			setExpFog( 128, 200, 0, 0, 0, time);
			break;
		case "grouped":
			setExpFog( 300, 700, .4, 0, 0, time);
			break;
		case "tank":
			setExpFog( 300, 700, .5, .5, .5, time);
			break;
		case "finale":
			setExpFog( 128, 2048, .5, .1, .1, time);
			break;
		default:
		if (level.dvar["env_fog"])
		{
			setExpFog( level.dvar["env_fog_start_distance"], level.dvar["env_fog_half_distance"], level.dvar["env_fog_red"]/255, level.dvar["env_fog_green"]/255, level.dvar["env_fog_blue"]/255, time);
		}
		else
		{
			setExpFog( 999999, 9999999, 0, 0, 0, time);
		}
		break;
	}
}

setVision(name, time)
{
	// if( level.vision == name )
		// return;
		
	level.vision = name;
	visionSetNaked( name, time );
}

resetVision(time)
{
	level.vision = getDefaultVision();
	visionSetNaked( level.vision, time );
}

setAmbient(ambient, delaystart, delaystop)
{
	if(!isDefined(delaystop))
		delaystop = 0;
	if(!isDefined(delaystart))
		delaystart = 7;
	if (level.dvar["env_ambient"])
	{
		AmbientStop(delaystop);
		AmbientPlay(ambient, delaystart);
	}
}

stopAmbient(time)
{
	if (!isdefined(time))
	time = 10;
	AmbientStop(time);
}

flashViewAll(colour, time, alpha){
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		players[i] thread scripts\include\hud::screenFlash(colour, time, alpha);
	}
}
