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

init()
{
	precacheShader("damage_feedback");
	precacheShader("icon_turret_hit");

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

		player.hud_damagefeedback_normal = newClientHudElem(player);
		player.hud_damagefeedback_normal.horzAlign = "center";
		player.hud_damagefeedback_normal.vertAlign = "middle";
		player.hud_damagefeedback_normal.x = -12;
		player.hud_damagefeedback_normal.y = -12;
		player.hud_damagefeedback_normal.alpha = 0;
		player.hud_damagefeedback_normal.archived = true;
		player.hud_damagefeedback_normal setShader("damage_feedback", 24, 48);

		player.hud_damagefeedback_turret = newClientHudElem(player);
		player.hud_damagefeedback_turret.horzAlign = "center";
		player.hud_damagefeedback_turret.vertAlign = "middle";
		player.hud_damagefeedback_turret.x = -47/2;
		player.hud_damagefeedback_turret.y = 20;
		player.hud_damagefeedback_turret.alpha = 0;
		player.hud_damagefeedback_turret.archived = true;
		player.hud_damagefeedback_turret setShader("icon_turret_hit", 47, 20);
	}
}

updateDamageFeedbackSound()
{
		if ( !isPlayer( self ) )
		return;
		
		self playlocalsound("MP_hit_alert");
} 

updateDamageFeedback( )
{
	if ( !isPlayer( self ) )
		return;
		
	self.hud_damagefeedback_normal setShader("damage_feedback", 24, 48);
	self playlocalsound("MP_hit_alert");
	
	self.hud_damagefeedback_normal.alpha = 1;
	self.hud_damagefeedback_normal fadeOverTime(1);
	self.hud_damagefeedback_normal.alpha = 0;
}

updateTurretDamageFeedback( )
{
	if ( !isPlayer( self ) )
		return;
		
	self.hud_damagefeedback_turret setShader("icon_turret_hit", 47, 20);
	
	self.hud_damagefeedback_turret.alpha = 0.8;
	self.hud_damagefeedback_turret fadeOverTime(1);
	self.hud_damagefeedback_turret.alpha = 0;
}