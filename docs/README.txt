//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//

//                                      //
//          General Information         //
//                                      //

Project Lead: Luk
Developers: Luk, 3aGl3
Website: http://puffyforum.com
Version: 0.7
Development state: ALPHA
Last Update: 01.11.14 (dd.mm.yyyy, down with 'murica's mm/dd/yyyy!)
Changelog: http://puffyforum.com/index.php?page=Thread&threadID=35
Contact:
    Xfire: lukluk1992 | Web: http://puffyforum.com

Based on the source of Reign of the Undead 2.1 by Bipo and Etheross.

//                                      //
//      Description and Features        //
//                                      //

Reign of the Undead is based on the Zombie mode from Call of Duty World at War and newer derivates of it, including several own interpretations and ideas. It made use of several custom models, weapons and classes.
Reign of the Undead-REVOLUTION took the original idea and fixed bugs, exchanged all custom zombie models with rips from WaW and newer Call of Duty versions that actually look like zombies, implemented or re-interpreted class abilites, further balanced out the weapons and difficulty, providing more configuration options than ever for hosts and a better experience overall.

It contains 19 zombie models, 5 classes, new sound effects, new visual effects, request and automated shouts from Battlefield 3, new guns, new turrets with new mechanics, new wave types, a new attack move for the boss with multiple twists, all new soundtrack, improved menus with more details and descriptions and more!

//                                  //
//          RCON commands           //
//                                  //

// displays the provided text as iPrintLnBold (big message) to all players
rcon saybold <text>

// Kills a player
rcon kill <playerID>

// Freezes the controls of a player
rcon freezeplayer <playerID>

// Unfreezes the controls of a player
rcon unfreezeplayer <playerID>

// Does a failsafe mapchange, only works when a player is on the server [ONLY NEEDED WHEN USING THE DEFAULT CoD4 SERVER FILES, USE map <mapname> WHEN USING 1.7a]
rcon change_map mapname

// Restarts the current map
rcon restart_map

// Resets a player to one of the spawn positions, can be useful when he's stuck
rcon resetplayer <playerID>

// Moves a player to spectator
rcon setspectator <playerID>

// Returns your current position and view angle. Can be used to add an endmap-view coordinate to a map
rcon getendview <playerID>

// Revives a player
rcon revive <playerID>

// Kills the given amount of zombies. If you set 0 all zombies will be killed
rcon kill_zombies <amount>

// Renames a player to the given name
rcon rename <playerID>&<name>

// Sets the rank (1-55) of a player
rcon setrank <playerID>&<rank>[&<force>]

Examples:
rcon setrank 12&10 (this would set the rank for player #12 to 10, but only when he is lower than 10!)
rcon setrank 12&12&1 (this would ALWAYS set the rank for player #12 to 12 and reset his skillpoints to achieve the change)

// Sets the prestige (0-45) of a player
rcon setprestige <playerID>&<prestige>[&<force>]

Examples:
rcon setprestige 12&10 (this would set the prestige for player #12 to 10, but only when he is lower than 10!)
rcon setprestige 12&12&1 (this would ALWAYS set the prestige for player #12 to 12 and reset his skillpoints to achieve the change)

// Prints READCONFIG; to games_mp.log, can be used with a manu admin mod plugin to issue a readconfig via rcon
rcon readconfig 1

//                                      //
//          Bugs and Problems           //
//                                      //

This mod is nowhere near finished, but it has been tested for quite a long time with 26 bots and 22 players and should be fairly stable.

However, if you encounter a bug or a problem, please provide ALL INFORMATION you can (when it happened, on which map it happened, on which version, what you did at this moment, what happened, what you expected to happen, what others did at this moment [if it's relevant]) and post it here: http://puffyforum.com/index.php?page=Thread&threadID=243
In case the website is offline, the mod is most likely dead, or you ask google if it is, maybe it moved somewhere else. But who knows the future... :P

//                                              //
//      Possible STOP of development            //
//                                              //

It may be likely that, once this mod is released, the development of it comes to a hold.
It does not look as if I have time left in the near future to add more stuff or fix existing things.
I really hope that most of the mod runs well and stable.

//                                      //
//      Decompilation of sources        //
//                                      //

I personally do not hate the decompilation of sources. I myself have decompiled many mods and maps in order to begin scripting for Call of Duty 4 myself. 
Without official documentation and only limited basic tutorials it is extremely hard to try out stuff. The easiest way is by decompiling a mod, understanding its structure and adding new features that often fail at first, but will motivate once they actually work!
The only thing I want you to do when you use any of the sources of this mod, no matter who made them, credit them accordingly!

--------------------------------

Original readme that came with the sources:
rotu21 source by Bipo (xfire: bipoalarmonk) and Etheross (xfire: etheross)

installation instructions:
 - download the cod4 mod tools + patch
 - place the zone_source folder in your cod4 directory (it can be removed from the rotu21source folder)
 - place the rotu21source folder in your mods directory
 - execute the compileMod.bat
 - wait for it to complete
 - mod has been compiled

disclaimer:
 Source code is free to be modified / ported to other game as long as credits are kept. All assets belong to Activision as can be read in their modtools eula.