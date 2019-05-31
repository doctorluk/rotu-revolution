/**
* vim: set ft=cpp:
* file: scripts\bots\_types.gsc
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
*	Handles loading and applying of zombie types.
*
*/

#include scripts\include\hud;
#include scripts\include\useful;
#include scripts\include\entities;
#include scripts\include\data;
#include scripts\include\codx_wrapper;

/**
* Initializes all zombie type and model related data.
*/
init()
{
	// declare zombie type and model variables
	level.zom_types = [];		// registred zombie types
	level.zom_heads = [];		// registred zombie heads
	level.zom_models = [];		// registred zombie models

	// register all zombie types
//	addZomType( name,		animType,	soundType,	moveSpeed,	meleeSpeed,	damage,	maxHealth,	runChance,	sprintChance,	infectionChance,	rewardMultiplier )
	addZomType( "zombie",	"zombie",	"zom",		0.8,		1.6,		30,		200,		0.0,		0.0,			0.075,				1.0 );
	addZomType( "burning",	"zombie",	"zom",		0.8,		1.6,		30, 	200,		0.8,		1.0,			0.0,				0.8 );
	addZomType( "napalm",	"zombie",	"zom",		0.8,		1.6,		100,	100,		0.8,		1.0,			0.0,				0.75 );
	addZomType( "scary",	"zombie",	"zom",		0.9,		1.6,		30,		200,		0.8,		0.3,			0.01,				0.8 );
	addZomType( "toxic",	"quad",		"zom",		0.4,		1.4,		30,		180,		0.6,		0.5,			0.15,				1.0 );
	addZomType( "fat",		"zombie",	"zom",		0.8,		1.4,		40,		275,		0.8,		0.2,			0.05,				1.2 );
	addZomType( "fast",		"zombie",	"zom",		1.0,		0.8,		30,		150,		0.7,		1.0,			0.075,				0.8 );
	addZomType( "tank",		"zombie",	"zom",		0.8,		2.0,		35,		800,		0.8,		0.4,			0.05,				1.35 );
	addZomType( "dog",		"dog",		"dog",		1.0,		2.5,		30,		125,		0.8,		1.0,			0.08,				0.5 );
	addZomType( "helldog",	"dog",		"dog",		1.0,		2.5,		20,		150,		0.8,		1.0,			0.08,				0.5 );
	
	// bosses
	// maxHealth was meant to be calculated like this: 5000 + (2000 * level.activePlayers)	--> this is actually pretty overkill!
	addZomType( "halfboss", "zombie",	"zom",		0.8,		2.0,		70,		5000,		0.8,		0.6,			0.0,				3.0 );
	addZomType( "boss",		"zombie",	"zom", 		1.0,		3.0,		80,		10000,		1.0,		0.0,			0.0,				3.0 );
	// TODO more boss zombies!!!
	
	// register zombie models
//	addZomModel( name, torso, headOff, torsoROff, torsoLOff, legs, legsROff, legsLOff, legsOff )
//	addZomHead( head, models )

	// register BO2 Tranzit models
	models = [];
	models[models.size] = addZomModel( "zom_zombie1_torso", "zom_head_off", "zom_zombie1_torso_rarmoff", "zom_zombie1_torso_larmoff", "zom_zombie1_legs", "zom_zombie1_legs_rlegoff", "zom_zombie1_legs_llegoff", "zom_zombie1_legs_legsoff" );
	models[models.size] = addZomModel( "zom_zombie2_torso", "zom_head_off", "zom_zombie2_torso_rarmoff", "zom_zombie2_torso_larmoff", "zom_zombie2_legs", "zom_zombie2_legs_rlegoff", "zom_zombie2_legs_llegoff", "zom_zombie2_legs_legsoff" );
	
	// register with heads
	addZomHead( "zom_head_a", models );
	addZomHead( "zom_head_b", models );
	addZomHead( "zom_head_c", models );
	addZomHead( "zom_head_d", models );
	
	// register to zombie types
	addZomTypeModels( "zombie", models );
	addZomTypeModels( "burning", models );
	addZomTypeModels( "napalm", models );
	addZomTypeModels( "scary", models );
	addZomTypeModels( "fat", models );
	addZomTypeModels( "fast", models );
	addZomTypeModels( "tank", models );
	
	// register Quad model		TODO rework model
	models = [];
	models[models.size] = addZomModel( "bo_quad" );
	
	addZomTypeModels( "toxic", models );
	
	// register Doge model		TODO rework model
	models = [];
	models[models.size] = addZomModel( "zombie_wolf" );
	
	addZomTypeModels( "dog", models );
	addZomTypeModels( "helldog", models );
	
	// register (Half-)Boss models
	models = [];
	models[models.size] = addZomModel( "zom_avagadro_body" );
	
	addZomTypeModels( "boss", models );
	
	models = [];
	models[models.size] = addZomModel( "zom_george_romero" );
	
	addZomTypeModels( "halfboss", models );	
	
	// init other type related things
	initGroupedSettings();
	initSeasonalFeatures();
}	/* init */

