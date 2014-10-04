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
#include scripts\include\hud;
#include scripts\include\useful;
#include common_scripts\utility;

lastChanceMain(){
	/* Do not start Last Chance if we had it already */
	if( isDefined( level.lastChance ) )
		return false;
	/* See if we can start Last Chance */
	buildLastChanceRequirement();
	if( !level.lastChance )
		return false;

	prepareLastChance();
	/* Building the HUD display for each player */
	/* START LAST CHANCE INPUT HERE */
	startLastChancePlayers();
	
	/* Start ambient sound */
	scripts\server\_environment::setAmbient("ambient_last_stand", 0, 0);
	level.silenceZombies = true;
	// thread test();
	/* Add timer display, WAIT 10 SECONDS */
	scripts\gamemodes\_hud::timer(10, &"LAST_CHANCE_TIMER", (1,0,0), undefined, 120);
	
	/* After resurrection etc. */
	level.silenceZombies = false;
	if( level.resurrectPeople.size > 0 ){
		postLastChance();
		level notify("delete_last_chance_hud");
		level notify("last_chance_end");
		
		// wait 0.05;
		return true;
	}
	else{
		ambientStop(0);
		// iprintlnbold("Not enough upgradepoints available, no resurrection by erection! (lol)");
		level notify("delete_last_chance_hud");
		wait 3;
		level notify("last_chance_failed");
		level notify("last_chance_end");
		return false;
	}
}

buildLastChanceRequirement(){
	level.lastChance = true;
	
	if( level.currentWave < level.dvar["surv_phoenix_minwave"] || level.activePlayers < level.dvar["surv_phoenix_minplayers"] ){
	// if(level.currentWave <= 0 || level.activePlayers <= 0){
		level.lastChance = false;
		return;
	}
	
	/* Increase the percentage of required points by 3% each 2 waves passed */
	waves = int(level.currentWave / level.dvar["surv_phoenix_wave_stepsize"]);
	requirement = level.dvar["surv_phoenix_base_percentage"] + (waves * level.dvar["surv_phoenix_wave_percentage"]);
	
	/* We should not get over 80% of points earned */
	if(requirement > 0.8)
		requirement = 0.8;
		
	/*  */
	level.lastChance_toPay = int(requirement * scripts\players\_players::getAverageUpgradePoints());
	iprintln("Required points for every person: " + level.lastChance_toPay);
	createLCArrays();
	level.resurrectPeople = [];
}

/* We have two arrays which are filled with players who can or can't pay the Death Fee */
/* The players with enough points to resurrect himself AND another player is being put in level.canPayMultipleLC */
/* The players with not enough points are put into level.cantPayLC */
createLCArrays(){
	// doWait = false;
	level.canPayMultipleLC = [];
	level.cantPayLC = [];
	
	for(i = 0; i < level.players.size; i++){
		p = level.players[i];
		if( !isReallyPlaying(p) ) // If player is not actually playing, we don't look if he has enough points etc.
			continue;
			
		if( p.infected ) p scripts\players\_infection::cureInfection();
		// if( p.isZombie ){ p suicide(); doWait = true;}

		if( p.points < level.lastChance_toPay ) // Put into according arrays
			level.cantPayLC[level.cantPayLC.size] = p;
		else if( p.points >= 2 * level.lastChance_toPay )
			level.canPayMultipleLC[level.cantPayLC.size] = p;
	}
	// if(doWait) wait 1;
}

prepareLastChance(){
	/* Start gameplay-specific tasks..... stop ambient, stop turrets etc. */
	scripts\server\_environment::stopAmbient(1);
	level.turretsDisabled = 1;
	level.spawningDisabled = 1;
	if( isDefined( level.bossOverlay ) ){
		level.bossOverlay fadeOverTime(2);
		level.bossOverlay.alpha = 0;
	}
	level notify("last_chance_start");
	
	/* Freezing players and removing HUD elements, start greyout vision */
	for(i = 0; i < level.players.size; i++){
		player = level.players[i];
		if( !isReallyPlaying(player) || player.isZombie )
			continue;
		player closeMenu();
		player closeInGameMenu();
		player freezePlayerForRoundEnd();
		player setclientdvar("ui_hud_hardcore", 1);
	}
	thread scripts\server\_environment::setBlur(5, 4);
	VisionSetNaked("greyvision", 4);
	wait 4;
}

startLastChancePlayers(){
	for(i = 0; i < level.players.size; i++){
		player = level.players[i];
		if( !isReallyPlaying( player ) || player.isZombie )
			continue;
		player thread lcHud();
	}
}

