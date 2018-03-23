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
#include scripts\include\persistence;

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
	
	
	// Register all XP-giving events
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
	
	// Loads all rank and prestige icons
	pId = 0; // PrestigeID
	rId = 0; // RankID
	for(pId = 0; pId <= level.maxPrestige; pId++)
	{
		for(rId = 0; rId <= level.maxRank; rId++)
			precacheShader(tableLookup("mp/rankIconTable.csv", 0, rId, pId + 1));
	}

	// Loads first existing rank name
	rankId = 0;
	rankName = tableLookup("mp/ranktable.csv", 0, rankId, 1);
	assert(isDefined(rankName) && rankName != "");
	
	// Loads all existing ranks with their xp info
	while(isDefined(rankName) && rankName != "")
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
	
}

getPrestigeLevel(){

	return self statGet("plevel");
}

getRankXP(){

	return self.pers["rankxp"];
}

/**
*	Returns the current rank of "self"
*/
getRank(){

	rankXp = self.pers["rankxp"];
	rankId = self.pers["rank"];
	
	// Returns the currently set rank if the amount of xp needed
	// for the next rank is lower
	// TODO: Wouldn't rankXp < getRankInfoMaxXP be enough?
	if (rankXp < (getRankInfoMinXP(rankId) + getRankInfoXPAmt(rankId)))
		return rankId;
	else
		return self getRankForXp(rankXp);
}

/**
*	Returns the rank for the given amount of xp
*	@xpVal: int, amount of XP to calculate the rank for
*/
getRankForXp(xpVal){

	rankId = 0;
	rankName = level.rankTable[rankId][1];
	assert(isDefined(rankName));
	
	// Loop through all given ranks until we hit
	// the rank that fits the amount of XP given
	while(isDefined(rankName) && rankName != "")
	{
		// TODO: Wouldn't rankXp < getRankInfoMaxXP be enough?
		if(xpVal < getRankInfoMinXP(rankId) + getRankInfoXPAmt(rankId))
			return rankId;

		rankId++;
		if(isDefined(level.rankTable[rankId]))
			rankName = level.rankTable[rankId][1];
		else
			rankName = undefined;
	}
	
	// Return the last rank that matched -1 since we're
	// always 1 rank too far
	rankId--;
	return rankId;
}

/**
*	Load player rank/prestige on connect
*/
onPlayerConnect(){

	self endon("disconnect");

	// Load player XP
	self.pers["rankxp"] = self statGet("rankxp");
	
	// Load player rank according to his XP
	rankId = self getRankForXp(self.pers["rankxp"]);
	
	// Save his rank
	self.pers["rank"] = rankId;
	self.pers["participation"] = 0;
	
	// Set rank, min-xp of rank, max-xp of rank and his current XP as of now
	self statSet("rank", rankId);
	self statSet("minxp", getRankInfoMinXp(rankId));
	self statSet("maxxp", getRankInfoMaxXp(rankId));
	self statSet("lastxp", self.pers["rankxp"]);
	
	prestige = self getPrestigeLevel();
	
	// Set current rank/prestige
	self setRank(rankId, prestige);
	self.pers["prestige"] = prestige;
	
	// Saves XPs gained by each individual type
	self.xpGains = [];
	
	// Load skillpoints for current rank
	self thread scripts\players\_classes::updateSkillpoints(rankId);
}


/**
*	Execute things on player spawn
*/
onPlayerSpawned(){

	self endon("disconnect");

}

/**
*	Give XP for the given type
*	@type: String, name for the XP-event
*	[@value]: Int, optional, forces the given amount, otherwise it is looked up by type
*/
giveRankXP(type, value){

	self endon("disconnect");

	// Get XP value from previously defined event if value isn't given
	if (!isDefined(value))
		value = getScoreInfoValue(type);
	
	// Initialize this type in self.xpGains[]
	if (!isDefined(self.xpGains[type]))
		self.xpGains[type] = 0;
	
	// Multiply by server's XP multiplier setting
	value *= level.dvar["game_xpmultiplier"];
	
	// Adds given xp to this type of event
	self.xpGains[type] += value;
	
	// Applies the awarded XP to the player
	self incRankXP(value);

	// Announce new rank if it has changed
	if (checkRankup())
		self thread updateRankAnnounceHUD();
}

