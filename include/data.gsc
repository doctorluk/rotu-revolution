//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.2 by Luk 
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (3 lines above)
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
	for (i=0; i<array.size; i++)
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
	for (i=0; i<string.size; i++)
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