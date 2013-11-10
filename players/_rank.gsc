#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\include\hud;

init()
{
	level.scoreInfo = [];
	level.rankTable = [];
	
	level.rankedMatch = 1;

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
	
	//buildChallegeInfo();
}


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
		rankId = self getRankForXp( self getRankXP() );
		self.pers["rank"] = rankId;
		self.pers["participation"] = 0;

		self scripts\players\_persistence::statSet( "rank", rankId );
		self scripts\players\_persistence::statSet( "minxp", getRankInfoMinXp( rankId ) );
		self scripts\players\_persistence::statSet( "maxxp", getRankInfoMaxXp( rankId ) );
		self scripts\players\_persistence::statSet( "lastxp", self.pers["rankxp"] );
		
		prestige = self getPrestigeLevel();
		
		self.rankHacker = false;
		if (prestige>1) {
			stat = self getstat(253);
			if (rankId>stat ) {
				if (rankId<20) {
					self setstat(253, rankId);
				} else {
					self.rankHacker = true;
					iprintln(self.name + " was kicked for rank hacking");
					Kick( self getEntityNumber());
				}
			} else { if (stat != rankId) self setstat(253, rankId); }
		}
		self.rankUpdateTotal = 0;
		
		// for keeping track of rank through stat#251 used by menu script
		// attempt to move logic out of menus as much as possible
		self.cur_rankNum = rankId;
		assertex( isdefined(self.cur_rankNum), "rank: "+ rankId + " does not have an index, check mp/ranktable.csv" );
		self setStat( 251, self.cur_rankNum );
		
		
		
		if (prestige!=self getstat(210)) {
			self.rankHacker = true;
			iprintln(self.name + " was kicked for prestige hacking");
			Kick( self getEntityNumber());
		}
		
		self setRank( rankId, prestige );
		self.pers["prestige"] = prestige;
		
		self setclientdvar( "ui_lobbypopup", "" );
		
		
		//player updateChallenges();
		//player.explosiveKills[0] = 0;
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

	self.spree = 0;
	
	/*for(;;)
	{
		self waittill("spawned_player");
		self.spree = 0;
		if(!isdefined(self.hud_rankscroreupdate))
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
			self.hud_rankscroreupdate maps\mp\gametypes\_hud::fontPulseInit();
		}
	}*/
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

	/*if ( level.teamBased && (!level.playerCount["allies"] || !level.playerCount["axis"]) )
		return;
	else if ( !level.teamBased && (level.playerCount["allies"] + level.playerCount["axis"] < 2) )
		return;*/

	if ( !isDefined( value ) )
		value = getScoreInfoValue( type );
	
	if ( !isDefined( self.xpGains[type] ) )
		self.xpGains[type] = 0;

	/*switch( type )
	{
		case "kill":
		case "headshot":
		case "suicide":
		case "teamkill":
		case "assist":
		case "capture":
		case "defend":
		case "return":
		case "pickup":
		case "assault":
		case "plant":
		case "defuse":
			if ( level.numLives >= 1 )
			{
				multiplier = max(1,int( 10/level.numLives ));
				value = int(value * multiplier);
			}
			break;
	}*/
	
	self.xpGains[type] += value;
		
	self incRankXP( value );

	if (  updateRank() )
		self thread updateRankAnnounceHUD();

	//if ( isDefined( self.enableText ) && self.enableText && !level.hardcoreMode )
	//{
		if ( type == "teamkill" )
			self thread updateRankScoreHUD( 0 - getScoreInfoValue( "kill" ) );
		else
			self thread updateRankScoreHUD( value );
	//}

	/*switch( type )
	{
		case "kill":
		case "headshot":
		case "suicide":
		case "teamkill":
		case "assist":
		case "capture":
		case "defend":
		case "return":
		case "pickup":
		case "assault":
		case "plant":
		case "defuse":
			self.pers["summary"]["score"] += value;
			self.pers["summary"]["xp"] += value;
			break;

		case "win":
		case "loss":
		case "tie":
			self.pers["summary"]["match"] += value;
			self.pers["summary"]["xp"] += value;
			break;

		case "challenge":
			self.pers["summary"]["challenge"] += value;
			self.pers["summary"]["xp"] += value;
			break;
			
		default:
			self.pers["summary"]["misc"] += value;	//keeps track of ungrouped match xp reward
			self.pers["summary"]["match"] += value;
			self.pers["summary"]["xp"] += value;
			break;
	}

	self setClientDvars(
			"player_summary_xp", self.pers["summary"]["xp"],
			"player_summary_score", self.pers["summary"]["score"],
			"player_summary_challenge", self.pers["summary"]["challenge"],
			"player_summary_match", self.pers["summary"]["match"],
			"player_summary_misc", self.pers["summary"]["misc"]
		);*/
}

