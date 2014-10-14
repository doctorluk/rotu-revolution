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

#include scripts\include\data;
#include scripts\include\useful;
#include common_scripts\utility;

init()
{
	level.waveHUD = 0;
	level.waveHUD_Killed = 0;
	level.waveHUD_Total = 0;
	level.objects = [];
	
	level.globalHUD = 0;
	
	level.callbackLastManStanding = ::lastManStanding;
	
	precache();
}

precache()
{
	precachestring(&"ZOMBIE_PROMOTION");
	precachestring(&"ZOMBIE_STREAK");
	
	precachestring(&"ZOMBIE_NEWWAVE0");
	precachestring(&"ZOMBIE_NEWWAVE1");
	precachestring(&"ZOMBIE_NEWWAVE2");
	precachestring(&"ZOMBIE_NEWBOSSWAVE");
	precachestring(&"ZOMBIE_SCARYWAVE");
	precachestring(&"ZOMBIE_SCARYWAVE_AFTER0");
	precachestring(&"ZOMBIE_SCARYWAVE_AFTER1");
	precachestring(&"ZOMBIE_SCARYWAVE_AFTER2");
	
	precachestring(&"ZOMBIE_BOSS_CATCHED_FIRE");
	precachestring(&"ZOMBIE_BOSS_EXPLOSIVES0");
	precachestring(&"ZOMBIE_BOSS_EXPLOSIVES1");
	precachestring(&"ZOMBIE_BOSS_EXPLOSIVES2");
	precachestring(&"ZOMBIE_BOSS_KNIFE0");
	precachestring(&"ZOMBIE_BOSS_KNIFE1");
	precachestring(&"ZOMBIE_BOSS_KNIFE2");
	precachestring(&"ZOMBIE_BOSS_GUNS0");
	precachestring(&"ZOMBIE_BOSS_GUNS1");
	precachestring(&"ZOMBIE_BOSS_GUNS2");

	precachestring(&"ZOMBIE_AVAILABLE_SKILLPOINTS");
	precachestring(&"ZOMBIE_LAST_MAN_STANDING");
	precachestring(&"ZOMBIE_SURV_LEFT");
	precachestring(&"ZOMBIE_SURV_DOWN");
	
	precachestring(&"MAPVOTE_WAIT4VOTES");
	precachestring(&"MAPVOTE_PRESSFIRE");

	precachestring(&"USE_GETWEAPON");
	precachestring(&"USE_UPGRADEWEAPON");
	precachestring(&"USE_GETAMMO");
	precachestring(&"USE_BUYUPGRADES");
	precachestring(&"USE_REBUILDBARRIER");
	precachestring(&"USE_REVIVE");
	precachestring(&"USE_CURE");
	precachestring(&"USE_PORTAL");
	precachestring(&"USE_TURRET");
	
	precachestring(&"LAST_CHANCE_TIMER");
	
	precachestring(&"FINALE_0_0");
	precachestring(&"FINALE_0_1");
	precachestring(&"FINALE_0_2");
	precachestring(&"FINALE_0_3");
	precachestring(&"FINALE_0_4");
	precachestring(&"FINALE_0_5");
	precachestring(&"FINALE_0_6");
	precachestring(&"FINALE_0_7");
	
	precachestring(&"FINALE_1_0");
	precachestring(&"FINALE_1_1");
	precachestring(&"FINALE_1_2");
	precachestring(&"FINALE_1_3");
	precachestring(&"FINALE_1_4");
	precachestring(&"FINALE_1_5");
	precachestring(&"FINALE_1_6");
	precachestring(&"FINALE_1_7");
	
	precachestring(&"FINALE_2_0");
	precachestring(&"FINALE_2_1");
	precachestring(&"FINALE_2_2");
	precachestring(&"FINALE_2_3");
	precachestring(&"FINALE_2_4");
	precachestring(&"FINALE_2_5");
	precachestring(&"FINALE_2_6");
	precachestring(&"FINALE_2_7");
	
	precachestring(&"FINALE_3_0");
	precachestring(&"FINALE_3_1");
	precachestring(&"FINALE_3_2");
	precachestring(&"FINALE_3_3");
	precachestring(&"FINALE_3_4");
	precachestring(&"FINALE_3_5");
	precachestring(&"FINALE_3_6");
	precachestring(&"FINALE_3_7");
	
	
	
	precachestring(&"+&&1");
	precachestring(&"&&1");
	
	
	
	precacheShader("overlay_low_health");
	precacheShader("progress_bar_fill");
	precacheshader("hud_weapons");
	precacheshader("hud_ammo");
	precacheshader("healthcross");
	precacheshader("lightning_icon");
	
	precacheShader("icon_ammobox_radar");
	precacheShader("icon_medkit_radar");
	
	lableArrays();
}

