/**
* vim: set ft=cpp:
* file: maps\mp\mp_killhouse_tradespawns.gsc
*
* authors: Luk, 3aGl3, Bipo, Etheross
* team: SOG Modding
*
* project: RotU - Revolution
* website: http://survival-and-obliteration.com/
*
* Reign of the Undead - Revolution ALPHA 0.7 by Luk and 3aGl3
* You may modify this code to your liking or reuse it, as long as you give credit to those who wrote it
* Based on Reign of the Undead 2.1 created by Bipo and Etheross
*/

load_tradespawns()
{
    level.tradespawns = [];

    level.tradespawns[0] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[0].origin = (84.4592,506.067,28.125);
    level.tradespawns[0].angles = (0,180.302,0);
    level.tradespawns[1] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[1].origin = (1314.77,1127.34,28.125);
    level.tradespawns[1].angles = (0,269.984,0);
    level.tradespawns[2] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[2].origin = (740.507,1816.83,74.7715);
    level.tradespawns[2].angles = (360,0.714118,0);
    level.tradespawns[3] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[3].origin = (132.774,1781.34,28.125);
    level.tradespawns[3].angles = (0,91.8457,0);

    level.tradeSpawnCount = level.tradespawns.size;
}
