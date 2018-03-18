/**
* vim: set ft=cpp:
* file: scripts\include\persistence.gsc
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
*	TODO: Add file description
*
*/

// ==========================================
// Script persistent data functions
// These are made for convenience, so persistent data can be tracked by strings.
// They make use of code functions which are prototyped below.

/*
=============
statGet

Returns the value of the named stat
=============
*/
statGet(dataName)
{

	return self getStat(int(tableLookup("mp/playerStatsTable.csv", 1, dataName, 0)));
	
}

/*
=============
setStat

Sets the value of the named stat
=============
*/
statSet(dataName, value)
{
	
	self setStat(int(tableLookup("mp/playerStatsTable.csv", 1, dataName, 0)), value);	
}

/*
=============
statAdd

Adds the passed value to the value of the named stat
=============
*/
statAdd(dataName, value)
{	

	curValue = self getStat(int(tableLookup("mp/playerStatsTable.csv", 1, dataName, 0)));
	self setStat(int(tableLookup("mp/playerStatsTable.csv", 1, dataName, 0)), value + curValue);
	
}
