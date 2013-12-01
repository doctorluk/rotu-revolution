/**********************************
	---- Reign of the Undead ----
			   v2.0
	
	(Do not copy without permission)
	
	Date: November 2010
	Version: 2.000
	Author: Bipo
		
	© Reign of the Undead Team
************************************/

//BOT MODELS AND ANIMATIONS
#include scripts\include\hud;
#include scripts\include\useful;
#include scripts\include\entities;
#include scripts\include\data;

initZomModels()
{
	level.zom_models = [];
	
	/* Make all possible variations between bodies and heads */
	bodies = [];
	heads = [];
	
	bodies[bodies.size] = "body_sp_russian_loyalist_a_dead";
	bodies[bodies.size] = "body_sp_russian_loyalist_b_dead";
	bodies[bodies.size] = "body_sp_russian_loyalist_d_dead";
	
	heads[heads.size] = "head_sp_loyalist_alex_helmet_body_a_dead";
	heads[heads.size] = "head_sp_loyalist_mackey_hat_body_b_dead";
	heads[heads.size] = "head_sp_loyalist_tom_hat_body_d_dead";

	for(i = 0; i < bodies.size; i++)
		for(ii = 0; ii < heads.size; ii++){
			addZomModel("zombie", bodies[i], heads[ii]);
			addZomModel("zombie_all", bodies[i], heads[ii]);
		}
			
	bodies = [];
	heads = [];
	
	bodies[bodies.size] = "char_ger_honorgd_bodyz1_1";
	bodies[bodies.size] = "char_ger_honorgd_bodyz2_1";
	bodies[bodies.size] = "char_ger_honorgd_bodyz2_2";
	bodies[bodies.size] = "bo1_c_usa_pent_zombie_scientist_body";
	
	heads[heads.size] = "char_ger_honorgd_zombiehead1_1";
	heads[heads.size] = "char_ger_honorgd_zombiehead1_2";
	heads[heads.size] = "char_ger_honorgd_zombiehead1_3";
	heads[heads.size] = "char_ger_honorgd_zombiehead1_4";
	heads[heads.size] = "bo1_c_ger_zombie_head1";
	heads[heads.size] = "bo1_c_ger_zombie_head2";
	heads[heads.size] = "bo1_c_ger_zombie_head3";
	heads[heads.size] = "bo1_c_ger_zombie_head4";
	
	for(i = 0; i < bodies.size; i++)
		for(ii = 0; ii < heads.size; ii++){
			addZomModel("zombie", bodies[i], heads[ii]);
			addZomModel("zombie_all", bodies[i], heads[ii]);
		}
	bodies = [];
	heads = [];
	
	// These combinations are unique, since the body does not include arms and needs a head that also attaches arms
	addZomModel("zombie", "body_sp_russian_loyalist_c_dead", "head_sp_loyalist_josh_helmet_body_c_dead");
	addZomModel("zombie_all", "body_sp_russian_loyalist_c_dead", "head_sp_loyalist_josh_helmet_body_c_dead");
	
	//
	addZomModel("zombie", "bo1_c_viet_zombie_female", "bo1_c_viet_zombie_female_head");
	addZomModel("zombie_all", "bo1_c_viet_zombie_female", "bo1_c_viet_zombie_female_head");
	
	addZomModel("zombie", "bo1_c_viet_zombie_nva1_body", "bo1_c_viet_zombie_nva1_head1");
	addZomModel("zombie_all", "bo1_c_viet_zombie_nva1_body", "bo1_c_viet_zombie_nva1_head1");
	
	addZomModel("napalm", "bo1_c_viet_zombie_napalm", "bo1_c_viet_zombie_napalm_head");
	
	
	// Tank
	bodies[bodies.size] = "bo1_c_zom_cosmo_cosmonaut_body";
	heads[heads.size] = "bo1_c_zom_cosmo_head1";
	heads[heads.size] = "bo1_c_zom_cosmo_head2";
	heads[heads.size] = "bo1_c_zom_cosmo_head3";
	heads[heads.size] = "bo1_c_zom_cosmo_head4";
	for(i = 0; i < bodies.size; i++)
		for(ii = 0; ii < heads.size; ii++){
			addZomModel("tank", bodies[i], heads[ii]);
		}
	bodies = [];
	heads = [];
	
	// Fast
	bodies[bodies.size] = "bo1_c_usa_pent_zombie_officeworker_body";
	heads[heads.size] = "char_ger_honorgd_zombiehead1_1";
	heads[heads.size] = "char_ger_honorgd_zombiehead1_2";
	heads[heads.size] = "char_ger_honorgd_zombiehead1_3";
	heads[heads.size] = "char_ger_honorgd_zombiehead1_4";
	for(i = 0; i < bodies.size; i++)
		for(ii = 0; ii < heads.size; ii++){
			addZomModel("fast", bodies[i], heads[ii]);
		}
	bodies = [];
	heads = [];
	
	// Fat
	bodies[bodies.size] = "bo1_c_usa_pent_zombie_militarypolice_body";
	bodies[bodies.size] = "bo1_c_zom_cosmo_spetznaz_body";
	heads[heads.size] = "bo1_c_zom_head_1";
	heads[heads.size] = "bo1_c_zom_head_2";
	heads[heads.size] = "bo1_c_zom_head_3";
	heads[heads.size] = "bo1_c_zom_head_4";
	for(i = 0; i < bodies.size; i++)
		for(ii = 0; ii < heads.size; ii++){
			addZomModel("fat", bodies[i], heads[ii]);
		}
	bodies = [];
	heads = [];
	
	addZomModel("electric", "bo2_c_zom_avagadro_fb", "");
	
	// OLD WAS COMPLETELY COMMENTED OUT
	// addZomModel("zombie", "body_sp_russian_loyalist_a_dead", "head_sp_loyalist_alex_helmet_body_a_dead");
	// addZomModel("zombie", "body_sp_russian_loyalist_b_dead", "head_sp_loyalist_alex_helmet_body_a_dead");
	// addZomModel("zombie", "body_sp_russian_loyalist_a_dead", "head_sp_loyalist_alex_helmet_body_a_dead");
	// addZomModel("zombie", "body_sp_russian_loyalist_b_dead", "head_sp_loyalist_mackey_hat_body_b_dead");
	// addZomModel("zombie", "body_sp_russian_loyalist_c_dead", "head_sp_loyalist_josh_helmet_body_c_dead");
	// addZomModel("zombie", "body_sp_russian_loyalist_d_dead", "head_sp_loyalist_tom_hat_body_d_dead");
	
	
	// OLD
	/*
	addZomModel("zombie_all", "izmb_zombie1_body", "izmb_zombie2_head");
	addZomModel("zombie_all", "izmb_zombie2_body", "izmb_zombie2_head");
	addZomModel("zombie_all", "izmb_zombie3", "");
	addZomModel("zombie_all", "body_complete_sp_russian_farmer", ""); //
	addZomModel("zombie_all", "body_complete_sp_vip", ""); //""
	addZomModel("zombie_all", "body_complete_sp_zakhaevs_son", "");
	addZomModel("zombie", "izmb_zombie1_body", "izmb_zombie2_head");
	addZomModel("zombie", "izmb_zombie2_body", "izmb_zombie2_head");
	addZomModel("zombie", "izmb_zombie3", "");
	*/
	
	addZomModel("quad", "bo_quad", "");
	// addZomModel("dog", "german_sheperd_dog", "");
	addZomModel("dog", "zombie_wolf", "");
	// addZomModel("halfboss", "bo1_c_zom_george_romero_zombiefied_fb", "");
	addZomModel("halfboss", "zom_george_romero", "");
	// addZomModel("boss", "body_sp_russian_loyalist_a_dead", "head_sp_loyalist_alex_helmet_body_a_dead");
	addZomModel("boss", "cyclops", "");
	// addZomModel("zombified_player", "skeleton", "");
	level.bossIsOnFire = false;
	initGroupedSettings();
}

