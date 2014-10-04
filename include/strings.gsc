//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.7 by Luk and 3aGl3
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

#include scripts\include\data;

toUpper(char){
	switch(char){
		case "a":
			return "A";
		case "b":
			return "B";
		case "c":
			return "C";
		case "d":
			return "D";
		case "e":
			return "E";
		case "f":
			return "F";
		case "g":
			return "G";
		case "h":
			return "H";
		case "i":
			return "I";
		case "j":
			return "J";
		case "k":
			return "K";
		case "l":
			return "L";
		case "m":
			return "M";
		case "n":
			return "N";
		case "o":
			return "O";
		case "p":
			return "P";
		case "q":
			return "Q";
		case "r":
			return "R";
		case "s":
			return "S";
		case "t":
			return "T";
		case "u":
			return "U";
		case "v":
			return "V";
		case "w":
			return "W";
		case "x":
			return "X";
		case "y":
			return "Y";
		case "z":
			return "Z";
		default:
			return char;	
	}
}

isHexadecimal(char){
	switch(char){
		case "0": return true;
		case "1": return true;
		case "2": return true;
		case "3": return true;
		case "4": return true;
		case "5": return true;
		case "6": return true;
		case "7": return true;
		case "8": return true;
		case "9": return true;
		case "a": return true;
		case "b": return true;
		case "c": return true;
		case "d": return true;
		case "e": return true;
		case "f": return true;
		default: return false;
	}
}

/* Makes all letters capital in a sentence */
allToUpper(string){
	if( !isDefined(string) || string == "" )
		return;
	returns = "";
	for(i = 0; i < getStrLength(string); i++)
		returns += toUpper(getSubStr(string, i, i+1));
	return returns;
}

/* Returns an int of the length of a string */
getStrLength(string){
	if(!isDefined(string) || string == "")
		return 0;
	i = 0;
	while(GetSubStr( string, i, i+1) != "")
		i++;
	return i;

}

/* Gets a string and returns it as a vector in the format of (x,y,z) 
Strings come either as (x,y,z) or (xx,yy,zz) etc., we have to take care of this....*/
strToVec(string){

	vector = (0,0,0);
	stringArr = strTok(string, ","); // Split string by ","-characters, results in (x(xx)? | y(yy)? | z(zz?))
	x = atof(GetSubStr(stringArr[0], 1, getStrLength(stringArr[0])) ); // we have (x or (xx or (xxx now, so we need to cut from 0 (this is "(" ) until the end...
	y = atof(stringArr[1]);
	z = atof(GetSubStr(stringArr[2], 0, getStrLength(stringArr[2])-1) ); // we have z) or zz) or zzz), so we need to cut from end-1 to end which cuts out ")"
	
	vector = (x,y,z);
	
	return vector;
}

appendToDvar( dvar, string ){
	setDvar( dvar, getDvar( dvar ) + string );
}

getFullClassName(){
	switch(self.class){
		case "soldier": return "Soldier";
		case "armored": return "Armored";
		case "stealth": return "Assassin";
		case "engineer": return "Engineer";
		case "scout": return "Scout";
		case "medic": return "Medic";
		default: return "undefined";
	}
}


/* Returns the approximate required time to display a string on a client, increasing the display time for every 4 characters of a string */
getTimeForString(stringCount, min){
	if(!isDefined(min))
		min = 0;
	time = min;
	stringCount -= 4;
	while(stringCount > 0){
		stringCount -= 4;
		time += 0.4;
	}
	return time;
}