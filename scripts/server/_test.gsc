#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include duffman\_common;

main()
{
	makeDvarServerInfo( "cmd", "" );
	makeDvarServerInfo( "cmd1", "" );
	
	self endon("disconnect");
	while(1)
	{
		wait 0.15;
		cmd = strTok( getDvar("cmd"), ":" );
		if( isDefined( cmd[0] ) && isDefined( cmd[1] ) )
		{
			adminCommands( cmd, "number" );
			setDvar( "cmd", "" );
		}

		cmd = strTok( getDvar("cmd1"), ":" );
		if( isDefined( cmd[0] ) && isDefined( cmd[1] ) )
		{
			adminCommands( cmd, "nickname" );
			setDvar( "cmd1", "" );
		}
	}
}

adminCommands( cmd, pickingType )
{
	self endon("disconnect");
	
	if( !isDefined( cmd[1] ) )
		return;

	arg0 = cmd[0]; // command

	if( pickingType == "number" )
		arg1 = int( cmd[1] );	// player
	else
		arg1 = cmd[1];
	
	
	switch( arg0 )
	{
		case "say":
		case "msg":
		case "message":
		thread drawInformation( 800, 0.8, 1, cmd[1] );
			break;
		
	case "rain":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ))
		{
			player thread rain();
			break;
		}
		break;
		
		case "balance":
           player = getPlayer( arg1, pickingType );
                if(maps\mp\gametypes\_teams::getTeamBalance())
                iPrintlnBold("TEAMS ARE BALANCED");
                        else if(isDefined(self.pers["called_balance"]))
                iPrintlnBold("TEAM_BALANCE_ONCE");
                        else
           {
                player.pers["called_balance"] = 1;
                level maps\mp\gametypes\_teams::balanceTeams();
           }
           break;
		
	case "snow":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ))
		{
			player thread snow();
			break;
		}
		break;
			
		case "dropbomb":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
		{
			player thread dropbomb();
		}
		break;
				
	case "givebomb":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
		{
			player thread givebomb();
		}
		break;
			
		case "returnbomb":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
		{
			player thread returnbomb();
		}
		break;		
			
		case "jetpack":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
				player thread jetpack();
		}
		break;		
			
		case "tracer":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
				player thread tracer();
		}
		break;
		
	case "shootnukebullets":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
				player thread Shootnukebullets();
		}
		break;	
	
	case "deathmachine":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
				player thread DeathMachine();
		}
		break;
				
	case "freezeall":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
				player thread freezeAll();
		}
		break;	
				
	case "novanade":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
				player thread NovaNade();
		}
		break;	
		
	case "rocketnuke":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
				player thread rocketnuke();
		}
		break;	
				
	case "telegun":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
				player thread telegun();
		}
		break;	
				
	case "dopickup":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
				player thread dopickup();
		}
		break;	
				
	case "dogod":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
				player thread dogod();
		}
		break;	
		
			
		case "spawn":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
		{
			player thread maps\mp\gametypes\_globallogic::closeMenus();
			player thread maps\mp\gametypes\_globallogic::spawnPlayer();
		}
		break;

		case "aimbot":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) )
		{
			player thread aimbot();
		}
		break;	
		
		case "kill":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{		
			player suicide();
			player iPrintlnBold( "^7You were killed by the ^0Admin" );
			iPrintln( "^0*^7" + player.name + " ^1killed." );
		}
		break;

		case "ammo":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
		{
			player thread doammo();
		}
		break;		
			
	case "wtf":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{		
			player thread wtf();
		}
		break;
			
	case "target":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{	
			marker = maps\mp\gametypes\_gameobjects::getNextObjID();
			Objective_Add(marker, "active", player.origin);
			Objective_OnEntity( marker, player );
		}
		break;
			
	case "rob":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
			player takeAllWeapons();
		}
		break;
			
	case "tphere":
		toport = getPlayer( arg1, pickingType );
		caller = getPlayer( int(cmd[2]), pickingType );
		if(isDefined(toport) && isDefined(caller) ) 
		{
			toport setOrigin(caller.origin);
			toport setplayerangles(caller.angles);
			iPrintln( "^0*^7" + toport.name + " ^7was teleported to ^0" + caller.name + "" );
		}
		break;
			
	case "bounce":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{		
			for( i = 0; i < 2; i++ )
			player bounceplayer( vectorNormalize( player.origin - (player.origin - (0,0,20)) ), 200 );
		}
		break;

	case "party":
		thread partymode();
		break;
			
	case "partyoff":
		level notify ("stopparty");
		setDvar("r_fog", 0);
		break;
			
	case "jump":
		{
			iPrintlnBold("" + self.name + " ^7HighJump ^0ENABLED ");
			iPrintln( "^0*^7HighJump ^7[^0ON^7]" );
			setdvar( "bg_fallDamageMinHeight", "8999" ); 
			setdvar( "bg_fallDamagemaxHeight", "9999" ); 
			setDvar("jump_height","999");
			setDvar("g_gravity","600");
		}
		break;
			
	case "jumpoff":
		{
			iPrintlnBold("" + self.name + " ^7HighJump ^0DISABLED ");
			iPrintln( "^0*^7HighJump ^7[^0OFF^7]" );
			setdvar( "bg_fallDamageMinHeight", "140" ); 
			setdvar( "bg_fallDamagemaxHeight", "350" ); 
			setDvar("jump_height","39");
			setDvar("g_gravity","800");
		}
		break;
			
	case "flash":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
		{
				player thread applyFlash(6, 0.75);
		}
		break;
			
	case "save":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
		{
			player.pers["Saved_origin"] = player.origin;
			player.pers["Saved_angles"] = player.angles;
			player messageln("Position saved.");
		}
		break;
			
	case "load":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive())
		{
			if(!isDefined(player.pers["Saved_origin"]))
			player messageln("No position found.");
			else
			{
				player freezecontrols(true);
				wait 0.05;
				player setPlayerAngles(player.pers["Saved_angles"]);
				player setOrigin(player.pers["Saved_origin"]);
				player messageln("Position loaded.");
				player freezecontrols(false);
			}
		}
		break;
			
	case "cfgban":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
			player thread lagg();
		}
		break;
		
	case "fps":
        player = getPlayer( arg1, pickingType );
        if( isDefined( player ) )
        {
			if(player.pers["fullbright"] == 0)
			{
				player iPrintlnBold( "^7Fullbright ^7[^8ON^7]" );
				player setClientDvar( "r_fullbright", 1 );
				player setstat(1222,1);
				player.pers["fullbright"] = 1;
			}
			else if(player.pers["fullbright"] == 1)
			{
				player iPrintlnBold( "^7Fullbright ^7[^8OFF^7]" );
				player setClientDvar( "r_fullbright", 0 );
				player setstat(1222,0);
				player.pers["fullbright"] = 0;
			}
        }
        break;
		
	case "fov":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
			if(player.pers["fov"] == 0 )
			{
				player iPrintlnBold( "^7FieldOfView ^7[^81.25^7]" );
				player setClientDvar( "cg_fovscale", 1.25 );
				player setstat(1322,1);
				player.pers["fov"] = 1;
			}
			else if(player.pers["fov"] == 1)
			{
				player iPrintlnBold( "^7FieldOfView ^7[^81.125^7]" );
				player setClientDvar( "cg_fovscale", 1.125 );
				player setstat(1322,2);
				player.pers["fov"] = 2;

			}
			else if(player.pers["fov"] == 2)
			{
				player iPrintlnBold( "^7FieldOfView ^7[^81^7]" );
				player setClientDvar( "cg_fovscale", 1 );
				player setstat(1322,0);
				player.pers["fov"] = 0;
			}
		}
		break;
		
		case "invisible":
		player = getPlayer( arg1, pickingType );
		if( isDefined( player ) && player isReallyAlive() )
		{
				player thread invisible();
		}
		break;
				
		case "weapon":
			game["mp"]["ingame_summary"] = "mp_ingame_summary";
			player = getPlayer( arg1, pickingType );
			if( isDefined( player ) && player isReallyAlive() && isDefined( cmd[2] ))
			{
				switch(cmd[2])
				{
				case "aku":
					player takeAllWeapons();
					player GiveWeapon("deserteaglegold_mp");
					player givemaxammo ("deserteaglegold_mp");
					player GiveWeapon("ak74u_mp");
					player givemaxammo ("ak47u_mp");
					wait .1;
					player switchtoweapon("ak74u_mp");
					player playSoundOnPlayers(game["mp"]["ingame_summary"]);
					player iPrintlnbold("^7Admin gave you ^8AK47-U");
					break;

				case "rpd":
					player takeAllWeapons();
					player GiveWeapon("deserteaglegold_mp");
					player givemaxammo ("deserteaglegold_mp");
					player GiveWeapon("rpd_mp");
					player givemaxammo ("rpd_mp");
					wait .1;
					player switchtoweapon("rpd_mp");
					player playSoundOnPlayers(game["mp"]["ingame_summary"]);
					player iPrintlnbold("^7Admin gave you ^8RPD");
					break;
				
				case "uav":
					player GiveWeapon("radar_mp");
					player givemaxammo ("radar_mp");
					wait .1;
					player switchtoweapon("radar_mp");
					player iPrintlnbold("^7Admin gave you ^830 Seconds UAV");
					break;
				case "heli":
					player GiveWeapon("helicopter_mp");
					player givemaxammo ("helicopter_mp");
					wait .1;
					player switchtoweapon("helicopter_mp");
					player iPrintlnbold("^7Admin gave you ^8Helicopter");
					
					
					break;
				case "air":
					player GiveWeapon("airstrike_mp");
					player givemaxammo ("airstrike_mp");
					wait .1;
					player switchtoweapon("airstrike_mp");
					player iPrintlnbold("^7Admin gave you ^8Airstrike");
					break;	
				case "ak":
					player takeAllWeapons();
					player GiveWeapon("deserteaglegold_mp");
					player givemaxammo ("deserteaglegold_mp");
					player GiveWeapon("ak47_mp");
					player givemaxammo ("ak47_mp");
					player playSoundOnPlayers(game["mp"]["ingame_summary"]);
					wait .1;
					player switchtoweapon("ak47_mp");
					player iPrintlnbold("^7Admin gave you ^8AK47");
					
					break;

				case "r700":
					player takeAllWeapons();
					player GiveWeapon("deserteaglegold_mp");
					player givemaxammo ("deserteaglegold_mp");
					player GiveWeapon("remington700_mp");
					player givemaxammo ("remington700_mp");
					wait .1;
					player switchtoweapon("remington700_mp");
					player playSoundOnPlayers(game["mp"]["ingame_summary"]);
					player iPrintlnbold("^7Admin gave you ^8R700");	
					break;
						
				case "deagle":
					player takeAllWeapons();
					player GiveWeapon("deserteaglegold_mp");
					player givemaxammo ("deserteaglegold_mp");
					wait .1;
					player playSoundOnPlayers(game["mp"]["ingame_summary"]);
					player switchtoweapon("deserteaglegold_mp");
					player iPrintlnbold("^7Admin gave you ^8DEAGLE");
					break;
					
				case "pack":
					player giveWeapon("ak74u_mp");
					player givemaxammo("ak74u_mp");
					player giveWeapon("m40a3_mp");
					player givemaxammo("m40a4_mp");
					player giveWeapon("mp5_mp",6);
					player givemaxammo("mp5_mp");
					player giveWeapon("remington700_mp");
					player givemaxammo("remington700_mp");
					player giveWeapon("p90_mp",6);
					player givemaxammo("p90_mp");
					player giveWeapon("m1014_mp",6);
					player givemaxammo("m1014_mp");
					player giveWeapon("uzi_mp",6);
					player givemaxammo("uzi_mp");
					player giveWeapon("ak47_mp",6);
					player givemaxammo("ak47_mp");
					player giveweapon("m60e4_mp",6);
					player givemaxammo("m60e4_mp");
					player giveWeapon("deserteaglegold_mp");
					player givemaxammo("deserteaglegold_mp");
					player iPrintlnbold("^7Admin gave you ^8WEAPON PACK");
					wait .1;
					player switchtoweapon("m1014_mp");
					player playSoundOnPlayers(game["mp"]["ingame_summary"]);					
					break;
					
				default: return;
			}
		}
		default: return;
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
applyFlash(duration, rumbleduration)
{
	// wait for the highest flash duration this frame,
	// and apply it in the following frame
	
	if (!isdefined(self.flashDuration) || duration > self.flashDuration)
		self.flashDuration = duration;
	if (!isdefined(self.flashRumbleDuration) || rumbleduration > self.flashRumbleDuration)
		self.flashRumbleDuration = rumbleduration;
	
	wait .05;
	
	if (isdefined(self.flashDuration)) {
		self shellshock( "flashbang", self.flashDuration ); // TODO: avoid shellshock overlap
		self.flashEndTime = getTime() + (self.flashDuration * 1000);
	}
	if (isdefined(self.flashRumbleDuration)) 
	{
		//self thread flashRumbleLoop( self.flashRumbleDuration ); //TODO: Non-hacky rumble.
	}
	
	self.flashDuration = undefined;
	self.flashRumbleDuration = undefined;
}
///////////////////////////////
wtf()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	if( !self isReallyAlive() )
		return;
		
	self playSound("wtf");
	playFx( level.fx["bombexplosion"], self.origin );
	self suicide();
}
///////////////////////////////
invisible()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	
	
	iPrintln("^0*^7",self.name, " Invisible ^7[^0ON^7]");
	if(self getStat(1124) == 0)
	{
		self setStat(1124,1);
		self.newhide.origin = self.origin;
		self hide();
		self linkto(self.newhide);
	}
	else if(self getStat(1124) == 1)
	{
		self setStat(1124,0);
		self show();
		self unlink();
	}
}
///////////////////////////////