initGroupedSettings(){
	/* Give zombie types a certain percentage chance to be spawned  */
	
	level.zombieProbability = [];
	level.zombieProbability[0] = 5; // Zombie
	level.zombieProbability[1] = 5; // Dog
	level.zombieProbability[2] = 5; // Tank
	level.zombieProbability[3] = 5; // Burning
	level.zombieProbability[4] = 5; // toxic
	level.zombieProbability[5] = 100; // halfboss
	level.zombieProbability[6] = 5; // Napalm
	// level.zombieProbability[7] = 5; // Electric
	
	level.zombieProbabilityScenario = [];
	setZombieProbabilityScenario(0, "normal zombies", 35, 10, 10, 10, 10, 0, 5/*, 0*/);
	setZombieProbabilityScenario(1, "burning only", 0, 0, 0, 3, 0, 0, 1/*, 0*/);
	setZombieProbabilityScenario(2, "crawlers only", 0, 0, 0, 0, 1, 0, 0/*, 0*/);
	setZombieProbabilityScenario(3, "tanks only", 0, 0, 1, 0, 0, 0, 0/*, 0*/);
	setZombieProbabilityScenario(4, "burning + crawlers", 0, 0, 0, 3, 3, 0/*, 1*/);
	setZombieProbabilityScenario(5, "tank + crawlers", 0, 0, 1, 1, 0, 0, 0/*, 0*/);
	setZombieProbabilityScenario(6, "all + boss", 30, 10, 10, 10, 10, 1, 10/*, 10*/);
	setZombieProbabilityScenario(7, "tank + dogs + boss", 0, 10, 40, 0, 0, 1, 0/*, 0*/);
	setZombieProbabilityScenario(8, "dogs + burning", 0, 3, 0, 3, 0, 0, 1/*, 0*/);
	// setZombieProbabilityScenario(0, "test", 0, 0, 0, 0, 0, 0, 1);
	
	/* Limit the amount of bullet-damageable bosses on the server, because too many can be.... quite.... devastating */
	level.bossBulletLimit = level.dvar["game_difficulty"];
	level.bossBulletCount = 0;
}

getTotalZombieProbability(){ // In case it exceeds "100%" in total
	total = 0;
	for(i = 0; i < level.zombieProbability.size; i++)
		total += level.zombieProbability[i];
	
	return total;
}

addZomModel(type, body, head)
{
	if (isdefined(level.zom_models[type]))
	{
		size = level.zom_models[type].size;
		level.zom_models[type][size] = body;
		level.zom_models_head[type][size] = head;
	}
	else
	{
		level.zom_models[type][0] = body;
		level.zom_models_head[type][0] = head;
	}
}

loadZomModel(type)
{
	self DetachAll(); 

	modelType = level.zom_types[type].modelType;
	id = randomint(level.zom_models[modelType].size);
	self setmodel(level.zom_models[modelType][id]);
	head = level.zom_models_head[modelType][id];
	if (head != ""){
		self.head = head;
		self attach(head);
	}
}