lableArrays(){

	level.announceNormal = [];
	
	level.announceNormal[level.announceNormal.size] = &"ZOMBIE_NEWWAVE0";
	level.announceNormal[level.announceNormal.size] = &"ZOMBIE_NEWWAVE1";
	level.announceNormal[level.announceNormal.size] = &"ZOMBIE_NEWWAVE2";
	
	level.finaleLables = [];
	
	level.finaleLables[0][0] = &"FINALE_0_0";
	level.finaleLables[0][1] = &"FINALE_0_1";
	level.finaleLables[0][2] = &"FINALE_0_2";
	level.finaleLables[0][3] = &"FINALE_0_3";
	level.finaleLables[0][4] = &"FINALE_0_4";
	level.finaleLables[0][5] = &"FINALE_0_5";
	level.finaleLables[0][6] = &"FINALE_0_6";
	level.finaleLables[0][7] = &"FINALE_0_7";

	level.finaleLables[1][0] = &"FINALE_1_0";
	level.finaleLables[1][1] = &"FINALE_1_1";
	level.finaleLables[1][2] = &"FINALE_1_2";
	level.finaleLables[1][3] = &"FINALE_1_3";
	level.finaleLables[1][4] = &"FINALE_1_4";
	level.finaleLables[1][5] = &"FINALE_1_5";
	level.finaleLables[1][6] = &"FINALE_1_6";
	level.finaleLables[1][7] = &"FINALE_1_7";

	level.finaleLables[2][0] = &"FINALE_2_0";
	level.finaleLables[2][1] = &"FINALE_2_1";
	level.finaleLables[2][2] = &"FINALE_2_2";
	level.finaleLables[2][3] = &"FINALE_2_3";
	level.finaleLables[2][4] = &"FINALE_2_4";
	level.finaleLables[2][5] = &"FINALE_2_5";
	level.finaleLables[2][6] = &"FINALE_2_6";
	level.finaleLables[2][7] = &"FINALE_2_7";

	level.finaleLables[3][0] = &"FINALE_3_0";
	level.finaleLables[3][1] = &"FINALE_3_1";
	level.finaleLables[3][2] = &"FINALE_3_2";
	level.finaleLables[3][3] = &"FINALE_3_3";
	level.finaleLables[3][4] = &"FINALE_3_4";
	level.finaleLables[3][5] = &"FINALE_3_5";
	level.finaleLables[3][6] = &"FINALE_3_6";
	level.finaleLables[3][7] = &"FINALE_3_7";
}

createRadarIcon( shader ){
	// id = level.objectID;
	if(level.objects.size >= 16) return;
	for(i = 0; i < level.objects.size; i++)
		if( !isDefined(level.objects[i]) )
			break;
			
	self.id = i;
	level.objects[i] = self;
	
	Objective_Add( self.id, "active", self.origin, shader );
	// Objective_OnEntity(self.id, level.players[0]);
	
	self thread removeRadarIconOnDeath();
}

removeRadarIconOnDeath(){
	self waittill("death");
	
	level.objects[self.id] = undefined;
	
	objective_delete(self.id);
}

createTeamObjpoint( origin, shader, alpha )
{
	objPoint = newHudElem();
	
	objPoint.x = origin[0];
	objPoint.y = origin[1];
	objPoint.z = origin[2];
	objPoint.isFlashing = false;
	objPoint.isShown = true;
	
	objPoint setShader( shader, 8, 8 );
	objPoint setWaypoint( true );
	
	if ( isDefined( alpha ) )
		objPoint.alpha = alpha;
	else
		objPoint.alpha = 1;
		
	objPoint.baseAlpha = objPoint.alpha;
	
	return objPoint;
}

