/**
* vim: set ft=cpp:
* file: scripts\include\hud.gsc
*
* authors: Luk, 3aGl3, Bipo, Etheross
* team: SOG Modding
*
* project: RotU - Revolution
* website: http://survival-and-obliteration.com/
*
* Reign of the Undead - Revolution ALPHA 0.7 by Luk and 3aGl3
* You may modify this code to your liking or reuse it, as long as you give credit to those who wrote it
* Based on Reign of the Undead 2.1 created by Bipo and Etheross
*/

#include scripts\include\useful;

/**
*	Updates the counters at the bottom left hand corner of a player's screen with the current wave progress
*	of zombies killed vs. total
*
*	@killed: Integer amount of zombies killed in the current wave
*	@total: Integer amount of total zombies in the current wave
*/
updateWaveHud( killed, total )
{
	level.waveHUD = 1;
	level.waveHUD_Killed = killed;
	level.waveHUD_Total = total;
	
	// Sets zombie progress numbers for every player in the bottom left hand corner display
	for ( i = 0; i < level.players.size; i++ )
	{
		if( level.intermission ) // Do not show any progress if there is no wave ongoing
			level.players[i] setClientDvars( "ui_wavetext", "?/?", "ui_waveprogress", 0 );
		else
			level.players[i] setClientDvars( "ui_wavetext", level.waveHUD_Killed + "/" +  level.waveHUD_Total, "ui_waveprogress", level.waveHUD_Killed / level.waveHUD_Total );
	}
}

/**
*	These are quick function pointers to the associated functions within the specific script file
*	For documentation, have a look at the functions they point to
*/
createTeamObjpoint( origin, shader, alpha )
{
	scripts\gamemodes\_hud::createTeamObjpoint( origin, shader, alpha );
}

specialRechargeFeedback()
{
	self thread scripts\gamemodes\_hud::specialRechargeFeedback();
}

healthFeedback()
{
	self thread scripts\gamemodes\_hud::healthFeedback();
}

addTimer( label, string, time )
{
	return self scripts\gamemodes\_hud::addTimer( label, string, time );
}

removeTimer( timer )
{
	self scripts\gamemodes\_hud::removeTimer( timer );
}

removeTimers()
{
	thread scripts\gamemodes\_hud::removeTimers();
}

announceMessage( label, text, glowcolor, duration, speed, size, height )
{
	for ( i = 0; i < level.players.size; i++ )
		level.players[i] thread scripts\gamemodes\_hud::glowMessage( label, text, glowcolor, duration, speed, size, undefined, height );
}

overlayMessage( label, text, glowcolor, size )
{
	// TODO: Why is there "return" here?
	return self thread scripts\gamemodes\_hud::overlayMessage( label, text, glowcolor, size );
}

glowMessage( label, text, glowcolor, duration, speed, size, sound, height )
{
	self thread scripts\gamemodes\_hud::glowMessage( label, text, glowcolor, duration, speed, size, sound, height );
}

finaleMessage( label, text, glowcolor, duration, speed, size )
{
	self thread scripts\gamemodes\_hud::showFinaleMessage( label, text, glowcolor, duration, speed, size );
}

// TODO: Move all of this into scripts\gamemodes\_hud
finaleMessageAll( label, text, glowcolor, duration, speed, size, all )
{
	if( !isDefined( all ) )
		all = false;
		
	for( i = 0; i < level.players.size; i++ )
	{
		p = level.players[i];
		
		if( !all && !isReallyPlaying( p ) )
			continue;
			
		p thread scripts\gamemodes\_hud::showFinaleMessage( label, text, glowcolor, duration, speed, size );
	}
	
}

timer( time, label, glowcolor, text, value )
{
	thread scripts\gamemodes\_hud::timer( time, label, glowcolor, text, undefined, value );
}

/**
*	Fades a HUD element out
*
*	@time: Float in seconds for the duration of the fadeout
*/
fadeout(time)
{
	self fadeOverTime( time );
	self.alpha = 0;
	
	wait time;
	
	if( isDefined( self ) )
		self destroy();
}

