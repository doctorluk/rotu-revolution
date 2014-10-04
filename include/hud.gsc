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

#include scripts\include\useful;

updateWaveHud(killed,total)
{
	level.waveHUD = 1;
	level.waveHUD_Killed = killed;
	level.waveHUD_Total = total;
	for (i=0; i<level.players.size; i++)
	{
		// if(level.players[i].sessionstate == "playing"){
			if(level.intermission == 1)
				level.players[i] setclientdvars("ui_wavetext", "?/?", "ui_waveprogress", 0);
			else if(level.intermission == 0)
				level.players[i] setclientdvars("ui_wavetext", level.waveHUD_Killed + "/" +  level.waveHUD_Total, "ui_waveprogress", level.waveHUD_Killed / level.waveHUD_Total);
		// }
	}
}

createTeamObjpoint( origin, shader, alpha)
{
	scripts\gamemodes\_hud::createTeamObjpoint( origin, shader, alpha);
}

specialRechargeFeedback()
{
	self thread scripts\gamemodes\_hud::specialRechargeFeedback();
}

healthFeedback()
{
	self thread scripts\gamemodes\_hud::healthFeedback();
}

addTimer(label, string, time)
{
	thread scripts\gamemodes\_hud::addTimer(label, string, time);
}

removeTimers()
{
	thread scripts\gamemodes\_hud::removeTimers();
}

announceMessage(label, text, glowcolor, duration, speed, size, height)
{
	for (i=0; i<level.players.size; i++)
		level.players[i] thread scripts\gamemodes\_hud::glowMessage(label, text, glowcolor, duration, speed, size, undefined, height);
}

overlayMessage(label, text, glowcolor, size)
{
	return self thread scripts\gamemodes\_hud::overlayMessage(label, text, glowcolor, size);
}

glowMessage(label, text, glowcolor, duration, speed, size, sound, height)
{
	self thread scripts\gamemodes\_hud::glowMessage(label, text, glowcolor, duration, speed, size, sound, height);
}

finaleMessage(label, text, glowcolor, duration, speed, size)
{
	self thread scripts\gamemodes\_hud::showFinaleMessage(label, text, glowcolor, duration, speed, size);
}

finaleMessageAll(label, text, glowcolor, duration, speed, size, all){
	if( !isDefined( all ) )
		all = false;
		
	for( i = 0; i < level.players.size; i++ ){
		p = level.players[i];
		
		if( !all && !isReallyPlaying( p ) )
			continue;
			
		p thread scripts\gamemodes\_hud::showFinaleMessage(label, text, glowcolor, duration, speed, size);
	}
	
}

timer(time, label, glowcolor, text, value)
{
	thread scripts\gamemodes\_hud::timer(time, label, glowcolor, text, undefined, value);
}

fadeout(time)
{
	self fadeOverTime( time );
	self.alpha = 0;
	wait time;
	if(isDefined(self))
		self destroy();
}

fadein(time, alpha)
{
	self.alpha = 0;
	self fadeOverTime( time );
	if (!isdefined(alpha))
		self.alpha = 1;
	else
		self.alpha = alpha;
}

fontPulseInit()
{
	self.baseFontScale = self.fontScale;
	self.maxFontScale = self.fontScale * 2;
	self.inFrames = 3;
	self.outFrames = 5;
}

fontPulse(player)
{
	self notify ( "fontPulse" );
	self endon ( "fontPulse" );
	player endon("disconnect");
	player endon("joined_team");
	player endon("joined_spectators");
	
	scaleRange = self.maxFontScale - self.baseFontScale;
	
	while ( self.fontScale < self.maxFontScale )
	{
		self.fontScale = min( self.maxFontScale, self.fontScale + (scaleRange / self.inFrames) );
		wait 0.05;
	}
		
	while ( self.fontScale > self.baseFontScale )
	{
		self.fontScale = max( self.baseFontScale, self.fontScale - (scaleRange / self.outFrames) );
		wait 0.05;
	}
}

