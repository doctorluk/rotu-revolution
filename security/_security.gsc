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

#include scripts\include\strings;

init()
{
	if( level.dvar["game_lan_mode"] )
		return;
	
/*	level.cheatDvars = [];						// This is a list of client side dvars we should check
	level.cheatDvars[0] = spawnStruct();
	level.cheatDvars[0].name = "cg_fovscale";
	level.cheatDvars[0].value = "1";			// the script will check if the value matches
	level.cheatDvars[1] = spawnStruct();
	level.cheatDvars[1].name = "cg_fov";
	level.cheatDvars[1].value = "65-80";		// the script will check if it's in range
	level.cheatDvars[2] = spawnStruct();
	level.cheatDvars[2].name = "r_fullbright";
	level.cheatDvars[2].value = "0";
	level.cheatDvars[x] = spawnStruct();
	level.cheatDvars[x].name = "example";
	level.cheatDvars[x].value = "0;1;2";		// the script will check if any of these match	*/

	thread onPlayerConnect();
}

onPlayerConnect()
{
	while(1)
	{
		level waittill( "connected", player );
		player thread check();
	}
}

check()
{
	self thread checkValidGuid();		// check the GUID for integrity
	self thread watchName();			// do a very basic name check
//	self thread watchCheatDvars();		// watch certain cheat protected dvars, they might be unlocked by a 3rd party program...and we can not check client dvars
}

checkValidGuid()
{
	self endon( "disconnect" );

	lpGuid = self getGuid();
	while(1)
	{
		guid = self getGuid();
		if( guid != lpGuid || guid.size != 32 )
		{
			// the guid is not supposed to change, and has to be always 32 chars long
			self sayAll( "I'm a hacking idiot, for which I now get kicked!" );
			kick( self getEntityNumber() );
		}
		else
		{
			// if it seems valid we check if it's hexadecimal
			for( i = 0; i < 32; i++ )
			{
				char = GetSubStr( guid, i, i+1 );
				if( !isHexadecimal(char) || char != toLower(char) )
				{
					self sayAll( "I'm a hacking idiot, for which I now get kicked!" );
					kick( self getEntityNumber() );
				}
			}
		}
		
		// TODO: Is it really needed to have this running all the time, if the guid is valid?
		
		wait 4 + randomfloat(2);
	}
}

watchName()
{
	self endon( "disconnect" );

	violations = 0;
	while( 1 )
	{
		name = toLower( getSubStr(self.name, 0, 3) );
		if( name == "bot" )		// should we maybe make this a list off names instead?
		{
			self iPrintLnBold( "^1Warning: bot is not allowed as name/prefix!" );
			violations++;
		}
		else if( violations > 0 && false /*level.dvar["admin_decay_namedbot"] TODO: ADD CONFIG VAR*/)
			violations--;
		
		if( violations >= 10 )
			kick( self getEntityNumber() );
		
		wait 2;
	}
}

/*
watchCheatDvars()
{
	self endon( "disconnect" );

	violations = 0;
	while( 1 )
	{
		for( i = 0; i < level.cheatDvars.size; i++ )
		{
			dvarname = level.cheatDvars[i].name;
			dvarvalue = level.cheatDvars[i].value;
					
			value = self getClientDvar( dvarname );
			
			if( isSubStr(dvarvalue, "-") )
			{
				from_to = strTok( dvarvalue, "-" );
				if( int(value) < int(from_to[0]) || int(value) > int(from_to[1]) )
				{
					self iPrintLnBold( "^1", dvarname, " is not allowed outside the range off ", dvarvalue, "!" );
					violations++;	
				}
			}
			else if( isSubStr(dvarvalue, ";") )
			{
				if( !isSubStr( dvarvalue, value ) )
				{
					self iPrintLnBold( "^1", dvarname, " is not allowed to be anything but ", dvarvalue, "!" );
					violations++;
				}
			}
			else
			{
				if( value != dvarvalue )
				{
					self iPrintLnBold( "^1", dvarname, " is not allowed to be any other value then ", dvarvalue, "!" );
					violations++;
				}
			}
		}
		
		if( violations >= 10 )
			kick( self getEntityNumber() );
		
		wait 2;
	}	
}
*/