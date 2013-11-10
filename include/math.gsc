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