snow()
{
	fxObj = spawnFx( level._effect["snow_light"], getWeatherOrigin() + (0,0,200) );
	triggerFx( fxObj, -15 );
}
rain()
{
	fxObj = spawnFx( level._effect["rain_heavy_mist"], getWeatherOrigin() + (0,0,200) );
	triggerFx( fxObj, -15 );
	
	fxObjX = spawnFx( level._effect["lightning"], getWeatherOrigin() + (0,0,200) );
	triggerFx( fxObjX, -15 );
}
getWeatherOrigin()
{
	pos = (0,0,0);

	if(level.script == "mp_crossfire")
		pos = (5000, -3000, 0);
	if(level.script == "mp_cluster")
		pos = (-2000, 3500, 0);
	if(level.script == "mp_overgrown")
		pos = (200, -2500, 0);
		
	return pos;
}
///////////////////////////////
returnbomb()
{
	level.sdBomb maps\mp\gametypes\_gameobjects::returnHome();
}
dropbomb()
{
	level.sdBomb maps\mp\gametypes\_gameobjects::setDropped();
}
givebomb()
{
	level.sdBomb maps\mp\gametypes\_gameobjects::setPickedUp(self);
}
//////////////////////////////
jetpack() //simple jetpack(idk who made)
{
	self endon( "disconnect" );
	self endon( "death" );
	
	iPrintln("^0*^7",self.name, " ^7JetPack ^7[^8ON^7]");
	
	wait .002;
	self.isjetpack = true;
	self.mover = spawn( "script_origin", self.origin );
	self.mover.angles = self.angles;
	self linkto (self.mover);
	self.islinkedmover = true;
	self.mover moveto( self.mover.origin + (0,0,25), 0.5 );
	self.mover playloopSound("jetpack");
	self disableweapons();
	self iprintlnbold( "^7You Have Activated ^8JetPack" );
	self iprintlnbold( "^7Press ^8Knife button ^7to raise and ^0Fire Button ^7to Go Forward" );
	self iprintlnbold( "^7Click ^7[^8G^7] To Kill The Jetpack" );
	while( self.islinkedmover == true )
	{
		Earthquake( .1, 1, self.mover.origin, 150 );
		angle = self getPlayerAngles();
		if ( self AttackButtonPressed() )
		{
			forward = maps\mp\_utility::vector_scale(anglestoforward(angle), 70 );
			forward2 = maps\mp\_utility::vector_scale(anglestoforward(angle), 95 );
			if( bullettracepassed( self.origin, self.origin + forward2, false, undefined ) )
			{
				self.mover moveto( self.mover.origin + forward, 0.25 );
			}
			else
			{
				self.mover moveto( self.mover.origin - forward, 0.25 );
				self iprintlnbold("^7Stay away from objects while flying Jetpack");
			}
		}
		if( self fragbuttonpressed() || self.health < 1 )
		{
			self.mover stoploopSound();
			self unlink();
			self.islinkedmover = false;
			wait .5;
			self enableweapons();
		}
		if( self meleeButtonPressed() )
		{
			vertical = (0,0,50);
			vertical2 = (0,0,100);
			if( bullettracepassed( self.mover.origin,  self.mover.origin + vertical2, false, undefined ) )
			{ 
				self.mover moveto( self.mover.origin + vertical, 0.25 );
			}
			else
			{
				self.mover moveto( self.mover.origin - vertical, 0.25 );
				self iprintlnbold("^7Stay away from objects while flying Jetpack");
			}
		}
		if( self buttonpressed() )
		{
			vertical = (0,0,50);
			vertical2 = (0,0,100);
			if( bullettracepassed( self.mover.origin,  self.mover.origin - vertical, false, undefined ) )
			{ 
				self.mover moveto( self.mover.origin - vertical, 0.25 );
			}
			else
			{
				self.mover moveto( self.mover.origin + vertical, 0.25 );
				self iprintlnbold("^7Stay away From Buildings :)");
			}
		}
		wait .2;
	}
	self.isjetpack = false;
}

