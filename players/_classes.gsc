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
	level.player_stat_rank["soldier"] = 430;
	level.player_stat_rank["stealth"] = 431;
	level.player_stat_rank["armored"] = 432;
	level.player_stat_rank["engineer"] = 433;
	level.player_stat_rank["scout"] = 434;
	level.player_stat_rank["medic"] = 435;
	updateGlobalClassCounts();
}

getSkillpoints(rank)
{
	self endon("disconnect");
	modRank = rank + 60 * self.pers["prestige"]; // Get 60 additional skillpoints per prestige
	if ( !level.dvar["game_class_ranks"] )
	{
		self.skillpoints = 0;
		self skillPointsNotify(self.skillpoints);
		self setclientdvar("ui_skillpoints", self.skillpoints);
		return;
	}
	self.rank["soldier"] = self getstat(level.player_stat_rank["soldier"]);
	wait 0.05;
	self.rank["stealth"] = self getstat(level.player_stat_rank["stealth"]);
	wait 0.05;
	self.rank["medic"] = self getstat(level.player_stat_rank["medic"]);
	wait 0.05;
	self.rank["scout"] = self getstat(level.player_stat_rank["scout"]);
	wait 0.05;
	self.rank["armored"] = self getstat(level.player_stat_rank["armored"]);
	wait 0.05;
	self.rank["engineer"] = self getstat(level.player_stat_rank["engineer"]);
	self.skillpoints = 0;
	spent = self.rank["soldier"] + self.rank["stealth"] + self.rank["medic"] + self.rank["scout"] + self.rank["armored"] + self.rank["engineer"];
	self.skillpoints = modRank - spent;
	
	if (self.rankHacker)
		self.skillpoints = 0;
		
	if ( modRank > 174)
		self.skillpoints = 174 - spent;
	
	self skillPointsNotify(self.skillpoints);
	self setclientdvar("ui_skillpoints", self.skillpoints);
}

skillPointsNotify(points)
{
	if (points > 0)
	{
		if (!isdefined(self.sptxt))
		{
			self.sptxt = newClientHudElem(self);
			self.sptxt.elemType = "font";
			self.sptxt.font = "default";
			self.sptxt.fontscale = 1.6;
			self.sptxt.x = 6;
			self.sptxt.y = 420;
			self.sptxt.color = (1, 0.8, 0.4);
			self.sptxt.glowAlpha = 0;
			self.sptxt.hideWhenInMenu = true;
			self.sptxt.archived = false;
			self.sptxt.alignX = "center";
			self.sptxt.alignY = "middle";
			self.sptxt.horzAlign = "center";
			self.sptxt.vertAlign = "top";
			self.sptxt.alpha = 1;
			self.sptxt.label = &"ZOMBIE_AVAILABLE_SKILLPOINTS";
		}
		self.sptxt setValue(points);
	}
	else
	{
		if (isdefined(self.sptxt))
		self.sptxt destroy();
	}
}

incClassRank(type)
{
	if (!level.dvar["game_class_ranks"])
	return ;
	
	if (self.skillpoints > 0)
	{
		newrank = self.rank[type] + 1;
		if (isdefined(newrank) && newrank < 30)
		{
			self.rank[type] = newrank;
			self.skillpoints -= 1;
			self skillPointsNotify(self.skillpoints);
			self setclientdvar("ui_skillpoints", self.skillpoints);
			self setstat(level.player_stat_rank[type], newrank);
		}
	}
}

updateGlobalClassCounts(){
	level endon("game_ended");
	while(1){
		level.classcount["soldier"] = 0;
		level.classcount["stealth"] = 0;
		level.classcount["armored"] = 0;
		level.classcount["engineer"] = 0;
		level.classcount["scout"] = 0;
		level.classcount["medic"] = 0;
		for(i = 0; i < level.players.size; i++){
			p = level.players[i];
			if(p.isActive){
				switch(p.class){
					case "soldier": level.classcount["soldier"]++; break;
					case "stealth": level.classcount["stealth"]++; break;
					case "armored": level.classcount["armored"]++; break;
					case "engineer": level.classcount["engineer"]++; break;
					case "scout": level.classcount["scout"]++; break;
					case "medic": level.classcount["medic"]++; break;
				}
			}
		}
		// iprintln("UPDATED CLASSCOUNTS!\nSoldier: " + level.classcount["soldier"] + ", Assassin: " + level.classcount["stealth"] + ", Armored: " + level.classcount["armored"] + ", Engineer: " + level.classcount["engineer"] + ", Scout: " + level.classcount["scout"] + ", Medic: " + level.classcount["medic"]);
		setGlobalClassCounts();
		level waittill("update_classcounts");
	}
}

setGlobalClassCounts(){
	for(i = 0; i < level.players.size; i++){
		p = level.players[i];
		p setclientdvars(
		"ui_classcount_soldier", level.classcount["soldier"],
		"ui_classcount_stealth", level.classcount["stealth"],
		"ui_classcount_armored", level.classcount["armored"],
		"ui_classcount_engineer", level.classcount["engineer"],
		"ui_classcount_scout", level.classcount["scout"],
		"ui_classcount_medic", level.classcount["medic"]
		);
	}
}


pickClass(class)
{
	if (isValidClass(class) )
	{
		//if (self.class==class)
		//return;
		//self setstat(434, 0);
		//self setstat(444, 1000);

		
		self setclientdvars("ui_class_rank", level.player_stat_rank[class]);
		self.class = class;
		self.pers["class"] = class;
		self setclientdvar("ui_loadout_class", class);
		self setclientdvar("ui_secondary_ability", "@ZOMBIE_NONE");
		self setclientdvar("ui_secondary_ability_4", 0);
		self setclientdvar("ui_secondary_ability_5", 0);
		self openMenu( game["menu_changeclass_ability"]  );
		self.secondaryAbility = "none";
	}
}


isValidClass(class)
{
	if (class == "soldier" || class == "stealth" || class == "armored" || class == "scout" || class == "medic" || class == "engineer")
	return true;
	
	return false;
}

pickSecondary(ability)
{
	if (self.class != "none")
	{
		rank = self getClassRank(self.class);
		if (scripts\players\_abilities::getAbilityAllowed(self.class, rank, "SC", ability))
		{
			self.secondaryAbility = ability;
			self setclientdvar("ui_secondary_ability", "@ZOMBIE_" + self.class + "_SC_" + ability);
		}
	}
}

acceptClass()
{
	if (self.class != "none")
	{
		self closeMenu();
		self closeInGameMenu();
		if (self.pers["team"] == "spectator") {
			self scripts\players\_players::joinAllies();
			self thread scripts\players\_players::spawnPlayer();
			return;
		}
		if (self.isActive)
		{
			self iprintlnbold("Class will change next wave (not implemented yet)");
		} else {
			self thread scripts\players\_players::spawnPlayer();
		}
	} else  {
		self iprintlnbold("Select a class!");
	}
}

getClassRank(class)
{
	if (!level.dvar["game_class_ranks"])
	return 29;
	else
	return self getStat(level.player_stat_rank[class]);
}