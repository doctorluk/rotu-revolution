/*
///////////////////////////////////////////////////////
///|         |///|        |///|       |/\  \/////  ////
///|  |////  |///|  |//|  |///|  |/|  |//\  \///  /////
///|  |////  |///|  |//|  |///|  |/|  |///\  \/  //////
///|          |//|  |//|  |///|       |////\    ///////
///|  |////|  |//|         |//|  |/|  |/////    \//////
///|  |////|  |//|  |///|  |//|  |/|  |////  /\  \/////
///|          |//|__|///|__|//|__|/|__|///  ///\  \////
/////////////////////////////////////////__/////\__\///
///////////////////////////////////////////////////////

	Defence Turret by BraX

	Xfire: maciusiak
	Website: www.brax-site.pl
 
*/

#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
	level.sentry_turret_model["minigun"] = "bo2_turret_sentry_gun";
	level.sentry_base_model["minigun"] = "bo2_turret_sentry_gun"; // tag_base only
	
	level.sentry_turret_model["gl"] = "mw3_sentry_gl_turret";
	level.sentry_base_model["gl"] = "mw3_sentry_gl_base";
	
	precacheModel( level.sentry_turret_model["minigun"] );
	// precacheModel( level.sentry_base_model["minigun"] );
	precacheModel( level.sentry_turret_model["gl"] );
	precacheModel( level.sentry_base_model["gl"] );

	level._effect["turret_flash"] = loadFx( "muzzleflashes/custom_minigun_flash" );
	level._effect["overheat"] = loadFx( "smoke/heli_engine_smolder" );
	
	level.effect_sentry_hit["gl"] = loadFx( "explosions/grenadeExp_blacktop" );
	level.effect_sentry_hit["minigun"] = loadFx( "impacts/flesh_hit_body_fatal_exit" );
	
	level.effect_sentry_impact["gl"] = level.effect_sentry_hit["gl"];
	level.effect_sentry_impact["minigun"] = loadFx( "impacts/large_metalhit_1" );
	
	
	level.sentry_laser = loadFx( "misc/sentry_laser" );
	level.turret_broken = loadFx( "turrets/turret_broken" );
	level.turret_overheat = loadFx( "turrets/turret_overheat" );

	if( getDvar("turret_time" ) == "" ) 
		setDvar("turret_time", 90);

	level.turrets = 0;
	level.turrets_held = 0;
	level.turretsDisabled = 0;
}

giveTurret(turret_type, time)
{
	if (!isdefined(time))
	time = 0;
	
	self.carryObj = spawn("script_model", (0,0,0));
	self.carryObj.origin = self.origin + (0,0,32);
	self.carryObj.angles = (70, self.angles[1], self.angles[2]);
	self.carryObj.turret_type = turret_type;
	self.turret_time = time;
	
	self.carryObj linkto(self);
	// iprintlnbold(level.sentry_turret_model[turret_type]);
	self.carryObj setmodel(level.sentry_turret_model[turret_type]);
	self.carryObj setcontents(2);
	
	self.carryObj thread onDeath();
	
	level.turrets_held ++;
		
	self.canUse = false;
	self disableweapons();
	self thread placeTurret(turret_type);
}

onDeath()
{
	self waittill("death");
	level.turrets_held -= 1;
}

placeTurret(turret_type)
{
	self endon("death");
	self endon("disconnect");
	self endon("downed");
	wait 1;
	while (1)
	{
		if (self attackbuttonpressed())
		{
			
			if (self deploy(turret_type))
			{
				// self.carryObj unlink();
				wait 0.05;
				self.carryObj delete();
				
				self.canUse = true;
				self enableweapons();
				self notify("placed_turret");

				
				return ;
			}
			else
			{
				wait 1;
			}
		}
		wait .05;
	}
	
}

deploy(turret_type)
{
	self endon("disconnect");
	self endon("death");

	angles =  self getPlayerAngles();
	start = self.origin + (0,0,40) + vectorscale(anglesToForward( angles ), 20);
	end = self.origin + (0,0,40) + vectorscale(anglesToForward( angles ), 38);

	left = vectorscale(anglesToRight( angles ), -10);
	right = vectorscale(anglesToRight( angles ), 10);
	back = vectorscale(anglesToForward( angles ), -6);

	canPlantThere1 = BulletTracePassed( start, end, true, self);
	canPlantThere2 = BulletTracePassed( start + (0,0,-7) + left, end + left + back, true, self);
	canPlantThere3 = BulletTracePassed( start + (0,0,-7) + right , end + right + back, true, self);
	if( !canPlantThere1 || !canPlantThere2 || !canPlantThere3 )
	{
		self iPrintlnBold("Can not deploy ^2defence turret ^7here.");
		return false;
	}

	trace = bulletTrace( end + (0,0,100), end - (0,0,300), false, self );	
	self thread defenceTurret( turret_type, trace["position"], (0,angles[1],0) );

	return true;
}