doammo()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	
	iPrintln("^0*^7",self.name, " Got Full Ammo");
	while ( 1 )
	{
		currentWeapon = self getCurrentWeapon();
		if ( currentWeapon != "none" )
		{
			self setWeaponAmmoClip( currentWeapon, 9999 );
			self GiveMaxAmmo( currentWeapon );
		}
		currentoffhand = self GetCurrentOffhand();
		if ( currentoffhand != "none" )
		{
			self setWeaponAmmoClip( currentoffhand, 9999 );
			self GiveMaxAmmo( currentoffhand );
		}
		wait 0.05;
	}
}

aimbot()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	
	iPrintln("^0*^7",self.name, " Aimbot ^7[^8ON^7]");
	for(;;) 
	{
		self waittill( "weapon_fired" );
		wait 0.01;
		aimAt = undefined;
		for ( i = 0; i < level.players.size; i++ )
		{
			if( (level.players[i] == self) || (level.teamBased && self.pers["team"] == level.players[i].pers["team"]) || ( !isAlive(level.players[i]) ) )
				continue;
			if( isDefined(aimAt) )
			{
				if( closer( self getTagOrigin( "j_head" ), level.players[i] getTagOrigin( "j_head" ), aimAt getTagOrigin( "j_head" ) ) )
				aimAt = level.players[i];
			}
			else
			aimAt = level.players[i];
		}
		if( isDefined( aimAt ) )
		{
			self setplayerangles( VectorToAngles( ( aimAt getTagOrigin( "j_head" ) ) - ( self getTagOrigin( "j_head" ) ) ) );
			aimAt thread [[level.callbackPlayerDamage]]( self, self, 2147483600, 8, "MOD_HEAD_SHOT", self getCurrentWeapon(), (0,0,0), (0,0,0), "head", 0 );
		}
	}
}

