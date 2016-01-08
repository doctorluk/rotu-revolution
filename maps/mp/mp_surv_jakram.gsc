#include maps\mp\_zombiescript;

main()
{
	maps\mp\_load::main();
	setExpFog(292, 2000, 0.537, 0.549, 0.564, 0.0);
	maps\mp\_compass::setupMiniMap("compass_map_mp_surv_jakram");

	maps\mp\win4::main();
	maps\mp\mp_surv_jakram_sound_fx::main();
	maps\mp\mp_surv_jakram_fx::main();
	maps\createfx\mp_surv_jakram_fx::main();
	maps\mp\killt::main();
	maps\mp\teleport1::main();
	maps\mp\teleport2::main();
	maps\mp\bobbing::main();
	maps\mp\_platform::main();

	thread WatchDoor1();
	thread WatchDoor2();
	thread WatchDoor3();
	thread WatchDoor4();
	thread zartax1();
	thread zartax2();
	thread zartax3();
	thread zartax4();
	thread zartax5();
	thread zartax6();
	thread zartax7();
	thread zartax8();
	thread zartax9();
	thread zartax10();
	thread fx_precache();
	thread sound1();
	thread voice();
	thread piece();
	thread rado1();
	thread rado2();
	thread rado3();
	thread rado4();
	thread rado5();
	thread rados();
	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	game["attackers"] = "axis";
	game["defenders"] = "allies";

	setdvar("r_specularcolorscale", "0.5");
	setdvar("r_glowbloomintensity0",".25");
	setdvar("r_glowbloomintensity1",".25");
	setdvar("r_glowskybleedintensity0",".3");
	setdvar("compassmaxrange","1800");

	waittillStart();
	buildAmmoStock("ammostock");
	buildWeaponUpgrade("weaponupgrade");
	buildSurvSpawn("spawngroup1", 1);
	buildSurvSpawn("spawngroup2", 1);
	buildSurvSpawn("spawngroup3", 1);
	buildSurvSpawn("spawngroup4", 1);
	buildSurvSpawn("spawngroup5", 1);
	buildSurvSpawn("spawngroup6", 1);
	startSurvWaves();

	level.barricadefx = LoadFX("dust/dust_trail_IR");
	buildBarricade( "staticbarricade", 6, 300, level.barricadefx, level.barricadefx );
}

WatchDoor1()
{
    door = getEnt( "purchase_door1", "targetname" );
    trigger = getEnt( "purchase_door1_trigger", "targetname" );
    needpoints = 3000;        //EDIT ME
    
    while(1)
    {
        trigger waittill( "trigger", player );
        if( player.points < needpoints )
        {
            player iPrintlnBold( "You do not have enough points to open the door!" );
            continue;
        }
        player.points -= needpoints;
		player scripts\players\_players::incUpgradePoints(-1 * needpoints);
        door Movez( -180, 3 );        //here you have to try which values are best; there also is MoveY and MoveZ
trigger playsound("door");
 fx = loadFX("props/powerTower_leg");
 PlayFX (fx ,(trigger.origin));

        trigger delete();
        break;

    }
}
WatchDoor2()
{
    door = getEnt( "purchase_door2", "targetname" );
    trigger = getEnt( "purchase_door2_trigger", "targetname" );
    needpoints = 5000;        //EDIT ME
    
    while(1)
    {
        trigger waittill( "trigger", player );
        if( player.points < needpoints )
        {
            player iPrintlnBold( "You do not have enough points to open the door!" );
            continue;
        }
        player.points -= needpoints;
		player scripts\players\_players::incUpgradePoints(-1 * needpoints);
        door Movez( -180, 3 );
trigger playsound("door2");
 fx = loadFX("props/powerTower_leg");
 PlayFX (fx ,(trigger.origin));
        trigger delete();
        break;

    }
}
WatchDoor3()
{
    door = getEnt( "purchase_door3", "targetname" );
    trigger = getEnt( "purchase_door3_trigger", "targetname" );
    needpoints = 8000;        //EDIT ME
    
    while(1)
    {
        trigger waittill( "trigger", player );
        if( player.points < needpoints )
        {
            player iPrintlnBold( "You do not have enough points to open the door!" );
            continue;
        }
        player.points -= needpoints;
		player scripts\players\_players::incUpgradePoints(-1 * needpoints);
        door Movez( -180, 3 );
        trigger playsound("door");
 fx = loadFX("props/powerTower_leg");
 PlayFX (fx ,(trigger.origin));
        trigger delete();
        break;

    }
}
WatchDoor4()