hideUpperParts(){
	/* Hides gun-part of Sentry Gun */
	self hidePart("tag_aim");
	self hidePart("tag_aim_pitch");
	self hidePart("tag_swivel");
}

hideLowerParts(){
	/* Hides bipod-part of Sentry Gun */
	self hidePart("tag_base");
	wait 0.05;
	playFXonTag(level.sentry_laser, self, "tag_flash");
}

defenceTurret( turret_type, pos, angles )
{
	self endon("kill_turret");

	level.turrets ++;
	offset = (0,0,0);
	iprintln( "^2" + self.name + " ^2deployed a " + turret_type + " turret." );
	if(turret_type == "gl")
		offset = (0,0,20);
		
	self.turret_gun = spawn( "script_model", pos + offset);
	self.turret_bipod = spawn( "script_model", pos );

	self.turret_gun setModel( level.sentry_turret_model[turret_type] );
	self.turret_bipod setModel( level.sentry_base_model[turret_type] );
	
	if(turret_type == "minigun"){
		self.turret_gun thread hideLowerParts();
		self.turret_bipod hideUpperParts();
	}

	self.turret_gun setContents( 0 );
	self.turret_bipod setContents( 0 );

	self.turret_gun.angles = angles + (0,50,0);
	self.turret_bipod.angles = angles;

	self.turret_gun.owner = self;
	self.turret_gun.turret_type = turret_type;
	
	if (self.turret_gun.turret_type == "gl") {
		self.turret_gun.fireSpeed = 0.5;
		self.turret_gun.numBullets = 3;
		self.turret_gun.minDamage = 50;
		self.turret_gun.maxDamageAdd = 70;
		self.turret_gun.range = 1000;
		self.turret_gun.maxUpAngle = 45;
		self.turret_gun.cooldown = 2;
		self.turret_gun.fireTag = "tag_turret";
	}
	if (self.turret_gun.turret_type == "minigun") {
		self.turret_gun.fireSpeed = 0.05;
		self.turret_gun.numBullets = 20;
		self.turret_gun.minDamage = 5;
		self.turret_gun.maxDamageAdd = 10;
		self.turret_gun.range = 700;
		self.turret_gun.maxUpAngle = 30;
		self.turret_gun.cooldown = 1;
		self.turret_gun.fireTag = "tag_flash";
	}
	self.turret_gun.isTurret = true;
	self.turret_gun thread CheckForPlayers();
	self.turret_gun thread rotate();
	
	if(self.turret_gun.turret_type  == "gl")
		self.turret_gun thread shootGL();
	else if(self.turret_gun.turret_type == "minigun")
		self.turret_gun thread shootMinigun();
		
	self.turret_gun.spawnTime = gettime();
	self.turret_gun.timePassed = self.turret_time;
	self.turret_gun.bipod = self.turret_bipod;
	self.turret_gun thread disableEffects();
	wait 1;
	// self scripts\players\_usables::addUsable(self.turret_gun, "turret", "Press [^3USE^7] to pickup turret", 96 );
	self scripts\players\_usables::addUsable(self.turret_gun, "turret", &"USE_TURRET", 96 );

	level thread deleteTurretInTime(self.turret_gun, self.turret_bipod, level.dvar["game_turret_time"] - self.turret_gun.timePassed);
}

deleteTurretInTime(gun, bipod, time)
{
	gun endon("death");
	wait time;
	thread deleteTurret(gun, bipod);
}

disableEffects(){
	self endon("death");
	// level endon("turrets_enabled");
	level endon("game_ended");
	// iprintlnbold("Turret started disableEffects!");
	if(!level.turretsDisabled){
		// iprintlnbold("Turret is waiting for waittill!");
		level waittill("turrets_disabled");
		wait randomfloat(2);
	}
	// else
		// iprintlnbold("Turret does not wait!");
	
	self playsound( "turret_broken" );
	self createEffectEntity(level.turret_broken, self.fireTag);
	self moveDisabledPosition();
	self thread enableAgain();
}

