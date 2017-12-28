/**
* vim: set ft=cpp:
* file: scripts\include\codx_wrapper.gsc
*
* authors: Luk, 3aGl3
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
* 	codx_wrapper.gsc
*	The .gsc file acts as a dummy for CoD4X functions in case they're not available when running the server <1.8
*
*/

/**
* 	Dummy function for the GetRealTime() function in CoD4X which isn't available here
*/
_GetRealTime(){
	return -1;
}
