/**
* vim: set ft=cpp:
* file: maps\mp\mp_shipment_tradespawns.gsc
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
    level.tradespawns[0].origin = (587.509,-52.1966,191.952);
    level.tradespawns[0].angles = (0,0.368035,0);
    level.tradespawns[1] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[1].origin = (728.138,-456.357,193.214);
    level.tradespawns[1].angles = (0.504139,272.098,0);
    level.tradespawns[2] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[2].origin = (-633.307,234.596,198.295);
    level.tradespawns[2].angles = (356.535,180.055,0);
    level.tradespawns[3] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[3].origin = (-695.475,756.548,192.128);
    level.tradespawns[3].angles = (360,359.242,0);

    level.tradeSpawnCount = level.tradespawns.size;
}