progressBar(time)
{
	self destroyProgressBar();
	self thread scripts\gamemodes\_hud::progressBar(time);
}


bar(color, initial, y)
{
	self destroyProgressBar();
	self scripts\gamemodes\_hud::bar(color, initial, y);
}

bar_setscale(scale, color)
{
	self thread scripts\gamemodes\_hud::bar_setscale(scale, color);
}

destroyProgressBar()
{
	if (isdefined(self.bar_bg))
	self.bar_bg destroy();
	if (isdefined(self.bar_fg))
	self.bar_fg destroy();
}

streakHud() {
	self.hud_streak = NewClientHudElem(self);
	self.hud_streak.alpha = 0;
	self.hud_streak.font = "objective";
	self.hud_streak.label = &"ZOMBIE_STREAK";
	self.hud_streak.fontscale = 2;
	self.hud_streak.x = 0;
	self.hud_streak.y = 0;
	self.hud_streak.glowAlpha = .7;
	self.hud_streak.hideWhenInMenu = false;
	self.hud_streak.archived = true;
	self.hud_streak.alignX = "center";
	self.hud_streak.alignY = "middle";
	self.hud_streak.horzAlign = "center";
	self.hud_streak.vertAlign = "middle";
	self.hud_streak.color = rgb(224, 178, 27);
	self.hud_streak.glowColor = (.7,0,0);
	self.hud_streak fontPulseInit();
}

rgb(r,g,b){
	return (r/255,g/255,b/255);
}

upgradeHud(points)
{
	self endon("disconnect");
	self.upgradeHudPoints += points; // Makes the points not show before all point sources have been added together for only one display
	old = self.upgradeHudPoints;
	wait 0.05;
	
	if(self.upgradeHudPoints != old)
		return;
		
	points = self.upgradeHudPoints;
	self.upgradeHudPoints = 0;
	
	hud_score = NewClientHudElem(self);
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
	if (points > 0)
	{
		hud_score.glowColor = (.1, .9, .2);
		hud_score.label = (&"+&&1");
		hud_score setvalue( int(points) );
	}
	else
	{
		hud_score.glowColor = (.9, .1, .2);
		hud_score.label = (&"&&1");
		hud_score setvalue( int(points) );
	}
	direction = randomint(360);
	
	hud_score FadeOverTime(.5);
	hud_score.alpha = 1;
	
	hud_score MoveOverTime(1.5);
	hud_score.x = cos(direction)*64;
	hud_score.y = sin(direction)*64;
	wait 1.3;
	hud_score FadeOverTime(.3);
	hud_score.alpha = 0;
	wait .3;
	hud_score destroy();
}

bulletModFeedback(type)//No message appears
{
	if(type != "fire" && type != "poison")
		return;
	self endon("disconnect");
	hud_score = NewClientHudElem(self);
	hud_score.alpha = 0;
	hud_score.font = "objective";
	hud_score.fontscale = 1.4;//1.4 is minimum
	hud_score.x = 0;
	hud_score.y = 0;
	hud_score.glowAlpha = 1;
	hud_score.hideWhenInMenu = false;
	hud_score.archived = true;
	hud_score.alignX = "center";
	hud_score.alignY = "middle";
	hud_score.horzAlign = "center";
	hud_score.vertAlign = "middle";
	if(type == "poison"){
		hud_score.glowColor = (.1, .9, .4);
		hud_score settext("^2Poison");
	}
	else if(type == "fire"){
		hud_score.glowColor = (.8, .4, .4);
		hud_score settext("^9Fire");
	}
	direction = randomint(360);
	
	hud_score FadeOverTime(.5);
	hud_score.alpha = 0.5;
	
	hud_score MoveOverTime(1.6);
	hud_score.x = cos(direction)*64;
	hud_score.y = sin(direction)*64;
	wait 1.3;
	hud_score FadeOverTime(.3);
	hud_score.alpha = 0;
	wait .3;
	hud_score destroy();
	
}