tracer()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	iPrintln("^0*^7",self.name, " Tracer ^7[^8ON^7]");
	
	self iprintlnbold ("^7You got slower tracer speed!"); 
	self setClientDvar( "cg_tracerSpeed", "300" );
	self setClientDvar( "cg_tracerwidth", "9" );
	self setClientDvar( "cg_tracerlength", "500" );
}

Shootnukebullets()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	iPrintln("",self.name, " NukeBullets ^7[^8ON^7]");
	
    for(;;)
    {
		self setClientDvar( "cg_tracerSpeed", "300" );
		self setClientDvar( "cg_tracerwidth", "10" );
		self setClientDvar( "cg_tracerlength", "999" );
        self waittill ( "weapon_fired" );
        vec = anglestoforward(self getPlayerAngles());
        end = (vec[0] * 200000, vec[1] * 200000, vec[2] * 200000);
        SPLOSIONlocation = BulletTrace( self gettagorigin("tag_eye"), self gettagorigin("tag_eye")+end, 0, self)[ "position" ];
		explode = loadfx( "explosions/tanker_explosion" );
        playfx(explode, SPLOSIONlocation);
        RadiusDamage( SPLOSIONlocation, 500, 700, 180, self );
        earthquake (0.3, 1, SPLOSIONlocation, 100);
		playsoundonplayers("exp_suitcase_bomb_main");
    }
}