loadAnimTree(type)
{
	animTree = level.zom_types[type].animTree;
	switch (animTree)
	{
		case "zombie":
			ran = randomint(2);
			self.animation["stand"] = "bot_zombie_stand_mp"; // bot_zom_stand
			self.animation["walk"] = "bot_zombie_walk_mp"; // bot_zom_walk
			self.animation["sprint"] = "bot_zombie_run"+ran+"_mp"; // bot_zom_run0 and bot_zom_run1
			self.animation["melee"] = "bot_zombie_melee_mp"; // bot_zom_melee
		break;
		case "zombiefast":
			self.animation["stand"] = "bot_zombie_stand_mp"; // bot_zom_stand
			self.animation["walk"] = "bot_zombie_walk_mp"; // bot_zom_walk
			self.animation["sprint"] = "m40a3_acog_mp"; // bot_zom_runfast
			self.animation["melee"] = "bot_zombie_melee_mp"; // bot_zom_melee
		break;
		case "dog":
			self.animation["stand"] = "bot_dog_idle_mp"; // bot_dog_idle
			self.animation["sprint"] = "bot_dog_run_mp"; // bot_dog_run
			self.animation["melee"] = "defaultweapon_mp"; // bot_dog_attack
		break;
		case "boss":
			ran = randomint(2);
			self.animation["stand"] = "bot_zombie_stand_mp"; // bot_zom_stand
			self.animation["sprint"] = "bot_zombie_run"+ran+"_mp"; // bot_zom_run0 and bot_zom_run1
			self.animation["melee"] = "bot_zombie_melee_mp"; // bot_zom_melee
			self.animation["jump"] = "g36c_gl_mp"; // bot_zom_melee
		break;
		case "quad":
			self.animation["stand"] = "flash_grenade_mp"; // bot_quad_idle
			self.animation["walk"] = "concussion_grenade_mp"; // bot_quad_crawl
			self.animation["sprint"] = "smoke_grenade_mp"; // bot_quad_sprint
			self.animation["melee"] = "g3_gl_mp"; // bot_quad_attack
		break;
	}
}


// TYPES

initZomTypes()
{
	level.zom_types = [];
	// addZomType(name, modelType, animTree, walkSpeed, runSpeed, meleeSpeed, meleeRange, damage, maxHealth, meleeTime, sprintOnly, infectionChance, soundType, rewardMultiplier)
	addZomType("zombie", "zombie", "zombie",	 16, 40, 20, 96 , 40, 200  , .8, 0, .075 , "zombie", 1); // Default zombie
	addZomType("burning", "zombie_all", "zombie",	 16, 36, 20, 96 , 40, 200  , .8, 1, 0    , "zombie", 0.8); // Code handled
	addZomType("napalm", "napalm", "zombie",	 16, 36, 20, 50 , 100, 100  , .8, 1, 0    , "zombie", 0.75); // Code handled
	addZomType("scary", "zombie_all", "zombie",	 18, 36, 20, 96 , 40, 200  , .8, 0, .01, "zombie", 0.8); // Code handled
	addZomType("toxic", "quad", "quad",		 8, 32, 16, 104 , 30, 180  , .6, 0, .15, "zombie",1); // Code handled
	addZomType("fat", "fat", "zombie",			 16, 42, 16, 100, 40, 275  , .8, 0, 0.05 , "zombie", 1.2);
	addZomType("fast", "fast", "zombiefast",	 20, 55, 24, 96 , 40, 150  , .7, 1, 0.075, "zombie", 0.8);
	addZomType("tank", "tank", "zombie", 		 16, 40, 20, 100, 30, 800  , .8, 0, 0.05 , "zombie", 1.35);
	// addZomType("electric", "electric", "zombie",  16, 40, 20, 100, 30, 800  , .8, 0, 0.05 , "zombie");
	addZomType("halfboss", "halfboss", "zombie",	 16, 40, 20, 96 , 90, 5000 + (2000 * level.activePlayers) , .8, 0, .0 , "zombie", 3); // Default zombie
	//addZomType("boss", "boss", "zombie", 30, 50, 20, 120, 65, 10000, .8, 1, "zombie");
	addZomType("dog", "dog", "dog", 			 18, 58, 30, 96 , 30, 125  , .8, 1, 0.08, "dog", 0.5); // Dog zombie
	addZomType("boss", "boss", "boss", 		 20, 58, 30, 160, 80, 10000, 1, 1, 0    , "zombie", 1);
	addZomType("boss_bullet", "boss", "boss", 		 20, 58, 30, 160, 80, 10000, .8, 1, 0    , "zombie", 5);
}

getBlurForType(type)
{
	switch (type)
	{
		case "burning":
		return .65;
		case "toxic":
		return 1;
		default:
		return level.dvar["env_blur"];
	}
}

getSpawntypeForType(type){
	switch(type){
		case "tank": return 1;
		case "toxic": return 2;
		default: return 0;
	}
}

