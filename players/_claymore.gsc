///////////////////////////////////////////////////////////
//														 //
//					Claymore Script 					 //
//														 //
///////////////////////////////////////////////////////////

/*
|----------------------------------------------------------------------------|
##############################################################################
##|       |##\  \####/  /##|        |##|        |##|        |##|   \####|  |##
##|   _   |###\  \##/  /###|  ______|##|   __   |##|   __   |##|    \###|  |##
##|  |_|  |####\  \/  /####|  |########|  |  |  |##|  |  |  |##|  \  \##|  |##
##|       |#####\    /#####|  |########|  |  |  |##|  |  |  |##|  |\  \#|  |##
##|       |######|  |######|  |########|  |  |  |##|  |  |  |##|  |#\  \|  |##
##|  |\  \#######|  |######|  |########|  |__|  |##|  |__|  |##|  |##\  |  |##
##|  |#\  \######|  |######|        |##|        |##|        |##|  |###\    |##
##|__|##\__\#####|__|######|________|##|________|##|________|##|__|####\___|##
##############################################################################
|----------------------------------------------------------------------------|

	-Made by Rycoon ( Xfire: phaedrean )
	
	This scripts makes claymores working on RotU.
|----------------------------------------------------------------------------|
*/

init()
{	
	if(!isDefined(level.claymoreFXid))
		precache();
	
	thread WatchForClaymore();
}

precache(){
	level.claymoreFXid = loadfx( "misc/claymore_laser" );
}

WatchForClaymore()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon("not_zombie_anymore");
	
	while(1)
	{
		self waittill( "grenade_fire", proj, weap );
		if( weap == "claymore_mp" )
		{
			proj.owner = self;
			proj thread WatchClaymore();
		}
	}
}

WatchClaymore()
{
	self endon( "death" );
	
	wait 0.3;
	self.fx = spawnFx( level.claymoreFxId, self getTagOrigin( "tag_fx" ), anglesToForward( self GetTagAngles( "tag_fx" ) ), anglesToUp( self getTagAngles( "tag_fx" ) ) );
	triggerFx( self.fx );
	self.trigger = spawn( "trigger_radius", self.origin-(0,0,192), 0, 192, 320 );
	self thread RemoveOn( "disconnect", self.owner );
	
	while(1)
	{
		self.trigger waittill( "trigger", player );
		if( !isDefined( self.owner ) )
			return;
		
		if( player.pers["team"] == self.owner.pers["team"] )
			continue;
		
		self PlaySound( "claymore_activated" );
		wait 0.3;
		self.fx delete();
		self detonate();
		self notify( "death" );
	}
}

RemoveOn( till, owner )
{
	self endon("death");
	if( isDefined( owner ) )
		owner waittill( till );
		
	self delete();
	self.fx delete();
	self notify( "death" );
}