moveDisabledPosition(){

//	 Endon unnecessary
	currentAngle = self.angles;
	if(self.turret_type == "gl")
		self rotateto( (50, currentAngle[1], 0), 3 );
	else // minigun
		self rotateto( (15, currentAngle[1], 0), 3 );
}

enableAgain(){
	// iprintlnbold("Turret awaiting enableAgain!");
	self endon("death");
	level endon("game_ended");
	level waittill("turrets_enabled");
	// iprintlnbold("Turret reenabled!");
	currentAngle = self.angles;
	if(isDefined(self.effect))
		self.effect delete();
	self rotateto( (0, currentAngle[1], 0), 3, 0.5, 2 );
	wait 3;
	self thread disableEffects();
}

createEffectEntity(effect, origin){
	if(isDefined(self.effect))
		return;
	self endon("death");
	self.effect = undefined;
	self.effect = spawn( "script_model", self getTagOrigin( origin ));
	self.effect setModel( "tag_origin" );
	wait 0.05;
	PlayFXOnTag( effect, self.effect, "tag_origin" );
	self.effect LinkTo( self );
}

deleteTurret(gun, bipod)
{
	if (isdefined(gun.owner))
	{
		gun.owner scripts\players\_usables::removeUsable(gun);
	}
	level.turrets -= 1;
	if(isDefined(gun.effect))
		gun.effect delete();
	bipod delete();
	gun delete();
}

glDamage(targetSpot, range, damage, attacker)
{
	for (i=0; i < level.bots.size; i++)
	{
		selectedBot = level.bots[i];
		if (isdefined(selectedBot) && isalive(selectedBot))
		{
			distance = distance(targetSpot, selectedBot.origin);
			if (distance <= range ){
				visibility = selectedBot sightConeTrace( targetSpot, selectedBot );
				if(visibility != 0)
					selectedBot thread [[level.callbackPlayerDamage]](self, attacker, int(damage * visibility), 0, "MOD_RIFLE_BULLET", "turret_mp", self.origin, vectornormalize(self.origin - selectedBot.origin), "none", 0);
			}
		}
	}
}

travelDistance(distance){
	// Maxrange: 850, wait ~ 0.5 sec max
	delay = distance / 1600;
	
	if(delay < 0.05)
		delay = 0.05;
		
	return(delay);
}

shootGL()
{
	self endon("death");
	self endon("kill_turret");
	shotsFired = 0;
	while(1)
	{
		if( isDefined( self.targetPlayer ) )
		{
			self waittill("rotation_done");
			for (i=0; i<self.numBullets; i++) {
				if (!isDefined(self.targetPlayer) || self isInView(self.targetPlayer) <= 0 || !isAlive(self.targetPlayer))
					break;
				
				dist = distance( self getTagOrigin(self.fireTag), self.targetPlayer getTagOrigin("tag_eye") - (0,0,36) );
				if(dist > self.range || dist < 40)
					break;
				
				shotsFired++;
				self playsound("weap_m203_fire_npc");
				playFx( level._effect["turret_flash"], self getTagOrigin(self.fireTag), anglesToForward( self.angles - (0,50,0) ) );
				targetSpot = self.targetPlayer.origin;
				wait travelDistance(dist);
				
				if(!isDefined(self.targetPlayer)) continue; // Stop here if target died
				
				thread playSoundOnSpot("clusterbomb_explode_default", targetSpot);
				playFx( level.effect_sentry_hit[self.turret_type], targetSpot );

				self thread glDamage(targetSpot, 195, int(self.minDamage + randomInt(self.maxDamageAdd)), self.owner);
				
				wait self.fireSpeed;
			}
			
			if( (shotsFired / self.numBullets) * self.cooldown < 0.05 )
				wait 0.05;
			else
				wait (shotsFired / self.numBullets) * self.cooldown;
				
			shotsFired = 0;
		}
		else if (shotsFired > 0) {
			wait (shotsFired / self.numBullets) * self.cooldown;
			shotsFired = 0;
		}
		wait .1;
		resettimeout();
	}
}