/* According to the global probability, this function chooses a random zombie */
getRandomZombieType(){
	returns = "";
	if(level.bossBulletCount < level.bossBulletLimit)
		ran = randomint(getTotalZombieProbability());
	else
		ran = randomint(getTotalZombieProbability() - getZombieProbability("halfboss"));
		
	if(ran < getZombieProbability("zombie"))
		returns = "zombie";
	else if(ran < ( getZombieProbability("zombie") + getZombieProbability("dog") ) )
		returns = "dog";
	else if(ran < ( getZombieProbability("zombie") + getZombieProbability("dog") + getZombieProbability("tank") ) )
		returns = "tank";
	else if(ran < ( getZombieProbability("zombie") + getZombieProbability("dog") + getZombieProbability("tank") + getZombieProbability("burning") ) )
		returns = "burning";
	else if(ran < ( getZombieProbability("zombie") + getZombieProbability("dog") + getZombieProbability("tank") + getZombieProbability("burning")+ getZombieProbability("toxic") ) )
		returns = "toxic";
	else if(ran < ( getZombieProbability("zombie") + getZombieProbability("dog") + getZombieProbability("tank") + getZombieProbability("burning")+ getZombieProbability("toxic") + getZombieProbability("halfboss") ) )
		returns = "halfboss";
	else if(ran <= ( getZombieProbability("zombie") + getZombieProbability("dog") + getZombieProbability("tank") + getZombieProbability("burning")+ getZombieProbability("toxic") + getZombieProbability("halfboss") + getZombieProbability("napalm")) )
		returns = "napalm";
	// else if(ran <= ( getZombieProbability("zombie") + getZombieProbability("dog") + getZombieProbability("tank") + getZombieProbability("burning")+ getZombieProbability("toxic") + getZombieProbability("halfboss") + getZombieProbability("napalm") + getZombieProbability("electric")) )
		// returns = "electric";
	// iprintln("ran is " + ran + " and spawns: " + returns);
	return returns;
}

/* Set certain probability to spawn type of zombie */
setZombieProbability(type, probability){
	level.zombieProbability[getZombieProbabilityIndex(type)] = probability;
}

setZombieProbabilityScenario(index, description, prob0, prob1, prob2, prob3, prob4, prob5, prob6/*, prob7*/){
	if(isDefined(level.zombieProbabilityScenario[index]))
		return;
	level.zombieProbabilityScenario[index]["description"] = description;
	level.zombieProbabilityScenario[index]["prob0"] = prob0;
	level.zombieProbabilityScenario[index]["prob1"] = prob1;
	level.zombieProbabilityScenario[index]["prob2"] = prob2;
	level.zombieProbabilityScenario[index]["prob3"] = prob3;
	level.zombieProbabilityScenario[index]["prob4"] = prob4;
	level.zombieProbabilityScenario[index]["prob5"] = prob5;
	level.zombieProbabilityScenario[index]["prob6"] = prob6;
	// level.zombieProbabilityScenario[index]["prob7"] = prob7;

}

/* Loop that rotates the scenarios, waiting fWaitingTime */
randomZombieProbabilityScenario(waitingTime){
	level endon("game_ended");
	level endon("wave_finished");
	assert(waitingTime >= 0.05);
	while(1){
		ran = randomint(level.zombieProbabilityScenario.size);
		i = 0;
		while(isDefined(level.zombieProbabilityScenario[ran]["prob"+i])){
			setZombieProbability(getZombieProbabilityType(i), level.zombieProbabilityScenario[ran]["prob"+i]);
			i++;
		}
		iprintln("Loading scenario '^3" + level.zombieProbabilityScenario[ran]["description"] + "^7'");
		wait waitingTime;
	}

}

getZombieProbability(type){
	return level.zombieProbability[getZombieProbabilityIndex(type)];
}

/* To get from index to typename */
getZombieProbabilityType(index){
	switch(index){
		case 0: return "zombie";
		case 1: return "dog";
		case 2: return "tank";
		case 3: return "burning";
		case 4: return "toxic";
		case 5: return "halfboss";
		case 6: return "napalm";
		// case 7: return "electric";
	}
}
/* To get from typename to index */
getZombieProbabilityIndex(type){
	switch(type){
		case "zombie": return 0;
		case "dog": return 1;
		case "tank": return 2;
		case "burning": return 3;
		case "toxic": return 4;
		case "halfboss": return 5;
		case "napalm": return 6;
		// case "electric": return 7;
	}
}

addToSpawnTypes(type){
	switch(type){
		case "dog": return true;
		case "tank": return true;
		case "burning": return true;
		case "toxic": return true;
		case "napalm": return true;
		default: return false;
	}
}

/* Function to do something while announcing the new zombie wave */
/* NOT THREADED */
preWave(type){
	level endon("game_ended");
	switch(type){
		case "scary":
			thread playSoundOnAllPlayers( "wave_start", randomfloat(1) );
			label = [];
			label[label.size] = &"ZOMBIE_SCARYWAVE_AFTER0";
			label[label.size] = &"ZOMBIE_SCARYWAVE_AFTER1";
			label[label.size] = &"ZOMBIE_SCARYWAVE_AFTER2";
			
			announceMessage(&"ZOMBIE_SCARYWAVE", level.waveSize, (.7,.2,0), 5.5, 85);
			
			level.flashlightEnabled = true;
			scripts\players\_players::flashlightForAll(true);
			wait 6.5 + randomfloat(1); // Wait at least as long as the announceMessage takes
			
			announceMessage(label[randomint(label.size)], "", (1,.3,0), 6, 85, undefined, 15);
			wait 2;
			
			scripts\bots\_types::setTurretsEnabledForType(type);
			
			for(i = 0; i < level.players.size; i++){
				if(level.players[i].isActive && level.players[i].isAlive){
					level.players[i] shellshock("general_shock", 7);
					level.players[i] thread scripts\players\_players::flickeringHud(getTime() + 6000);
				}
			}
			break;
		case "boss":
			thread playSoundOnAllPlayers( "wave_start", randomfloat(1) );
			announceMessage(&"ZOMBIE_NEWBOSSWAVE", undefined, (.7,.2,0), 5, 85);
			wait 5;
			break;
		case "normal":
			thread playSoundOnAllPlayers( "wave_start", randomfloat(1) );
			announceMessage( level.announceNormal[ randomint(level.announceNormal.size) ] , level.waveSize, (.2,.7,0), 4, 95);
			wait 5;
			break;
		default:
			thread playSoundOnAllPlayers( "wave_start", randomfloat(1) );
			announceMessage(&"ZOMBIE_NEWSPECIALWAVE", level.zom_typenames[type], (.7,.2,0), 5, 85);
			wait 5;
			break;
	}

}

