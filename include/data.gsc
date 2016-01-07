/**
* vim: set ft=cpp:
* file: scripts\include\data.gsc
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

/**
* Converts the string to float.
*
*	@string: string to be converted
*/
atof( string )
{
	// set a helper dvar
	setDvar( "2float", string );
	
	// return the float value retrieved from the dvar
	return getDvarFloat( "2float" );
}

/**
* Converts the string to integer.
*	NOTE: This is obsolete as int( string ) does the exeac same thing without a dvar
*
*	@string: string to be converted
*/
atoi( string )
{
	// forward to int( ... )
	return int( string );
}

/**
* Removes the item from the array.
*
*	@array: Array of items
*	@item: Item to be removed from the array
*/
removeFromArray( array, item )
{
	// loop through the array and try to find the item
	for( i = 0; i < array.size; i++ )
	{
		if( array[i] == item )		// if the item is found
		{							// move all following items up by one
			for( ; i < array.size - 1; i++ )
			{
				// move the next item into the spot of the current item
				array[i] = array[i + 1];
			}
			
			break;
		}
	}

	return array;
}

/**
* Returns true if the item is found in the array, false otherwise.
*
*	@array: Array of items
*	@item: Item to be searched
*/
arrayContains( array, item )
{
	// loop through the array and try to find the item
	for( i = 0; i < array.size; i++ )
	{
		if( array[i] == item )		// if the item is found
		{							// return true
			return true;
		}
	}

	// if the item wasn't found
	return false;
}

/**
* Seperates the string by spaces.
*	NOTE: This function is obsolete as strTok( string, " " ) will do exectly the same
*	ToDo: Remove this function and replace it in the code
*
*	@string: String to be seperated
*/
dissect( string )
{
	// forward to the strTok function
	return strTok( string, " " );
}