createHeadiconKits( origin, shader, alpha )
{
	objPoint = newHudElem();
	
	objPoint.x = origin[0];
	objPoint.y = origin[1];
	objPoint.z = origin[2];
	// objPoint.isFlashing = false;
	objPoint.isFlashing = false;
	objPoint.isShown = true;
	
	objPoint setShader( shader, 8, 8 );
	objPoint setWaypoint( true );
	
	if ( isDefined( alpha ) )
		objPoint.alpha = alpha;
	else
		objPoint.alpha = 1;
		
	objPoint.baseAlpha = objPoint.alpha;
	
	self waittill("death");
	
	objPoint destroy();
}

onPlayerConnect()
{
	self.announceHUD = 0;
	self.announceIndex = 0;
	self.announceTotal = 0;
	if ( level.waveHUD ){
		self setclientdvars("ui_wavetext", level.waveHUD_Killed + "/" +  level.waveHUD_Total, "ui_waveprogress", level.waveHUD_Killed / level.waveHUD_Total);
	}
	else
		self setclientdvars("ui_wavetext", "", "ui_waveprogress", 0);
		
	self.hud_message = NewClientHudElem(self);
	self.hud_message.alpha = 0;
	self.welcome_message = NewClientHudElem(self);
	self.welcome_message.alpha = 0;
	self.hud_overlay = [];
	self.hud_timers = [];
	
	/* Usables hinttext */
	self.hinttext = newClientHudElem(self);
	self.hinttext.archived = false;
	self.hinttext.x = 0;
	self.hinttext.alignX = "center";
	self.hinttext.alignY = "middle";
	self.hinttext.horzAlign = "center_safearea";
	self.hinttext.vertAlign = "top";
	self.hinttext.sort = 1; // force to draw after the bars
	self.hinttext.font = "objective";
	self.hinttext.foreground = true;
	self.hinttext.y = 300;
	self.hinttext.fontscale = 1.4;
	self.hinttext.alpha = 0;
}

healthFeedback(){

	self endon("disconnect");
	
	if( !isDefined( self.lastHealthFeedback ) ) // Don't add too many client hudelements or display will get bugged
		self.lastHealthFeedback = getTime();
	else if( self.lastHealthFeedback + 300 > getTime() )
		return;
	else
		self.lastHealthFeedback = getTime();
	
	healthcross = NewClientHudElem(self);
	
	healthcross.alpha = 0;
	healthcross.x = 104;
	healthcross.y = -108;
	healthcross.hideWhenInMenu = false;
	healthcross.alignX = "left";
	healthcross.alignY = "bottom";
	healthcross.horzAlign = "left";
	healthcross.vertAlign = "bottom";
	healthcross.archived = false;
	healthcross setShader("healthcross", 20, 20);
	direction = -30 + randomint(50);
	
	
	healthcross FadeOverTime(.5);
	healthcross.alpha = 1;
	
	healthcross MoveOverTime(1.5);
	healthcross.x += cos(direction)*48;
	healthcross.y += sin(direction)*40;
	wait 1.3;
	healthcross FadeOverTime(.3);
	healthcross.alpha = 0;
	wait .3;
	healthcross destroy();

}

specialRechargeFeedback(){

	self endon("disconnect");
	
	if( !isDefined( self.lastSpecialRechargeFeedback ) )  // Don't add too many client hudelements or display will get bugged
		self.lastSpecialRechargeFeedback = getTime();
	else if( self.lastSpecialRechargeFeedback + 300 > getTime() )
		return;
	else
		self.lastSpecialRechargeFeedback = getTime();
	
	lightning_icon = NewClientHudElem(self);
	lightning_icon.alpha = 0;
	lightning_icon.x = 104;
	lightning_icon.y = -92;
	lightning_icon.hideWhenInMenu = false;
	lightning_icon.alignX = "left";
	lightning_icon.alignY = "bottom";
	lightning_icon.horzAlign = "left";
	lightning_icon.vertAlign = "bottom";
	lightning_icon.archived = false;
	lightning_icon setShader("lightning_icon", 20, 20);
	direction = -30 + randomint(50);
	
	
	lightning_icon FadeOverTime(.5);
	lightning_icon.alpha = 1;
	
	lightning_icon MoveOverTime(1.5);
	lightning_icon.x += cos(direction)*48;
	lightning_icon.y += sin(direction)*40;
	wait 1.3;
	lightning_icon FadeOverTime(.3);
	lightning_icon.alpha = 0;
	wait .3;
	lightning_icon destroy();

}


