/**
* vim: set ft=cpp:
* file: maps\mp\gametypes\war.gsc
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

main()
{
	setDvar( "g_gametype", "surv" );
	maps\mp\gametypes\surv::main();
}
