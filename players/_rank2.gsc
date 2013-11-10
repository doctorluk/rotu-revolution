/**********************************
	---- Reign of the Undead ----
			   v2.0
	
	(Do not copy without permission)
	
	Date: November 2010
	Version: 2.000
	Author: Bipo
		
	© Reign of the Undead Team
************************************/

#include common_scripts\utility;
#include scripts\include\hud;

init()
{
	level.scoreInfo = [];
	level.rankTable = [];

	precacheShader("white");

	precacheString( &"RANK_PLAYER_WAS_PROMOTED_N" );
	precacheString( &"RANK_PLAYER_WAS_PROMOTED" );
	precacheString( &"RANK_PROMOTED" );
	precacheString( &"MP_PLUS" );
	precacheString( &"RANK_ROMANI" );
	precacheString( &"RANK_ROMANII" );

	registerScoreInfo( "kill", 10 );
	registerScoreInfo( "assist0", 1 );
	registerScoreInfo( "assist1", 2 );
	registerScoreInfo( "assist2", 3 );
	registerScoreInfo( "assist3", 5 );
	registerScoreInfo( "assist4", 7 );
	registerScoreInfo( "assist5", 10 );
	registerScoreInfo( "revive", 50 );
	registerScoreInfo( "headshot", 10 );
	registerScoreInfo( "suicide", 0 );
	registerScoreInfo( "teamkill", 0 );
	

	
	registerScoreInfo( "challenge", 250 );

	level.maxRank = int(tableLookup( "mp/rankTable.csv", 0, "maxrank", 1 ));
	level.maxPrestige = int(tableLookup( "mp/rankIconTable.csv", 0, "maxprestige", 1 ));
	
	pId = 0;
	rId = 0;

	for ( pId = 0; pId <= level.maxPrestige; pId++ )
	{
		for ( rId = 0; rId <= level.maxRank; rId++ )
			precacheShader( tableLookup( "mp/rankIconTable.csv", 0, rId, pId+1 ) );
		
			  
	}

	rankId = 0;
	rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
	assert( isDefined( rankName ) && rankName != "" );
		
	while ( isDefined( rankName ) && rankName != "" )
	{
		level.rankTable[rankId][1] = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
		level.rankTable[rankId][2] = tableLookup( "mp/ranktable.csv", 0, rankId, 2 );
		level.rankTable[rankId][3] = tableLookup( "mp/ranktable.csv", 0, rankId, 3 );
		level.rankTable[rankId][7] = tableLookup( "mp/ranktable.csv", 0, rankId, 7 );

		precacheString( tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 ) );

		rankId++;
		rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );		
	}

	level.statOffsets = [];
	level.statOffsets["weapon_assault"] = 290;
	level.statOffsets["weapon_lmg"] = 291;
	level.statOffsets["weapon_smg"] = 292;
	level.statOffsets["weapon_shotgun"] = 293;
	level.statOffsets["weapon_sniper"] = 294;
	level.statOffsets["weapon_pistol"] = 295;
	level.statOffsets["perk1"] = 296;
	level.statOffsets["perk2"] = 297;
	level.statOffsets["perk3"] = 298;

	level.numChallengeTiers	= 10;
	
}

/*doStuff()
{
	wait 5;
	setdvar("logfile", 2);
	println("STARTING...");
		for ( rId = 0; rId <= level.maxRank; rId++ )
		{
			string = "";
			for (iii=0; iii<=16; iii++)
			{
				string += TableLookup("mp/ranktable.csv", 0, rId, iii) + ",";
			}
			println(string);
			wait .1;
		}
	wait .1;
	setdvar("logfile", 0);
}*/


isRegisteredEvent( type )
{
	if ( isDefined( level.scoreInfo[type] ) )
		return true;
	else
		return false;
}

registerScoreInfo( type, value )
{
	level.scoreInfo[type]["value"] = value;
}

getScoreInfoValue( type )
{
	overrideDvar = "scr_" + level.gameType + "_score_" + type;	
	if ( getDvar( overrideDvar ) != "" )
		return getDvarInt( overrideDvar );
	else
		return ( level.scoreInfo[type]["value"] );
}

getScoreInfoLabel( type )
{
	return ( level.scoreInfo[type]["label"] );
}

getRankInfoMinXP( rankId )
{
	return int(level.rankTable[rankId][2]);
}

getRankInfoXPAmt( rankId )
{
	setdvar("bugme", rankId);
	return int(level.rankTable[rankId][3]);
}

getRankInfoMaxXp( rankId )
{
	return int(level.rankTable[rankId][7]);
}

getRankInfoFull( rankId )
{
	return tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 );
}

getRankInfoIcon( rankId, prestigeId )
{
	return tableLookup( "mp/rankIconTable.csv", 0, rankId, prestigeId+1 );
}

getRankInfoUnlockWeapon( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 8 );
}

getRankInfoUnlockPerk( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 9 );
}

getRankInfoUnlockChallenge( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 10 );
}

getRankInfoUnlockFeature( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 15 );
}

getRankInfoUnlockCamo( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 11 );
}

getRankInfoUnlockAttachment( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 12 );
}