addTimer(label, string, time)
{
	if( !isDefined( time ) || time < 1 )
		return;

	self endon("death");
	self endon("disconnect");
	
	timer = spawnstruct();
	timer.id = self.hud_timers.size;
	self.hud_timers[timer.id] = timer;
	timer.hud_timer = newClientHudElem(self);
	timer.hud_timer.font = "default";
	timer.hud_timer.fontscale = 1.4;
	timer.hud_timer.x = -16;
	timer.hud_timer.y = -48-timer.id*32;
	timer.hud_timer.glowAlpha = 1;
	timer.hud_timer.hideWhenInMenu = false;
	timer.hud_timer.archived = true;
	timer.hud_timer.alignX = "right";
	timer.hud_timer.alignY = "bottom";
	timer.hud_timer.horzAlign = "right";
	timer.hud_timer.vertAlign = "bottom";
	timer.hud_timer.alpha = 1;
	timer.hud_timer.glowAlpha = 0;
	timer.hud_timer.glowColor = (1,1,0);
	timer.hud_timer SetTimer(time);
	
	timer.hud_timertext = newClientHudElem(self);
	timer.hud_timertext.elemType = "font";
	timer.hud_timertext.font = "default";
	timer.hud_timertext.fontscale = 1.4;
	timer.hud_timertext.x = -16;
	timer.hud_timertext.y = -64-timer.id*32;
	timer.hud_timertext.glowAlpha = 1;
	timer.hud_timertext.hideWhenInMenu = false;
	timer.hud_timertext.archived = true;
	timer.hud_timertext.alignX = "right";
	timer.hud_timertext.alignY = "bottom";
	timer.hud_timertext.horzAlign = "right";
	timer.hud_timertext.vertAlign = "bottom";
	timer.hud_timertext.alpha = 1;
	timer.hud_timertext.glowAlpha = 0;
	timer.hud_timertext.glowColor = (1,1,0);
	timer.hud_timertext.label = label;
	timer.hud_timertext setText(string);
	
	wait time;
	if(isDefined(timer.hud_timer))
		timer.hud_timer destroy();
	if(isDefined(timer.hud_timertext))
		timer.hud_timertext destroy();
	
	self.hud_timers = removefromarray(self.hud_timers, timer);
	for (i=0; i<self.hud_timers.size; i++)
	{
		self.hud_timers[i].id = i;
		self.hud_timers[i].hud_timer.y = -48-i*32;
		self.hud_timers[i].hud_timertext.y = -64-i*32;
	}
	
}

removeTimers()
{
	for (i=0; i<self.hud_timers.size; i++)
	{
		if ( isDefined( self.hud_timers[i].hud_timer ) )
			self.hud_timers[i].hud_timer destroy();
		if ( isDefined( self.hud_timers[i].hud_timertext ) )
			self.hud_timers[i].hud_timertext destroy();
	}
	self.hud_timers = [];
}

