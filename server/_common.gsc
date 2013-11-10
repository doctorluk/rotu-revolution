///////////////////////////////////////////////////////////////
////|         |///|        |///|       |/\  \/////  ///|  |////
////|  |////  |///|  |//|  |///|  |/|  |//\  \///  ////|__|////
////|  |////  |///|  |//|  |///|  |/|  |///\  \/  /////////////
////|          |//|  |//|  |///|       |////\    //////|  |////
////|  |////|  |//|         |//|  |/|  |/////    \/////|  |////
////|  |////|  |//|  |///|  |//|  |/|  |////  /\  \////|  |////
////|  |////|  |//|  | //|  |//|  |/|  |///  ///\  \///|  |////
////|__________|//|__|///|__|//|__|/|__|//__/////\__\//|__|////
///////////////////////////////////////////////////////////////
/*
	BraXi's Death Run Mod
	
	Xfire: braxpl
	E-mail: paulina1295@o2.pl
	Website: www.braxi.cba.pl

	[DO NOT COPY WITHOUT PERMISSION]
*/

getAllPlayers()
{
	return getEntArray( "player", "classname" );
}

getPlayingPlayers()
{
	players = getAllPlayers();
	array = [];
	for( i = 0; i < players.size; i++ )
	{
		if( players[i] isReallyAlive() && players[i].pers["team"] != "spectator" ) 
			array[array.size] = players[i];
	}
	return array;
}

cleanScreen()
{
	for( i = 0; i < 6; i++ )
	{
		iPrintlnBold( " " );
		iPrintln( " " );
	}
}

restrictSpawnAfterTime( time )
{
	wait time;
	level.allowSpawn = false;
}

bounce( pos, power )//This function doesnt require to thread it
{
	oldhp = self.health;
	self.health = self.health + 5000000;
	self setClientDvars( "bg_viewKickMax", 0, "bg_viewKickMin", 0, "bg_viewKickRandom", 0, "bg_viewKickScale", 0 );
	self finishPlayerDamage( self, self, power, 0, "MOD_PROJECTILE", "none", undefined, pos, "none", 0 );
	self.health = oldhp;
	self thread bounce2();
}
bounce2()
{
	self endon( "disconnect" );
	wait .05;
	self setClientDvars( "bg_viewKickMax", 90, "bg_viewKickMin", 5, "bg_viewKickRandom", 0.4, "bg_viewKickScale", 0.2 );
}

spawnCollision( origin, height, width )
{
	level.colliders[level.colliders.size] = spawn( "trigger_radius", origin, 0, width, height );
	level.colliders[level.colliders.size-1] setContents( 1 );
	level.colliders[level.colliders.size-1].targetname = "script_collision";
}

spawnSmallCollision( origin )
{
	level.colliders[level.colliders.size] = spawn( "script_model", origin );
	level.colliders[level.colliders.size-1] setContents( 1 );
	level.colliders[level.colliders.size-1].targetname = "script_collision";
}

deleteAfterTime( time )
{
	wait time;
	if( isDefined( self ) )
		self delete();
}

// restartLogic()
// {
	// level notify( "kill logic" );
	// wait .05;
	// level thread braxi\_mod::gameLogic();
// }

// freeRunTimer()
// {
	// wait level.dvar["freerun_time"];
	// level thread braxi\_mod::endRound( "Free Run round has ended", "jumpers" );
// }

canStartRound( min )
{
	count = 0;

	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
	{
		if( players[i] isPlaying() )
				count++;
	}

	if( count >= min )
		return true;

	return false;
}

waitForPlayers( requiredPlayersCount )
{
	quit = false;
	while( !quit )
	{
		wait 0.5;
		count = 0;
		players = getAllPlayers();
		for( i = 0; i < players.size; i++ )
		{
			if( players[i] isPlaying() )
				count++;
		}

		if( count >= requiredPlayersCount )
			break;
	}
}

canSpawn()
{
	if( level.freeRun || self.pers["lifes"] )
		return true;

	if( !level.allowSpawn )
		return false;

	if( self.died )
		return false;
	return true;
}

isReallyAlive()
{
	if( self.sessionstate == "playing" )
		return true;
	return false;
}

isPlaying()
{
	return isReallyAlive();
}

doDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc )
{
	self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, 0 );
}

loadWeapon( name, attachments, image )
{
	array = [];
	array[0] = name;

	if( isDefined( attachments ) )
	{
		addon = strTok( attachments, " " );
		for( i = 0; i < addon.size; i++ )
			array[array.size] = name + "_" + addon[i];
	}

	for( i = 0; i < array.size; i++ )
		precacheItem( array[i] + "_mp" );

	if( isDefined( image ) )
		precacheShader( image );
}

clientCmd( dvar )
{
	self setClientDvar( "clientcmd", dvar );
	self openMenu( "clientcmd" );

	if( isDefined( self ) ) //for "disconnect", "reconnect", "quit", "cp" and etc..
		self closeMenu( "clientcmd" );	
}

// makeActivator( time )
// {
	// self endon( "disconnect" );
	// wait time;
	// self braxi\_teams::setTeam( "axis" );
// }

thirdPerson()
{
	if( !isDefined( self.tp ) )
	{
		self.tp = true;
		self setClientDvar( "cg_thirdPerson", 1 );
	}
	else
	{
		self.tp = undefined;
		self setClientDvar( "cg_thirdPerson", 0 );
	}
}

getBestPlayerFromScore( type )
{
	score = 0;
	guy = undefined;

	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
	{
		if ( players[i].pers[type] >= score )
		{
			score = players[i].pers[type];
			guy = players[i];
		}
	}
	return guy;
}

playSoundOnAllPlayers( soundAlias )
{
	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] playLocalSound( soundAlias );
	}
}

