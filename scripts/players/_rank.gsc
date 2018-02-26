/**
* vim: set ft=cpp:
* file: scripts\players\_rank.gsc
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

#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\include\hud;

init()
{
	// Saves all xp-giving events via registerScoreInfo("eventname", value)
	level.scoreInfo = [];
	level.rankTable = [];
	
	level.rankedMatch = 1;

	precacheShader("white");

	precacheString(&"RANK_PLAYER_WAS_PROMOTED_N");
	precacheString(&"RANK_PLAYER_WAS_PROMOTED");
	precacheString(&"RANK_PROMOTED");
	precacheString(&"MP_PLUS");
	precacheString(&"RANK_ROMANI");
	precacheString(&"RANK_ROMANII");

	registerScoreInfo("kill", 10);
	registerScoreInfo("assist0", 1);
	registerScoreInfo("assist1", 2);
	registerScoreInfo("assist2", 3);
	registerScoreInfo("assist3", 5);
	registerScoreInfo("assist4", 7);
	registerScoreInfo("assist5", 10);
	registerScoreInfo("revive", 50);
	registerScoreInfo("headshot", 10);
	registerScoreInfo("cheat", 5000);
	registerScoreInfo("suicide", 0);
	registerScoreInfo("teamkill", 0);
	registerScoreInfo("challenge", 250);

	level.maxRank = int(tableLookup("mp/rankTable.csv", 0, "maxrank", 1));
	level.maxPrestige = int(tableLookup("mp/rankIconTable.csv", 0, "maxprestige", 1));
	
	pId = 0; // PrestigeID
	rId = 0; // RankID
	for (pId = 0; pId <= level.maxPrestige; pId++)
	{
		for (rId = 0; rId <= level.maxRank; rId++)
			precacheShader(tableLookup("mp/rankIconTable.csv", 0, rId, pId + 1)); // Loads all rank and prestige icons
	}

	// Loads first existing rank name
	rankId = 0;
	rankName = tableLookup("mp/ranktable.csv", 0, rankId, 1);
	assert(isDefined(rankName) && rankName != "");
	
	// Loads all existing 
	while (isDefined(rankName) && rankName != "")
	{
		level.rankTable[rankId][1] = tableLookup("mp/ranktable.csv", 0, rankId, 1); // Rank Name
		level.rankTable[rankId][2] = tableLookup("mp/ranktable.csv", 0, rankId, 2); // Minimum XP
		level.rankTable[rankId][3] = tableLookup("mp/ranktable.csv", 0, rankId, 3); // XP Range (max - min)
		level.rankTable[rankId][7] = tableLookup("mp/ranktable.csv", 0, rankId, 7); // Maximum XP

		precacheString(tableLookupIString("mp/ranktable.csv", 0, rankId, 16)); // Precache localized string of given rank
		
		// Setup next loop
		rankId++;
		rankName = tableLookup("mp/ranktable.csv", 0, rankId, 1);		
	}

	// TODO: They are not used
	// Setup stats saving offsets
	// level.statOffsets = [];
	// level.statOffsets["weapon_assault"] = 290;
	// level.statOffsets["weapon_lmg"] = 291;
	// level.statOffsets["weapon_smg"] = 292;
	// level.statOffsets["weapon_shotgun"] = 293;
	// level.statOffsets["weapon_sniper"] = 294;
	// level.statOffsets["weapon_pistol"] = 295;
	// level.statOffsets["perk1"] = 296;
	// level.statOffsets["perk2"] = 297;
	// level.statOffsets["perk3"] = 298;
	// level.numChallengeTiers	= 10;
	
	//buildChallegeInfo();
}

/**
*	Checks whether an XP-giving event exists
*	@type: String, the name of the event
*	@return: Boolean, whether it exists or not
*/
isRegisteredEvent(type)
{
	if (isDefined(level.scoreInfo[type]))
		return true;
	else
		return false;
}

/**
*	Registers a given XP-award-event
*	@type: String, the name of the event
*	@value: Int, the base amount of XP received
*/
registerScoreInfo(type, value)
{
	level.scoreInfo[type]["value"] = value;
}

/**
*	Returns the base amount of XP registered to this event
*	@type: String, the name of the event
*	@return: Int, the base amount of XP given by that event
*/
getScoreInfoValue(type)
{
	return (level.scoreInfo[type]["value"]);
}

