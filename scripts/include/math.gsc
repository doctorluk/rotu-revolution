/**
* vim: set ft=cpp:
* file: scripts\include\math.gsc
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

randomNormalInt(mean, stddev) // Approximation by sum of two uniform variables (I know it's just a triangle ;D)
{
	return (randomint(stddev) + randomint(stddev) + mean - stddev);
}

randomNormalFloat(mean, stddev) // Approximation by sum of two uniform variables
{
	return (randomfloat(stddev) + randomfloat(stddev) + mean - stddev);
}

power(val, power) // Only works for positive integers
{
	if (power <= 0)
	return 1;
	
	for (i=1; i<power; i++)
	{
		val = val * val;
	}
	return val;
}

abs(x)
{
	if (x<0)
	return x*-1;
	return x;
}

/*
	Cross Product of two vectors, giving us an orthogonal vector c of the plane drawn by a and b
		(a2b3 - a3b2)
	c =	(a3b1 - a1b3)
		(a1b2 - a2b1)
*/
crossProduct(a, b){
	
	x = (a[1] * b[2]) - (a[2] * b[1]);
	y = (a[2] * b[0]) - (a[0] * b[2]);
	z = (a[0] * b[1]) - (a[1] * b[0]);
	
	return (x,y,z);

}

dotProduct(vec1, vec2){
	if(!isDefined(vec1) || !isDefined(vec2))
		return;
	
	return(vec1[0] * vec2[0], vec1[1] * vec2[1], vec1[2] * vec2[2]);
}


sqrt(x) // Using Newton's iterative approximation
{
	tolerance = .001;
	y=x;
	for(;;)
	{
		z=1/2*(y+x/y);
		if (abs(y-z)<tolerance) break;
		y=z;
	}
	return y;
}