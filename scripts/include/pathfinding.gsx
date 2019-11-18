/**
* vim: set ft=cpp:
* file: scripts\include\pathfinding.gsx
*
* authors: 3aGl3
* team: SOG Modding
*
* project: RotU - Revolution
* website: http://survival-and-obliteration.com/
*
* Reign of the Undead - Revolution by Luk and 3aGl3
* You may modify this code to your liking or reuse it, as long as you give credit to those who wrote it
* Based on Reign of the Undead 2.1 created by Bipo and Etheross
*/

// WAYPOINTS/NAVMESHING AND PATHFINDING
#include scripts\include\data;

/**
* Loads the navmesh or waypoints for the map
*/
initPathfinding()
{
	/**
	* These are the options we need to go through in order, to load some nav nodes
	*	1. We have a navmesh.gsc file		-> isDefined(level.navPolys)
	*	2. We have a waypoints.gsc file		-> isDefined(level.waypoints)
	*	3. We have a waypoints.csv file		-> FS_TestFile( mapname_wp.csv )
	*	4. We have none of the above, this is kinda bad... -> TODO cancel the map?
	*
	*	NOTE that navmesh is preferable over waypoints but it's not relevant which way waypoints are loaded
	*/
	
	level.navMesh = false;		// true if we use a nav mesh
//	level.waypoints = {}		// array of waypoints or nav polygons
	
	// check if we have a gsc loaded navmesh
	if( isDefined(level.navPolys) )
	{
		// set the navMesh flag
		level.navMesh = true;
		
		// move navPolys into level.waypoints for backwards compatibility
		level.waypoints = level.navPolys;
		level.navPolys = undefined;
		
		level.waypointCount = level.waypoints.size;
		
		// build a filename for the lua csv file
		filename = "waypoints/"+ toLower(getDvar("mapname")) + "_nav.csv";
		
		// check if a csv file already exists
		if( !FS_TestFile( filename ) )
			// dump the navmesh into a csv file and load them
			thread dumpNavmesh( filename );
		else
			// load the navmesh csv file
			LoadNavmeshInternal( getDvar( "fs_game" ) + "/" + filename );
	}
	else
	{
		// build a filename for the waypoints csv
		filename =  "waypoints/"+ toLower(getDvar("mapname")) + "_wp.csv";
		
		// load the waypoints from the maps csv file if needed
		if( !isDefined( level.waypoints ) )
		{
			// setup waypoint variables
			level.waypoints = [];
			level.waypointCount = 0;

			printLn( "Loading waypoints from '" + fileName + "'." );

			// get the waypoint count
			level.waypointCount = int(tableLookup(fileName, 0, 0, 1));
			
			// get all waypoints
			for( i=0; i<level.waypointCount; i++ )
			{
				// create a struct for each waypoint
				waypoint = spawnStruct();
				
				// get the origin and seperate it into x, y and z values
				origin = tableLookup(fileName, 0, i+1, 1);
				waypoint.origin = stringToVector(origin);
				
				// save the waypoint into the waypoints array
				level.waypoints[i] = waypoint;
			}

			// go through all waypoints and link them
			for( i=0; i<level.waypointCount; i++ )
			{
				waypoint = level.waypoints[i]; 
				
				// get the children waypoint IDs and seperate them
				strLnk = tableLookup( fileName, 0, i+1, 2 );
				tokens = strTok( strLnk, " " );
				
				// set the waypoints children count
				waypoint.childCount = tokens.size;
				
				// add all the children as integers
				for(j=0; j<tokens.size; j++)
					waypoint.children[j] = int(tokens[j]);
			}
		}
		
		// check if a csv file already exists
		if( !FS_TestFile( filename ) )
			// dump the waypoints into a csv file and load them
			thread dumpWaypoints( filename );
		else
			// load the waypoints csv file
			LoadWaypointsInternal( getDvar( "fs_game" ) + "/" + filename );
	}
	
	/#	// draw the navmesh/waypoints for debugging
	setDvarIfUninitialized( "dev_debug_navnodes", "0" );
	
	if( getDvarInt("dev_debug_navnodes") > 0 )
		thread debugPathfinding();
	#/
}	/* initPathfinding */

/**
* Returns the id of a random navpoly or waypoint
*/
getRandomNavNode()
{
	return randomInt( level.waypoints.size );
}	/* getRandomNavNode */

/**
* Returns the origin of the given waypoint or a random origin on the nav poly
*/
getNavNodeOrigin( nnode )
{
	if( level.navMesh )
	{
		printLn( "TODO: getNavNodeOrigin actual" );
		// todo get a random point in the poly
	}

	return level.waypoints[nnode].origin;
}	/* getNavNodeOrigin */

