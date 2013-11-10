/**********************************
	---- Reign of the Undead ----
			   v2.0
	
	(Do not copy without permission)
	
	Date: November 2010
	Version: 2.000
	Author: Bipo
		
	© Reign of the Undead Team
************************************/

init()
{
	scripts\server\_maps::getMaprotation();
	level.onChangeMap = ::map_rotate;
}

map_rotate()
{
	nextmap = scripts\server\_maps::getNextMap();
	if (isdefined(nextmap))
	scripts\server\_maps::changeMap(nextmap);
	else
	{
		map_restart( false );
	}
}