bar(color, initial, y)
{
	self endon("disconnect");
		
	self.bar_bg = newClientHudElem( self );
	self.bar_fg = newClientHudElem( self );
	
	self.bar_bg endon("death");
	
	width = 128;
	height = 7;
	
	if (!isdefined(y))
		y = 0;
	
	self.bar_bg.x = -0.5 * width - 2;
	self.bar_bg.y = y;
	self.bar_bg.sort = -2;
	self.bar_bg.width = width;
	self.bar_bg.height = height;
	self.bar_bg.shader = "black";
	self.bar_bg setShader( "black", width + 4, height + 4 );
	self.bar_bg.alignX = "left";
	self.bar_bg.alignY = "middle";
	self.bar_bg.horzAlign = "center";
	self.bar_bg.vertAlign = "middle";
	self.bar_bg.color = (1,1,1);
	self.bar_bg.alpha = 1;
	self.bar_bg.hidden = false;
	
	self.bar_fg.x = -.5*width;
	self.bar_fg.y = y;
	self.bar_fg.sort = -1;
	self.bar_fg.width = width;
	self.bar_fg.height = height;
	self.bar_fg.shader = "white";
	self.bar_fg setShader( "white", initial * width, height );
	self.bar_fg.alignX = "left";
	self.bar_fg.alignY = "middle";
	self.bar_fg.horzAlign = "center";
	self.bar_fg.vertAlign = "middle";
	self.bar_fg.color = color;
	self.bar_fg.alpha = 1;
	self.bar_fg.hidden = false;
	

}

bar_setscale(scale, color)
{
	if (isdefined(self.bar_fg))
	{
		self.bar_fg ScaleOverTime(1, int(self.bar_fg.width*scale), self.bar_fg.height);
		if (isdefined(color))
		self.bar_fg.color = color;
	}
}

progressBar(time)
{
	self endon("disconnect");
		
	self.bar_bg = newClientHudElem( self );
	self.bar_fg = newClientHudElem( self );
	
	self.bar_bg endon("death");
	
	width = 128;
	height = 7;
	
	self.bar_bg.x = -.5*width-2;
	self.bar_bg.y = 0;
	self.bar_bg.sort = -2;
	self.bar_bg.width = width;
	self.bar_bg.height = height;
	self.bar_bg.shader = "black";
	self.bar_bg setShader( "black", width + 4, height + 4 );
	self.bar_bg.alignX = "left";
	self.bar_bg.alignY = "middle";
	self.bar_bg.horzAlign = "center";
	self.bar_bg.vertAlign = "middle";
	self.bar_bg.color = (1,1,1);
	self.bar_bg.alpha = 1;
	self.bar_bg.hidden = false;
	
	self.bar_fg.x = -.5*width;
	self.bar_fg.y = 0;
	self.bar_fg.sort = -1;
	self.bar_fg.width = width;
	self.bar_fg.height = height;
	self.bar_fg.shader = "white";
	self.bar_fg setShader( "white", 0, height );
	self.bar_fg.alignX = "left";
	self.bar_fg.alignY = "middle";
	self.bar_fg.horzAlign = "center";
	self.bar_fg.vertAlign = "middle";
	self.bar_fg.color = (1,1,1);
	self.bar_fg.alpha = 1;
	self.bar_fg.hidden = false;
	self.bar_fg ScaleOverTime(time, width, height);
	
	wait time;
	
	self.bar_fg destroy();
	self.bar_bg destroy();
	
}

timer(time, label, glowcolor, text, height, value)
{
	level endon("game_ended");
	level.globalHUD = 1;
	if (time < 2)
	time = 2;
	if( !isDefined(height) )
		height = 84;
	
	hud_timer = newHudElem();
	hud_timer.font = "objective";
	hud_timer.fontscale = 1.8;
	hud_timer.x = 0;
	hud_timer.y = height;
	hud_timer.glowAlpha = 1;
	hud_timer.hideWhenInMenu = false;
	hud_timer.archived = true;
	hud_timer.alignX = "center";
	hud_timer.alignY = "middle";
	hud_timer.horzAlign = "center";
	hud_timer.vertAlign = "top";
	hud_timer.alpha = 0;
	hud_timer.glowAlpha = 1;
	hud_timer.glowColor = glowcolor;
	hud_timer SetTimer(time);
	
	hud_timertext = newHudElem();
	hud_timertext.elemType = "font";
	hud_timertext.font = "objective";
	hud_timertext.fontscale = 1.8;
	hud_timertext.x = 0;
	hud_timertext.y = height - 20;
	hud_timertext.glowAlpha = 1;
	hud_timertext.hideWhenInMenu = false;
	hud_timertext.archived = true;
	hud_timertext.alignX = "center";
	hud_timertext.alignY = "middle";
	hud_timertext.horzAlign = "center";
	hud_timertext.vertAlign = "top";
	hud_timertext.alpha = 0;
	hud_timertext.glowAlpha = 1;
	hud_timertext.glowColor = glowcolor;
	hud_timertext.label = label;
	if (isdefined(text))
		hud_timertext setText(text);
	if(isDefined(value))
		hud_timertext setValue(int(value));
	
	hud_timertext FadeOverTime(1);
	hud_timertext.alpha = 1;
	hud_timer FadeOverTime(1);
	hud_timer.alpha = 1;
	
	hud_timer thread destroyTimerOnGameEnd();
	hud_timertext thread destroyTimerOnGameEnd();
	
	wait time -.5 ;
	
	hud_timer setPulseFX( 0, 0, 1000 );
	hud_timertext setPulseFX( 0, 0, 1000 );
	
	wait .5;
	
	hud_timer notify("destroyed_my_hud");
	hud_timertext notify("destroyed_my_hud");
	hud_timer destroy();
	hud_timertext destroy();
	
	level.globalHUD = 0;
	level notify("hud_global_done");
	
}