/**
*	Returns the label of the event
*	@type: String, the name of the event
*	@return: Int, the base amount of XP given by that event
*	TODO: Doesn't seem to be used, remove?
*/
getScoreInfoLabel(type)
{
	return (level.scoreInfo[type]["label"]);
}

/**
*	Returns the minimum amount of XP for given rankID
*	@rankId: Int, the ID of the rank to check
*	@return: Int, the minimum amount of XP for the given rank ID
*/
getRankInfoMinXP(rankId)
{
	return int(level.rankTable[rankId][2]);
}

/**
*	Returns the difference between min and max XP for given rankID
*	@rankId: Int, the ID of the rank to check
*	@return: Int, the difference between min and max XP for given rankID
*/
getRankInfoXPAmt(rankId)
{
	return int(level.rankTable[rankId][3]);
}

/**
*	Returns the maximum amount of XP for given rankID
*	@rankId: Int, the ID of the rank to check
*	@return: Int, the maximum amount of XP for the given rank ID
*/
getRankInfoMaxXp(rankId)
{
	return int(level.rankTable[rankId][7]);
}

/**
*	Returns the localized string for the given rank ID
*	@rankId: Int, the ID of the rank to check
*	@return: IString, the localized string for the given rank ID
*/
getRankInfoFull(rankId)
{
	return tableLookupIString("mp/ranktable.csv", 0, rankId, 16);
}

/**
*	Returns the material name (rank icon) of the given rank ID and prestige ID
*	@rankId: Int, the ID of the rank to check
*	@prestigeId: Int, the ID of the prestige to check
*	@return: String, the material name for the given combination of rank ID and prestige ID
*/
getRankInfoIcon(rankId, prestigeId)
{
	return tableLookup("mp/rankIconTable.csv", 0, rankId, prestigeId + 1);
}


// STOCK _rank.gsc FUNCTIONS
// TODO: They appear unused. Remove?
getRankInfoUnlockWeapon(rankId)
{
	return tableLookup("mp/ranktable.csv", 0, rankId, 8);
}

getRankInfoUnlockPerk(rankId)
{
	return tableLookup("mp/ranktable.csv", 0, rankId, 9);
}

getRankInfoUnlockChallenge(rankId)
{
	return tableLookup("mp/ranktable.csv", 0, rankId, 10);
}

getRankInfoUnlockFeature(rankId)
{
	return tableLookup("mp/ranktable.csv", 0, rankId, 15);
}

getRankInfoUnlockCamo(rankId)
{
	return tableLookup("mp/ranktable.csv", 0, rankId, 11);
}

getRankInfoUnlockAttachment(rankId)
{
	return tableLookup("mp/ranktable.csv", 0, rankId, 12);
}

getRankInfoLevel(rankId)
{
	return int(tableLookup("mp/ranktable.csv", 0, rankId, 13));
}
// END STOCK _rank.gsc FUNCTIONS


