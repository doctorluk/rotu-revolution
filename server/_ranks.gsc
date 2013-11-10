/**********************************
	---- Reign of the Undead ----
			   v2.0
	
	(Do not copy without permission)
	
	Date: November 2010
	Version: 2.000
	Author: Bipo
		
	© Reign of the Undead Team
************************************/

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