/**
*	Fades a HUD element in
*
*	@time: Float in seconds for the duration of the fadein
*	@alpha: Float between 0 and 1 corresponding to 0%-100% alpha that the element should have and the end of the fadein
*/
fadein( time, alpha )
{
	self.alpha = 0;
	self fadeOverTime( time );
	
	if ( !isDefined( alpha ) )
		self.alpha = 1;
	else
		self.alpha = alpha;
}

/**
*	Loads the animation properties for the HUD Streak messages
*/
fontPulseInit()
{
	self.baseFontScale = self.fontScale;
	self.maxFontScale = self.fontScale * 2;
	self.inFrames = 3;
	self.outFrames = 5;
}

/**
*	Animates a HUD element
*/
fontPulse( player )
{
	self notify( "fontPulse" );
	self endon( "fontPulse" );
	player endon( "disconnect" );
	player endon( "joined_team" );
	player endon( "joined_spectators" );
	
	scaleRange = self.maxFontScale - self.baseFontScale;
	
	// Increases font size until self.maxFontScale is reached
	while( self.fontScale < self.maxFontScale )
	{
		self.fontScale = min( self.maxFontScale, self.fontScale + ( scaleRange / self.inFrames ) );
		wait 0.05;
	}
	
	// Decreases font size until self.baseFontScale is reached
	while( self.fontScale > self.baseFontScale )
	{
		self.fontScale = max( self.baseFontScale, self.fontScale - ( scaleRange / self.outFrames ) );
		wait 0.05;
	}
}

/**
*	Creates a progress bar that fills up in @time
*
*	@time: Float, duration length of the bar filling up
*/
progressBar( time )
{
	self destroyProgressBar();
	self thread scripts\gamemodes\_hud::progressBar( time );
}

/**
*	Creates a colored bar on the player's screen
*
*	@color: Color the foreground bar should have
*	@initial: Float, amount in 0-1 how much the bar should be filled when calling
*	@y: Integer y-position of the bar on the player's screen
*/
bar( color, initial, y ) // TODO: THIS FUNCTION IS NEVER USED
{
	self destroyProgressBar();
	self scripts\gamemodes\_hud::bar( color, initial, y );
}

/**
*	Scales a bar to @scale size with @color coloring
*
*	@scale: Float amount of scaling
*	@color: Color of the bar
*/
bar_setscale( scale, color ) // TODO: THIS FUNCTION IS NEVER USED
{
	self thread scripts\gamemodes\_hud::bar_setscale( scale, color );
}

/**
*	Destroys the progress bar on the player's screen
*/
destroyProgressBar()
{
	if ( isDefined( self.bar_bg ) )
		self.bar_bg destroy();
	
	if ( isDefined( self.bar_fg ) )
		self.bar_fg destroy();
}

/**
*	Initializes the player's Killing-Streak number display
*/
streakHud()
{
	self.hud_streak = newClientHudElem( self );
	self.hud_streak.alpha = 0;
	self.hud_streak.font = "objective";
	self.hud_streak.label = &"ZOMBIE_STREAK";
	self.hud_streak.fontscale = 2;
	self.hud_streak.x = 0;
	self.hud_streak.y = 0;
	self.hud_streak.glowAlpha = 0.7;
	self.hud_streak.hideWhenInMenu = false;
	self.hud_streak.archived = true;
	self.hud_streak.alignX = "center";
	self.hud_streak.alignY = "middle";
	self.hud_streak.horzAlign = "center";
	self.hud_streak.vertAlign = "middle";
	self.hud_streak.color = rgb(224, 178, 27);
	self.hud_streak.glowColor = (0.7, 0, 0);
	self.hud_streak fontPulseInit();
}

/**
*	Converts RGB range to float range between 0 and 1
*
*	@r: Integer between 0 and 255, amount of RED
*	@g: Integer between 0 and 255, amount of GREEN
*	@b: Integer between 0 and 255, amount of BLUE
*	@return: Returns script compatible color vector
*/
rgb( r, g, b )
{
	return (r / 255, g / 255, b / 255);
}