/**
*	Load player rank/prestige on connect
*/
onPlayerConnect()
{
	self endon("disconnect");

	// Load player XP
	self.pers["rankxp"] = self scripts\players\_persistence::statGet("rankxp");
	
	// Load player rank according to his XP
	rankId = self getRankForXp(self.pers["rankxp"]);
	
	// Save his rank
	self.pers["rank"] = rankId;
	self.pers["participation"] = 0;
	
	// Set rank, min-xp of rank, max-xp of rank and his current XP as of now
	self scripts\players\_persistence::statSet("rank", rankId);
	self scripts\players\_persistence::statSet("minxp", getRankInfoMinXp(rankId));
	self scripts\players\_persistence::statSet("maxxp", getRankInfoMaxXp(rankId));
	self scripts\players\_persistence::statSet("lastxp", self.pers["rankxp"]);
	
	prestige = self getPrestigeLevel();
	
	// TODO: Remove rank hacker check? I mean... whoever wants to hack their rank in a 10+ year old game... I don't mind.
	// self.rankHacker = false;
	// if (prestige>1) {
		// stat = self getstat(253);
		// if (rankId>stat) {
			// if (rankId<20) {
				// self setstat(253, rankId);
			// } else {
				// self.rankHacker = true;
				// iprintln(self.name + " was kicked for rank hacking.");
				// Kick(self getEntityNumber());
			// }
		// } else { if (stat != rankId) self setstat(253, rankId); }
	// }
	
	// TODO: Appears unused. Remove?
	self.rankUpdateTotal = 0;
	
	// for keeping track of rank through stat#251 used by menu script
	// attempt to move logic out of menus as much as possible
	self.cur_rankNum = rankId;
	assertex(isdefined(self.cur_rankNum), "rank: "+ rankId + " does not have an index, check mp/ranktable.csv");
	self setStat(251, self.cur_rankNum);
	
	
	
	// if (prestige!=self getstat(210)) {
		// self.rankHacker = true;
		// iprintln(self.name + " was kicked for prestige hacking.");
		// Kick(self getEntityNumber());
	// }
	
	// Set current rank/prestige
	self setRank(rankId, prestige);
	self.pers["prestige"] = prestige;
	
	// TODO: Does this do anything? Only found here.
	self setclientdvar("ui_lobbypopup", "");
	
	// Saves XP's gained by each individual type
	self.xpGains = [];
	
	// TODO: See next function below
	self thread onJoinedTeam();
	
	// Load skillpoints for current rank
	self thread scripts\players\_classes::getSkillpoints(rankId);
}

// TODO:
// joined_team is never triggered, removeRankHUD() is also empty
onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		self thread removeRankHUD();
	}
}

// TODO:
// joined_team is never triggered, removeRankHUD() is also empty
onJoinedSpectators()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");
		self thread removeRankHUD();
	}
}

/**
*	Set starting spree value
*/
onPlayerSpawned()
{
	self endon("disconnect");

	self.spree = 0;
}