destroyTimerOnGameEnd(){
	self endon("destroyed_my_hud");
	level waittill("game_ended");
	self destroy();
}

/* To be shown when at least 3 players are on the server and only one is alive */
lastManStanding(){
	self endon("disconnect");
	
	if( self.isDown )
		return;
	
	self thread scripts\include\hud::screenFlash( (1, 0, 0), 1, 0.4);
	
	self.lastManStanding_message = NewClientHudElem(self);
	self.lastManStanding_message.elemType = "font";
	self.lastManStanding_message.font = "objective";
	self.lastManStanding_message.fontscale = 3;
	self.lastManStanding_message.x = 0;
	self.lastManStanding_message.y = -128;
	self.lastManStanding_message.glowAlpha = 1;
	self.lastManStanding_message.hideWhenInMenu = true;
	self.lastManStanding_message.archived = false;
	self.lastManStanding_message.alignX = "center";
	self.lastManStanding_message.alignY = "middle";
	self.lastManStanding_message.horzAlign = "center";
	self.lastManStanding_message.vertAlign = "bottom";
	self.lastManStanding_message.alpha = 0;
	self.lastManStanding_message.color = (2, 0, 0);
	self.lastManStanding_message.glowAlpha = 1;
	self.lastManStanding_message.glowColor = (.7, .4, .4);
	self.lastManStanding_message.label = &"ZOMBIE_LAST_MAN_STANDING";
	self playlocalsound("last_man_standing");
	self.lastManStanding_message thread increaseFontSize(1.4, 3.5, 0.1);
	self.lastManStanding_message fadeOverTime(1);
	self.lastManStanding_message.alpha = 1;
	wait 3;
	self.lastManStanding_message fadeOverTime(1);
	self.lastManStanding_message.alpha = 0;
	wait 1;
	self.lastManStanding_message destroy();
}

increaseFontSize(start, end, stepsize){
	self endon("death");
	
	if( start < 1.4 )
		start = 1.4;
		
	if( end > 4.8 )
		end = 4.8;
	
	for( i = start; i < end; i += stepsize ){
		self.fontscale = i;
		wait 0.05;
	}
}

glowMessage(label, text, glowcolor, duration, speed, size, sound, height)
{
	self endon("disconnect");
	
	while(level.globalHUD)
	{
		level waittill("hud_global_done");
		wait .5;
	}
	if (self.announceHUD)
	{
		self.announceTotal++;
		index = self.announceTotal;
		
		while (1)
		{
			self waittill("hud_announce_done");
			if (index == self.announceIndex)
			{
				self.announceHUD = 1;
				break;
			}
		}
	}
	else
	self.announceHUD = 1;
	
	if (isdefined(sound))
	self playlocalsound(sound);
	if(!isDefined(height))
		height = 64;
	else
		height = 64 + height;
	showGlowMessage(label, text, glowcolor, duration, speed, size, height);
	wait duration;
	self.announceHUD  = 0;
	self.announceIndex ++;
	self notify("hud_announce_done");
}