/**
* Adds the given zombie type to the list of spawnable zombies
*/
addZomType( name, animType, soundType, moveSpeed, meleeSpeed, damage, maxHealth, runChance, sprintChance, infectionChance, rewardMultiplier )
{
	// create a struct to save the data in
	ztype = spawnStruct();
	
	// add the given data to the struct
	ztype.animType = animType;					// animation type, can be zombie, quad or dog
	ztype.soundType = soundType;				// sound type, can be zombie or dog
	ztype.moveSpeed = moveSpeed;				// move speed multiplier
	ztype.meleeSpeed = meleeSpeed;				// timeout between melee attacks
	ztype.maxHealth	= maxHealth;				// max health of the bot
	ztype.damage = damage;						// damage dealt per attack
	ztype.runChance = runChance;				// chance this bot starts as a runner
	ztype.sprintChance = sprintChance;			// chance this bot starts as a sprinter
	ztype.infectionChance = infectionChance;	// chance to be infected when hit by this bot
	ztype.rewardMultiplier = rewardMultiplier;	// multiplier for all rewards earned by killing this bot
	
	// add variables for data added later
	ztype.models = [];		// array for compatible models
	
	// save the zombie type in the zom_types array
	level.zom_types[name] = ztype;
}	/* addZomType */

/**
* Adds the given models to the given zombie type
*
*	@param type, String name of the zombie model
*	@param models, Array of models to add
*/
addZomTypeModels( ztype, models )
{
	for( i=0; i<models.size; i++ )
	{
		type = level.zom_types[ztype];
		type.models[type.models.size] = models[i];
	}
}	/* addZomTypeModels */

/**
* Adds the given models for zombies to use
*
*	@param torso
*	@param headOff
*	@param torsoROff
*	@param torsoLOff
*	@param legs
*	@param legsROff
*	@param legsLOff
*	@param legsOff
*/
addZomModel( torso, headOff, torsoROff, torsoLOff, legs, legsROff, legsLOff, legsOff )
{
	// check for required variables
	assert( isDefined(torso), "Can't register zombie model without a body!" );

	// create a struct to save the data in
	model = spawnStruct();
	
	// clean torso or full body model
	model.torso = torso;
	precacheModel( torso );
	
	// right arm off torso or full body model
	model.torsoROff = torsoROff;
	if( isDefined(torsoROff) )
		precacheModel( torsoROff );
		
	// left arm off torso or full body model
	model.torsoLOff = torsoLOff;
	if( isDefined(torsoLOff) )
		precacheModel( torsoLOff );
	
	// clean legs model
	model.legs = legs;
	if( isDefined(legs) )
		precacheModel( legs );
	
	// right leg off model
	model.legsROff = legsROff;
	if( isDefined(legsROff) )
		precacheModel( legsROff );
	
	// left leg off model
	model.legsLOff = legsLOff;
	if( isDefined(legsLOff) )
		precacheModel( legsLOff );
	
	// both legs off model
	model.legsOff = legsOff;
	if( isDefined(legsOff) )
		precacheModel( legsOff );
	
	// popped head model
	model.headOff = headOff;
	if( isDefined(headOff) )
		precacheModel( headOff );
	
	// array for compatible heads
	model.heads = [];

	// save the model in the zom_models array
	level.zom_models[torso] = model;
	
	return torso;
}	/* addZomModel */

