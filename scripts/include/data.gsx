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
* Reign of the Undead - Revolution by Luk and 3aGl3
* You may modify this code to your liking or reuse it, as long as you give credit to those who wrote it
* Based on Reign of the Undead 2.1 created by Bipo and Etheross
*/

/**
* Sets the given dvar if it's empty
*/
setDvarIfUninitialized( dvar, value )
{
	if( getDvar(dvar) == "" )
		setDvar(dvar, value );
}

/**
* Removes the item from the array.
*
*	@array: Array of items
*	@item: Item to be removed from the array
*/
removeFromArray(array, item)
{
	// loop through the array and try to find the item
	for(i = 0; i < array.size; i++)
	{
		if(array[i] == item)		// if the item is found
		{							// move all following items up by one
			for(; i < array.size - 1; i++)
			{
				// move the next item into the spot of the current item
				array[i] = array[i + 1];
			}
			array[array.size - 1] = undefined;
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
arrayContains(array, item)
{
	// loop through the array and try to find the item
	for(i = 0; i < array.size; i++)
	{
		if(array[i] == item)		// if the item is found
		{							// return true
			return true;
		}
	}

	// if the item wasn't found
	return false;
}

/**
* Casts a vector3 into a space seperated string
*/
vectorToString( v )
{
	str = "" + v[ 0 ] + " " + v[ 1 ] + " " + v[ 2 ];
	return str;
}	/* vectorToString */

/**
* Casts a space seperated string into a vector3
*/
stringToVector( str )
{
	tok = strTok( str, " " );
	v = (float(tok[0]), float(tok[1]), float(tok[2]));
	return v;
}	/* stringToVector */

/**
*	Seperates the string by spaces.
*	NOTE: This function is obsolete as strTok(string, " ") will do exectly the same
*	ToDo: Remove this function and replace it in the code
*
*	@string: String to be seperated
*/
dissect(string)
{
	printLn( "WARNING: Called deprecated function dissect, use strTok instead." );

	// forward to the strTok function
	return strTok(string, " ");
}

/**
*	Returns an array of the current hour and minutes
*
*	@seconds: Int, current time in seconds
*	@return: Array, 0: Int, Minutes of current hour
*					1: Int, Current daytime hour
*/
getDaytime(seconds){

	minutes = int(seconds / 60) % 60;
	hours = int(seconds / 3600) % 24;
	
	daytime = [];
	daytime[0] = minutes;
	daytime[1] = hours;
	
	return daytime;
}


/**
*	Returns an array of the current day and month
*
*	@seconds: Int, current time in seconds since 2012-01-01
*	@return: Array, 0: Int, Days into the month
*					1: Int, Months into the year
*/
getCurrentMonthAndDay(seconds){

	if(getCurrentYear(seconds) % 4 == 0)
		leapday = 1;
	else
		leapday = 0;
		
	dayandmonth = [];
	dayandmonth[0] = 0;
	dayandmonth[1] = 0;
		
	// Get remaining days in the current year
	minutes = int(seconds / 60);
	hours = int(minutes / 60);
	days = int(hours / 24);
	additionalDays = int(days / 365 / 4);
	days -= additionalDays;
	days = days % (365 + leapday);
	
	// January has 31 days
	if(days < 31){
		dayandmonth[0] = days;
		dayandmonth[1] = 1;
		return dayandmonth;
	}
	days -= 31;

	// February has 28 days (29 if leapday)
	if(days < (28 + leapday)){
		dayandmonth[0] = days;
		dayandmonth[1] = 2;
		return dayandmonth;
	}
	days -= 28 + leapday;
	
	// March has 31 days
	if(days < 31){
		dayandmonth[0] = days;
		dayandmonth[1] = 3;
		return dayandmonth;
	}
	days -= 31;
	
	// April has 30 days
	if(days < 30){
		dayandmonth[0] = days;
		dayandmonth[1] = 4;
		return dayandmonth;
	}
	days -= 30;
	
	// May has 31 days
	if(days < 31){
		dayandmonth[0] = days;
		dayandmonth[1] = 5;
		return dayandmonth;
	}
	days -= 31;
	
	// June has 30 days
	if(days < 30){
		dayandmonth[0] = days;
		dayandmonth[1] = 6;
		return dayandmonth;
	}
	days -= 30;
	
	// July has 31 days
	if(days < 31){
		dayandmonth[0] = days;
		dayandmonth[1] = 7;
		return dayandmonth;
	}
	days -= 31;
	
	// August has 31 days
	if(days < 31){
		dayandmonth[0] = days;
		dayandmonth[1] = 8;
		return dayandmonth;
	}
	days -= 31;
	
	// September has 30 days
	if(days < 30){
		dayandmonth[0] = days;
		dayandmonth[1] = 9;
		return dayandmonth;
	}
	days -= 30;
	
	// October has 31 days
	if(days < 31){
		dayandmonth[0] = days;
		dayandmonth[1] = 10;
		return dayandmonth;
	}
	days -= 31;
	
	// November has 30 days
	if(days < 30){
		dayandmonth[0] = days;
		dayandmonth[1] = 11;
		return dayandmonth;
	}
	days -= 30;
	
	// December has 31 days
	dayandmonth[0] = days;
	dayandmonth[1] = 12;
	return dayandmonth;
}

/**
*	Returns current year
*
*	@seconds: Int, current time in seconds since 2012-01-01
*	@return: Int, Current year
*/
getCurrentYear(seconds){

	minutes = int(seconds / 60);
	hours = int(minutes / 60);
	days = int(hours / 24);
	additionalDays = int(days / 365 / 4);
	days += additionalDays;
	return 2012 + int(days / 365);
}