postLastChance(){
	ambientStop(0);
	scripts\server\_environment::setAmbient(level.ambient, 0, 1);
	iprintln("The players have managed to get enough points to resurrect!");
	
	scripts\server\_environment::setVision(level.vision, 3);
	/* Kill all zombies before reviving them */
	for( i = 0; i < level.bots.size; i++ ){
		bot = level.bots[i];
		if( bot.sessionstate == "playing" && bot.type != "boss" )
			bot suicide();
	}
	playSoundOnAllPlayers("phoenix");
	wait 1;
	for ( i = 0; i < level.players.size; i++ ) {
		player = level.players[i];
		
		if( arrayContains(level.resurrectPeople, player) ){
			level.resurrectPeople = removeFromArray(level.resurrectPeople, player);
			if( !isReallyPlaying(player) )
				continue;
			if ( player.isDown && !player.isBot && !player.isZombie ){
				player thread reviveEffects();
				player thread scripts\players\_players::revive();
			}
		}
		else if( isReallyPlaying(player) && !player.isZombie )
			player thread scripts\players\_infection::goInfected();
	}
	
	for(i = 0; i < level.players.size; i++){
		player = level.players[i];
		player closeMenu();
		player closeInGameMenu();
		player unfreezePlayerForRoundEnd();
		player setclientdvar("ui_hud_hardcore", 0);
	}
	
	thread scripts\server\_environment::setBlur(scripts\bots\_types::getBlurForType(level.currentType), 3);
	level.resurrectPeople = undefined;
	level.lastChance = false;
	
	if( isDefined( level.bossOverlay ) )
		level.bossOverlay thread fadein(1);
		
	thread scripts\gamemodes\_survival::watchEnd();
	thread scripts\players\_players::updateActiveAliveCounts();
	if(level.currentType != "scary")
		level.turretsDisabled = 0;
	level.spawningDisabled = 0;
}

reviveEffects(){
	self endon("death");
	self endon("disconnect");
	visionSetNaked("last_chance_revive", 0.2);
	wait 0.8;
	scripts\server\_environment::setVision(level.vision, 4);
}

lcHud(){
	if(self.points >= level.lastChance_toPay)
		self thread buildLCHud_canPay();
	else
		self thread buildLCHud_cantPay();
}

buildLCHud_cantPay(){
		/* BOT CANT PAY &&1 */
	self.lastChance_cantpay1 = newClientHudElem(self);
	self.lastChance_cantpay1.archived = true;
	self.lastChance_cantpay1.x = 0;
	self.lastChance_cantpay1.alignX = "center";
	self.lastChance_cantpay1.alignY = "middle";
	self.lastChance_cantpay1.horzAlign = "center_safearea";
	self.lastChance_cantpay1.vertAlign = "top";
	self.lastChance_cantpay1.sort = 1; // force to draw after the bars
	self.lastChance_cantpay1.font = "objective";
	self.lastChance_cantpay1.foreground = true;
	self.lastChance_cantpay1.y = 290;
	self.lastChance_cantpay1.fontscale = 1.4;
	self.lastChance_cantpay1.alpha = 1;
	self.lastChance_cantpay1.label = &"LAST_CHANCE_SPEND_AMOUNT_CANT_PAY";
	self.lastChance_cantpay1 setText( int(level.lastChance_toPay) );
	self.lastChance_cantpay1.owner = self;
	self.lastChance_cantpay1 thread destroyOnLCEnd();	
	self.lastChance_cantpay1 thread destroyOnPaid();	
}

buildLCHud_canpay(){
	if(isDefined(self.hinttext) && self.hinttext.alpha != 0)
		self.hinttext.alpha = 0;
	
	self.lastChanceTarget = self;
	
	/* TOP TOTAL REQUIRED */
	self.lastChance_top = newClientHudElem(self);
	self.lastChance_top.archived = true;
	self.lastChance_top.x = 0;
	self.lastChance_top.alignX = "center";
	self.lastChance_top.alignY = "middle";
	self.lastChance_top.horzAlign = "center_safearea";
	self.lastChance_top.vertAlign = "top";
	self.lastChance_top.sort = 1; // force to draw after the bars
	self.lastChance_top.font = "objective";
	self.lastChance_top.foreground = true;
	self.lastChance_top.y = 190;
	self.lastChance_top.fontscale = 1.4;
	self.lastChance_top.alpha = 1;
	self.lastChance_top.label = &"LAST_CHANCE_SPEND_AMOUNT";
	self.lastChance_top setText( int(level.lastChance_toPay) );
	self.lastChance_top.owner = self;
	self.lastChance_top thread destroyOn();
	self.lastChance_top thread destroyOnLCEnd();
	
	/* HINT TEXT HOW TO SPEND "FIRE" */
	self.lastChance_botFire = newClientHudElem(self);
	self.lastChance_botFire.archived = true;
	self.lastChance_botFire.x = 0;
	self.lastChance_botFire.alignX = "center";
	self.lastChance_botFire.alignY = "middle";
	self.lastChance_botFire.horzAlign = "center_safearea";
	self.lastChance_botFire.vertAlign = "top";
	self.lastChance_botFire.sort = 1; // force to draw after the bars
	self.lastChance_botFire.font = "objective";
	self.lastChance_botFire.foreground = true;
	self.lastChance_botFire.y = 290;
	self.lastChance_botFire.fontscale = 1.4;
	self.lastChance_botFire.alpha = 1;
	self.lastChance_botFire.label = &"LAST_CHANCE_SPEND_FIRE_YOURSELF";
	self.lastChance_botFire.owner = self;
	self.lastChance_botFire thread destroyOn();
	self.lastChance_botFire thread destroyOnLCEnd();
	
	self thread updateSpentPoints();
}