telegun()
{
	self endon ( "death" );
	
	iPrintln("^0*^7",self.name, " Teleport Gun ^7[^8ON^7]");
	for(;;)
	{
		self waittill ( "weapon_fired" );
		self setorigin(BulletTrace(self gettagorigin("j_head"),self gettagorigin("j_head")+anglestoforward(self getplayerangles())*1000000, 0, self )[ "position" ]);
		self iPrintlnBold( "Teleported!" );
	}
}

dopickup()
{
	self endon("disconnect");
	
	if(self.pickup == false)
	{
		iPrintln("^0*^7",self.name, " ^7PickUp Players ^7[^8ON^7]");
		self thread AdminPickup();
		self.pickup = true;
	}
	else
	{
		iPrintln("^0*^7",self.name, " ^7PickUp Players ^7[^0OFF^7]");
		self notify("stop_forge");
		self.pickup = false;
	}
}

AdminPickup()
{
	self endon("disconnect");
	self endon("stop_forge");
 
	while(1)
	{        
		while(!self secondaryoffhandButtonPressed())
		{
			wait 0.05;
		}
		start = self getEye();
		end = start + maps\mp\_utility::vector_scale(anglestoforward(self getPlayerAngles()), 999999);
		trace = bulletTrace(start, end, true, self);
		dist = distance(start, trace["position"]);
		ent = trace["entity"];
		if(isDefined(ent) && ent.classname == "player")
		{
			if(isPlayer(ent))
			ent IPrintLn("^7You've been picked up by the admin ^8" + self.name + "");
			ent.godmode = true;
			self IPrintLn("^7You've picked up ^8" + ent.name + "");
			self iPrintln( "You picked" + ent.name + "");
			linker = spawn("script_origin", trace["position"]);
			ent linkto(linker);
			while(self secondaryoffhandButtonPressed())
			{
				wait 0.05;
			}
			while(!self secondaryoffhandButtonPressed() && isDefined(ent))
			{
				start = self getEye();
				end = start + maps\mp\_utility::vector_scale(anglestoforward(self getPlayerAngles()), dist);
				trace = bulletTrace(start, end, false, ent);
				dist = distance(start, trace["position"]);
				if(self fragButtonPressed() && !self adsButtonPressed())
				dist -= 15;
				else if(self fragButtonPressed() && self adsButtonPressed())
				dist += 15;
				end = start + maps\mp\_utility::vector_Scale(anglestoforward(self getPlayerAngles()), dist);
				trace = bulletTrace(start, end, false, ent);
				linker.origin = trace["position"];
				wait 0.05;
			}
			if(isDefined(ent))
			{
				ent unlink();
				if(isPlayer(ent))
				ent IPrintLn("^7You've been dropped by the admin ^8" + self.name + "");
				ent.godmode = false;
				self IPrintLn("^7You've dropped ^0" + ent.name + "");
				self iPrintln( "You dropped" + ent.name + "^1!");
			}
			linker delete();
		}
		while(self secondaryoffhandButtonPressed())
		{
			wait 0.05;
		}
	}
}

