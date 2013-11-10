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