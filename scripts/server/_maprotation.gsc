/**
* vim: set ft=cpp:
* file: scripts\server\_maprotation.gsc
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

/***
*
*	TODO: Add file description
*
*/

init()
{
	scripts\server\_maps::getMaprotation();
	level.onChangeMap = ::map_rotate;
}

map_rotate()
{
	nextmap = scripts\server\_maps::getNextMap();
	if (isdefined(nextmap))
	scripts\server\_maps::changeMap(nextmap);
	else
	{
		map_restart(false);
	}
}