setTurretsEnabledForType(type)
{
	switch (type)
	{
		case "scary":
			level.turretsDisabled = 1;
			scripts\players\_shop::disableTurrets(1);
			break;
		default:
			level.turretsDisabled = 0;
			scripts\players\_shop::disableTurrets(0);
			break;
	}
}

getZombieType(type){
	switch(type){
		case "grouped": return getRandomZombieType();
		default: return type;
		case "burning":
			ran = randomfloat(1);
			if(ran < 0.8)
				return "burning";
			else
				return "napalm";
	}
}

getSpawnType(zombieType, waveType){
	switch(waveType){
		case "grouped": 
			switch(zombieType){
				case "tank": return getSpawntypeForType("tank");
				case "toxic": return getSpawntypeForType("toxic");
				case "electric": return getSpawntypeForType("electric");
				default: return 0;
			}
		case "electric": return 3;
		case "toxic": return 2;
		case "tank": return 1;
		default: return 0;
	}
}

getWaveFactorForType(type){
	switch(type){
	
		case "boss":
			return 0;
		case "scary":
			return 0.6;
		case "grouped":
			return 0.8;
		case "burning":
			return 0.6;
		case "tank":
			return 0.5;
		case "finale":
			return 0.6;
		case "electric":
			return 0.4;
		default:
			return 0.25;
	}
}

getRandomSpecialWaveType(ignoreLastType){		
	previousType = "";
	type = "";
	
	if(!isDefined(ignoreLastType))
		ignoreLastType = false;
		
	if(ignoreLastType){
		previousType = level.lastSpecialWave;
		if(previousType != "" && previousType != "boss")
			level.availableSpecialWaves = removeFromArray(level.availableSpecialWaves, previousType);
	}
		
	type = level.availableSpecialWaves[randomint(level.availableSpecialWaves.size)];
	
	if(previousType != "" && previousType != "boss")
		level.availableSpecialWaves[level.availableSpecialWaves.size] = previousType;
	
	return type;
}

getAmbientForType(type)
{
	switch (type)
	{
		case "burning":
			return "ambient_inferno";
		case "normal":
			return "zom_ambient";
		case "toxic":
			return "ambient_toxic";
		case "scary":
			return "ambient_scary";
		case "tank":
			return "ambient_tank";
		case "grouped":
			return "ambient_grouped";
		case "boss":
			return "ambient_boss";
		case "dog":
			thread playSoundOnAllPlayers("dog_howl");
			return "zom_ambient";
		default:
			return "zom_ambient";
	}
}

getFogForType(type)
{
	switch (type)
	{
		case "toxic":
			return "toxic";
		case "boss":
			return "boss";
		case "scary":
			return "scary";
		case "grouped":
			return "grouped";
		case "tank":
			return "tank";
		default:
			return "";
	}
}

getVisionForType(type)
{
	switch (type)
	{
		case "burning":
			return "inferno";
		case "boss":
			return "boss";
		case "scary":
			return "night";
		default:
			return "";
	}
}

getFxForType(type)
{
	switch (type)
	{
		case "burning":
			return "ember";
		case "tank":
			return "lightning";
		case "boss":
			return "lightning_boss";
		default:
			return "";
	}
}

addZomType(name, modelType, animTree, walkSpeed, runSpeed, meleeSpeed, meleeRange, damage, maxHealth, meleeTime, sprintOnly, infectionChance, soundType, rewardMultiplier)
{
	struct = spawnstruct();
	level.zom_types[name] = struct;
	struct.modelType = modelType;
	struct.animTree = animTree;
	struct.walkSpeed = walkSpeed;
	struct.runSpeed = runSpeed;
	struct.meleeSpeed = meleeSpeed;
	struct.meleeRange = meleeRange;
	struct.damage = damage;
	struct.maxHealth = maxHealth;
	struct.meleeTime = meleeTime;
	struct.sprintOnly = sprintOnly;
	struct.infectionChance = infectionChance;
	struct.soundType = soundType;
	struct.barricadeDamage = damage;
	struct.spawnFX = undefined;
	struct.rewardMultiplier = rewardMultiplier;
	
}

loadZomStats(type)
{
	struct = level.zom_types[type];
	
	self.walkSpeed = struct.walkSpeed;
	self.runSpeed = struct.runSpeed;
	self.meleeSpeed = struct.meleeSpeed;
	self.meleeRange = struct.meleeRange;
	self.damage = struct.damage;
	self.barricadeDamage = struct.barricadeDamage;
	self.meleeTime = struct.meleeTime;
	self.sprintOnly = struct.sprintOnly;
	self.maxHealth = int(struct.maxHealth);
	self.infectionChance = struct.infectionChance;
	self.soundType = struct.soundType;
	self.rewardMultiplier = struct.rewardMultiplier;
	
	self.walkOnly = false;
	if ( randomfloat(1) > level.slowBots )
	{
		self.walkOnly = true;
	}
}