checkSpree() {
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );
	self notify("end_spree");
	self endon("end_spree");
	self.spree++;
	if (self.spree>1) {
		switch (self.spree) {
			case 2:
				self playlocalsound("double_kill");
				self scripts\players\_rank::giveRankXP("spree", 5);
			break;
			case 3:
				self playlocalsound("triple_kill");
				self scripts\players\_rank::giveRankXP("spree", 10);
				self.laststreak = "Triple kill! ";
			break;
			case 4:
				self playlocalsound("multikill");
				self scripts\players\_rank::giveRankXP("spree", 50);
				self.laststreak = "Multi kill! ";
			break;
			case 5:
				self playlocalsound("megakill");
				self scripts\players\_rank::giveRankXP("spree", 100);
				self.laststreak = "Mega kill! ";
			break;
			case 6:
				self playlocalsound("ultrakill");
				self scripts\players\_rank::giveRankXP("spree", 250);
				self.laststreak = "Ultra kill! ";
			break;
			case 7:
				self playlocalsound("ludicrouskill");
				self scripts\players\_rank::giveRankXP("spree", 500);
				self.laststreak = "Ludicrous kill! ";
			break;
		
		}
	} else {self.laststreak = "";}
	wait 1.25;
	if (self.laststreak!="") {
		iprintln(self.laststreak+self.name+"^7 killed "+self.spree+" enemies in a spree!");
	}
	self.spree = 0;
	self.laststreak = "";
}

prestigeUp() {
	//if (self.rankHacker)
	//return;
	
	if (self.pers["prestige"] == level.maxPrestige)
	return;
	if (self getRank() < level.maxRank)
	return;
	
	//self.pers["rank"] = 0;
	self.pers["prestige"]+=int(self.pers["rankxp"]/(getRankInfoMaxXp(level.maxRank)-10));
	self setStat(2326, self.pers["prestige"]);
	self setStat(210, self.pers["prestige"]);
	/*rankId = 0;
	self.pers["rank"] = 0;
	self setRank(rankId, self.pers["prestige"]);
	wait 100;
	//self scripts\players\_classes::getSkillpoints(rankId);
	wait 0.05;
	self setStat( 252, rankId );
	self setStat( 253, rankId );
	self.pers["rankxp"] = 0;
	self scripts\players\_persistence::statSet( "rankxp", 0 );
	self scripts\players\_persistence::statSet( "rank", rankId );
	self scripts\players\_persistence::statSet( "minxp", int(level.rankTable[rankId][2]) );
	self scripts\players\_persistence::statSet( "maxxp", int(level.rankTable[rankId][7]) );
	self updateRankAnnounceHUD();*/
	self scripts\players\_persistence::statSet( "rankxp", 0 );
	self scripts\players\_persistence::statSet( "rank", 0 );
	self scripts\players\_persistence::statSet( "minxp", int(level.rankTable[0][2]) );
	self scripts\players\_persistence::statSet( "maxxp", int(level.rankTable[0][7]) );
	self setStat( 252, 0 );
	self setStat( 253, 0 );
	self.pers["rankxp"] = 0;
	self setRank(0, self.pers["prestige"]);
	//updateRank();
	self thread resetRank(.5);
}

resetRank(delay) {
	self endon("disconnect");
	wait delay;
	rankId = self getRankForXp( self getRankXP() );
	self.pers["rank"] = rankId;
	
	self scripts\players\_classes::getSkillpoints(rankId);
}

updateRank()
{
	if (self.rankHacker)
	return;
	
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
	
		

		rankId++;
	}
	self logString( "promoted from " + oldRank + " to " + newRankId + " timeplayed: " + self scripts\players\_persistence::statGet( "time_played_total" ) );		

	self setRank( newRankId, self.pers["prestige"] );
	self scripts\players\_classes::getSkillpoints(newRankId);
	return true;
}

updateRankAnnounceHUD()
{
	self endon("disconnect");

	self notify("update_rank");
	self endon("update_rank");

	team = self.pers["team"];
	if ( !isdefined( team ) )
		return;	
		
	newRankName = self getRankInfoFull( self.pers["rank"] );
	
	/*subRank = int(rank_char[rank_char.size-1]);
	
	if ( subRank == 2 )
	{
		textLabel = newRankName;
		notifyText = &"RANK_ROMANI";
	}
	else if ( subRank == 3 )
	{
		textLabel = newRankName;
		notifyText = &"RANK_ROMANII";
	}
	else
	{
		notifyText = newRankName;
	}

	thread scripts\players\_hud_message::notifyMessage( notifyData );*/
	
	rank_char = level.rankTable[self.pers["rank"]][1];
	subRank = int(rank_char[rank_char.size-1]);
	
	self glowMessage(&"RANK_PROMOTED", "", (0,1,0), 5, 90, 2, "mp_level_up");
	
	rank_char = level.rankTable[self.pers["rank"]][1];
	subRank = int(rank_char[rank_char.size-1]);
	
	if (subRank == 1)
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			player iprintln( &"RANK_PLAYER_WAS_PROMOTED", self, newRankName);
		}
	}
}


endGameUpdate()
{
	player = self;			
}

updateRankScoreHUD( amount )
{
	/*self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );

	if ( amount == 0 )
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
		self.hud_rankscroreupdate thread maps\mp\gametypes\_hud::fontPulse( self );

		wait 1.25;
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
	if(getDvar("developer_script") == "1") return;
	
	xp = self getRankXP();
	newXp = (xp + amount);

	if ( self.pers["rank"] == level.maxRank && newXp >= getRankInfoMaxXP( level.maxRank ) )
		newXp = getRankInfoMaxXP( level.maxRank );

	self.pers["rankxp"] = newXp;
	self scripts\players\_persistence::statSet( "rankxp", newXp );
}
