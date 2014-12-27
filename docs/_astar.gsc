#include common_scripts\utility;
#include maps\_utility;

// pick a random path every 10 seconds, debugging
pickRandomPath()
{
	// this was meant to calculate the distances between all waypoints, it was commented by IW
	calcDists();
	while (1)
	{
		// we pick a random start node
		startNode = level.waypointHeading[randomint(level.waypointHeading.size)];
		endNode = startNode;
		
		// we pick a random end node
		while( endNode == startNode )
			endNode = level.waypointHeading[randomint(level.waypointHeading.size)];
		
		// we generate the path between those two nodes
		randomPath = generatePath( startNode, endNode );
		// we draw the path, 10 is the time it'll be drawn
		level thread drawPath( randomPath, 10 );
		
		// we wait 10 seconds and do this all over again
		wait 10.0;
	}
}

// call function as generatePath(startNode, destNode), otherwise paths will be reversed
generatePath (destNode, startNode, blockedNodes)
{
	// the open list contains all 
	level.openList = [];
	// the closed list contains all nodes we already worked on
	level.closedList = [];
	foundPath = false;
	pathNodes = [];

	// this is quite usefull it seems to block nodes
	if( !isDefined(blockedNodes) )
		blockedNodes = [];
	
	// G is the distance from the start, obviously 0
	startNode.g = 0;
	// H is an approx value to the end node, distance in inch
	startNode.h = getHValue( startNode, destNode );
	// F is G+H, basically the entire distance you travel when using thsi node
	startNode.f = startNode.g + startNode.h;
	
	// the start nodes values have been set up, push it on Closed list
	addToClosedList( startNode );

	curNode = startNode;
	while( 1 )
	{
		// we check out all nodes that are linked to the current node
		for( i = 0; i < curNode.link.size; i++ )
		{
			checkNode = curNode.link[i];
			
			// if this node is on the blocked list we don't bother
			if( is_in_array(blockedNodes, checkNode) )
				continue;
			
			// if it's on the closed list we don't bother either
			if( is_in_array(level.closedList, checkNode) )
				continue;
				
			if( !is_in_array(level.openList, checkNode) )
			{
				// if it's not on the open list already, we add it
				addToOpenList( checkNode );
				checkNode.parentNode = curNode;
				// G value is the distance from the startNode, following all previous nodes
				checkNode.g = getGValue( checkNode, curNode );
				// H value is the distance to the destNode
				checkNode.h = getHValue( checkNode, destNode );
				// F = G+H
				checkNode.f = checkNode.g + checkNode.h;
				
				// if we are at the end we found a valid path
				if( checkNode == destNode )
					foundPath = true;
			}
			else
			{
				// if the node is already on the open list we just check if it's G is lower the the one of the curNode
				if( checkNode.g < getGValue( curNode, checkNode ) )
					continue;
				
				checkNode.parentNode = curNode;
				// update G
				checkNode.g = getGValue( checkNode, curNode );
				// update F
				checkNode.f = checkNode.g + checkNode.h;					
			}
		}
		
		// if we found a path we are done here
		if( foundPath )
			break;
		
		// now that we have worked on all the child nodes, push cuNode onto the closed list
		addToClosedList( curNode );
		
		// we get the bestNode, just assume the first one on openList is it
		bestNode = level.openList[0];
		for( i = 1; i < level.openList.size; i++ )
		{
			// check if F off this node is below the other one
			if( level.openList[i].f > bestNode.f )
				continue;

			// if that's the case this one is better as lower F = better
			bestNode = level.openList[i];
		}
		
		// no path found...shouldn't we go back to another node?
		if( !isDefined(bestNode) )
			return pathNodes;	

		// add the bestNode also to the closedList
		addToClosedList( bestNode );
		// now search on from this node
		curNode = bestNode;
	}

	// WAT?
	assert( isDefined(destNode.parentNode) );

	// we build an array of nodes from the destNode to the startNode
	curNode = destNode;
	while( curNode != startNode )
	{
		pathNodes[pathNodes.size] = curNode;
		curNode = curNode.parentNode;
	}
	// eventually add the last curNode aka startNode
	pathNodes[pathNodes.size] = curNode;

	// return the array of nodes
	return pathNodes;
}

