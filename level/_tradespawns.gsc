//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.7 by Luk and 3aGl3
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//
#include scripts\include\hud;

init(){
	precache();
}

precache(){
	precachemodel("com_vending_can_new1_lit"); // Equipment
	precachemodel("com_stove");	   // Weapon Upgrade
	
	level.tradespawnModels = [];
	level.tradespawnModels["upgrade"] = "com_stove";
	level.tradespawnModels["equipment"] = "com_vending_can_new1_lit";
}

// We want to exclude the stock maps from using the tradespawns, but we still load them to make a unified map opening script

buildTradespawns(){
	if( !isDefined( level.tradespawns ) )
		return;
		
	cleanupMap();
	
	for( i = 0; i < level.tradespawns.size; i++ ){
	
		level.tradespawns[i].model = spawn("script_model", level.tradespawns[i].origin);
		level.tradespawns[i].model.angles = level.tradespawns[i].angles;
		
		if( i % 2 == 0 )
			level.tradespawns[i].model setModel(level.tradespawnModels["upgrade"]);
		else
			level.tradespawns[i].model setModel(level.tradespawnModels["equipment"]);
	}
	
	for( i = 0; i < level.tradespawns.size; i++ ){
		if( i % 2 == 0 )
			thread buildUsableShop(level.tradespawns[i].model, "upgrade", level.tradespawns[i].origin, level.tradespawns[i].angles);
		else
			thread buildUsableShop(level.tradespawns[i].model, "equipment", level.tradespawns[i].origin, level.tradespawns[i].angles);
	}
}

/*
	Builds interactable objects on the map where players can upgrade weapons or buy equipment
	Only used when the map does not have these and uses _tradespawns.gsc
*/
buildUsableShop(ent, type, origin, angles){

	switch( type ){
		case "upgrade":
			wait 0.05;
			level scripts\players\_usables::addUsable(ent, "ammobox", &"USE_UPGRADEWEAPON", 96);
			createTeamObjpoint( ent.origin + (0, 0, 80), "hud_weapons", 1);
			ent spawnCollider();
			break;
			
		case "equipment":
			wait 0.05;
			level scripts\players\_usables::addUsable(ent, "extras", &"USE_BUYUPGRADES", 96);
			createTeamObjpoint( ent.origin + (0, 0, 80), "hud_ammo", 1);
			ent spawnCollider();
			ent correctPosition();
			break;
	}

}

cleanupMap(){
	ent = getEntArray("oldschool_pickup", "targetname");
	for( i = 0; i < ent.size; i++ ){
		ent[i] delete();
	}
	
	allowed = [];
	maps\mp\gametypes\_gameobjects::main(allowed);
}

/*
	The soda machine is not centered on its position which means that we have to translate the thing back 15 and sideways 20
*/
correctPosition(){

	position = 	self.origin;
	angle =		self.angles;
	
	forwardVector = anglesToForward(self.angles);
	self.origin = ( forwardVector[0] * -20 + position[0], position[1], position[2] );
}

/*
	Since the spawned-in tradespawns are not solid, we have to "fake" the "solidness" by spawning trigger_radius at them and making them solid
*/

spawnCollider(){
	self.collider = spawn( "trigger_radius", self.origin, 0, 40, 80 );
	self.collider setContents(1);
}