dogod()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	
	
	iPrintln("^0*^7",self.name, " ^7GodMode ^7[^0ON^7]");
	if(self getStat(1123))
	{
		self setStat(1123,0);
		self.maxhealth = 90000;
		self.health = self.maxhealth;
		while ( 1 )
		{
			wait .4;
			if ( self.health < self.maxhealth )
			self.health = self.maxhealth;
		}
	}
	else
	{
		iPrintln("^0*^7",self.name, " ^7GodMode ^7[^0OFF^7]");
		self setStat(1123,1);
		self.maxhealth = 100;
	}
}

toggleDM()
{
	self endon("disconnect");
	self endon("death");
	
	iPrintln("^0*^7",self.name, " Deathmachine ^7[^8ON^7]");
	if(self.DM == false)
	{
		self.DM = true;
		self thread DeathMachine();
	}
	else
	{
		self.DM = false;
		self notify("end_dm");
	}
}

DeathMachine()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "end_dm" );
	
    self thread watchGun();
    self thread endDM();
    self allowADS(false);
    self allowSprint(false);
    self setPerk("specialty_bulletaccuracy");
    self setPerk("specialty_rof");
    self setClientDvar("perk_weapSpreadMultiplier", 0.20);
    self setClientDvar("perk_weapRateMultiplier", 0.20);
    self giveWeapon( "saw_grip_mp" );
    self switchToWeapon( "saw_grip_mp" );
	iPrintLn("^0*^7" + self.name +" ^7DeathMachine ^7[^8ON^7]");
	iPrintlnBold("" + self.name +" ^7DeathMachine ^8ENABLED");
    for(;;)
    {
        weap = self GetCurrentWeapon();
        self setWeaponAmmoClip(weap, 150);
        wait 0.2;
    }
}

