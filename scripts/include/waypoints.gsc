/**
* vim: set ft=cpp:
* file: scripts\include\waypoints.gsc
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

// WAYPOINTS AND PATHFINDING
#include scripts\include\data;

/**
* Returns the float value of a string.
*
*	@number: string to be converted to float.
*/
float( number )
{
	// forward to the atof function
	return atof( number );
}

/**
* Loads the levels waypoints from a csv file and convertes them for the gamemode.
*/
loadWaypoints()
{
	// workaround for maps with script waypoints, e.g stock maps
	if( isDefined( level.waypoints ) && level.waypoints.size > 0 )
	{
		return;
	}

	level.waypoints = [];
	level.waypointCount = 0;
	level.waypointLoops = 0;

	// create the full filepath for the waypoint csv file
	fileName =  "waypoints/"+ toLower(getDvar("mapname")) + "_wp.csv";
/#	printLn( "Getting waypoints from csv: "+fileName );		#/

	// get the waypoint count, then get all the waypoint data
	level.waypointCount = int( tableLookup(fileName, 0, 0, 1) );
	for( i=0; i<level.waypointCount; i++ )
	{
		// create a struct for each waypoint
		waypoint = spawnStruct();
		
		// get the origin and seperate it into x, y and z values
		origin = tableLookup( fileName, 0, i+1, 1 );
		orgToks = strtok( origin, " " );
		
		// convert the origin to a vector3
		waypoint.origin = ( float(orgToks[0]), float(orgToks[1]), float(orgToks[2]));
		
		// save the waypoint into the waypoints array
		level.waypoints[i] = waypoint;
	}

	// go through all waypoints and link them
	for( i=0; i<level.waypointCount; i++ )
	{
		waypoint = level.waypoints[i]; 
		
		// get the children waypoint IDs and seperate them
		strLnk = tableLookup( fileName, 0, i+1, 2 );
		tokens = strTok(strLnk, " ");
		
		// set the waypoints children count
		waypoint.childCount = tokens.size;
		
		// add all the children as integers
		for( j=0; j<tokens.size; j++ )
			waypoint.children[j] = int(tokens[j]);
	}

	//thread drawWP();
}

/**
* Returns the ID of the waypoint closest to the given origin, -1 if none is found.
*
*	@origin: Origin to find the closest waypoint to
*/
getNearestWp( origin )
{
	// set initial values for the waypoint
	nearestWp = -1;
	nearestDist = 9999999999;

	// loop through all waypoints
	for( i = 0; i < level.waypointCount; i++ )
	{
		// get the squared distance
		dist = distanceSquared( origin, level.waypoints[i].origin );
    
		// check if the distance is closer than the currently closest
		if( dist < nearestDist )
		{
			// memorize the current waypoint
			nearestDist = dist;
			nearestWp = i;
		}
	}

	// return the ID of the closest waypoint
	return nearestWp;
}