updateHealthHud(delta)
{
	self setclientdvar("ui_healthbar", delta);
	if(isDefined(self.armored_hud) && self.heavyArmor && !self.god && !self.immune)
		self updateArmorHud();
}

updateArmorHud(){

	if (self.health / self.maxhealth >= .65 && !self.isZombie)
	{
		alpha = (self.health - self.maxhealth * 0.65) / (0.35 * self.maxhealth); // Alpha = 0 when Health is < 65%, else it raises linearly from alpha 0 at 65% to alpha 0.7 at 100%
	}
	else
		alpha = 0;
	alpha *= 0.7;

	if(self.armored_hud.alpha != alpha)
		self.armored_hud.alpha = alpha;
	if(self.armored_hud.color != (1,1,1))
		self.armored_hud.color = (1,1,1);
}

screenFlash(color, time, alpha)
{
	self endon("disconnect");
	whitescreen = newclientHudElem(self);
	whitescreen.sort = -2;
	whitescreen.alignX = "left";
	whitescreen.alignY = "top";
	whitescreen.x = 0;
	whitescreen.y = 0;
	whitescreen.horzAlign = "fullscreen";
	whitescreen.vertAlign = "fullscreen";
	whitescreen.foreground = true;
	whitescreen.color = color;
	
	whitescreen.alpha = alpha;
	whitescreen setShader("white", 640, 480);
	whitescreen fadeOverTime( time );
	whitescreen.alpha = 0;
	wait time;
	whitescreen destroy();
}

screenFlashAll(color, time, alpha, all){
	if( !isDefined( all ) )
		all = false;
	
	for( i = 0; i < level.players.size; i++ ){
		p = level.players[i];
		
		if( !all && !isReallyPlaying( p ) )
			continue;
			
		p thread screenFlash(color, time, alpha);
	}

}

blackScreen(){
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
	level.blackscreen setShader("black", 640, 480);
	thread scripts\server\_environment::updateBlur(8);
}

killBlackscreen(){
	if( isDefined(level.blackscreen) )
		level.blackscreen destroy();
}

createHealthOverlay(color)
{
	whitescreen = newclientHudElem(self);
	whitescreen.sort = -2;
	whitescreen.alignX = "left";
	whitescreen.alignY = "top";
	whitescreen.x = 0;
	whitescreen.y = 0;
	whitescreen.horzAlign = "fullscreen";
	whitescreen.vertAlign = "fullscreen";
	whitescreen.foreground = true;
	whitescreen.color = color;
	whitescreen.alpha = 1;
	whitescreen setShader("overlay_low_health", 640, 480);

	return whitescreen;
}

playerFilmTweaks(enable, invert, desaturation, darktint,  lighttint, brightness, contrast, fovscale)
{
	self.tweaksOverride = 1;
	self setClientDvars( "r_filmusetweaks", 1, "r_filmtweaks", 1 , "r_filmtweakenable", enable , "r_filmtweakinvert", invert , "r_filmtweakdesaturation", desaturation , "r_filmtweakdarktint", 
	darktint , "r_filmtweaklighttint", lighttint , "r_filmtweakbrightness", brightness ,"r_filmtweakcontrast", contrast, "cg_fovscale", fovscale );
}

playerFilmTweaksOff()
{
	self setClientDvars( "r_filmusetweaks", 0, "cg_fovscale", 1 );
	self.tweaksOverride = 0;
	if (self.tweaksPermanent)
	doPermanentTweaks();
}

playerSetPermanentTweaks(invert, desaturation, darktint,  lighttint, brightness, contrast, fovscale)
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

doPermanentTweaks()
{
	self setClientDvars("r_filmusetweaks", 1,
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

permanentTweaksOff()
{
	self setClientDvars( "r_filmusetweaks", 0, "cg_fovscale", 1 );
	self.tweaksPermanent = 0;
}