/**
* Adds the given model as a head for the zombie model
*
*	@param model, String modelname of the head
*	@param models, Array of valid models
*/
addZomHead( head, models )
{
	// precache the head model if not already done
	if( !isDefined(level.zom_heads[head]) )
	{
		precacheModel( head );
		level.zom_heads[head] = true;
	}
	
	// go through all models that the head is meant for
	for( i=0; i<models.size; i++ )
	{
		// add the head to the models heads array
		zmdl = level.zom_models[models[i]];
		zmdl.heads[zmdl.heads.size] = head;
	}
}	/* addZomHead */

/**
* Initializes the zombie probabilities
*/
initGroupedSettings(){
	// Give zombie types a certain percentage chance to be spawned
	level.zombieProbability = [];
	level.zombieProbability[0] = 5; // Zombie
	level.zombieProbability[1] = 5; // Dog
	level.zombieProbability[2] = 5; // Tank
	level.zombieProbability[3] = 5; // Burning
	level.zombieProbability[4] = 5; // toxic
	level.zombieProbability[5] = 100; // halfboss
	level.zombieProbability[6] = 5; // Napalm
	level.zombieProbability[7] = 5; // Helldoge
	// level.zombieProbability[7] = 5; // Electric
	
	// Adjust zombie chance on a per wave base
	level.zombieProbabilityScenario = [];
	setZombieProbabilityScenario(0, "normal zombies", 35, 10, 10, 10, 10, 0, 5, 5/*, 0*/);
	setZombieProbabilityScenario(1, "burning only", 0, 0, 0, randomint(2)+1, 0, 0, randomint(2), randomint(2)/*, 0*/);
	setZombieProbabilityScenario(2, "crawlers only", 0, 0, 0, 0, 1, 0, 0, 0/*, 0*/);
	setZombieProbabilityScenario(3, "tanks only", 0, 0, 1, 0, 0, 0, 0, 0/*, 0*/);
	setZombieProbabilityScenario(4, "burning + crawlers", 0, 0, 0, randomint(2)+1, randomint(2)+1, randomint(1), randomint(1)/*, 1*/);
	setZombieProbabilityScenario(5, "tank + crawlers", 0, 0, randomint(2)+1, 0, randomint(2)+1, 0, 0, 0/*, 0*/);
	setZombieProbabilityScenario(6, "all + boss", 30, 10, 10, 10, 10, 1, 10, 10/*, 10*/);
	setZombieProbabilityScenario(7, "tank + dogs + boss", 0, 10, 40, 0, 0, 1, 0, 1/*, 0*/);
	setZombieProbabilityScenario(8, "dogs + burning", 0, 3, 0, 3, 0, 0, 1, 1/*, 0*/);
	setZombieProbabilityScenario(9, "Pure random", randomint(4)+1, randomint(5), randomint(5), randomint(5), randomint(5), randomint(5), randomint(5), randomint(5)/*, 0*/);
	setZombieProbabilityScenario(10, "dogs + helldogs", 0, 1, 0, 0, 0, 0, 0, 1/*, 0*/);
	// setZombieProbabilityScenario(0, "test", 0, 0, 0, 0, 0, 0, 1);
	
	// Limit the amount of bullet-damageable bosses on the server, because too many can be.... quite.... devastating
	level.bossBulletLimit = level.dvar["game_difficulty"];
	level.bossBulletCount = 0;
}

/**
* Initializes the seasonal features in case they are to be loaded by server config
*	Currently applies santa hats during December
*/
initSeasonalFeatures(){
	level.seasonalFeature = "";
	
	if( !level.dvar["surv_seasonal_features"] )
		return;
		
	seconds = _GetRealTime();
	if(seconds == -1)
		return;
		
	date = getCurrentMonthAndDay(seconds);
	month = date[1];
	
	if(month == 1 || month == 12)
		level.seasonalFeature = "santa";
}

/**
* Calculates the value of all zombie probabilities
*	In case it exceeds "100%" in total
*/
getTotalZombieProbability(){
	total = 0;
	for(i = 0; i < level.zombieProbability.size; i++)
		total += level.zombieProbability[i];
	
	return total;
}