onSpawn(type)
{
	switch (type)
	{
		case "burning":
			self thread createEffectEntity(level.burningFX, "j_spinelower" );
			self playloopsound("fire_wood_medium");
			break;
		case "zombie":
				PlayFXOnTag( level.eye_le_fx, self, "j_eyeball_le" );
				PlayFXOnTag( level.eye_ri_fx, self, "j_eyeball_ri" );
			break;
		case "fat":
				PlayFXOnTag( level.eye_le_fx, self, "j_eyeball_le" );
				PlayFXOnTag( level.eye_ri_fx, self, "j_eyeball_ri" );
			break;
		case "fast":
				PlayFXOnTag( level.eye_le_fx, self, "j_eyeball_le" );
				PlayFXOnTag( level.eye_ri_fx, self, "j_eyeball_ri" );
			break;
		case "scary":
				PlayFXOnTag( level.eye_le_fx, self, "j_eyeball_le" );
				PlayFXOnTag( level.eye_ri_fx, self, "j_eyeball_ri" );
		case "dog":
			// self thread createEffectEntity(level.burningFX, "j_head" );
			break;
		case "toxic":
			//PlayFXOnTag(level.toxicFX, self, "j_head");
			break;
		case "boss":
			level.bossPhases = 1;
			level.bossPhase = getRandomBossPhase();
			label = getLabelForBoss();
			colour = getColourForPhase();
			level.bossOverlay = overlayMessage(label, "", colour);
			level.bossOverlay setvalue(0);
			level.bossOverlay.alpha = 0;
			level.bossOverlay fadeOverTime( 1 );
			level.bossOverlay.alpha = 1;
			level.bossDamageDone[level.bossPhase] = 0;
			level.bossDamageToDo[level.bossPhase] = calculateBossHP();
			self.quake = true;
			self thread bossSpecialAttack();
			self thread spawnHitboxBot();
		break;
		case "napalm":
			PlayFXOnTag( level.napalmTummyGlowFX, self, "j_spineupper" );
			break;
	}
}

spawnHitboxBot(){
	bot = scripts\bots\_bots::getAvailableBot();
	assertEx( isDefined( bot ), "Error: Bot attached to boss is non existant!" );
	if ( !isDefined( bot ) ){
		iprintlnbold("^1ERROR^7: Could not get an available bot for the boss!");
		return;
	}
		
	self.attachment = spawn( "script_model", self getTagOrigin( "tag_origin" ) + (0,0,75) );
	self.attachment setModel( "tag_origin" );
	wait 0.05;
	self.attachment linkto(self);
	
	self.partner = bot;
	spawn = self.attachment;
	self.number = 0;
	scripts\bots\_bots::spawnPartner(spawn, bot, self);
}

getColourForPhase(){
	switch(level.bossPhase){
		case 0: return (1,0,0);
		case 1: return (0,1,0);
		case 2: return (1,1,0);
	}
}

/* Returns an HP amount to assign with a boss-phase */
calculateBossHP(){
	switch(level.dvar["game_difficulty"]){
		case 1: return (0.5 * getPhaseMulti() * level.activePlayers);
		case 2: return (0.8 * getPhaseMulti() * level.activePlayers);
		case 3: return (  1 * getPhaseMulti() * level.activePlayers);
		case 4:	return (1.5 * getPhaseMulti() * level.activePlayers);
	}
}
/* Gets generally considered "okay" multipliers for each stage-HP of the boss  */
getPhaseMulti(){
	// 0 = EXPLOSIVE, 1 = KNIFE, 2 = GUNFIRE
	switch(level.bossPhase){
		case 0: return 900 + (level.dvar["game_difficulty"] * 300);
		// case 0: return 120;
		case 1: return 900 + (level.dvar["game_difficulty"] * 300);
		// case 1: return 90;
		case 2: return 2200 + (level.dvar["game_difficulty"] * 300);
		// case 2: return 250;
	}
}
/* Returns either Explosive, Knife or Gunfire, but prevents the old one from being chosen */
getRandomBossPhase(){
	selection = level.bossPhase;
	while(selection == level.bossPhase){
		switch(level.dvar["game_difficulty"]){
			case 1: selection = randomint(2); break;
			case 2: selection = randomint(3); break;
			case 3: selection = randomint(3); break;
			case 4: selection = randomint(3); break;
		}
	}		
	return selection;
}

getLabelForBoss(){
	expl = [];
	expl[expl.size] = &"ZOMBIE_BOSS_EXPLOSIVES0";
	expl[expl.size] = &"ZOMBIE_BOSS_EXPLOSIVES1";
	expl[expl.size] = &"ZOMBIE_BOSS_EXPLOSIVES2";
	knife = [];
	knife[knife.size] = &"ZOMBIE_BOSS_KNIFE0";
	knife[knife.size] = &"ZOMBIE_BOSS_KNIFE1";
	knife[knife.size] = &"ZOMBIE_BOSS_KNIFE2";
	gun = [];
	gun[gun.size] = &"ZOMBIE_BOSS_GUNS0";
	gun[gun.size] = &"ZOMBIE_BOSS_GUNS1";
	gun[gun.size] = &"ZOMBIE_BOSS_GUNS2";
	
	switch(level.bossPhase){
		case 0: return expl[randomint(expl.size)];
		case 1: return knife[randomint(knife.size)];
		case 2: return gun[randomint(gun.size)];
	}
}

createEffectEntity(effect, origin, offset){
	if(isDefined(self.effect))
		return;
	if(!isDefined(offset))
		offset = (0,0,0);
	self endon("killed");
	self.effect = undefined;
	self.effect = spawn( "script_model", self getTagOrigin( origin ) + offset);
	self.effect setModel( "tag_origin" );
	wait 0.05;
	PlayFXOnTag( effect, self.effect, "tag_origin" );
	self.effect LinkTo( self );
}

bossSpecialAttack()
{
	self endon("death");
	wait 5;
	while (1)
	{
		self thread doSpecialAttack();
		wait 20 + randomint(10);
	}
}