giveRankXP(type, value)
{
	self endon("disconnect");
	
	// if (self.rankHacker)
	// return;

	// Get XP value from previously defined event if value isn't given
	if (!isDefined(value))
		value = getScoreInfoValue(type);
	
	// Initialize this type in self.xpGains[]
	if (!isDefined(self.xpGains[type]))
		self.xpGains[type] = 0;
	
	// Multiply by server's XP multiplier setting
	value *= level.dvar["game_xpmultiplier"]; // Multiply XP Gain
	
	self.xpGains[type] += value;
		
	self incRankXP(value);

	if ( updateRank())
		self thread updateRankAnnounceHUD();

	//if (isDefined(self.enableText) && self.enableText && !level.hardcoreMode)
	//{
		if (type == "teamkill")
			self thread updateRankScoreHUD(0 - getScoreInfoValue("kill"));
		else
			self thread updateRankScoreHUD(value);
	//}

	/*switch(type)
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

/* [0] = player-ID, [1] = prestige level, [2] = force overwrite */
overwritePrestige(args){
	if(args.size != 2 && args.size != 3)
		return;
		
	// args[3] = check whether old prestige > new prestige, don't act if not
	if(args.size == 2)
		args[2] = 0;
	
	for(i = 0; i < level.players.size; i++)
		if(level.players[i] getEntityNumber() == int(args[0])){
			player = level.players[i];
			player endon("disconnect");
			prestige = int(args[1]);
			
			if(!int(args[2])) // in case we don't overwrite, we don't continue
				if(prestige <= player.pers["prestige"])
					return;
				
			if(prestige > level.maxPrestige)
				prestige = level.maxPrestige;
			
			if(prestige < player.pers["prestige"])
				player fullReset();
			
			player.pers["prestige"] = prestige;
			
			player prestigeUp(true);
			player iprintlnbold("Your ^3Prestige ^7has been changed to " + prestige + " by the Server!");
			iprintln("The ^3Prestige ^7of " + player.name + " has been changed to " + prestige + " by the Server!");
	}
}

/* [0] = player-ID, [1] = prestige level, [2] = force overwrite */
overwriteRank(args){
	if(args.size != 2 && args.size != 3)
		return;
		
	// args[3] = check whether old prestige > new prestige, don't act if not
	if(args.size == 2)
		args[2] = 0;
	
	for(i = 0; i < level.players.size; i++)
		if(level.players[i] getEntityNumber() == int(args[0])){
			player = level.players[i];
			player endon("disconnect");
			rank = int(args[1]);
			
			if(!int(args[2])) // in case we don't overwrite, we don't continue
				if(rank - 1 <= player.pers["rank"])
					return;
			
			if(rank > 55)
				rank = 55;
			else if(rank < 0)
				rank = 0;
			
			if(rank < player.pers["rank"]){
				oldPrestige = [];
				oldPrestige[0] = args[0];
				oldPrestige[1] = player.pers["prestige"];
				overwritePrestige(oldPrestige);
			}
			player incRankXP(getXPNeededForRank(rank) - player.pers["rankxp"]);
			player updateRank(true);
			player iprintlnbold("Your ^5Rank ^7has been changed to " + rank + " by the Server!");
			iprintln("The ^5Rank ^7of " + player.name + " has been changed to " + rank + " by the Server!");
	}
}

fullResetRcon(args){
	if(args.size < 1)
		return;
	
	for(i = 0; i < level.players.size; i++)
		if(level.players[i] getEntityNumber() == int(args[0])){
			player = level.players[i];
			
			player fullReset();
	}
}

prestigeUp(force) {
	//if (self.rankHacker)
	//return;
	if(!isDefined(force))
		force = false;
	
	if (self.pers["prestige"] == level.maxPrestige && !force)
		return;
	if (self getRank() < level.maxRank && !force)
		return;
	
	//self.pers["rank"] = 0;
	if(!force)
		self.pers["prestige"]+=int(self.pers["rankxp"]/(getRankInfoMaxXp(level.maxRank)-10));
	self setStat(2326, self.pers["prestige"]);
	self setStat(210, self.pers["prestige"]);
	/*rankId = 0;
	self.pers["rank"] = 0;
	self setRank(rankId, self.pers["prestige"]);
	wait 100;
	//self scripts\players\_classes::getSkillpoints(rankId);
	wait 0.05;
	self setStat(252, rankId);
	self setStat(253, rankId);
	self.pers["rankxp"] = 0;
	self scripts\players\_persistence::statSet("rankxp", 0);
	self scripts\players\_persistence::statSet("rank", rankId);
	self scripts\players\_persistence::statSet("minxp", int(level.rankTable[rankId][2]));
	self scripts\players\_persistence::statSet("maxxp", int(level.rankTable[rankId][7]));
	self updateRankAnnounceHUD();*/
	self scripts\players\_persistence::statSet("rankxp", 0);
	self scripts\players\_persistence::statSet("rank", 0);
	self scripts\players\_persistence::statSet("minxp", int(level.rankTable[0][2]));
	self scripts\players\_persistence::statSet("maxxp", int(level.rankTable[0][7]));
	self setStat(252, 0);
	self setStat(253, 0);
	self.pers["rankxp"] = 0;
	self setRank(0, self.pers["prestige"]);
	//updateRank();
	self thread resetRank(.5);
}

fullReset(){
	self setStat(2326, 0);
	self setStat(210, 0);
	self scripts\players\_persistence::statSet("rankxp", 0);
	self scripts\players\_persistence::statSet("rank", 0);
	self scripts\players\_persistence::statSet("minxp", int(level.rankTable[0][2]));
	self scripts\players\_persistence::statSet("maxxp", int(level.rankTable[0][7]));
	self setStat(252, 0);
	self setStat(253, 0);
	self.pers["rank"] = 0;
	self.pers["rankxp"] = 0;
	self setRank(0, 0);
	self scripts\players\_classes::resetSkillpoints();
}

resetRank(delay) {
	self endon("disconnect");
	wait delay;
	rankId = self getRankForXp(self getRankXP());
	self.pers["rank"] = rankId;
	
	self scripts\players\_classes::getSkillpoints(rankId);
	self notify("reset_rank_over");
}

/**
 * Determine if player needs to be ranked up or not
 * @return will send true if player needs rank up and false if not.
 */

updateRank(useWait)
{
	if (/*self.rankHacker || */isdefined(self.updatingrank))
		return false;
	
	self.updatingrank = true;
	
	if(!isDefined(useWait))
		useWait = false;
	
	if(useWait)
		self endon("disconnect");
	
	newRankId = self getRank();
	if (newRankId == self.pers["rank"])
	{
		self.updatingrank = undefined;
		return false;
	}

	oldRank = self.pers["rank"];
	rankId = self.pers["rank"];
	self.pers["rank"] = newRankId;

	while (rankId <= newRankId)
	{	
		self scripts\players\_persistence::statSet("rank", rankId);
		self scripts\players\_persistence::statSet("minxp", int(level.rankTable[rankId][2]));
		self scripts\players\_persistence::statSet("maxxp", int(level.rankTable[rankId][7]));
	
		// set current new rank index to stat#252
		self setStat(252, rankId);
		self setStat(253, rankId);
		
		rankId++;
		if(useWait)
			wait 0.05;
	}
	self logString("promoted from " + oldRank + " to " + newRankId + " timeplayed: " + self scripts\players\_persistence::statGet("time_played_total"));
	
	self setRank(newRankId, self.pers["prestige"]);
	self scripts\players\_classes::getSkillpoints(newRankId);
	self.updatingrank = undefined;
	return true;
}

/**
 * Update rank in hud and announce rank up to other players
 */

updateRankAnnounceHUD()
{
	self endon("disconnect");

	self notify("update_rank");
	self endon("update_rank");

	team = self.pers["team"];
	if (!isdefined(team))
		return;	
		
	newRankName = self getRankInfoFull(self.pers["rank"]);
	
	/*subRank = int(rank_char[rank_char.size-1]);
	
	if (subRank == 2)
	{
		textLabel = newRankName;
		notifyText = &"RANK_ROMANI";
	}
	else if (subRank == 3)
	{
		textLabel = newRankName;
		notifyText = &"RANK_ROMANII";
	}
	else
	{
		notifyText = newRankName;
	}

	thread scripts\players\_hud_message::notifyMessage(notifyData);*/
	
	rank_char = level.rankTable[self.pers["rank"]][1];
	subRank = int(rank_char[rank_char.size-1]);
	
	self glowMessage(&"ZOMBIE_PROMOTION", "", (0.9,0,0), 5, 90, 2, "rotu_level_up");
	
	rank_char = level.rankTable[self.pers["rank"]][1];
	subRank = int(rank_char[rank_char.size-1]);
	
	if (subRank == 1)
	{
		iprintln(&"RANK_PLAYER_WAS_PROMOTED", self.name, newRankName);
	}
}


endGameUpdate()
{
	player = self;			
}

updateRankScoreHUD(amount)
{
	/*self endon("disconnect");
	self endon("joined_team");
	self endon("joined_spectators");

	if (amount == 0)
		return;

	self notify("update_score");
	self endon("update_score");

	self.rankUpdateTotal += amount;

	wait (0.05);

	if(isDefined(self.hud_rankscroreupdate))
	{			
		if (self.rankUpdateTotal < 0)
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
		self.hud_rankscroreupdate thread maps\mp\gametypes\_hud::fontPulse(self);

		wait 1.25;
		self.hud_rankscroreupdate fadeOverTime(0.75);
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
	
	if (rankXp < (getRankInfoMinXP(rankId) + getRankInfoXPAmt(rankId)))
		return rankId;
	else
		return self getRankForXp(rankXp);
}

getXPNeededForRank(rankID){
	rankID -= 1;
	
	if(rankID < 0)
		rankID = 0;
	else if(rankID > 54)
		rankID = 54;
		
	return getRankInfoMinXP(rankID);
}

getRankForXp(xpVal)
{
	rankId = 0;
	rankName = level.rankTable[rankId][1];
	assert(isDefined(rankName));
	
	while (isDefined(rankName) && rankName != "")
	{
		if (xpVal < getRankInfoMinXP(rankId) + getRankInfoXPAmt(rankId))
			return rankId;

		rankId++;
		if (isDefined(level.rankTable[rankId]))
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
	return self scripts\players\_persistence::statGet("plevel");
}

getRankXP()
{
	return self.pers["rankxp"];
}

incRankXP(amount)
{
	if(getDvar("developer_script") == "1") return;
	
	xp = self getRankXP();
	newXp = (xp + amount);

	if (self.pers["rank"] == level.maxRank && newXp >= getRankInfoMaxXP(level.maxRank))
		newXp = getRankInfoMaxXP(level.maxRank);

	self.pers["rankxp"] = newXp;
	self scripts\players\_persistence::statSet("rankxp", newXp);
}