/**
*	Displays the upgradepoint gain/loss on the player's screen around the crosshair
*
*	@points: Integer amount of upgradepoints a player has gained/lost
*/
upgradeHud( points )
{
	self endon( "disconnect" );
	
	// START: Collection of upgradepoints
	
	// We collect all upgradepoints we gain during two server frames, so we don't display
	// too many upgradepoint increases/decreases on the player's screen, resulting in some of them not being displayed
	self.upgradeHudPoints += points;
	old = self.upgradeHudPoints;
	wait 0.05;
	
	if( self.upgradeHudPoints != old )
		return;
	
	// END: Collection of upgradepoints
	
	points = self.upgradeHudPoints;
	self.upgradeHudPoints = 0;
	
	// Update total "Upgradepoints:" display on player's screen
	self setClientDvar( "ui_upgradetext", "Upgrade Points: " + int( self.points ) );
	
	// Create hud element showing the gain/loss of upgradepoints
	hud_score = newClientHudElem( self );
	hud_score.alpha = 0;
	hud_score.font = "objective";
	hud_score.fontscale = 1.6;
	hud_score.x = 0;
	hud_score.y = 0;
	hud_score.glowAlpha = 1;
	hud_score.hideWhenInMenu = false;
	hud_score.archived = true;
	hud_score.alignX = "center";
	hud_score.alignY = "middle";
	hud_score.horzAlign = "center";
	hud_score.vertAlign = "middle";
	
	// Distinguish between gaining and losing points, use apropriate coloring
	if ( points > 0 )
	{
		hud_score.glowColor = ( 0.1, 0.9, 0.2 );
		hud_score.label = ( &"+&&1" ); // TODO: MAKE LABEL IN LANGUAGE FILE
		hud_score setValue( int( points ) );
	}
	else
	{
		hud_score.glowColor = ( 0.9, 0.1, 0.2 );
		hud_score.label = ( &"&&1" );
		hud_score setValue( int( points ) );
	}
	
	hud_score fadeOverTime( 0.5 );
	hud_score.alpha = 1;
	
	// Make it move a random direction outward from the player's crosshair
	direction = randomint( 360 );
	hud_score moveOverTime( 1.5 ); // TODO: The wait amount adds to 1.6 seconds, we move for 1.5 seconds. Reduce wait or extend moving duration?
	hud_score.x = cos( direction ) * 64;
	hud_score.y = sin( direction ) * 64;
	
	// Wait for the animation to progress, then smoothly fade it out and remove
	wait 1.3;
	
	hud_score fadeOverTime( 0.3 );
	hud_score.alpha = 0;
	
	wait 0.3;
	
	hud_score destroy();
}

/**
*	Similar to the upgradepoint gaining display, we show a text indicating we're hurting zombies using poison or fire
*	@type: String type of the damage
*/
bulletModFeedback( type )
{
	self endon( "disconnect" );
	
	
	if( type != "fire" && type != "poison" )
		return;
	
	hud_score = newClientHudElem( self );
	hud_score.alpha = 0;
	hud_score.font = "objective";
	hud_score.fontscale = 1.4;
	hud_score.x = 0;
	hud_score.y = 0;
	hud_score.glowAlpha = 1;
	hud_score.hideWhenInMenu = false;
	hud_score.archived = true;
	hud_score.alignX = "center";
	hud_score.alignY = "middle";
	hud_score.horzAlign = "center";
	hud_score.vertAlign = "middle";
	
	if( type == "poison" )
	{
		hud_score.glowColor = ( 0.1, 0.9, 0.4 );
		hud_score setText( "^2Poison" ); // TODO: USE LABEL TO AVOID DEFINING TOO MANY TEXT VARS
	}
	else if( type == "fire" )
	{
		hud_score.glowColor = ( 0.8, 0.4, 0.4 );
		hud_score setText( "^9Fire" ); // TODO: USE LABEL TO AVOID DEFINING TOO MANY TEXT VARS
	}
	
	hud_score fadeOverTime( 0.5 );
	hud_score.alpha = 1;
	
	// Make it move a random direction outward from the player's crosshair
	direction = randomint( 360 );
	hud_score moveOverTime( 1.5 ); // TODO: The wait amount adds to 1.6 seconds, we move for 1.5 seconds. Reduce wait or extend moving duration?
	hud_score.x = cos( direction ) * 64;
	hud_score.y = sin( direction ) * 64;
	
	// Wait for the animation to progress, then smoothly fade it out and remove
	wait 1.3;
	
	hud_score fadeOverTime( 0.3 );
	hud_score.alpha = 0;
	
	wait 0.3;
	
	hud_score destroy();
	
}