/**
* Dumps the navmesh into a csv file for lua plugin
*/
dumpNavmesh( fname )
{
	dump = [];
	
	// dump all vertices into the csv file
	for( i=0; i < level.navVerts.size; i++ )
	{
		dump[dump.size] = "v," + ( i + 1 ) + "," + vectorToString( level.navVerts[i] );
	}
	
	// dump all nav polygons into the csv file
	for( i=0; i < level.waypoints.size; i++ )
	{
		if( isDefined(level.waypoints[i].type) )
			dump[dump.size] = "p," + ( i + 1 ) + "," + vectorToString( level.waypoints[i].origin ) + "," + dumpChildren( level.waypoints[i].children ) + "," + level.waypoints[i].type + ",nil," + dumpChildren( level.waypoints[i].verts );
		else
			dump[dump.size] = "p," + ( i + 1 ) + "," + vectorToString( level.waypoints[i].origin ) + "," + dumpChildren( level.waypoints[i].children ) + ",nil," + level.waypoints[i].height + "," + dumpChildren( level.waypoints[i].verts );
		
		if( i % 1000 == 0 )
			ResetTimeout();
	}
	
	writeToFile( fname, dump );
	LoadNavmeshInternal( getDvar( "fs_game" ) + "/" + fname );
}	/* dumpNavmesh */

/**
* Dumps the waypoints into a csv file for the lua plugin
*/
dumpWaypoints( fname )
{
	dump = [];
	
	for( i=0; i < level.waypoints.size; i++ )
	{
		if( !isArray( level.waypoints[i].children ) )		// TODO why is this here?
			level.waypoints[i].children[0] = ( i + 1 );
		
		dump[dump.size] = "" + ( i + 1 ) + "," + vectorToString( level.waypoints[i].origin ) + "," + dumpChildren( level.waypoints[i].children );
		
		if( i % 1000 == 0 )
			ResetTimeout();
	}
	
	writeToFile( fname, dump );
	LoadWaypointsInternal( getDvar( "fs_game" ) + "/" + fname );
}	/* dumpWaypoints */

/**
* Dumps the nav node children into a string
*/
dumpChildren( children )
{
	string = "";
	for( i = 0; i < children.size; i++ )
		string += (children[i]+1) + " ";
	
	return string;
}	/* dumpChildren */

/**
* Writes the given array into the file at the given path
*/
writeToFile( fname, content )
{
	// attempt to open the file for writing
	file = FS_FOpen( fname, "write" );
	if( !isDefined( file ) )
		return false;
	
	// write each entry in the array into the file
	for( i=0; i < content.size; i++ )
		FS_WriteLine(  file , content[i] );
	
	FS_FClose( file );
	
	return true;
}	/* writeToFile */

/**
* Draws the waypoints or navmesh around the player
*/
debugPathfinding()
{
	/#
	setDvarIfUninitialized( "dev_pfind_distance", 800 );
	setDvarIfUninitialized( "dev_pfind_color", "1 1 1" );

	level waittill( "connected", player );
	
	frames = 20;
	
	for(;;)
	{
		wait 0.01;
		waittillframeend;
		
		if( !isDefined(player) )
			break;
		
		// color to draw the navmesh in
		color = stringToVector( getDvar("dev_pfind_color") );
		
		verts = [];
		// draw navmesh polygons and their vertex
		for( i=0; i<level.waypoints.size; i++ )
		{
			poly = level.waypoints[i];
			// don't draw the polygon if it's out of range
			if( getDvarInt("dev_pfind_distance") == -1 || distance(player.origin, poly.origin) < getDvarInt("dev_pfind_distance") )
			{	
				// draw the polygon center
				line( poly.origin, poly.origin+(0,0,10), color, frames );
				
				// check if drawing navmesh
				if( isDefined(poly.verts) )
				{
					// draw the vertices and connections of this polygon
					for( j=0; j<poly.verts.size; j++ )
					{
						x = poly.verts[j];
						origin = level.navVerts[x];
						// draw the vertex if not done yet
						if( !isDefined(verts[x]) || verts[x] )
						{
							line( origin, origin+(0,0,5), color, frames );
							verts[x] = true;
						}
						
						// draw the connection to the next vertex, or the first
						if( isDefined(poly.verts[j+1]) )
							line( origin, level.navVerts[poly.verts[j+1]], color, frames );
						else
							line( origin, level.navVerts[poly.verts[0]], color, frames );
					}
				} else {
					// draw the connections to other waypoints
					for( j=0; j<poly.children.size; j++ )
					{
						x = poly.children[j];
						line( poly.origin, level.waypoints[x].origin, color, frames );
					}
				}
			}
		}
	}

	thread debugPathfinding();
	#/
}	/* debugPathfinding */