// adds a node to the open list
addToOpenList( node )
{
	node.openListID = level.openList.size;
	level.openList[level.openList.size] = node;
	// unsure if we should also remove it from the closed list properly...
	node.closedListID = undefined;
}

// adds a node to the closed list
addToClosedList( node )
{
	// if it's already on the closed list, nothing to do
	if( isDefined(node.closedListID) )
		return;
	
	// assign an ID to it and add it to the closed list
	node.closedListID = level.closedList.size;
	level.closedList[level.closedList.size] = node;

	if( !is_in_array(level.openList, node) )
		return;
	
	// if it's on the open list already we remove it...is this safe?
	level.openList[node.openListID] = level.openList[level.openList.size - 1];
	level.openList[node.openListID].openListID = node.openListID;
	level.openList[level.openList.size - 1] = undefined;
	node.openListID = undefined;
}

// calculates the distances between all waypoints
calcDists ()
{
	/* which is useless
	for (i = 0; i < level.waypointHeading.size; i++)
	{
		curNode = level.waypointHeading[i];
		
		if (!isdefined (curNode.nodeDists))
			curNode.nodeDists = [];
			
		for (j = 0; j < curNode.link.size; j++)
		{
			if (curNode getentnum() < curNode.link[j] getentnum())
			{
				storageNode = curNode;
				storageString = curNode getentnum() + " " + curNode.link[j] getentnum();
			}
			else
			{
				storageNode = curNode.link[j];
				storageString = curNode.link[j] getentnum() + " " + curNode getentnum();
			}
			
			if (!isdefined (storageNode.nodeDists) || !isdefined (storageNode.nodeDists[storageString]))
				storageNode.nodeDists[storageString] = distance (curNode.origin, curNode.link[j].origin);
		}
	}
	*/
}

// get the H off a node, distance in best case scenario
getHValue( node1, node2 )
{
	return distance( node1.origin, node2.origin );
}

// get the G off a node, which should be the distance to the startNode
getGValue( node1, node2 )
{
	// this is a little redundant as node1.parentNode should be node2
	return (node1.parentNode.g + distance( node1.origin, node2.origin ));
}

// gets the distance between two nodes
getDist( node1, node2 )
{
/* but is apparently broken or something
	if (node2 getentnum() < node1 getentnum())
	{
		tempNode = node2;
		node2 = node1;
		node1 = tempNode;
	}
	
	indexString = node1 getentnum() + " " + node2 getentnum();
	assert (isdefined (node1.nodeDists[indexString]));
	
	return (node1.nodeDists[indexString]);
*/
}

// draws a path for a set ammount of time, debugging
drawPath( pathNodes, duration, id )
{
	if( !isDefined(id) )
		id = "msg";

	// the notify stops all previous draws for this path
	level notify( "draw new path" + id );
	for( i = 1; i < pathNodes.size; i++ )
		level thread drawLink( pathNodes[i].origin, pathNodes[i - 1].origin, duration, id );
}

// draws a path and all it's branches, debugging
drawPathOffshoots( pathNodes, duration )
{
	level endon( "newpath" );
	duration = 10;

	for( i = 0; i < pathNodes.size-1; i++ )
	{
		for( p = 0; p < pathNodes[i].link.size; p++ )
		{
			if( i > 0 && pathNodes[i].link[p] == pathNodes[i-1] )
				continue;
			
			if( pathNodes[i].link[p] == pathNodes[i+1] )
				level thread drawLinkFull( pathNodes[i], pathNodes[i].link[p], (1,0,0), false, duration );
			else
				level thread drawLinkFull( pathNodes[i], pathNodes[i].link[p], (0,0,1), true, duration );
		}
	}

	lastLink = pathNodes[pathNodes.size-1];
	for( p = 0; p < lastLink.link.size; p++ )
	{
		if( lastLink.link[p] == pathNodes[pathNodes.size-2] )
			continue;
		
		level thread drawLinkFull( lastLink, lastLink.link[p], (0,0,1), true, duration );
	}
}