getRankInfoLevel( rankId )
{
	return int( tableLookup( "mp/ranktable.csv", 0, rankId, 13 ) );
}


onPlayerConnect()
{
	//for(;;)
	//{
	//	level waittill( "connected", player );

			self.pers["rankxp"] = self scripts\players\_persistence::statGet( "rankxp" );
			self.pers["prestige"] = 0;
			rankId = self getRankForXp( self getRankXP() );
			self.pers["rank"] = rankId;
			self.pers["participation"] = 0;
			self.rankHacker = false;
			
			if (rankId > 20)
			{
				if (rankId != self getstat(253))
				{
					self.rankHacker = true;
					self iprintlnbold("It appears you didnt earn your rank.");
				}
			}


			self scripts\players\_persistence::statSet( "rank", rankId );
			self scripts\players\_persistence::statSet( "minxp", getRankInfoMinXp( rankId ) );
			self scripts\players\_persistence::statSet( "maxxp", getRankInfoMaxXp( rankId ) );
			self scripts\players\_persistence::statSet( "lastxp", self.pers["rankxp"] );
			
			self.rankUpdateTotal = 0;
			self setclientdvar("myrank", rankId + 1);
			
			// for keeping track of rank through stat#251 used by menu script
			// attempt to move logic out of menus as much as possible
			self.cur_rankNum = rankId;
			assertex( isdefined(self.cur_rankNum), "rank: "+ rankId + " does not have an index, check mp/ranktable.csv" );
			
			if(self.rankHacker)
			self setrank(0, 1);
			else
			self setRank( rankId );

			self.explosiveKills[0] = 0;
			self.xpGains = [];
			
			self thread onJoinedTeam();
			self thread scripts\players\_classes::getSkillpoints(rankId);

	//}
}


onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		self thread removeRankHUD();
	}
}


onJoinedSpectators()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");
		self thread removeRankHUD();
	}
}


onPlayerSpawned()
{
	self endon("disconnect");

	//for(;;)
	//{
		//self waittill("spawned_player");

		/*if(!isdefined(self.hud_rankscroreupdate))
		{
			self.hud_rankscroreupdate = newClientHudElem(self);
			self.hud_rankscroreupdate.horzAlign = "center";
			self.hud_rankscroreupdate.vertAlign = "middle";
			self.hud_rankscroreupdate.alignX = "center";
			self.hud_rankscroreupdate.alignY = "middle";
	 		self.hud_rankscroreupdate.x = 0;
			self.hud_rankscroreupdate.y = -60;
			self.hud_rankscroreupdate.font = "default";
			self.hud_rankscroreupdate.fontscale = 2.0;
			self.hud_rankscroreupdate.archived = false;
			self.hud_rankscroreupdate.color = (0.5,0.5,0.5);
			self.hud_rankscroreupdate scripts\players\_hud::fontPulseInit();
		}*/
	//}
}

roundUp( floatVal )
{
	if ( int( floatVal ) != floatVal )
		return int( floatVal+1 );
	else
		return int( floatVal );
}

giveRankXP( type, value )
{
	self endon("disconnect");
	if (self.rankHacker)
	return;
	
	if ( !isDefined( value ) )
		value = getScoreInfoValue( type );
			
	self incRankXP( value );
	
	if ( updateRank() )
	self thread updateRankAnnounceHUD();

	if ( getDvarInt( "scr_enable_scoretext" ) )
	{
		if ( type == "teamkill" )
			self thread updateRankScoreHUD( 0 - getScoreInfoValue( "kill" ) );
		else
			self thread updateRankScoreHUD( value );
	}
}

