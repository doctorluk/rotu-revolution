//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.5 by Luk 
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

/*-------------------------------
--MAP VOTING--
-------------------------------*/
init()
{
	level.onChangeMap = ::doMapVote;
}

doMapVote()
{	
	prepareMapVote();
		
	level.voting_players = level.players;
	for ( index = 0; index < level.voting_players.size; index++ )
	{
		player = level.voting_players[index];
		player.health = player.maxhealth;
		player suicide();
		player setClientDvars( "r_filmusetweaks", 0, "cg_fovscale", 1 );
		for (iii=0; iii<level.addon_vote_mapCount; iii++)
		{
			player setclientdvar("ui_map"+(iii+1), level.addon_vote_mapnameList[level.addon_vote_mapPicked[iii]]);
			player setclientdvar("ui_map_votes"+(iii+1), 0);
			player setclientdvar("ui_selected", -1);
		}
		player thread playerVote();
		player thread onLeave();
		wait 0.05;
	}
	
	iprintln("Map voting started...  (" + level.addon_vote_time + " seconds)"); 

	wait level.addon_vote_time;
	
	level notify ("vote_ended");
	
	winner = getVoteWinner();
	winningmap = undefined;
	
	winningmap = level.addon_vote_mapList[level.addon_vote_mapPicked[winner]];
	iprintln("Next map: " + level.addon_vote_mapnameList[level.addon_vote_mapPicked[winner]]);
	//setdvar("sv_maprotation", "map " +  level.addon_vote_mapList[level.addon_vote_mapPicked[winner]]);
	
	scripts\server\_maps::changeMap(winningmap);
	
}

getVoteWinner()
{
	countVotes();
	highestVotes = -1;
	winner = 0;
	for (i=0; i<level.addon_vote_mapCount; i++)
	{
		if (highestVotes < level.addon_vote_mapVotes[i])
		{
			highestVotes = level.addon_vote_mapVotes[i];
			winner = i;
		}
	}
	return winner;
}

playerVote()
{
	level endon ("vote_ended");
	self closeMenu();
	self closeInGameMenu();
	self openMenu(game["menu_mapvoting"]);
	self.myVote = -1;
	while (1)
	{
		self waittill("menuresponse", menu, response);
		
		for (i=0; i<level.addon_vote_mapCount; i++) 
		{
			if (response == "vote"+i)
			{
				if (self.myVote >= 0)
				{
					oldvote = self.myVote;
					self.myVote = i;
					//level.addon_vote_mapVotes[self.myVote] -= 1;
					thread updateVotes(oldvote);
					
				}
				else
				{
					self.myVote = i;
				}
				self setclientdvar("ui_selected", i+1);
				
				thread updateVotes(self.myVote);
				break;
			}
		}
	}
}

onLeave()
{
	level endon("vote_ended");
	self waittill("disconnect");
	if (self.myVote >= 0)
	updateVotes(self.myVote);
	
}

updateVotes(i)
{
	level.addon_vote_mapVotes[i] = 0;
	for ( ii = 0; ii < level.voting_players.size; ii++ )
	{
		player = level.voting_players[ii];
		if (isdefined(player.myVote))
		{
			if (player.myVote == i)
			level.addon_vote_mapVotes[i] ++;
		}
	}
	for ( ii = 0; ii < level.voting_players.size; ii++ )
	{
		player = level.voting_players[ii];
		adi = i+1;
		if (isdefined(player))
		player setclientdvar("ui_map_votes"+adi, level.addon_vote_mapVotes[i]);
		wait 0.05;
	}
}

countVotes()
{
	for (i=0; i<level.addon_vote_mapCount; i++)
	{
		level.addon_vote_mapVotes[i] = 0;
	}

	players = level.voting_players;
	for ( ii = 0; ii < players.size; ii++ )
	{
		player = players[ii];
		if (isdefined(player.myVote))
		{
			if (player.myVote >= 0)
			level.addon_vote_mapVotes[player.myVote] ++;
		}
	}
	
	/*for ( ii = 0; ii < players.size; ii++ )
	{
		player = players[ii];
		for (iii=0; iii<level.addon_vote_mapCount + level.dvar["game_mapvote_repeat"]; iii++)
		{
			println(iii);
			player setclientdvar("ui_map_votes"+iii, level.addon_vote_mapVotes[iii]);
		}
		//wait 0.05;
	}*/
	

}

prepareMapVote()
{
	level.addon_vote_mapCount = level.dvar["game_mapvote_count"];
	level.addon_vote_time = level.dvar["game_mapvote_time"];
	
	level.addon_vote_mapList = [];
	level.addon_vote_mapnameList = [];
	index = 1;
	index2 = 0;
	while (getdvar("zom_mapvote_map_" + index) != "")
	{
		val = getdvar("zom_mapvote_map_" + index);
		if (val != getdvar("mapname"))
		{
			level.addon_vote_mapList[index2] = val;
			level.addon_vote_mapnameList[index2] = getdvar("zom_mapvote_mapname_" + index );
			index2 ++;
		}
		index ++;
	}
	availablemapCount = level.addon_vote_mapList.size;
	
	
	
	assert( availablemapCount >=  level.addon_vote_mapCount);
	
	level.addon_vote_mapPicked = [];
	level.addon_vote_mapVotes = [];
	
	
	width = 392;
	height = 32 * (level.addon_vote_mapCount) +  64;
	
	
	randomValues = [];
	for (ii=0; ii < availablemapCount; ii++)
	{
		randomValues[ii] = ii;
	}
	size = randomValues.size;
	for (i=0; i<level.addon_vote_mapCount; i++)
	{
		rI = randomint(size);
		level.addon_vote_mapPicked[i] = randomValues[rI];
		for (iii = rI; iii < size - 1; iii++)
		{
			randomValues[iii] = randomValues[iii + 1];
		}
		size = size - 1;
		level.addon_vote_mapVotes[i] = 0;
	}

	
}