reportRevive(){
	if( !isDefined(self) || !isDefined(self.lastChanceTarget) )
		return;
		
	if(self == self.lastChanceTarget)
		iprintln(self.name + " has payed for himself!");
	else
		iprintln(self.name + " has payed the death fee for " + self.lastChanceTarget.name);
}

isLegitLCTarget(player){
	if(!isDefined(player)){
		logPrint("ERROR: The player " + self.name + " tried to revive a person that is not defined!\n");
		iprintlnbold("^1ERROR: ^7Report to Luk:\n^1ERROR IN isLegitLCTarget!");
		return false;
	}
	if(!player.isActive || player.sessionstate != "playing" || player.isZombie)
		return false;
	return true;
}

updateSpentPoints(){
	self endon("disconnect");
	self endon("death");
	level endon("last_chance_end");
	
	haspressedAttack = false;
	while(level.lastChance && isDefined(self.lastChanceTarget) ){
		if(self attackButtonPressed() && !haspressedAttack && self.points >= level.lastChance_toPay){
			haspressedAttack = true;
			/* See if the selected player is on the Server and can be legitimately added to the revives */
			if( self isLegitLCTarget(self.lastChanceTarget) ){
				self iprintln("We had a legit target! -> " + self.lastChanceTarget.name);
				level.resurrectPeople[level.resurrectPeople.size] = self.lastChanceTarget; // You have saved the selected person
				self reportRevive(); // Show revive in bottom left
				self.lastChanceTarget.savior = self;
				self.lastChanceTarget notify("saved_lc");
				self scripts\players\_players::incUpgradePoints(-1 * level.lastChance_toPay);
				self.lastChanceTarget = undefined;
			}
			/* In case we can revive someone else (enough money, enough revivable players left), let's pick someone and set him as target */
			if(self.points >= level.lastChance_toPay && level.cantPayLC.size > 0){
				// It can happen that people leave during the last chance....
				// while(!isDefined(self.lastChanceTarget) && self.points >= level.lastChance_toPay && level.cantPayLC.size > 0){
					// ran = randomint(level.cantPayLC.size);
					// self.lastChanceTarget = level.cantPayLC[ran];
				// }
				if( level.cantPayLC.size > 0 && !isDefined(self.lastChanceTarget)){
					ran = randomint(level.cantPayLC.size);
					self.lastChanceTarget = level.cantPayLC[ran];
					level.cantPayLC = removeFromArray(level.cantPayLC, self.lastChanceTarget);
				}
				
				if( !isDefined(self.lastChanceTarget) ){
					self iprintln("There is nobody left to revive!");
					self notify("stop_lctext");
					break;
				}
				else{
					level.cantPayLC = removeFromArray(level.cantPayLC, self.lastChanceTarget);
					self iprintln("You have another target: " + self.lastChanceTarget.name);
					self.lastChance_botFire setText(self.lastChanceTarget.name);
					self.lastChance_botFire.label = &"LAST_CHANCE_SPEND_FIRE";
					self.lastChance_botFire setText(self.lastChanceTarget.name);
				}
				
				
			}
			else{
				self iprintln("You either don't have enough points to revive someone else or there is nobody left");
				self notify("stop_lctext");
				break;
			}
		}
		else if(!self attackButtonPressed() && haspressedAttack)
			haspressedAttack = false;
		wait 0.05;
	}
}

destroyOn(){
	self endon("disconnect");
	self endon("death");
	self.owner waittill("stop_lctext");
	if(!isDefined(self))
		return;
	self fadeOverTime(1);
	self.alpha = 0;
	wait 1;
	if(isDefined(self))
		self destroy();
}

destroyOnLCEnd(){
	self endon("disconnect");
	self endon("death");
	level waittill_any("last_chance_end", "delete_last_chance_hud");
	if(!isDefined(self))
		return;
	self fadeovertime(1);
	self.alpha = 0;
	wait 1;
	if(isDefined(self))
		self destroy();
}

destroyOnPaid(){
	self endon("disconnect");
	self endon("death");
	self.owner waittill("saved_lc");
	if(!isDefined(self))
		return;
	self.label = &"LAST_CHANCE_YOU_GOT_SAVED_BY";
	self setText( self.owner.savior.name );
}