/**
*	Adjusts the player's health bar width to @deltas amount -1 or 0-1
*
*	@delta: Float, can be -1 to disable health hud, can be 0-1 for empty or up to full health bar
*/
updateHealthHud( delta )
{
	self setClientDvar( "ui_healthbar", delta );
	
	// In case we're using the armored hud display, we also have to adjust its alpha accordingly
	if( isDefined( self.armored_hud ) && self.heavyArmor && !self.god && !self.immune )
		self updateArmorHud();
}

/**
*	Updates the alpha of the armored mesh HUD element of the armored class
*/
updateArmorHud()
{
	if ( self.health / self.maxhealth >= 0.65 && !self.isZombie )
	{
		// Alpha = 0 when Health is < 65%, else it raises linearly from alpha 0 at 65% to alpha 0.7 at 100%
		alpha = ( self.health - self.maxhealth * 0.65 ) / ( 0.35 * self.maxhealth ); 
	}
	else
		alpha = 0;
	
	// Limit alpha to 0.7
	alpha *= 0.7;

	if( self.armored_hud.alpha != alpha )
		self.armored_hud.alpha = alpha;
		
	if( self.armored_hud.color != ( 1, 1, 1 ) )
		self.armored_hud.color = ( 1, 1, 1 );
}

/**
*	Flashes the player's screen shortly with a fullsize color image
*
*	@color: Color of the flash
*	@time: Float time duration of the flash
*	@alpha: Float 0-1 initial alpha value
*/
screenFlash( color, time, alpha )
{
	self endon( "disconnect" );
	
	screenFlash = newClientHudElem( self );
	screenFlash.sort = -2;
	screenFlash.alignX = "left";
	screenFlash.alignY = "top";
	screenFlash.x = 0;
	screenFlash.y = 0;
	screenFlash.horzAlign = "fullscreen";
	screenFlash.vertAlign = "fullscreen";
	screenFlash.foreground = true;
	screenFlash.color = color;
	screenFlash.alpha = alpha;
	screenFlash setShader( "white", 640, 480 );
	
	screenFlash fadeOverTime( time );
	screenFlash.alpha = 0;
	
	wait time;
	
	screenFlash destroy();
}

/**
*	Function that flashes the screen for all playersif @all is true, not only for the calling player

*	@color: Color of the flash
*	@time: Float time duration of the flash
*	@alpha: Float 0-1 initial alpha value
*	@all: Boolean whether all playing players should be flashed, or only the one who is calling
*
*	TODO: Why do we use the all boolean if we could only use screenFlash instead?
*/
screenFlashAll( color, time, alpha, all )
{
	if( !isDefined( all ) )
		all = false;
	
	for( i = 0; i < level.players.size; i++ )
	{
		p = level.players[i];
		
		if( !all && !isReallyPlaying( p ) )
			continue;
			
		p thread screenFlash( color, time, alpha );
	}

}

/**
*	Creates a black screen for all players
*	Used in the finale announcement
*/
blackScreen()
{
	level.blackscreen = newHudElem();
	level.blackscreen.sort = -2;
	level.blackscreen.alignX = "left";
	level.blackscreen.alignY = "top";
	level.blackscreen.x = 0;
	level.blackscreen.y = 0;
	level.blackscreen.horzAlign = "fullscreen";
	level.blackscreen.vertAlign = "fullscreen";
	level.blackscreen.foreground = true;
	level.blackscreen.alpha = 1;
	level.blackscreen setShader( "black", 640, 480 );
	thread scripts\server\_environment::updateBlur( 8 );
}

/**
*	Removes the black screen for all players
*/
killBlackscreen()
{
	if( isDefined( level.blackscreen ) )
		level.blackscreen destroy();
}