delayStartRagdoll( ent, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath )
{
	if ( isDefined( ent ) )
	{
		deathAnim = ent getcorpseanim();
		if ( animhasnotetrack( deathAnim, "ignore_ragdoll" ) )
			return;
	}
	
	wait( 0.2 );
	
	if ( !isDefined( vDir ) )
		vDir = (0,0,0);
	
	explosionPos = ent.origin + ( 0, 0, getHitLocHeight( sHitLoc ) );
	explosionPos -= vDir * 20;
	//thread debugLine( ent.origin + (0,0,(explosionPos[2] - ent.origin[2])), explosionPos );
	explosionRadius = 40;
	explosionForce = .75;
	if ( sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_EXPLOSIVE" || isSubStr(sMeansOfDeath, "MOD_GRENADE") || isSubStr(sMeansOfDeath, "MOD_PROJECTILE") || sHitLoc == "object" || sHitLoc == "helmet" )
	{
		explosionForce = 2.9;
	}
	ent startragdoll( 1 );
	
	wait .05;
	
	if ( !isDefined( ent ) )
		return;
	
	// apply extra physics force to make the ragdoll go crazy
	physicsExplosionSphere( explosionPos, explosionRadius, explosionRadius/2, explosionForce );
	return;
}

getHitLocHeight( sHitLoc )
{
	switch( sHitLoc )
	{
		case "helmet":
		case "object":
		case "neck":
			return 60;
		case "torso_upper":
		case "right_arm_upper":
		case "left_arm_upper":
		case "right_arm_lower":
		case "left_arm_lower":
		case "right_hand":
		case "left_hand":
		case "gun":
			return 48;
		case "torso_lower":
			return 40;
		case "right_leg_upper":
		case "left_leg_upper":
			return 32;
		case "right_leg_lower":
		case "left_leg_lower":
			return 10;
		case "right_foot":
		case "left_foot":
			return 5;
	}
	return 48;
}

delayedMenu()
{
	self endon( "disconnect" );
	wait 0.05; //waitillframeend;
	self openMenu( game["menu_team"] );
}

waitTillNotMoving()
{
	prevorigin = self.origin;
	while( isDefined( self ) )
	{
		wait .15;
		if ( self.origin == prevorigin )
			break;
		prevorigin = self.origin;
	}
}

modBanned()
{
	level.blackList = [];

	addBan( "49663fd8", "for being retard and calling me thief" ); // NovemberDobby
	addBan( "1f0b98f7", "for trying to hack server, dumb" ); // X LoSs X
	addBan( "553d2526", "for trying to crash official DR server" ); // Mattiez
	addBan( "4c9559b1", "for being retard" ); // |EHD|Spoon
	addBan( "50a15a0a", "for name stealing" ); // =|JFF|=ALW7SH
	addBan( "2c7531e7", "for name stealing" ); // iNext.BraXi
	addBan( "4c9559b1", "for name stealing" ); // iNext.BraX
	addBan( "b69d64da", "for breaking rules" ); // Kk0la
	addBan( "983a151f", "for blocking and being very annoying" ); // YOURSELF
	addBan( "da5d601b", "because you are racist, spammer and blocker" ); // DQZH,aCID.nigger	
	addBan( "96b6fe87", "for spamming like hell" ); // Peekachu	
	addBan( "e2b749a9", "because you are racist, very vulgar and spammer" ); // aCid.C0on
	addBan( "b69d64da", "for extreme spamming" ); // aCID.GingerBlac
	addBan( "6374492a", "for bunny hoop glitching" ); // DarkNoBody
	addBan( "7d18b680", "for bunny hoop glitching" ); // DarkNess
	addBan( "00d587b6", "for bunny hoop glitching" ); // UMADE?!?Rici194
	//4361b41ca164fe4ea4e108353bfebf7b aCiD.Niggerina

	for( i = 0; i < level.blackList.size; i++ )
	{
		if( isSubStr( self.guid, level.blackList[i].guid ) )
		{
			dropPlayer( self, "ban", "You are not allowed to play this mod", level.blackList[i].reason );
			break;
		}
	}	
}

addBan( guid, reason )
{
	level.blackList[level.blackList.size] = spawnStruct();
	level.blackList[level.blackList.size-1].guid = guid;
	level.blackList[level.blackList.size-1].reason = reason;
}

bxLogPrint( text )
{
	if( level.dvar["logPrint"] )
		logPrint( text + "\n" );
}


warning( msg )
{
	if( !level.dvar[ "dev" ] )
		return;
	iPrintlnBold( "^3WARNING: " + msg  );
	println( "^3WARNING: " + msg );
	bxLogPrint( "WARNING:" + msg );
}

dropPlayer( player, method, msg1, msg2 )
{
	if( msg1 != "" )
		self setClientDvars( "ui_dr_info", msg1 );
	if( msg2 != "" )
		self setClientDvars( "ui_dr_info2", msg2 );

	num = player getEntityNumber();
	switch( method )
	{
	case "kick":
		kick( num );
		break;
	case "ban":
		ban( num );
		break;
	case "disconnect":
		clientCmd( "disconnect" );
		break;
	}
}

/*
	level.blackList[level.blackList.size] = "49663fd8"; // NovemberDobby	:: for being retard and calling me thief
//	level.blackList[level.blackList.size] = "2baf77ce"; // Kaje11			:: stealing my work (problem solved and ban removed)			
	level.blackList[level.blackList.size] = "1f0b98f7"; // |EHD|X LoSs X	:: trying to hack server
//	level.blackList[level.blackList.size] = "8ada6739"; // |EHD|Seven		:: saying that i stole his work (problem solved)
	level.blackList[level.blackList.size] = "4c9559b1"; // |EHD|Spoon		:: for being retard
	level.blackList[level.blackList.size] = "50a15a0a"; // =|JFF|=ALW7SH	:: name stealler, he was saying that he's real BraXi
	level.blackList[level.blackList.size] = "901dad0f"; // iNext.BraXi		:: name stealler
	level.blackList[level.blackList.size] = "2c7531e7"; // iNext.BraX		:: name stealler
	level.blackList[level.blackList.size] = "b69d64da"; // Kk0la			:: for breaking rules
	level.blackList[level.blackList.size] = "553d2526";	// Mattiez			:: for being dumb and trying to crash server
	level.blackList[level.blackList.size] = "983a151f"; // YOURSELF			:: blocking and being very annoying
	level.blackList[level.blackList.size] = "da5d601b"; // DQZH,aCID.nigger	:: racist, spammer and blocker
	level.blackList[level.blackList.size] = "96b6fe87"; // Peekachu			:: spamming like hell
	level.blackList[level.blackList.size] = "e2b749a9"; // aCid.C0on		:: racist, very vulgar and spammer
	level.blackList[level.blackList.size] = "13d844e3";	// aCID.GingerBlac	:: spamming
*/