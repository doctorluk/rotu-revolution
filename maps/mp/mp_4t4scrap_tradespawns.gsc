/**
* vim: set ft=cpp:
* file: maps\mp\mp_4t4scrap_tradespawns.gsc
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

load_tradespawns()
{
    level.tradespawns = [];

    level.tradespawns[0] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[0].origin = (1057.82,413.481,5.625);
    level.tradespawns[0].angles = (0,91.5819,0);
    level.tradespawns[1] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[1].origin = (2060.18,172.285,4.125);
    level.tradespawns[1].angles = (0,94.1582,0);
    level.tradespawns[2] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[2].origin = (496.321,2456.74,85.125);
    level.tradespawns[2].angles = (0,269.654,0);
    level.tradespawns[3] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[3].origin = (445.501,1805.09,85.125);
    level.tradespawns[3].angles = (0,273.483,0);
    level.tradespawns[4] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[4].origin = (1881.38,3878.02,52.125);
    level.tradespawns[4].angles = (0,1.29647,0);
    level.tradespawns[5] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[5].origin = (1404.16,3611.84,52.125);
    level.tradespawns[5].angles = (0,273.417,0);
    level.tradespawns[6] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[6].origin = (2799.23,2017.8,4.125);
    level.tradespawns[6].angles = (0,358.989,0);
    level.tradespawns[7] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[7].origin = (2540.35,2642.47,4.125);
    level.tradespawns[7].angles = (0,184.581,0);
    level.tradespawns[8] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[8].origin = (694.085,1333.85,4.17975);
    level.tradespawns[8].angles = (359.686,91.0272,0);
    level.tradespawns[9] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[9].origin = (2751.34,847.098,11.125);
    level.tradespawns[9].angles = (0,181.643,0);

    level.tradeSpawnCount = level.tradespawns.size;
}
