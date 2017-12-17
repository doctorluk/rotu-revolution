
// vim: set ft=cpp:

load_tradespawns()
{
    level.tradespawns = [];
    
    level.tradespawns[0] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[0].origin = (-611.011,-1737.22,-17.3553);
    level.tradespawns[0].angles = (2.09611,181.291,0);
    level.tradespawns[1] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[1].origin = (-495.356,-990.015,-17.9124);
    level.tradespawns[1].angles = (0.248368,268.918,0);
    level.tradespawns[2] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[2].origin = (-3253.73,-1621.93,130.984);
    level.tradespawns[2].angles = (0.760676,88.0224,0);
    level.tradespawns[3] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[3].origin = (-2464.49,-891.274,-10.0536);
    level.tradespawns[3].angles = (0.392535,7.49813,0);
    level.tradespawns[4] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[4].origin = (-2285.43,-3038.21,239.128);
    level.tradespawns[4].angles = (354.85,157.698,0);
    level.tradespawns[5] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[5].origin = (-2203.95,-3103.19,235.829);
    level.tradespawns[5].angles = (354.317,158.571,0);
    level.tradespawns[6] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[6].origin = (277.138,-742.308,-14.875);
    level.tradespawns[6].angles = (0,89.5221,0);
    level.tradespawns[7] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[7].origin = (445.164,-2921.54,-15.875);
    level.tradespawns[7].angles = (0,184.334,0);
    level.tradespawns[8] = spawnstruct();  // spec'd for weapon shop
    level.tradespawns[8].origin = (-715.856,140.11,-20.0156);
    level.tradespawns[8].angles = (359.758,273.505,0);
    level.tradespawns[9] = spawnstruct();  // spec'd for equipment shop
    level.tradespawns[9].origin = (-381.771,-99.1137,-8.67509);
    level.tradespawns[9].angles = (359.836,265.54,0);
    
    level.tradeSpawnCount = level.tradespawns.size;
}