{
    door = getEnt( "purchase_door4", "targetname" );
    trigger = getEnt( "purchase_door4_trigger", "targetname" );
    needpoints = 10000;        //EDIT ME
    
    while(1)
    {
        trigger waittill( "trigger", player );
        if( player.points < needpoints )
        {
            player iPrintlnBold( "You do not have enough points to open the door!" );
            continue;
        }
        player.points -= needpoints;
		player scripts\players\_players::incUpgradePoints(-1 * needpoints);
        door Movex( 180, 3 );        
        trigger playsound("door2");
 fx = loadFX("props/powerTower_leg");
 PlayFX (fx ,(trigger.origin));
        trigger delete();
        break;

    }
}
zartax1()
{
fx = loadfx("explosions/nuke_base_child");


{
trigger = getent("fumis2","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-20122, -980, 173),(0, 34, -320));
     
}
 } 

zartax2()
{
fx = loadfx("explosions/nuke_bg");


{
trigger = getent("fumis2","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-20122, -980, 5000),(0, 34, -320));
     
}
 } 

zartax3()
{
fx = loadfx("explosions/nuke_cap_child");


{
trigger = getent("fumis2","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-20122, -980, 173),(0, 34, -320));
     
}
 } 

zartax4()
{
fx = loadfx("explosions/nuke_cap_up_child");


{
trigger = getent("fumis2","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-20122, -980, 173),(0, 34, -320));
     
}
 } 

zartax5()
{
fx = loadfx("explosions/nuke_column_child");


{
trigger = getent("fumis2","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-20122, -980, 173),(0, 34, -320));
     
}
 } 

zartax6()
{
fx = loadfx("explosions/nuke_dirt_shockwave");


{
trigger = getent("fumis2","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-20122, -980, 173),(0, 34, -320));
     
}
 } 

zartax7()
{
fx = loadfx("explosions/nuke_dirt_shockwave_child");


{
trigger = getent("fumis2","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-20122, -980, 173),(0, 34, -320));
     
}
 } 

zartax8()
{
fx = loadfx("explosions/nuke_explosion");


{
trigger = getent("fumis2","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-20122, -980, 5000),(0, 34, -320));
     
}
 } 

zartax9()
{
fx = loadfx("explosions/nuke_flash");


{
trigger = getent("fumis2","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-20122, -980, 173),(0, 34, -320));
     
}
 } 

zartax10()
{
fx = loadfx("explosions/nuke_smoke_fill");


{
trigger = getent("fumis2","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-20122, -980, 173),(0, 34, -320));
trigger delete();
        
     
}
 }

fx_precache()

{

fx = loadfx("props/powerTower_leg");
fx = loadfx("dust/dust_trail_IR");

}
 
sound1()
{
mysound = getentarray("soundtrigger","targetname");



for(i=0;i<mysound.size;i++)
mysound[i] thread playmysound(i);
}

playmysound(i)

{

while (1)

{


self waittill("trigger");
self playsound("nuke"); //replace yoursound with your soundalias name
self delete();
}
}

voice()
{
voice = getentarray("ammostock","targetname");



for(i=0;i<voice.size;i++)
voice[i] thread playvoice(i);
}

playvoice(i)

{

while (1)

{


self waittill("trigger");
self playsound("voice"); //replace yoursound with your soundalias name
wait 5;
}
}

piece()
{
piece = getentarray("weaponupgrade","targetname");



for(i=0;i<piece.size;i++)
piece[i] thread playpiece(i);
}

playpiece(i)

{

while (1)

{


self waittill("trigger");
self playsound("piece"); //replace yoursound with your soundalias name
wait 2;
}
}

rado1()
{
fx = loadfx("custom/rado");
while ( 1 )

{
trigger = getent("rado1","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-12602, 4432, -196));
wait 5;
     
}
 } 

rado2()
{
fx = loadfx("custom/rado");
while ( 1 )

{
trigger = getent("rado2","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-13082, 4432, -196));
wait 5;
     
}
 } 

rado3()
{
fx = loadfx("custom/rado");
while ( 1 )

{
trigger = getent("rado3","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-13530, 4432, -196));
wait 5;
     
}
 } 

rado4()
{
fx = loadfx("custom/rado");
while ( 1 )

{
trigger = getent("rado4","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-13978, 4432, -196));
wait 5;
     
}
 } 

rado5()
{
fx = loadfx("custom/rado");
while ( 1 )

{
trigger = getent("rado5","targetname");
trigger waittill("trigger");
PlayFX (fx ,(-14330, 4432, -196));
wait 5;
     
}
 }

rados()
{
rados = getentarray("rados","targetname");



for(i=0;i<rados.size;i++)
rados[i] thread playrados(i);
}

playrados(i)

{

while (1)

{


self waittill("trigger");
self playsound("rados"); //replace yoursound with your soundalias name
wait 10;
}
}
 