welcomeMessage(label, text, glowcolor, duration, speed, size, sound, height)
{
	self endon("disconnect");
	
	if(!isDefined(height))
	height = 64;
	
	showWelcomeMessage(label, text, glowcolor, duration, speed, size, height);
	wait duration;
}

overlayMessage(label, text, glowcolor, size)
{
	hud_message = newHudElem();
	hud_message.elemType = "font";
	hud_message.font = "objective";
	if (!isdefined(size))
	hud_message.fontscale = 2;
	else
	hud_message.fontscale = size;
	hud_message.x = 0;
	hud_message.y = 96;
	hud_message.glowAlpha = 1;
	hud_message.hideWhenInMenu = true;
	hud_message.archived = false;
	hud_message.alignX = "center";
	hud_message.alignY = "middle";
	hud_message.horzAlign = "center";
	hud_message.vertAlign = "top";
	hud_message.alpha = 1;
	hud_message.glowAlpha = 1;
	hud_message.glowColor = glowcolor;
	hud_message.label = label;
	if (isdefined(text))
	hud_message setText( text );
	
	return hud_message;
}

showGlowMessage(label, text, glowcolor, duration, speed, size, height)
{
	
	self.hud_message.elemType = "font";
	self.hud_message.font = "objective";
	
	if (!isdefined(size))
		self.hud_message.fontscale = 2;
	else
		self.hud_message.fontscale = size;
		
	self.hud_message.x = 0;
	self.hud_message.y = height;
	self.hud_message.glowAlpha = 1;
	self.hud_message.hideWhenInMenu = true;
	self.hud_message.archived = false;
	self.hud_message.alignX = "center";
	self.hud_message.alignY = "middle";
	self.hud_message.horzAlign = "center";
	self.hud_message.vertAlign = "top";
	self.hud_message.alpha = 1;
	self.hud_message.glowAlpha = 1;
	self.hud_message.glowColor = glowcolor;
	self.hud_message.label = label;
	if (isdefined(text))
	self.hud_message setText( text );

	self.hud_message setPulseFX( speed, int((duration)*1000), 1000 );
	
}

showFinaleMessage(label, text, glowcolor, duration, speed, size)
{
	
	self.hud_message.elemType = "font";
	self.hud_message.font = "objective";
	
	if (!isdefined(size))
		self.hud_message.fontscale = 2;
	else
		self.hud_message.fontscale = size;
		
	self.hud_message.x = 0;
	self.hud_message.y = 0;
	self.hud_message.glowAlpha = 1;
	self.hud_message.hideWhenInMenu = false;
	self.hud_message.archived = true;
	self.hud_message.alignX = "center";
	self.hud_message.alignY = "middle";
	self.hud_message.horzAlign = "center";
	self.hud_message.vertAlign = "middle";
	self.hud_message.alpha = 1;
	self.hud_message.glowAlpha = 1;
	self.hud_message.glowColor = glowcolor;
	self.hud_message.label = label;
	if (isdefined(text))
	self.hud_message setText( text );

	self.hud_message setPulseFX( speed, int((duration)*1000), 1000 );
	
}

showWelcomeMessage(label, text, glowcolor, duration, speed, size, height)
{
	
	self.welcome_message.elemType = "font";
	self.welcome_message.font = "objective";
	
	if (!isdefined(size))
		self.welcome_message.fontscale = 2;
	else
		self.welcome_message.fontscale = size;
		
	self.welcome_message.x = 0;
	self.welcome_message.y = height;
	self.welcome_message.glowAlpha = 1;
	self.welcome_message.hideWhenInMenu = true;
	self.welcome_message.archived = false;
	self.welcome_message.alignX = "center";
	self.welcome_message.alignY = "middle";
	self.welcome_message.horzAlign = "center";
	self.welcome_message.vertAlign = "top";
	self.welcome_message.alpha = 1;
	self.welcome_message.glowAlpha = 1;
	self.welcome_message.glowColor = glowcolor;
	self.welcome_message.label = label;
	if (isdefined(text))
	self.welcome_message setText( text );

	self.welcome_message setPulseFX( speed, int((duration)*1000), 1000 );
	
}