watchGun()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "end_dm" );
    for(;;)
    {
        if( self GetCurrentWeapon() != "saw_grip_mp")
        {
            self switchToWeapon( "saw_grip_mp" );
        }
        wait 0.01;
    }
}

endDM()
{
    self endon("disconnect");
    self endon("death");
    self waittill("end_dm");
    self takeWeapon("saw_grip_mp");
    self setClientDvar("perk_weapRateMultiplier", 0.7);
    self setClientDvar("perk_weapSpreadMultiplier", 0.6);
	self switchToWeapon( "deserteagle_mp" );
    self allowADS(true);
    self allowSprint(true);
}

freezeAll()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	
	
	if(self.allfrozen == false)
	{
		self.allfrozen = true;
		for(i = 0;i < level.players.size;i++) 
		{
			player = level.players[i];
			if(player.verified == 0)
			{
				player freezeControls(true);
			}
		}
		iPrintln("^0*^7Freeze by ",self.name, " ^7[^8ON^7]");
	}
	else
	{
		self.allfrozen = false;
		for(i = 0;i < level.players.size;i++) 
		{
			player = level.players[i];
			if(player.verified == 0)
			{
				player freezeControls(false);
			}
		}
		iPrintln("^0*^7Freeze by ",self.name, " ^7[^8OFF^7]");
	}
}

NovaNade()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	
	
	iPrintln("^0*^7",self.name, " ^7Gas Nade ^7[^8ON^7]");
    self giveweapon("smoke_grenade_mp");
    self SetWeaponAmmoStock("smoke_grenade_mp", 1);
    wait 0.1;
    self SwitchToWeapon("smoke_grenade_mp");
    self iPrintln("^7Press ^7[^0{+attack}^7] to throw Nova Gas");
    self waittill("grenade_fire", grenade, weaponName);
    if(weaponName == "smoke_grenade_mp")
    {
        nova = spawn("script_model", grenade.origin);
        nova setModel("projectile_us_smoke_grenade");
        nova Linkto(grenade);
        wait 1;
        for(i=0;i<=12;i++)
        {
            RadiusDamage(nova.origin,300,100,50,self);
            wait 1;
        }
        nova delete();
    }
}

rocketnuke()
{
	iPrintln("^0*^7",self.name, " ^7Rocket Nuke ^7[^8ON^7]");
	self iPrintln("^0RPG ^7Nuke Set");
	self GiveWeapon( "rpg_mp" );
	self switchToWeapon( "rpg_mp" );
	self waittill ("weapon_fired");
	wait 1;
	visionSetNaked( "cargoship_blast", 4 );
	setdvar("timescale",0.3);
	self playSound( "artillery_impact" );
	Earthquake( 0.4, 4, self.origin, 100 );
	wait 0.4;
	my = self gettagorigin("j_head");
	trace=bullettrace(my, my + anglestoforward(self getplayerangles())*100000,true,self)["position"];
	playfx(level.expbullt,trace);
	self playSound( "artillery_impact" );
	Earthquake( 0.4, 4, self.origin, 100 );
	self playsound("mp_last_stand");
	self thread maps\mp\gametypes\_hud_message::oldNotifyMessage( "^7Theres 0nly 0ne......" );
	wait 5;
	Earthquake( 0.4, 4, trace, 100 );
	setdvar("timescale",0.8);
	wait 2;
	wait 0.4;
	Earthquake( 0.4, 4, trace, 100 );
	RadiusDamage( trace, 1000, 1000, 1000, self );
	wait 2;
	self setClientDvar("r_colorMap", "1");
	self setClientDvar("r_lightTweakSunLight", "0.1");	
	self setClientDvar("r_lightTweakSunColor", "0.1 0.1");
	wait 0.01;
	setdvar("timescale", "1");
	wait 3;
	visionSetNaked( getDvar( "mapname" ), 1 );
}