/**
*	Increases player's XP by given amount
*	@amount: Int, amount of XP to give to player
*/
incRankXP(amount){

	if(getDvar("developer_script") == "1") return;
	
	// Get current XP and add the new XP to it
	xp = self getRankXP();
	newXp = (xp + amount);

	// If the new XP exceeds the highest value possible, we cap it
	if (self.pers["rank"] == level.maxRank && newXp >= getRankInfoMaxXP(level.maxRank))
		newXp = getRankInfoMaxXP(level.maxRank);
	
	// Save new XP amount to player
	self.pers["rankxp"] = newXp;
	self statSet("rankxp", newXp);
}

/**
*	@returns: Boolean, whether the player can increase his prestige by 1
*/
canPrestige(){

	return (self getRank() == level.maxRank && self.pers["prestige"] < level.maxPrestige);

}

/**
*	Set prestige to newPrestige
*	@newPrestige: Int, new prestige level
*/
setPrestige(newPrestige){

	// Check if prestige can be increased
	assert(newPrestige >= 0 && newPrestige < level.maxPrestige);
	
	// Don't go over maximum prestige level
	if (self.pers["prestige"] == level.maxPrestige)
		return;	
	
	// Setup new prestige level
	self.pers["prestige"] = newPrestige;
	self statSet("plevel", self.pers["prestige"]);
	self statSet("rankxp", 0);
	self statSet("rank", 0);
	self statSet("minxp", int(level.rankTable[0][2]));
	self statSet("maxxp", int(level.rankTable[0][7]));
	self.pers["rankxp"] = 0;
	self setRank(0, self.pers["prestige"]);
	self refreshRank();
}

/**
*	Fully resets the player to rank 1 and prestige 0
*/
fullReset(){

	self statSet("plevel", 0);
	self statSet("rankxp", 0);
	self statSet("rank", 0);
	self statSet("minxp", int(level.rankTable[0][2]));
	self statSet("maxxp", int(level.rankTable[0][7]));
	self.pers["rank"] = 0;
	self.pers["rankxp"] = 0;
	self setRank(0, 0);
	self scripts\players\_classes::resetSkillpoints();
}

/**
*	Updates the rank of the player and reloads skillpoints
*/
refreshRank(){

	rankId = self getRankForXp(self getRankXP());
	self.pers["rank"] = rankId;
	
	self scripts\players\_classes::updateSkillpoints(rankId);
}

/**
*	Determine if player needs to be ranked up or not
*	@returns: Boolean, whether the player can be ranked up or not
*/
checkRankup(){

	// Check if the resulting rank from his current XP is the same
	// as the one he currently has
	newRankId = self getRank();
	if (newRankId == self.pers["rank"])
		return false;

	// Save old rank and set new rank
	oldRank = self.pers["rank"];
	rankId = self.pers["rank"];
	self.pers["rank"] = newRankId;

	// Set the new rank
	self statSet("rank", rankId);
	self statSet("minxp", int(level.rankTable[rankId][2]));
	self statSet("maxxp", int(level.rankTable[rankId][7]));
		
	self logString("promoted from " + oldRank + " to " + newRankId + " timeplayed: " + self statGet("time_played_total"));
	
	self setRank(newRankId, self.pers["prestige"]);
	self scripts\players\_classes::updateSkillpoints(newRankId);
	
	return true;
}

/**
*	Display rank-up text to player and to others
*/
updateRankAnnounceHUD()
{
	self endon("disconnect");
	
	// Only run this in one thread
	self notify("update_rank");
	self endon("update_rank");

	team = self.pers["team"];
	if (!isDefined(team))
		return;	
	
	// Show rankup message to player
	self glowMessage(&"ZOMBIE_PROMOTION", "", (0.9,0,0), 5, 90, 2, "rotu_level_up");
	
	
	// Get rank name
	newRankName = self getRankInfoFull(self.pers["rank"]);
	
	// The ranks are called
	// sgt1
	// sgt2
	// ...
	// We only display a rankup message if we're at e.g. sgt1
	rank_char = level.rankTable[self.pers["rank"]][1];
	subRank = int(rank_char[rank_char.size-1]);
	
	if (subRank == 1)
	{
		iprintln(&"RANK_PLAYER_WAS_PROMOTED", self.name, newRankName);
	}
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
