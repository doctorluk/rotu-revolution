//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.3 by Luk 
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon
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
	level.rank = [];
	setupRanks();

}

setupRanks()
{
	addRank("^1developer", 0);
	addRank("^2admin", 100, "icon_admin");
	
	i = 1;
	for (;;)
	{
		dvar = getdvar("rank_custom_"+i);
		if (dvar== "")
		return;
		else
		addRank(dvar);
		
		i++;
	}
	
}

/*setupPlayerRanks()
{
	for (i=1; i<level.rank.size; i++) 
	{
		ii = 1;
		for (;;)
		{
			dvar = getdvar("rank_" + level.rank[i].title + "_slot_" + ii);
			if (dvar== "")
			break;
			else
			addGuid(level.rank[i].ID, dvar);
			
			ii ++;
		}
	}
	//level.rank[0].players[0] = "062dfa3f";
}*/

loadPlayerRank()
{
	self.title = "";
	self.overrideStatusIcon = "";
	self.power = 0;
	guid = self getGuid();
	
	if (guid == "")
	{
		self.title = "^5HOST";
		self.power = 100;
		//self.overrideStatusIcon = "icon_dev";
		//self.statusicon = self.overrideStatusIcon;
		return 1;
	}
	
	for (i=0; i<level.rank.size; i++)
	{
		struct = level.rank[i];
		for (ii=0;ii<struct.players.size;ii++)
		{
			if (struct.players[ii] == getSubStr( guid, 24, 32 ))
			{
				self.title = struct.title;
				self.power = struct.power;
				self.overrideStatusIcon =  struct.icon;
				self.statusicon = self.overrideStatusIcon;
				return 1;
			}
		}
	}
	return 0;
}

addGuid(rank_title, guid)
{
	for (i=1; i<level.rank.size; i++)
	{
		if (IsSubStr(rank_title, level.rank[i].title) )
		{
			level.rank[i].players[level.rank[i].players.size] = guid;
			return;
		}
	}
}

addRank(title, power, icon)
{
	struct = spawnstruct();
	struct.ID = level.rank.size;
	level.rank[level.rank.size] = struct;
	struct.title = title;
	struct.power = power;
	if (!isdefined(icon))
	icon = "";
	struct.players = [];
	
}