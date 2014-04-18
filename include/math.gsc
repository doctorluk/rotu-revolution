//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.4.2 by Luk 
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

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


sqrt(x) // Using Newton's itterative approximation
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