// update copy of a challenges to be progressed this game, only at the start of the game
// challenges unlocked during the game will not be progressed on during that game session
updateChallenges()
{
	self.challengeData = [];
	for ( i = 1; i <= level.numChallengeTiers; i++ )
	{
		tableName = "mp/challengetable_tier"+i+".csv";

		idx = 1;
		// unlocks all the challenges in this tier
		for( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
		{
			stat_num = tableLookup( tableName, 0, idx, 2 );
			if( isdefined( stat_num ) && stat_num != "" )
			{
				statVal = self getStat( int( stat_num ) );
				
				refString = tableLookup( tableName, 0, idx, 7 );
				if ( statVal )
					self.challengeData[refString] = statVal;
			}
		}
	}
}

endGameUpdate()
{
	player = self;			
}


updateRank()
{
	newRankId = self getRank();
	if ( newRankId == self.pers["rank"] )
		return false;

	oldRank = self.pers["rank"];
	rankId = self.pers["rank"];
	self.pers["rank"] = newRankId;

	while ( rankId <= newRankId )
	{	
		self scripts\players\_persistence::statSet( "rank", rankId );
		self scripts\players\_persistence::statSet( "minxp", int(level.rankTable[rankId][2]) );
		self scripts\players\_persistence::statSet( "maxxp", int(level.rankTable[rankId][7]) );
	
		// set current new rank index to stat#252
		self setStat( 252, rankId );
		self setStat( 253, rankId );
	
		// tell lobby to popup promotion window instead
		self.setPromotion = true;
		
		rankId++;
	}
	self logString( "promoted from " + oldRank + " to " + newRankId + " timeplayed: " + self scripts\players\_persistence::statGet( "time_played_total" ) );		

	self setRank( newRankId );
	self scripts\players\_classes::getSkillpoints(newRankId);
	
	return true;
}

updateRankAnnounceHUD()
{
	self endon("disconnect");

	self notify("update_rank");
	self endon("update_rank");

	/*team = self.pers["team"];
	if ( !isdefined( team ) )
		return;	
	
	self notify("reset_outcome");
	newRankName = self getRankInfoFull( self.pers["rank"] );
	
	notifyData = spawnStruct();

	notifyData.titleText = &"RANK_PROMOTED";
	notifyData.iconName = self getRankInfoIcon( self.pers["rank"], self.pers["prestige"] );
	notifyData.sound = "mp_level_up";
	notifyData.duration = 4.0;
	
	/* //flawed
	if ( isSubStr( level.rankTable[self.pers["rank"]][1], "2" ) )
		subRank = 2;
	else if ( isSubStr( level.rankTable[self.pers["rank"]][1], "3" ) )
		subRank = 3;
	else
		subRank = 1;
	*//*
	*/
	/*rank_char = level.rankTable[self.pers["rank"]][1];
	subRank = int(rank_char[rank_char.size-1]);
	
	if ( subRank == 2 )
	{
		notifyData.textLabel = newRankName;
		notifyData.notifyText = &"RANK_ROMANI";
	}
	else if ( subRank == 3 )
	{
		notifyData.textLabel = newRankName;
		notifyData.notifyText = &"RANK_ROMANII";
	}
	else
	{
		notifyData.notifyText = newRankName;
	}

	thread scripts\players\_hud_message::notifyMessage( notifyData );

	if ( subRank > 1 )
		return;*/
		
	if ( isSubStr( level.rankTable[self.pers["rank"]][1], "2" ) )
		subRank = 2;
	else if ( isSubStr( level.rankTable[self.pers["rank"]][1], "3" ) )
		subRank = 3;
	else
		subRank = 1;
	
	newRankName = self getRankInfoFull( self.pers["rank"] );
	
	self glowMessage(&"RANK_PROMOTED", "", (0,1,0), 5, 90);
	
	if (subRank == 1)
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			player iprintln( &"RANK_PLAYER_WAS_PROMOTED", self, newRankName );
		}
	}
}

updateRankScoreHUD( amount )
{
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );

	/*if ( amount == 0 )
		return;

	self notify( "update_score" );
	self endon( "update_score" );

	self.rankUpdateTotal += amount;

	wait ( 0.05 );

	if( isDefined( self.hud_rankscroreupdate ) )
	{			
		if ( self.rankUpdateTotal < 0 )
		{
			self.hud_rankscroreupdate.label = &"";
			self.hud_rankscroreupdate.color = (1,0,0);
		}
		else
		{
			self.hud_rankscroreupdate.label = &"MP_PLUS";
			self.hud_rankscroreupdate.color = (1,1,0.5);
		}

		self.hud_rankscroreupdate setValue(self.rankUpdateTotal);
		self.hud_rankscroreupdate.alpha = 0.85;
		self.hud_rankscroreupdate thread scripts\players\_hud::fontPulse( self );

		wait 1;
		self.hud_rankscroreupdate fadeOverTime( 0.75 );
		self.hud_rankscroreupdate.alpha = 0;
		
		self.rankUpdateTotal = 0;
	}*/
}

removeRankHUD()
{
	//if(isDefined(self.hud_rankscroreupdate))
	//	self.hud_rankscroreupdate.alpha = 0;
}

getRank()
{	
	rankXp = self.pers["rankxp"];
	rankId = self.pers["rank"];
	
	if ( rankXp < (getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId )) )
		return rankId;
	else
		return self getRankForXp( rankXp );
}

getRankForXp( xpVal )
{
	rankId = 0;
	rankName = level.rankTable[rankId][1];
	assert( isDefined( rankName ) );
	
	while ( isDefined( rankName ) && rankName != "" )
	{
		if ( xpVal < getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId ) )
			return rankId;

		rankId++;
		if ( isDefined( level.rankTable[rankId] ) )
			rankName = level.rankTable[rankId][1];
		else
			rankName = undefined;
	}
	
	rankId--;
	return rankId;
}

getSPM()
{
	rankLevel = (self getRank() % 61) + 1;
	return 3 + (rankLevel * 0.5);
}

getPrestigeLevel()
{
	return self scripts\players\_persistence::statGet( "plevel" );
}

getRankXP()
{
	return self.pers["rankxp"];
}

incRankXP( amount )
{
	
	xp = self getRankXP();
	newXp = (xp + amount);

	if ( self.pers["rank"] == level.maxRank && newXp >= getRankInfoMaxXP( level.maxRank ) )
		newXp = getRankInfoMaxXP( level.maxRank );

	self.pers["rankxp"] = newXp;
	self scripts\players\_persistence::statSet( "rankxp", newXp );
}
