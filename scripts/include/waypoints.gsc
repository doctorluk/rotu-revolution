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
* Reign of the Undead - Revolution by Luk and 3aGl3
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
float(number)
{
	// forward to the atof function
	return atof(number);
}

/**
* Loads the levels waypoints from a csv file and convertes them for the gamemode.
*/
loadWaypoints()
{
	// workaround for maps with script waypoints, e.g stock maps
	if(isDefined(level.waypoints) && level.waypoints.size > 0)
	{
		return;
	}

	level.waypoints = [];
	level.waypointCount = 0;
	level.waypointLoops = 0;

	// create the full filepath for the waypoint csv file
	fileName =  "waypoints/"+ toLower(getDvar("mapname")) + "_wp.csv";
/#	printLn("Getting waypoints from csv: "+fileName);		#/

	// get the waypoint count, then get all the waypoint data
	level.waypointCount = int(tableLookup(fileName, 0, 0, 1));
	for(i=0; i<level.waypointCount; i++)
	{
		// create a struct for each waypoint
		waypoint = spawnStruct();
		
		// get the origin and seperate it into x, y and z values
		origin = tableLookup(fileName, 0, i+1, 1);
		orgToks = strtok(origin, " ");
		
		// convert the origin to a vector3
		waypoint.origin = (float(orgToks[0]), float(orgToks[1]), float(orgToks[2]));
		
		// save the waypoint into the waypoints array
		level.waypoints[i] = waypoint;
	}

	// go through all waypoints and link them
	for(i=0; i<level.waypointCount; i++)
	{
		waypoint = level.waypoints[i]; 
		
		// get the children waypoint IDs and seperate them
		strLnk = tableLookup(fileName, 0, i+1, 2);
		tokens = strTok(strLnk, " ");
		
		// set the waypoints children count
		waypoint.childCount = tokens.size;
		
		// add all the children as integers
		for(j=0; j<tokens.size; j++)
			waypoint.children[j] = int(tokens[j]);
	}

	//thread drawWP();
}

/**
* Returns the ID of the waypoint closest to the given origin, -1 if none is found.
*
*	@origin: Origin to find the closest waypoint to
*/
getNearestWp(origin)
{
	// set initial values for the waypoint
	nearestWp = -1;
	nearestDist = 9999999999;

	// loop through all waypoints
	for(i = 0; i < level.waypointCount; i++)
	{
		// get the squared distance
		dist = distanceSquared(origin, level.waypoints[i].origin);
    
		// check if the distance is closer than the currently closest
		if(dist < nearestDist)
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
*	Returns the ID of the first waypoint step toward goalWp, or -1 on failure.
*
*	@startWp: ID of the starting waypoint
*	@goalWp:  ID of the target waypoint
*
* Rewritten from the original PezBots-based version with the following improvements:
*   - O(1) open/closed checks via boolean arrays indexed by waypoint ID
*     (replaces the O(N) PQExists linear scans)
*   - O(1) g/f-cost access via flat arrays (replaces spawnStruct per node)
*   - O(1) removal from open set via swap-with-last (replaces O(N) left-shift)
*   - Bug fix: better paths to already-queued open nodes are updated in-place
*     instead of being silently dropped
*   - Path reconstruction via flat parentId[] array (replaces struct pointer chain)
*   - level.waypointLoops tracks actual work done for the throttle in zomMoveTowards
*/
AStarSearch(startWp, goalWp)
{
	// O(1)-lookup arrays indexed by waypoint ID (GSC sparse integer arrays)
	inOpen   = [];   // inOpen[id]   == true  → node is in the open set
	inClosed = [];   // inClosed[id] == true  → node has been fully expanded
	gCost    = [];   // gCost[id]             → accumulated path cost from start
	fCost    = [];   // fCost[id]             → g + h (priority)
	parentId = [];   // parentId[id]          → predecessor waypoint ID (-1 = none)

	openIds  = [];   // IDs of nodes currently in the open set
	openSize = 0;

	// initialize start node
	gCost[startWp]    = 0;
	fCost[startWp]    = distance(level.waypoints[startWp].origin, level.waypoints[goalWp].origin);
	parentId[startWp] = -1;
	inOpen[startWp]   = true;
	openIds[0]        = startWp;
	openSize          = 1;

	while(openSize > 0)
	{
		// --- POP: find and remove the node with the lowest f-cost ---
		// O(N) linear scan — acceptable for N < 300; a min-heap would give O(log N)
		// but requires swap-by-reference which GSC does not support natively.
		bestIdx = 0;
		bestF   = fCost[openIds[0]];
		for(i = 1; i < openSize; i++)
		{
			if(fCost[openIds[i]] < bestF)
			{
				bestF   = fCost[openIds[i]];
				bestIdx = i;
			}
		}
		nId = openIds[bestIdx];

		// O(1) remove: overwrite slot with the last element, shrink size
		openIds[bestIdx] = openIds[openSize - 1];
		openSize--;
		inOpen[nId]   = false;
		inClosed[nId] = true;

		// track work done for the throttle guard in zomMoveTowards
		level.waypointLoops += level.waypoints[nId].childCount;

		// --- GOAL REACHED: trace parentId[] back to find the first step ---
		if(nId == goalWp)
		{
			cur = goalWp;
			while(parentId[cur] != startWp && parentId[cur] != -1)
				cur = parentId[cur];
			return cur;
		}

		// --- EXPAND CHILDREN ---
		wp = level.waypoints[nId];
		for(i = 0; i < wp.childCount; i++)
		{
			cId = wp.children[i];

			if(inClosed[cId])   // O(1) — was O(N) PQExists scan
				continue;

			newg = gCost[nId] + distance(wp.origin, level.waypoints[cId].origin);

			if(inOpen[cId])     // O(1) — was O(N) PQExists scan
			{
				// node already queued — update if this path is strictly better
				// (bug fix: old code dropped the better path here)
				if(newg < gCost[cId])
				{
					gCost[cId]    = newg;
					fCost[cId]    = newg + distance(level.waypoints[cId].origin, level.waypoints[goalWp].origin);
					parentId[cId] = nId;
					// node stays in openIds; updated fCost is picked up on next pop
				}
			}
			else
			{
				// new node — add to open set
				gCost[cId]        = newg;
				fCost[cId]        = newg + distance(level.waypoints[cId].origin, level.waypoints[goalWp].origin);
				parentId[cId]     = nId;
				inOpen[cId]       = true;
				openIds[openSize] = cId;
				openSize++;
			}
		}
	}

	return -1;   // no path found
}


/**
* @deprecated No longer used internally — AStarSearch now uses O(1) boolean arrays.
*             Kept for API compatibility with any external callers.
*/
PQIsEmpty(Q, QSize)
{
	return QSize <= 0;
}

/**
* @deprecated No longer used internally — AStarSearch now uses O(1) boolean arrays.
*             Kept for API compatibility with any external callers.
*/
PQExists(Q, n, QSize)
{
	for(i = 0; i < QSize; i++)
	{
		if(Q[i].wpIdx == n)
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
		for(i = 0; i < level.waypointCount; i++)
		{
			wp = level.waypoints[i];
			line(wp.origin, wp.origin + (0,0,96), (0,1,0));
			
			for(j = 0; j < wp.childCount; j++)
				line(wp.origin, level.waypoints[wp.child[j]].origin, (0,0,1));
		}
		
		wait 0.05;
	}
}

