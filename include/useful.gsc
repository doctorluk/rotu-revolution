freezePlayerForRoundEnd()
{	
	self closeMenu();
	self closeInGameMenu();
	
	self freezeControls( true );
}

unfreezePlayerForRoundEnd()
{	
	self closeMenu();
	self closeInGameMenu();
	
	self freezeControls( false );
}

isReallyPlaying(player){
	if( !isDefined( player ) )
		return false;
	
	if(player.sessionstate != "playing" || !player.isActive || player.sessionteam != "allies")
		return false;
		
	return true;
}