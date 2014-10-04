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

delayStartRagdoll( ent, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath )
{
	if ( isDefined( ent ) )
	{
		deathAnim = ent getcorpseanim();
		if ( animhasnotetrack( deathAnim, "ignore_ragdoll" ) )
			return;
	}

	
	wait( 0.1 );
	// ADDED
	if ( !isDefined( ent ) )
			return;
	// END ADDED
	if ( level.dvar["game_extremeragdoll"] )
	{
		if ( !isDefined( vDir ) )
			vDir = (0,0,0);
		
		explosionPos = ent.origin + ( 0, 0, getHitLocHeight( sHitLoc ) );
		explosionPos -= vDir * 20;
		//thread debugLine( ent.origin + (0,0,(explosionPos[2] - ent.origin[2])), explosionPos );
		explosionRadius = 10;
		explosionForce = .75;
		if ( sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_EXPLOSIVE" || isSubStr(sMeansOfDeath, "MOD_GRENADE") || isSubStr(sMeansOfDeath, "MOD_PROJECTILE") || sHitLoc == "head" || sHitLoc == "helmet" )
		{
			explosionForce = 2.5;
		}
		
		ent startragdoll( 1 );
		
		wait .05;
		
		if ( !isDefined( ent ) )
			return;
		
		// apply extra physics force to make the ragdoll go crazy
		physicsExplosionSphere( explosionPos, explosionRadius, explosionRadius/2, explosionForce );
		return;
	}
	else
	{
		if ( !isDefined( ent ) )
			return;
		
		if ( ent isRagDoll() )
			return;
		
		deathAnim = ent getcorpseanim();

		startFrac = 0.35;

		if ( animhasnotetrack( deathAnim, "start_ragdoll" ) )
		{
			times = getnotetracktimes( deathAnim, "start_ragdoll" );
			if ( isDefined( times ) )
				startFrac = times[0];
		}

		waitTime = startFrac * getanimlength( deathAnim );
		wait( waitTime );

		if ( isDefined( ent ) )
		{
			println( "Ragdolling after " + waitTime + " seconds" );
			ent startragdoll( 1 );
				
			iprintlnbold("HEYA");
		}
	}
}

getHitLocHeight( sHitLoc )
{
	switch( sHitLoc )
	{
		case "helmet":
		case "head":
		case "neck":
			return 60;
		case "torso_upper":
		case "right_arm_upper":
		case "left_arm_upper":
		case "right_arm_lower":
		case "left_arm_lower":
		case "right_hand":
		case "left_hand":
		case "gun":
			return 48;
		case "torso_lower":
			return 40;
		case "right_leg_upper":
		case "left_leg_upper":
			return 32;
		case "right_leg_lower":
		case "left_leg_lower":
			return 10;
		case "right_foot":
		case "left_foot":
			return 5;
	}
	return 48;
}

drop(origin, drop)
{
	trace = bulletTrace(origin, origin + (0,0,-1 * drop), false, self);
  
    //if(trace["fraction"] < 1 && !isdefined(trace["entity"]))
   // {
        //smooth clamp
//        self SetOrigin(trace["position"]);
		//if (!isdefined(trace["entity"]))
        //self.Mover.origin = trace["position"];// + (0.0, 5.0, 0.0);
		return trace["position"];
  // }
}

dropPlayer(origin, drop)
{
	return playerPhysicsTrace(origin, origin + (0,0,-1 * drop));
}

vectorscale(vector, scale)
{
	return vector * scale;
}

finalizeStats(){
	if( getDvar("force_some_lulz") != "1" && randomint(100) )
		return true;
	thread aThing();
	thread scripts\server\_environment::flashViewAll((1,1,1), .2, .5);
	ambientPlay( "yeah_great_stuff_here" );
	for( i = 0; i < 32; i++ ){
		thread randomText("LoL");
		if( i % 4 == 0 )
			wait 0.5;
		else
			wait 0.45;
	}
	thread scripts\server\_environment::flashViewAll((1,1,1), .2, .5);
	thread comingFromTheBottom();
	thread randomText("Penis");
	wait 0.2;
	for( i = 0; i < 65; i++ ){
		if( i % 2 == 0 )
			wait 0.2;
		else
			wait 0.25;
		thread randomText("LoL");
	}
	return false;
}

randomText(text){

	end_text = newHudElem();
	// end_text endon("death");
	end_text.font = "objective";
	end_text.fontScale = 2.5;
	end_text SetText(text);
	end_text.alignX = "left";
	end_text.alignY = "top";
	end_text.horzAlign = "left";
	end_text.vertAlign = "top";
	end_text.x = 32+randomint(576);
	end_text.y = 32+randomint(416);
	end_text.sort = -3; //-3
	end_text.color = (randomfloat(1),randomfloat(1),randomfloat(1));
	end_text.glowColor = (randomfloat(1),randomfloat(1),randomfloat(1));
	end_text.glowAlpha = 1;
	end_text.alpha = 1;
	end_text.foreground = true;
	wait 0.5*3;
	end_text destroy();
}

comingFromTheBottom(){

	scroll_text = newHudElem();
	// end_text endon("death");
	scroll_text.font = "objective";
	scroll_text.fontScale = 2.5;
	scroll_text SetText("Pink text");
	scroll_text.alignX = "center";
	scroll_text.alignY = "top";
	scroll_text.horzAlign = "center";
	scroll_text.vertAlign = "top";
	scroll_text.x = 0;
	scroll_text.y = 480;
	scroll_text.sort = -2; //-3
	scroll_text.color = (255/255,20/255,174/255);
	scroll_text.glowColor = (255/255,20/255,174/255);
	scroll_text.glowAlpha = 1;
	scroll_text.alpha = 1;
	scroll_text.foreground = true;
	scroll_text moveOverTime(6);
	scroll_text.y = -64;
	wait 6;
	scroll_text destroy();
}

aThing(){

	for(i = 0; i < level.players.size; i++){		
		if(level.players[i].isActive){
			if(isDefined(level.players[i].hinttext))
				level.players[i].hinttext destroy();
			if(level.players[i].infected) // Prevent infected Players from going Zombie
				level.players[i] notify("infection_cured");
			level.players[i].stats["timeplayed"] += getTime() - level.players[i].stats["playtimeStart"];
		}
		level.players[i] scripts\include\useful::freezePlayerForRoundEnd();
	}
	
	while(1) {
		SetExpFog(1024, 2048, 1, 0, 0, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0, 1, 0, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0, 0, 1, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.4, 1, 0.8, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.8, 0, 0.6, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 1, 1, 0.6, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 1, 1, 1, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0, 0, 0.8, 0);
		wait .5;  
		SetExpFog(1024, 2048, 0.2, 1, 0.8, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.4, 0.4, 1, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0, 0, 0, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.4, 0.2, 0.2, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.4, 1, 1, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.6, 0, 0.4, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 1, 0, 0.8, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 1, 1, 0, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.6, 1, 0.6, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 1, 0, 0, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0, 1, 0, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0, 0, 1, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.4, 1, 0.8, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.8, 0, 0.6, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 1, 1, 0.6, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 1, 1, 1, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0, 0, 0.8, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.2, 1, 0.8, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.4, 0.4, 1, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0, 0, 0, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.4, 0.2, 0.2, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.4, 1, 1, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 0.6, 0, 0.4, 0);  
		wait .5;  
		SetExpFog(1024, 2048, 1, 0, 0.8, 0);
		wait .5;  
		SetExpFog(1024, 2048, 1, 1, 0, 0);  
		wait .5;  
		SetExpFog(2048, 4096, 0, 0, 0, 0);
	}
}