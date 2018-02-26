/**
* vim: set ft=cpp:
* file: scripts\players\_damagefeedback.gsc
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
		if (!isPlayer(self))
		return;
		
		self playlocalsound("MP_hit_alert");
} 

updateDamageFeedback()
{
	if (!isPlayer(self))
		return;
		
	self.hud_damagefeedback_normal setShader("damage_feedback", 24, 48);
	self playlocalsound("MP_hit_alert");
	
	self.hud_damagefeedback_normal.alpha = 1;
	self.hud_damagefeedback_normal fadeOverTime(1);
	self.hud_damagefeedback_normal.alpha = 0;
}

updateTurretDamageFeedback()
{
	if (!isPlayer(self))
		return;
		
	self.hud_damagefeedback_turret setShader("icon_turret_hit", 47, 20);
	
	self.hud_damagefeedback_turret.alpha = 0.8;
	self.hud_damagefeedback_turret fadeOverTime(1);
	self.hud_damagefeedback_turret.alpha = 0;
}