// 
/**
* Returns the A-Star path from one waypoint to another.
*	Note: ASTAR PATHFINDING ALGORITHM: CREDITS GO TO PEZBOTS!
*
*	@startWp: ID of the starting waypoint
*	@goalWp: ID of the target waypoint
*/
AStarSearch( startWp, goalWp )
{
	// info regarding the A-Star Algorithm can be found here:
	// https://en.wikipedia.org/wiki/A*_search_algorithm

	pQOpen = [];
	pQSize = 0;
	closedList = [];
	listSize = 0;

	s = spawnStruct();
	s.g = 0; //start node
	s.h = distance( level.waypoints[startWp].origin, level.waypoints[goalWp].origin );
	s.f = s.g + s.h;
	s.wpIdx = startWp;
	s.parent = spawnStruct();
	s.parent.wpIdx = -1;

	//push s on Open
	pQOpen[pQSize] = spawnStruct();
	pQOpen[pQSize] = s; //push s on Open
	pQSize++;

	// while Open is not empty  
	while( !PQIsEmpty(pQOpen, pQSize) )
	{
		// pop node n from Open  // n has the lowest f
		n = pQOpen[0];
		highestPriority = 9999999999;
		bestNode = -1;
		for( i=0; i<pQSize; i++ )
		{
			if( pQOpen[i].f < highestPriority )
			{
				bestNode = i;
				highestPriority = pQOpen[i].f;
			}
		}
    
		if( bestNode != -1 )
		{
			n = pQOpen[bestNode];
			//remove node from queue    
			for( i=bestNode; i<pQSize-1; i++ )
			{
				pQOpen[i] = pQOpen[i+1];
			}
			pQSize--;
		}
		else
		{
			return -1;
		}
		
		// if n is a goal node; construct path, return success
		if( n.wpIdx == goalWp )
		{
			x = n;
			for( z=0; z<1000; z++ )
			{
				parent = x.parent;
				if( parent.parent.wpIdx == -1 )
					return x.wpIdx;
				
				// line(level.waypoints[x.wpIdx].origin, level.waypoints[parent.wpIdx].origin, (0,1,0));
				x = parent;
			}
			
			return -1;      
		}
		
		// for each successor nc of n
		for( i=0; i<level.waypoints[n.wpIdx].childCount; i++ )
		{
			//newg = n.g + cost(n,nc)
			newg = n.g + distance( level.waypoints[n.wpIdx].origin, level.waypoints[level.waypoints[n.wpIdx].children[i]].origin );
      
			//if nc is in Open or Closed, and nc.g <= newg then skip
			if( PQExists(pQOpen, level.waypoints[n.wpIdx].children[i], pQSize) )
			{
				//find nc in open
				nc = spawnStruct();
				for( p=0; p<pQSize; p++ )
				{
					if( pQOpen[p].wpIdx == level.waypoints[n.wpIdx].children[i] )
					{
						nc = pQOpen[p];
						break;
					}
				}
				
				if( nc.g <= newg )
				{
					continue;
				}
			}
			else if( PQExists(closedList, level.waypoints[n.wpIdx].children[i], listSize) )
			{
				//find nc in closed list
				nc = spawnStruct();
				for( p=0; p<listSize; p++ )
				{
					if( closedList[p].wpIdx == level.waypoints[n.wpIdx].children[i] )
					{
						nc = closedList[p];
						break;
					}
				}
				
				if( nc.g <= newg )
				{
					continue;
				}
			}
			
			nc = spawnStruct();
			nc.parent = n;
			nc.g = newg;
			nc.h = distance( level.waypoints[level.waypoints[n.wpIdx].children[i]].origin, level.waypoints[goalWp].origin );
			nc.f = nc.g + nc.h;
			nc.wpIdx = level.waypoints[n.wpIdx].children[i];
			
			//if nc is in Closed,
			if( PQExists(closedList, nc.wpIdx, listSize) )
			{
				//remove it from Closed
				deleted = false;
				for( p=0; p<listSize; p++ )
				{
					if( closedList[p].wpIdx == nc.wpIdx )
					{
						for( x=p; x<listSize-1; x++ )
							closedList[x] = closedList[x+1];
						
						deleted = true;
						break;
					}
					
					if( deleted )
						break;
				}
				listSize--;
			}
			
			// if nc is not yet in Open, 
			if( !PQExists(pQOpen, nc.wpIdx, pQSize) )
			{
				//push nc on Open
				pQOpen[pQSize] = nc;
				pQSize++;
			}
		}
		
		// Done with children, push n onto Closed
		if( !PQExists(closedList, n.wpIdx, listSize) )
		{
			closedList[listSize] = n;
			listSize++;
		}
	}
}


/**
* Returns true if the open list is empty
*
*	@Q: Open List
*	@QSize: Size of Open List
*/
PQIsEmpty( Q, QSize )
{
	if( QSize <= 0 )
	{
		return true;
	}

	return false;
}


/**
* Returns true if n exists in the array Q
*
*	@Q: Array of waypoints
*	@n: Waypoint
*	@QSize: Size of array Q
*/
PQExists( Q, n, QSize )
{
	for( i=0; i<QSize; i++ )
	{
		if( Q[i].wpIdx == n )
			return true;
	}

	return false;
}

//
// DEBUG
//

/**
* Draws all waypoints and connections between waypoints for debugging.
*/
drawWP()
{
	for(;;)
	{
		for( i = 0; i < level.waypointCount; i++ )
		{
			wp = level.waypoints[i];
			line( wp.origin, wp.origin + (0,0,96), (0,1,0) );
			
			for( j = 0; j < wp.childCount; j++ )
				line( wp.origin, level.waypoints[wp.child[j]].origin, (0,0,1) );
		}
		
		wait 0.05;
	}
}