doSpecialAttack()
{
	for (i=0; i<level.players.size; i++)
	{
		if (level.players[i].isAlive)
			self thread kill_ball_out(level.players[i]);
		wait 0.5 + randomfloat(1);
	}
}

bossCatchFire(){
	self endon("death");
	level endon("game_ended");
	
	self thread burnThrowback();
	range = 100;
	time = 2; // in seconds, we need 4 * time encounters to make us burn
	
	while(1){
		for(i = 0; i < level.players.size; i++){
			p = level.players[i];
			if( !isReallyPlaying(p) ) continue; // Ignore not-playing players
			
			if(distance(self.origin, p.origin) <= range && (p.fireCatchCount < time * 4) && !p.isDown && !p.isZombie ){
				p.fireCatchCount++;
			}
			else if(p.fireCatchCount > 0)
					if(p.fireCatchCount > time * 4)
						p.fireCatchCount = time * 4 - 2;
					else
						p.fireCatchCount -= 2;
			
			if(p.fireCatchCount >= time * 4){
				self thread bossBurn(p);
			}
		}
		wait 0.25;
	}

}

burnThrowback(){
	self endon("death");
	level endon("game_ended");
	level endon("wave_finished");
	
	level.bossThrowback = false;
	
	while(1){
		level.bossThrowback = !level.bossThrowback;
		iprintln("Throwback of burning boss is now " + level.bossThrowback);
		if(level.bossThrowback) // Make it turn off faster than turning on
			wait 5 + randomfloat(20);
		else
			wait 6 + randomfloat(20);
	}
}

bossBurn(target){
	fwdDir = anglestoforward(self getplayerangles());
	dirToTarget = vectorNormalize(target.origin-self.origin);
	dot = vectorDot(fwdDir, dirToTarget);
	if (dot > .5){
		target.isPlayer = true;
		//target.damageCenter = self.Mover.origin;
		target.entity = target;
		target damageEnt(
				self, // eInflictor = the entity that causes the damage (e.g. a claymore)
				self, // eAttacker = the player that is attacking
				int( self.damage * level.dif_zomDamMod * ( 0.05 + randomfloat( (level.dvar["game_difficulty"] * 0.05) ) ) ), // iDamage = the amount of damage to do
				"MOD_MELEE", // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
				self.pers["weapon"], // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
				self.origin, // damagepos = the position damage is coming from
				//(0,self GetPlayerAngles()[1],0) // damagedir = the direction damage is moving in      
				vectorNormalize(target.origin-self.origin)
			);
		if(level.bossThrowback)
			self onAttack(self.type, target);
	}
}
deleteKillBall(time)
{
	self endon("death");
	wait time;
	self delete();
}

kill_ball_out(p)
{
	offset = (0,0,40);
	ball_tag = spawn("script_model",self.origin + offset);
	ball_tag setModel("tag_origin");
	ball_tag thread deleteKillBall(10+level.players.size/5);
	wait 0.05;
	playFXOnTag(level.soulFX,ball_tag,"tag_origin");
	ball_tag endon("death");
	movespeed = 2;
	
	ball_tag moveto(self.origin + (0,0,400), 5);
	wait 5;
	while(isdefined(p) && !level.gameEnded)
	{
		wait 0.1;
		head_tag_org = p getTagOrigin("j_head");
		if(distance(ball_tag.origin,head_tag_org) > 30)
			{
			
			if (movespeed > 1.5)
			movespeed -= 0.05;
			
			if(distance(ball_tag.origin,head_tag_org) > 30 && distance(ball_tag.origin,head_tag_org) < 64)
				{movespeed = .1;}
				
			head_tag_org = p getTagOrigin("j_head");
			ball_tag moveTo(head_tag_org,movespeed);
				
			
			}
		else
		{
		p.isPlayer = true;
		p.entity = p;
		p damageEnt(
			self, // eInflictor = the entity that causes the damage (e.g. a claymore)
			self, // eAttacker = the player that is attacking
			int(50*level.dif_zomDamMod), // iDamage = the amount of damage to do
									"MOD_MELEE", // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
									self.pers["weapon"], // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
									self.origin, // damagepos = the position damage is coming from
									//(0,self GetPlayerAngles()[1],0) // damagedir = the direction damage is moving in      
									vectorNormalize(p.origin-self.origin)
								);
		ball_tag delete();
		break;
		}

	}
	ball_tag delete();
}


