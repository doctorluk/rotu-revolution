//IZaRTaX
#include maps\mp\_zombiescript;
main()
{
	maps\mp\_load::main();
	maps\mp\gametypes\_gameobjects::main([]);
	
	targets = [];
	targets[targets.size] = "mp_sd_spawn_defender";
	targets[targets.size] = "mp_sab_spawn_axis_start";
	targets[targets.size] = "mp_sab_spawn_axis";
	targets[targets.size] = "mp_dom_spawn_axis_start";
	targets[targets.size] = "mp_sab_spawn_axis";
	targets[targets.size] = "mp_ctf_spawn_axis_start";
	targets[targets.size] = "mp_dom_spawn";
	targets[targets.size] = "misc_turret";
	for( i = 0; i < targets.size; i++ ){
		ent = getEntArray(targets[i], "classname");
		for( ii = 0; ii < ent.size; ii++ ){
			ent[ii] delete();
		}
	}
	
	level.timelimit = 2147483648; // Fix script errors with RotU-R, this is 2^31
	
	setExpFog(2000, 1000, 0.9176, 0.8235, 0.6352, 10);
	 
	 ambientPlay("amb_oukhta");
	 
	 level.airstrikeheightscale = 1.0;
	 
     maps\mp\mp_oukhta_fx::main();
	 maps\createfx\mp_oukhta_fx::main();
     maps\mp\mp_oukhta_sound_fx::main();
	 maps\mp\winz::main();
	 maps\mp\_compass::setupMiniMap("compass_map_mp_oukhta");
	 
	 
     game["allies"] = "marines";
     game["axis"] = "opfor";
     game["allies_soldiertype"] = "desert";
     game["axis_soldiertype"] = "desert";

     game["attackers"] = "axis";
     game["defenders"] = "allies";

	setdvar( "r_specularcolorscale", "1" );
	
	setdvar("r_glowbloomintensity0",".25");
	setdvar("r_glowbloomintensity1",".25");
	setdvar("r_glowskybleedintensity0",".3");
	setdvar("compassmaxrange","1800");
	
	precacheShellShock( "radiation_low" );
	
	
	 // thread amb_global();
	 // thread alarm();
	 thread bird();
	 thread bird2();
	 thread bird3();
	 thread bird4();
	 // thread missile_launch01();
	 // thread missile_launch02();
	 // thread missile_launch03();
	 // thread radiation();
     thread maps\mp\_dynamic_foliage::dyna();
	 // thread maps\mp\killt::main();
	 thread maps\mp\mp_oukhta_mip::main();
     
	thread maps\mp\mp_oukhta_waypoints::load_waypoints();
	thread maps\mp\mp_oukhta_tradespawns::load_tradespawns();
	
	waittillStart();
	
	buildSurvSpawnByClassname("mp_dm_spawn");
	startSurvWaves();
	
	}
	bird()
	
{

trigger = getEnt( "bird", "targetname" );
fx = loadFX("misc/bird_takeoff");

{

while (1)

{

trigger waittill( "trigger");
playFX( fx, trigger.origin );

trigger playsound("bird");

wait 60;

}
}
}

bird2()
	
{

trigger = getEnt( "bird2", "targetname" );
fx = loadFX("misc/bird_takeoff");

{

while (1)

{

trigger waittill( "trigger");
playFX( fx, trigger.origin );

trigger playsound("bird");

wait 60;

}
}
}

bird3()
	
{

trigger = getEnt( "bird3", "targetname" );
fx = loadFX("misc/bird_takeoff");

{

while (1)

{

trigger waittill( "trigger");
playFX( fx, trigger.origin );

trigger playsound("bird");

wait 60;

}
}
}

bird4()
	
{

trigger = getEnt( "bird4", "targetname" );
fx = loadFX("misc/bird_takeoff");

{

while (1)

{

trigger waittill( "trigger");
playFX( fx, trigger.origin );

trigger playsound("bird");

wait 60;

}
}
}

amb_global()
{

amb_global = getentarray("amb_global","targetname");



for(i=0;i<amb_global.size;i++)
amb_global[i] thread playamb_global(i);
}

playamb_global(i)

{

while (1)

{


self waittill("trigger");
wait 60;

self playsound("amb_global"); 



wait 60;

}
}

missile_launch01()

{
	air = getEnt("missile1","targetname");
	air2 = getEnt("missile2","targetname");
	trigger = getEnt("jump","targetname");
    fx = loadFX("smoke/smoke_geotrail_icbm");

	air1 = getEnt("air1","targetname");
	air2 = getEnt("air2","targetname");
	
	

		trigger waittill ("trigger");
		wait 300;
		trigger playsound("launch");
		wait 4;
		playfxontag( fx, air, "tag_nozzle" );
		air moveTo ( air1.origin, 5 );
		wait 5;
		air moveto ( air2.origin, 1 );
		wait 1;
		
		air delete();
		
		
}

missile_launch02()

{
	air = getEnt("missile2","targetname");
	md_1 = getent("md_1","targetname");
	md_2 = getent("md_2","targetname");
	md_3 = getent("md_3","targetname");
	md_4 = getent("md_4","targetname");
	md_5 = getent("md_5","targetname");
	md_6 = getent("md_6","targetname");
	md_7 = getent("md_7","targetname");
	md_8 = getent("md_8","targetname");
	br_9 = getent("br_9","targetname");
	fx_1 = getent("fx_1","targetname");
	trigger = getEnt("jump","targetname");
	
    fx = loadFX("explosions/helicopter_explosion_cobra");
    
	air1 = getEnt("air1","targetname");
	air2 = getEnt("air2","targetname");
	air3 = getEnt("air3","targetname");
	
	
	

	trigger waittill ("trigger");
	wait 304;
	
		
		VisionSetNaked ( "icbm_launch", 4 );	
	
		air moveTo ( air1.origin, 5 );
		wait 5;
		air RotatePitch( -120, 1, 0, 0 );
		wait 1;
		air moveTo( air3.origin, 3 );
		wait 3;
		
		
		
		playFX( fx, fx_1.origin );
		fx_1 playsound("explo");
		
		air delete();
		md_1 delete();
		md_2 delete();
		md_3 delete();
		md_4 delete();
		md_5 delete();
		md_6 delete();
		md_7 delete();
		md_8 delete();
		br_9 delete();
		
		
		wait 18;
		VisionSetNaked ( "mp_oukhta" );
		
		
}

missile_launch03()

{
	air = getEnt("missile3","targetname");
	trigger = getEnt("jump","targetname");
    fx = loadFX("smoke/smoke_geotrail_icbm");

	air4 = getEnt("air4","targetname");
	
	

		trigger waittill ("trigger");
		wait 312;
		playfxontag( fx, air, "tag_nozzle" );
		air moveTo ( air4.origin, 23 );
		wait 23;
		
		air delete();
		
		}
		
radiation()
{
rads = getentarray("radiation", "targetname");
for(i = 0; i < rads.size; i++)
rads[i] thread onEnter();

}

onEnter()
{


self waittill("trigger", player);
wait 300;
player shellshock("radiation_low", 2);


self delete();
}

alarm()
{

alarm = getentarray("alarm","targetname");



for(i=0;i<alarm.size;i++)
alarm[i] thread playalarm(i);
}

playalarm(i)

{

while (1)

{


self waittill("trigger");
wait 290;

self playsound("alarm"); 

self delete ();


}
}


