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

atof(string)
{
	setdvar("2float", string);
	return getdvarfloat("2float");
}

atoi(string)
{
	setdvar("2int", string);
	return getdvarint("2int");
}

removeFromArray(array, item)
{
	for (i = 0; i<array.size; i++)
	{
		if (array[i] == item)
		{
			for (; i<array.size - 1; i++)
			{
				array[i] = array[i+1];
			}
			array[array.size-1] = undefined;
			return array;
		}
	}
	return array;
}

arrayContains(array, item){
	for(i = 0; i < array.size; i++){
		if(array[i] == item)
			return true;
	}
	return false;
}

dissect(string)
{
	ret = [];
	index = -1;
	skip = 1;
	for (i = 0; i<string.size; i++)
	{
		if (string[i]==" ")
		{
			skip = 1;
			continue;
		}
		else
		{
			if (skip)
			{
				index ++;
				skip = 0;
				ret[index] = "";
			}
			ret[index] += string[i];
		}
		
	}
	return ret;
}