onDamage(type, sMeansOfDeath, sWeapon, iDamage, eAttacker)
{
	switch (type)
	{
		case "boss":
			self.health = 10000;
			/* EXPLOSIVES */
			if ( level.bossPhase == 0 )
			{
				if (sMeansOfDeath != "MOD_IMPACT")
				{
					if ( ( sWeapon == "c4_mp" || sWeapon == "frag_grenade_mp" || sWeapon == "claymore_mp" || sWeapon == "rpg_mp" || sWeapon == "at4_mp" || sMeansOfDeath == "MOD_MELEE" ) )
					{
						if( isDefined( eAttacker.lastBossHit ) && eAttacker.lastBossHit != self.number ){
							eAttacker thread resetBossHit();
							return 0;
						}
						eAttacker.lastBossHit = self.number;
						if (sMeansOfDeath == "MOD_MELEE"){
							iDamage = int(iDamage*.5);
							eAttacker scripts\players\_players::incUpgradePoints(1*level.dvar["game_rewardscale"]);
						}
						else
							eAttacker scripts\players\_players::incUpgradePoints(5*level.dvar["game_rewardscale"]);
						
						level.bossDamageDone[level.bossPhase] += idamage;
						newval = int(level.bossDamageDone[level.bossPhase]*100/level.bossDamageToDo[level.bossPhase]);
						if (newval > 100)
						newval = 100;
						level.bossOverlay setvalue(newval);
						thread nextBossStatus();
						return 1;
					}
				}

			}
			/* KNIFE */
			else if ( level.bossPhase == 1 )
			{
				if (sMeansOfDeath == "MOD_MELEE")
				{
					eAttacker scripts\players\_players::incUpgradePoints(5*level.dvar["game_rewardscale"]);
					level.bossDamageDone[level.bossPhase] += idamage;
					newval = int(level.bossDamageDone[level.bossPhase]*100/level.bossDamageToDo[level.bossPhase]);
					if (newval > 100)
					newval = 100;
					level.bossOverlay setvalue(newval);
					self thread nextBossStatus();
					return 1;
				}
			}
			/* GENERAL DAMAGE */
			else if (level.bossPhase == 2)
			{
				if( isDefined( eAttacker.lastBossHit ) && eAttacker.lastBossHit != self.number ){
					eAttacker thread resetBossHit();
					return 0;
				}
				eAttacker.lastBossHit = self.number;
				eAttacker scripts\players\_players::incUpgradePoints( int( level.dvar["game_rewardscale"]/20 * iDamage ) );
				level.bossDamageDone[level.bossPhase] += idamage;
				newval = int(level.bossDamageDone[level.bossPhase]*100/level.bossDamageToDo[level.bossPhase]);
				if (newval > 100)
				newval = 100;
				level.bossOverlay setvalue(newval);
				self thread nextBossStatus();
				return 1;
			}
			eAttacker.damageDealtToBoss += iDamage;
			return 0;
		default:
		return 1;
	}
}

resetBossHit(){
	self endon("disconnect");
	self endon("death");
	self notify("resetboss_hit"); // _ there to NOT read it as boss-shit lol
	self endon("resetboss_hit");
	wait 0.05;
	self.lastBossHit = undefined;
}

nextBossStatus()
{
	if (level.bossDamageDone[level.bossPhase] >= level.bossDamageToDo[level.bossPhase])
		if(level.bossPhases < level.maxBossPhases){
			if( isDefined( level.bossOverlay ) ) level.bossOverlay destroy();
			
			level.bossPhase = getRandomBossPhase();
			label = getLabelForBoss();
			colour = getColourForPhase();
			level.bossOverlay = overlayMessage(label, "", colour /*(1,0,0)*/);
			level.bossOverlay setvalue(0);
			level.bossDamageDone[level.bossPhase] = 0;
			level.bossDamageToDo[level.bossPhase] = calculateBossHP();
			level.bossOverlay setvalue(0);
			level.bossPhases++;
			if(randomfloat(1) < 0.5 && !level.bossIsOnFire){
				self thread createEffectEntity(level.bossFireFX, "j_spinelower" );
				self thread bossCatchFire();
				level.bossIsOnFire = true;
				// announceMessage(label, text, glowcolor, duration, speed, size, height)
				announceMessage(&"ZOMBIE_BOSS_CATCHED_FIRE", "", (1,.3,0), 6, 100, undefined, 10);
			}
		}
		else{
			level.bossOverlay thread fadeout(1);
			self diedelay();
		}
}

dieDelay(){
	self.damageoff = true;
	self.partner.damageoff = true;
	wait 0.05;
	if( isDefined( self.partner ) ){
		self.partner suicide();
		self.partner.damageoff = undefined;
		if( isDefined( self.attachment ) )
			self.attachment delete();
	}
	else
		iprintlnbold("^1ERROR^7: Boss' partner undefined!");
	self.damageoff = undefined;
	self suicide();
}

onAttack(type, target)
{
	switch (type)
	{
		case "boss":
			target thread scripts\players\_players::bounce(vectorNormalize(target.origin+(0,0,15)-self.origin));
			target shellShock("boss",2);
		default:
		return 1;
	}
}



onCorpse(type)
{
	switch (type)
	{
		case "burning":
			PlayFX(level.explodeFX, self.origin);
			self PlaySound("explo_metal_rand");
			self scripts\bots\_bots::zomAreaDamage(160);
		return 0;
		case "napalm":
			if( !isDefined( self.suicided ) ){
				PlayFX(level.explodeFX, self.origin);
				self PlaySound("explo_metal_rand");
				self scripts\bots\_bots::zomAreaDamage(60);
			}
		return 0;
		case "dog":
		return 1;
		case "toxic":
			if (randomfloat(1) < .15)
			thread toxicCloud(self.origin, 10);
		return 2;
		default:
		return 2;
	}
}

toxicCloud(org, time) {
	ent = spawn("script_origin", org);
	playfx(level.toxicFX, org);
	ent playsound("toxic_gas");
	self endon("death");
	for ( t = 0; t<28; t++ ){
		for (i=0; i<level.players.size; i++) {
			if( !isReallyPlaying(level.players[i]) )
				continue;
			if ( distance(level.players[i].origin, org) < 128 ) {
				if (!level.players[i].entoxicated) {
					level.players[i].entoxicated = true;
					level.players[i] shellshock("toxic_gas_mp", 5);
					level.players[i] thread unEntoxicate(8);
				}
			}
		}
		wait .25;
	}
	ent delete();
}


unEntoxicate(time) {
	self endon("death");
	self endon("disconnect");
	wait time;
	self.entoxicated = false;
}

playSoundOnAllPlayers(sound, delay){
	if( isDefined( delay ) && delay >= 0.05 )
		wait delay;
	for(i = 0; i < level.players.size; i++)
		level.players[i] playlocalsound(sound);
}