// draws a line between two point for a set ammount of time, debugging
drawLink( start, end, duration, id )
{
	// if we start to draw a new path, end this drawing
	level endon( "draw new path" + id );

	for( i = 0; i < duration * 20; i++ )
	{
		line( start, end, (1, 0, 0), true );
		wait 0.05;
	}
}

// draws a full link between two pathnodes, debugging
drawLinkFull( start, end, color, limit, duration )
{
	level endon( "newpath" );

	pts = [];
	angles = vectorToAngles( start.origin - end.origin );
	right = anglesToRight( angles );
	forward = anglesToForward( angles );

	pts[pts.size] = end.origin + vectorScale( right, end.radius );
	pts[pts.size] =  start.origin + vectorScale( right, start.radius );
	pts[pts.size] =  start.origin + vectorScale( right, start.radius * -1 );
	pts[pts.size] =  end.origin + vectorscale( right, end.radius * -1 );

	dist = distance( start.origin, end.origin );
	arrow = [];
	stages = 10;
	range = 0.15;
	for( i = 0; i < stages; i++ )
	{
		stage = i+1;
		arrow[i][0] = start.origin;
		arrow[i][1] = start.origin + vectorscale(right, dist*(range * (i/stages))) + vectorscale(forward, dist*-0.2);
		arrow[i][2] = end.origin;
		arrow[i][3] = start.origin + vectorscale(right, dist*(-1 * range * (i/stages))) + vectorscale(forward, dist*-0.2);
	}

	for( p = 0; p < duration * 20; p++ )
	{
		for( i = 0; i < pts.size; i++ )
		{
			nextpoint = i+1;
			if( nextpoint >= pts.size )
			{
				if( limit )
					break;
				nextpoint = 0;
			}
			line( pts[i], pts[nextpoint], color, 1.0 );
		}

		for( i = 0; i < stages; i++ )
		{
			for( p = 0; p < 4; p++ )
			{
				nextpoint = p+1;
				if( nextpoint >= 4 )
					nextpoint = 0;
				
				line( arrow[i][p], arrow[i][nextpoint], color, 1.0 );
			}
		}
		wait 0.05;
	}
}

// gets a path between to points
getPathBetweenPoints( start, end )
{
	// get the closest waypoint to the two points
	startNode = getClosest( start, level.waypointHeading );
	endNode = getClosest( end, level.waypointHeading );

	// get the path between those points
	path = generatePath( startNode, endNode );
/#
	// if we want debug info we draw the path
	if( getDebugDvar( "debug_astar" ) == "on" )
		level thread drawPath( path, 15 );
#/

	return path;
}

// gets a path between a start point an an array, no idea what this is for
getPathBetweenArrayOfPoints( start, orgArray )
{
	paths=[];
	array = [];

	// get the waypoints for the origins
	for( i = 0; i < orgArray.size; i++ )
		array[i] = getClosest( orgArray[i], level.waypointHeading );

	// get the start waypoint and generate the first path
	startNode = getClosest( start, level.waypointHeading );
	paths[paths.size] = generatePath( startNode, array[0] );

	// generate all other paths
	for( i = 0; i < array.size-1; i++ )
		paths[paths.size] = generatePath( array[i], array[i+1] );

	newpath = [];
	for( i = 0; i < paths.size; i++ )
	{
		for( p = 0; p < paths[i].size-1; p++ )
			newpath[newpath.size] = paths[i][p];
	}

	// tag the last connection on 
	newpath[newpath.size] = paths[paths.size-1][paths[paths.size-1].size-1];

	path = newpath;
	newpath = [];
	if( !path.size )
		return newpath;

	// pemove duplicate path waypoints
	curpath = path[0];
	newpath[newpath.size] = curpath;
	for( i = 1; i < path.size; i++ )
	{
		if( path[i] == curpath )
			continue;

		newpath[newpath.size] = path[i];
	}

/#
	// if we want debug info, draw the path
	if( getDebugDvar("debug_astar") == "on" )
		level thread drawPath( newpath, 15 );
#/
	return newpath;
}