/**
* Applies the zombie type data to the given zombie
*/
loadZomType()
{
	// get the data for the zombies type
	struct = level.zom_types[self.type];
	
	// apply all data to the zombie
	self.animType = struct.animType;
	self.soundType = struct.soundType;
	self.moveSpeed = struct.moveSpeed;
	self.meleeSpeed = struct.meleeSpeed;
	self.maxHealth = int(struct.maxHealth * level.dif_zomHPMod);
	self.health = self.maxHealth;
	self.damage = struct.damage;
	self.runChance = struct.runChance;
	self.sprintChance = struct.sprintChance;
	self.infectionChance = struct.infectionChance;
	self.rewardMultiplier = struct.rewardMultiplier;

	// apply the move speed to the zombie
	self setMoveSpeedScale( self.moveSpeed );

	// random chance to prevent the bot from running
	self.walkOnly = undefined;
	if( randomFloat(1) > level.slowBots )
		self.walkOnly = true;
}	/* loadZomType */

/**
* Applies a random zombie model for the given type
*/
loadZomModel()
{
	// detach all previous models
	self DetachAll(); 

	// get all models for the zombie type
	models = level.zom_types[self.type].models;
	
	// get a random model from the available ones
	model = level.zom_models[models[randomInt(models.size)]];
	
	// set the main body model or torso
	self.bodyStatus = 0;		// clean torso status for gibbing
	self.body = model.torso;
	self setModel( self.body );
	
	// apply clean leg model
	self.legStatus = 0;			// clean leg status for gibbing
	if( isDefined(model.legs) )
	{
		self.legs = model.legs;
		self attach( self.legs );
	}
	else
		self.legs = undefined;
	
	// apply a random head model
	if( model.heads.size > 0 )
	{
		self.head = model.heads[randomInt(model.heads.size)];
		self attach( self.head );
	}
	else
		self.head = undefined;

	// apply seasonal features like hats
	self onSeasonalFeatures();
}

/**
* Applies seasonal features like hats
*/
onSeasonalFeatures()
{
	// check which seasonal feature is enabled
	switch(level.seasonalFeature)
	{
		// Santa will run from 01.12.xx till 01.01.xx
		case "santa":
			if( self.type != "boss" && self.type != "helldog" && self.type != "dog" )
				self attach( "santa_hat" );
			break;
		default:
			break;
	}
}	/* onSeasonalFeatures */

/**
* Applies the animation weapon for the given zombie type
*/
loadZomWeapon()
{
	switch( self.animType )
	{
		case "dog":
			self.pers["weapon"] = "dog_mp";
			break;
		case "quad":
			self.pers["weapon"] = "concussion_grenade_mp";
			break;
		default:
			self.pers["weapon"] = "flash_grenade_mp";
			break;
	}
}	/* loadZomWeapon */


