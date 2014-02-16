//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.2 by Luk 
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (3 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

freezePlayerForRoundEnd()
{	
	self closeMenu();
	self closeInGameMenu();
	self scripts\players\_usables::usableAbort();
	
	self freezeControls( true );
}

unfreezePlayerForRoundEnd()
{	
	self closeMenu();
	self closeInGameMenu();
	
	self freezeControls( false );
}

reviveActivePlayers(){

	if ( level.dvar["surv_endround_revive"] ) {
	
		revives = 0;
		for ( i = 0 ; i < level.players.size; i++ ) {
			player = level.players[i];
			if( !isReallyPlaying(player) )
				continue;
			if ( player.isDown && !player.isZombie ) {
				player thread scripts\players\_players::revive();
				revives++;
			}
		}
		
		if(revives == 1)
			iprintln(revives + " Player has been auto-^2revived^7!");
		else if (revives > 1)
			iprintln(revives + " Players have been auto-^2revived^7!");
			
	}
}

isReallyPlaying(player){
	if( !isDefined( player ) )
		return false;
	
	if(player.sessionstate != "playing" || !player.isActive || player.sessionteam != "allies")
		return false;
		
	return true;
}