/**
*	Creates the infection HUD image overlaying the player's vision
*
*	@color: Color of the overlay
*	@return: HUD element that is being created
*/
createHealthOverlay(color)
{
	healthOverlay = newclientHudElem( self );
	healthOverlay.sort = -2;
	healthOverlay.alignX = "left";
	healthOverlay.alignY = "top";
	healthOverlay.x = 0;
	healthOverlay.y = 0;
	healthOverlay.horzAlign = "fullscreen";
	healthOverlay.vertAlign = "fullscreen";
	healthOverlay.foreground = true;
	healthOverlay.color = color;
	healthOverlay.alpha = 1;
	healthOverlay setShader( "overlay_low_health", 640, 480 );

	return healthOverlay;
}

/**
*	Sets FilmTweaks for a player
*
*	@enable: Boolean whether it should be enabled or not
*	@invert: Boolean whether the display should be inverted
*	@desaturation: Float 0-1 How much saturation should be removed
*	@darktint: Color(0-2,0-2,0-2) of dark parts of the image
*	@lighttint: Color(0-2,0-2,0-2) of bright parts of the image
*	@brightness: Float -1-1 Brightness amount
*	@contrast: Float 0-4 Contrast amount
*	@fovscale: Float 0.2-2 Scaling the field of view
*/
playerFilmTweaks( enable, invert, desaturation, darktint, lighttint, brightness, contrast, fovscale )
{
	self.tweaksOverride = 1;
	self setClientDvars( "r_filmusetweaks", 1, "r_filmtweaks", 1, "r_filmtweakenable", enable, "r_filmtweakinvert", invert, "r_filmtweakdesaturation", desaturation, "r_filmtweakdarktint",	darktint, "r_filmtweaklighttint", lighttint, "r_filmtweakbrightness", brightness,"r_filmtweakcontrast", contrast, "cg_fovscale", fovscale );
}

/**
*	Disables Film Tweaks and resets them to the default set film tweaks if there are any
*/
playerFilmTweaksOff()
{
	self setClientDvars( "r_filmusetweaks", 0, "cg_fovscale", 1 );
	self.tweaksOverride = 0;
	
	if ( self.tweaksPermanent )
		doPermanentTweaks();
}

/**
*	Sets filmtweaks a player should always have
*
*	@invert: Boolean whether the display should be inverted
*	@desaturation: Float 0-1 How much saturation should be removed
*	@darktint: Color(0-2,0-2,0-2) of dark parts of the image
*	@lighttint: Color(0-2,0-2,0-2) of bright parts of the image
*	@brightness: Float -1-1 Brightness amount
*	@contrast: Float 0-4 Contrast amount
*	@fovscale: Float 0.2-2 Scaling the field of view
*/
playerSetPermanentTweaks( invert, desaturation, darktint,  lighttint, brightness, contrast, fovscale )
{
	self.tweakBrightness = brightness;
	self.tweakContrast = desaturation;
	self.tweakDarkTint = darktint;
	self.tweakLightTint = lighttint;
	self.tweakDesaturation = desaturation;
	self.tweakInvert = invert;
	self.tweakFovScale = fovscale;
	self.tweakContrast = contrast;
	self.tweaksPermanent = 1;
	
	doPermanentTweaks();
}

/**
*	Sets the permanent tweaks
*/
doPermanentTweaks()
{
	self setClientDvars( "r_filmusetweaks", 1,
						"r_filmtweaks", 1 ,
						"r_filmtweakenable", 1,
						"r_filmtweakinvert", self.tweakInvert,
						"r_filmtweakdesaturation", self.tweakDesaturation,
						"r_filmtweakdarktint",self.tweakDarkTint,
						"r_filmtweaklighttint", self.tweakLightTint,
						"r_filmtweakbrightness", self.tweakBrightness,
						"r_filmtweakcontrast", self.tweakContrast,
						"cg_fovscale", self.tweakFovScale );
}

/**
*	Disables the current and permanent tweaks
*/
permanentTweaksOff()
{
	self setClientDvars( "r_filmusetweaks", 0, "cg_fovscale", 1 );
	self.tweaksPermanent = 0;
}