getBlurForType(type)
{
	switch (type)
	{
		case "burning":
		return .65;
		case "helldog":
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

getFullyRandomZombieType(){
	ran = 9;
	// Only select halfboss when he lives
	if(level.bossBulletCount < level.bossBulletLimit)
		ran = 10;
		
	switch(randomint(ran)){
		case 0: return "zombie";
		case 1: return "dog";
		case 2: return "fast";
		case 3: return "fat";
		case 4: return "burning";
		case 5: return "toxic";
		case 6: return "tank";
		case 7: return "napalm";
		case 8: return "helldog";
		case 9: return "halfboss";
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
		
	else if(ran < (getZombieProbability("zombie") + getZombieProbability("dog")))
		returns = "dog";
		
	else if(ran < (getZombieProbability("zombie") + getZombieProbability("dog") + getZombieProbability("tank")))
		returns = "tank";
		
	else if(ran < (getZombieProbability("zombie") + getZombieProbability("dog") + getZombieProbability("tank") + getZombieProbability("burning")))
		returns = "burning";
		
	else if(ran < (getZombieProbability("zombie") + getZombieProbability("dog") + getZombieProbability("tank") + getZombieProbability("burning")+ getZombieProbability("toxic")))
		returns = "toxic";
		
	else if(ran < (getZombieProbability("zombie") + getZombieProbability("dog") + getZombieProbability("tank") + getZombieProbability("burning")+ getZombieProbability("toxic") + getZombieProbability("napalm")))
		returns = "napalm";
		
	else if(ran < (getZombieProbability("zombie") + getZombieProbability("dog") + getZombieProbability("tank") + getZombieProbability("burning")+ getZombieProbability("toxic") + getZombieProbability("napalm") + getZombieProbability("helldog")))
		returns = "helldog";
		
	else if(ran <= (getZombieProbability("zombie") + getZombieProbability("dog") + getZombieProbability("tank") + getZombieProbability("burning")+ getZombieProbability("toxic") + getZombieProbability("napalm") + getZombieProbability("helldog") + getZombieProbability("halfboss")))
		returns = "halfboss";
		
	// else if(ran <= (getZombieProbability("zombie") + getZombieProbability("dog") + getZombieProbability("tank") + getZombieProbability("burning")+ getZombieProbability("toxic") + getZombieProbability("halfboss") + getZombieProbability("napalm") + getZombieProbability("electric")))
		// returns = "electric";
	// iprintln("ran is " + ran + " and spawns: " + returns);
	return returns;
}

/* Set certain probability to spawn type of zombie */
setZombieProbability(type, probability){
	level.zombieProbability[getZombieProbabilityIndex(type)] = probability;
}

setZombieProbabilityScenario(index, description, prob0, prob1, prob2, prob3, prob4, prob5, prob6, prob7/*, prob7*/){
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
	level.zombieProbabilityScenario[index]["prob7"] = prob7;
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
		// iprintln("Loading scenario '^3" + level.zombieProbabilityScenario[ran]["description"] + "^7'");
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
		case 7: return "helldog";
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
		case "helldog": return 7;
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
		case "helldog": return true;
		default: return false;
	}
}


finaleVision(){
	level endon("game_ended");
	level endon("wave_finished");
	
	level waittill("finale_vision");
	
	scripts\server\_environment::setVision(scripts\bots\_types::getVisionForType("finale"), 5);
}

goBlackscreen(){
	level endon("game_ended");
	level endon("wave_finished");
	
	level waittill("finale_blackscreen");
	
	level.blackscreen = newHudElem();
	level.blackscreen.sort = 4;
	level.blackscreen.alignX = "left";
	level.blackscreen.alignY = "top";
	level.blackscreen.x = 0;
	level.blackscreen.y = 0;
	level.blackscreen.horzAlign = "fullscreen";
	level.blackscreen.vertAlign = "fullscreen";
	level.blackscreen.foreground = true;
	level.blackscreen.alpha = 0.95;
	level.blackscreen setShader("black", 640, 480);
	
	thread scripts\server\_environment::updateBlur(8);
}

announceFinale(a){ // 8 waits
	self endon("disconnect");
	level endon("game_ended");
	
	screenFlashAll((1,1,1), 0.2, 0.5);
	// finaleMessageAll(label, text, glowcolor, duration, speed, size)
	finaleMessageAll(level.finaleLables[a][0], "", (1, 0, 0), 2.4, 5, 2.6);
	wait 2.4;
	
	screenFlashAll((1,1,1), 0.2, 0.5);
	finaleMessageAll(level.finaleLables[a][1], "", (1, 0, 0), 2.4, 5, 2.6);
	wait 2.4;
	
	screenFlashAll((1,1,1), 0.2, 0.5);
	finaleMessageAll(level.finaleLables[a][2], "", (1, 0, 0), 2.4, 5, 2.6);
	wait 2.35;
	
	screenFlashAll((1,1,1), 0.2, 0.5);
	finaleMessageAll(level.finaleLables[a][3], "", (1, 0, 0), 2.4, 5, 2.6);
	wait 2.35;
	
	screenFlashAll((1,1,1), 0.2, 0.5);
	finaleMessageAll(level.finaleLables[a][4], "", (1, 0, 0), 2.4, 5, 2.9);
	
	level notify("finale_vision");
	
	wait 2.35;
	
	screenFlashAll((1,1,1), 0.2, 0.5);
	finaleMessageAll(level.finaleLables[a][5], "", (1, 0, 0), 2.4, 5, 2.6);
	wait 2.4;
	
	screenFlashAll((1,1,1), 0.2, 0.5);
	finaleMessageAll(level.finaleLables[a][6], "", (1, 0, 0), 2.4, 5, 2.6);
	wait 2.4;
	
	screenFlashAll((1,1,1), 0.2, 0.5);
	finaleMessageAll(level.finaleLables[a][7], "", (1, 0, 0), 2.4, 5, 2.6);
	wait 2.35;
	
	level notify("finale_blackscreen");
		
	level notify("finale_announce_done");
}

announceFinaleShort(){
	self endon("disconnect");
	level endon("game_ended");
	
	screenFlashAll((1,1,1), 0.2, 0.5);
	
	level notify("finale_vision");
	level notify("finale_blackscreen");
	
	wait 0.2;
	
	thread scripts\server\_environment::updateBlur(8);
	
	level notify("finale_announce_done");
}

dynamicFinale(){
	level endon("game_ended");
	level endon("wave_finished");
	
	level.finaleToSpawn = level.dvar["bot_count"];
	level.finaleDelay = 2;
	toSpawn = 1;
	delay = 0;
	
	if(level.dvar["surv_dynamic_finale_difficulty"]){
		while(1){
			switch(level.dvar["game_difficulty"]){
				case 1:
					toSpawn = int(level.activePlayers) + randomIntRange(-1, 5);
					delay = 4;
					break;
				case 2:
					toSpawn = int(level.activePlayers * 3) + randomIntRange(-2, 5);
					delay = 3;
					break;
				case 3:
					toSpawn = int(level.dvar["bot_count"] * 1.4);
					delay = 2.5;
					break;
				case 4:
					toSpawn = int(level.dvar["bot_count"] * 2.5);
					delay = 1.5;
					break;
			}
			
			if(toSpawn < 1)
				toSpawn = 1;
		
			level.finaleToSpawn = toSpawn;
			level.finaleDelay = delay;
			
			level waittill("burst_done");
		}
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
		case "burning":
			ran = randomfloat(1);
			if(ran < 0.8)
				if(randomfloat(1) < 0.2)
					return "helldog";
				else
					return "burning";
			else
				return "napalm";
				
		default: return type;
	}
}

getSpawnType(zombieType, waveType){
	switch(waveType){
		case "grouped": return randomint(6);
		case "scary": return 3;
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
		case "dog":
			return 0.6;
		case "helldog":
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
		case "helldog":
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
		case "finale":
			return "ambient_finale";
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
		case "finale":
			return "finale";
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
		case "helldog":
			return "inferno";
		case "boss":
			return "boss";
		case "scary":
			return "night";
		case "finale":
			return "finale";
		default:
			return "default";
	}
}

getFxForType(type)
{
	switch (type)
	{
		case "burning":
			return "ember";
		case "helldog":
			return "ember";
		case "tank":
			return "lightning";
		case "boss":
			return "lightning_boss";
		case "finale":
			return "finale";
		default:
			return "";
	}
}

/**
* Applies the effect for the given type
*/
onSpawn( type )
{
	switch( type )
	{
	case "burning":
		self thread createEffectEntity( level.burningFX, "j_spinelower" );
		self playLoopSound( "fire_wood_medium" );
		break;
	case "helldog":
		self thread createEffectEntity( level.burningFX, "tag_origin" );
		self playLoopSound( "fire_wood_medium" );
		break;
	case "napalm":
		PlayFXOnTag( level.napalmTummyGlowFX, self, "j_spineupper" );
		break;		// TODO maybe we want glowing eyes too?
	case "zombie":
	case "scary":
	case "fast":
	case "fat":
		PlayFXOnTag( level.leftEyeFx, self, "j_eyeball_le" );
		PlayFXOnTag( level.rightEyeFX, self, "j_eyeball_ri" );
		break;
	case "dog":
		// self thread createEffectEntity(level.burningFX, "j_head");
		break;
	case "toxic":
		// PlayFXOnTag(level.toxicFX, self, "j_head");
		break;
	case "boss":
		level.bossPhases = 1;
		level.bossPhase = getRandomBossPhase();
		label = getLabelForBoss();
		colour = getColourForPhase();
		level.bossOverlay = overlayMessage( label, "", colour );
		level.bossOverlay.alpha = 0;
		level.bossOverlay setValue( 0 );
		level.bossOverlay fadeOverTime( 1 );
		level.bossOverlay.alpha = 1;
		level.bossDamageDone[level.bossPhase] = 0;
		level.bossDamageToDo[level.bossPhase] = calculateBossHP();
		self.quake = true;
		self thread bossSpecialAttack();
	//	self thread spawnHitboxBot();	NOTE unclear if we have to do this, needs testing
		break;
	}
}	/* onSpawn */

spawnHitboxBot(){
	wait 0.1;
	bot = scripts\bots\_bots::getAvailableBot();
	assertEx(isDefined(bot), "Error: Bot attached to boss is non existant!");
	if (!isDefined(bot)){
		iprintlnbold("^1ERROR^7: Could not get an available bot for the boss!");
		return;
	}
		
	self.attachment = spawn("script_model", self getTagOrigin("tag_origin") + (0,0,80));
	self.attachment setModel("tag_origin");
	wait 0.05;
	self.attachment linkto(self);
	
	self.child = bot;
	level.bossParent = self;
	level.bossChild = bot;
	bot.parent = self;
	spawn = self.attachment;
	self.number = 0;
	self.child.number = 1;
	scripts\bots\_bots::spawnPartner(spawn, self.child);
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
		case 3: return ( 1 * getPhaseMulti() * level.activePlayers);
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
	self.effect = spawn("script_model", self getTagOrigin(origin) + offset);
	self.effect setModel("tag_origin");
	wait 0.05;
	PlayFXOnTag(effect, self.effect, "tag_origin");
	self.effect LinkTo(self);
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
	range = 130;
	time = 2; // in seconds, we need 4 * time encounters to make us burn
	
	while(1){
		for(i = 0; i < level.players.size; i++){
			p = level.players[i];
			if(!isReallyPlaying(p)) continue; // Ignore not-playing players
			
			if(distance(self.origin, p.origin) <= range && (p.fireCatchCount < time * 4) && !p.isDown && !p.isZombie){
				p.fireCatchCount++;
			}
			else 
			if(p.fireCatchCount > 0)
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
		// iprintln("Throwback of burning boss is now " + level.bossThrowback);
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
				int(self.damage * level.dif_zomDamMod * (0.05 + randomfloat((level.dvar["game_difficulty"] * 0.05)))), // iDamage = the amount of damage to do
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


onDamage( type, sMeansOfDeath, sWeapon, iDamage, eAttacker )
{
	switch( type )
	{
		case "boss":
			self.health = 10000;
			/* EXPLOSIVES */
			if (level.bossPhase == 0)
			{
				if (sMeansOfDeath != "MOD_IMPACT")
				{
					if ((sWeapon == "c4_mp" || sWeapon == "frag_grenade_mp" || sWeapon == "claymore_mp" || sWeapon == "rpg_mp" || sWeapon == "at4_mp" || sMeansOfDeath == "MOD_MELEE"))
					{
						if(isDefined(eAttacker.lastBossHit) && eAttacker.lastBossHit != self.number){
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
			else if (level.bossPhase == 1)
			{
				if (sMeansOfDeath == "MOD_MELEE")
				{
					eAttacker scripts\players\_players::incUpgradePoints(5*level.dvar["game_rewardscale"]);
					level.bossDamageDone[level.bossPhase] += iDamage;
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
				if(isDefined(eAttacker.lastBossHit) && eAttacker.lastBossHit != self.number){
					eAttacker thread resetBossHit();
					return 0;
				}
				eAttacker.lastBossHit = self.number;
				eAttacker scripts\players\_players::incUpgradePoints(int(level.dvar["game_rewardscale"]/20 * iDamage));
				level.bossDamageDone[level.bossPhase] += idamage;
				newval = int(level.bossDamageDone[level.bossPhase]*100/level.bossDamageToDo[level.bossPhase]);
				if (newval > 100)
				newval = 100;
				level.bossOverlay setvalue(newval);
				self thread nextBossStatus();
				return 1;
			}
			
			eAttacker.stats["damageDealtToBoss"] += iDamage;
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
			if(isDefined(level.bossOverlay)) level.bossOverlay destroy();
			
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
				self thread createEffectEntity(level.bossFireFX, "j_spinelower");
				self thread bossCatchFire();
				level.bossIsOnFire = true;
				// announceMessage(label, text, glowcolor, duration, speed, size, height)
				announceMessage(&"ZOMBIE_BOSS_CATCHED_FIRE", "", (1,.3,0), 6, 100, undefined, 10);
			}
		}
		else{
			level.bossOverlay thread fadeout(1);
			level.bossParent diedelay();
			level.bossParent = undefined;
			level.bossChild = undefined;
		}
}

dieDelay(){
	self.god = true;
	self.child.god = true;
	wait 0.05;
	if(isDefined(self.child)){
		self.child suicide();
		self.child.god = undefined;
		if(isDefined(self.attachment))
			self.attachment delete();
	}
	else
		iprintln("^1ERROR^7: Boss' child undefined!");
	self.god = undefined;
	self suicide();
}

/* Find a spawnpoint for the scary wave from which players are far away, but not too far away, to allow zombies to spawn all over the map, but at a distance from the players */
getScarySpawnpoint(){
	if(level.waveType == "finale"){
		minDistance = 150;
		maxDistance = 1000;
	}
	else{
		minDistance = 400;
		maxDistance = 1800;
	}
	validSpawnpoints = [];
	valid = false;
	distance = 0;
	for(i = 0; i < level.waypoints.size; i++){
		wp = level.waypoints[i];
		valid = true;
		for(ii = 0; ii < level.players.size; ii++){
			p = level.players[ii];
			if(!isReallyPlaying(p)) // Ignore not playing players
				continue;
			distance = distance2d(p.origin, wp.origin);
			if(distance <= minDistance || distance > maxDistance){ // If any of the players is too close, stop here and continue with the next waypoint
				valid = false;
				break;
			}
		}
		if(valid){
			validSpawnpoints[validSpawnpoints.size] = wp;
		}
	}
	// In case there are no spawnpoints that are not too close + not too far, just consider the minDistance for the next search, so we avoid spawning the zombies too close to the players
	if(validSpawnpoints.size <= 1){
		validSpawnpoints = [];
		
		for(i = 0; i < level.waypoints.size; i++){
			wp = level.waypoints[i];
			valid = true;
			
			for(ii = 0; ii < level.players.size; ii++){
				p = level.players[ii];
				
				if(!isReallyPlaying(p)) // Ignore not playing players
					continue;
					
				distance = distance2d(p.origin, wp.origin);
				if(distance <= minDistance){ // If any of the players is too close, stop here and continue with the next waypoint
					valid = false;
					break;
				}
			}
			
			if(valid){
				validSpawnpoints[validSpawnpoints.size] = wp;
			}
		}
	}
	// In case everything fails, we just spawn the zombie somewhere on the map randomly
	if(validSpawnpoints.size <= 1)
		if(level.waypoints.size > 2)
			return level.waypoints[randomint(level.waypoints.size)];
		else
			return  scripts\gamemodes\_waves::getRandomSpawn();
		
	return validSpawnpoints[randomint(validSpawnpoints.size)];
}

onAttack(type, target)
{
	switch (type)
	{
		case "boss":
			target thread scripts\players\_players::bounce(vectorNormalize(target.origin + (0,0,15) - self.origin));
			target shellShock("boss", 2);
		default:
		return 1;
	}
}

/**
* Handles ragdoll creation for bots
*/
onCorpse()
{
	switch( self.type )
	{
	case "burning":
		self playSound( "explo_metal_rand" );
		playFX( level._effect["zom_explode"], self.origin );
		self scripts\bots\_bots::zomExplodeBody();
		
		self scripts\bots\_bots::zomAreaDamage( 160 );
		return 0;
	case "helldog":
		self playSound( "explo_metal_rand" );
		playFX( level._effect["zom_explode"], self.origin );
		self scripts\bots\_bots::zomExplodeBody();
		
		self scripts\bots\_bots::zomAreaDamage( 120 );
		return 0;
	case "napalm":
		if( !isDefined(self.suicided) )
		{
			self playSound( "explo_metal_rand" );
			playFX( level._effect["zom_explode"], self.origin );
			self scripts\bots\_bots::zomExplodeBody();
			
			self scripts\bots\_bots::zomAreaDamage( 60 );
		}
		return 0;
	case "dog":
		return 1;
	case "toxic":
		if( randomFloat(1) < .15 )
			thread toxicCloud( self.origin, 10 );
		return 1;
	default:
		return 2;
	}
}	/* onCorpse */

toxicCloud(org, time) {
	ent = spawn("script_origin", org);
	playfx(level.toxicFX, org);
	ent playsound("toxic_gas");
	self endon("death");
	for (t = 0; t < 28; t++){
		for (i = 0; i < level.players.size; i++) {
			p = level.players[i];
			
			if(!isReallyPlaying(p))
				continue;
				
			if (distance(p.origin, org) < 128 && !p.toxicImmunity) {
				if (!p.entoxicated){
					p.entoxicated = true;
					p shellshock("toxic_gas_mp", 5);
					p thread unEntoxicate(8);
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