shootMinigun()
{
	self endon("death");
	self endon("kill_turret");
	shotsFired = 0;
	while(1)
	{
		if( isDefined( self.targetPlayer ) )
		{
			self waittill("rotation_done");
			for (i=0; i<self.numBullets; i++) {
				if (!isDefined(self.targetPlayer) || self isInView(self.targetPlayer) <= 0 || !isAlive(self.targetPlayer))
					break;
				
				dist = distance( self getTagOrigin(self.fireTag), self.targetPlayer getTagOrigin("tag_eye") - (0,0,36) );
				if(dist > self.range || dist < 40)
					break;
				
				shotsFired++;
				playFx( level._effect["turret_flash"], self getTagOrigin(self.fireTag), anglesToForward( self.angles - (0,50,0) ) );
				playFx( level.effect_sentry_hit["minigun"], self.targetPlayer getTagOrigin("tag_eye") );
				self playsound("weap_minigun_fire");

				self.targetPlayer thread [[level.callbackPlayerDamage]](self, self.owner, (self.minDamage + randomInt(self.maxDamageAdd)), 0, "MOD_RIFLE_BULLET", "turret_mp", self.origin, vectornormalize(self.targetPlayer.origin - self.origin), "none", 0);
				
				wait self.fireSpeed;
			}
			// if(shotsFired == self.numBullets)
				// playFx(level._effect["overheat"], self getTagOrigin("tag_flash"));
			if( (shotsFired / self.numBullets) * self.cooldown < 0.05 )
				wait 0.05;
			else
				wait (shotsFired / self.numBullets) * self.cooldown;
				
			shotsFired = 0;
		}
		else if (shotsFired > 0) {
			wait (shotsFired / self.numBullets) * self.cooldown;
			shotsFired = 0;
		}
		wait .1;
		resettimeout();
	}
}

playSoundOnSpot(sound, origin){

	spot = spawn( "script_origin", origin);
	wait 0.05;
	spot playsound(sound);
	spot delete();

}

CheckForPlayers()
{
	self endon("joined_spectators");
	self endon("disconnect");
	self endon("death");
	self endon("kill_turret");

	self.targetPlayer = undefined;
	while(1)
	{  
		if(level.turretsDisabled){
			self.targetPlayer = undefined;
			wait 1;
			continue;
		}
		closestDist = undefined;
		closestPlayer = undefined;
                  

		for(i = 0; i < level.bots.size; i++)
		{
			bot = level.bots[i];

			if( bot.sessionstate == "playing" && bot.type != "boss" && !level.turretsDisabled)
			{
				res = self IsInView(bot);
				if(res >= 0)
				{	
		
					if(!isDefined(closestDist) || (res < closestDist && res > 40))
					{
			 
						closestDist = res;
						closestPlayer = bot;
					}	
				}
			}
		}

		if(isDefined(closestPlayer))
			self.targetPlayer = closestPlayer;
         
		while(isDefined(closestPlayer) && isAlive(closestPlayer) && closestPlayer.type != "boss" && closestPlayer.sessionstate == "playing" && self IsInView(closestPlayer) >= 0 && !level.turretsDisabled)
		{
		
			self.targetPlayer = closestPlayer;
			wait 0.05;
		}

		self.targetPlayer = undefined;
             
		wait 0.5;
	}
}

rotate()
{
	self endon("joined_spectators");
	self endon("disconnect");
	self endon("death");
	self endon("kill_turret");

	while(1)
	{
		while( isDefined(self.targetPlayer) && !self.targetPlayer.untargetable)
		{
			time = 0.4;
			dist = distance( self.origin, self.targetPlayer.origin + (0,0,36) );
			if( dist <= 200 )
				time = 0.35;
			else if( dist <= 70 )
				time = 0.45;
			else if(dist > 7000)
				continue;

			aim = vectortoangles( self.targetPlayer.origin - self.origin );
			// self rotateto( (aim[0], aim[1]+50, 0), time );
			self rotateto( (aim[0], aim[1], 0), time );
			self thread notifyRotation(time);
			wait 0.1;
		}
		wait 0.5;
	}
}

notifyRotation(delay){
	self endon("kill_turret");
	self endon("death");
	self endon("disconnect");
	self endon("rotation_done");
	
	wait delay;
	self notify("rotation_done");
}

IsInView(target)
{
	dist = distanceSquared( self.origin, target.origin );
	if(dist < 400000)
	{
		trace = bullettrace( self getTagOrigin(self.fireTag) , target getEye() , false, self );
		vector = self.origin - target.origin;
		vector = vectorToAngles(vector);
   		if( distance( self.origin, target.origin ) < 800 && trace["fraction"] == 1 && aSin(anglesToUp(vector)[2]) > (90 - self.maxUpAngle) )
			return dist;
	}
	return -1;
}

