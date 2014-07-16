//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.6 by Luk 
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

// WAYPOINTS AND PATHFINDING
#include scripts\include\data;
loadWaypoints()
{
	level.Wp = [];
	level.WpCount = 0;
	level.waypointLoops = 0;
	
	fileName =  "waypoints/"+ tolower(getdvar("mapname")) + "_wp.csv";
	level.WpCount = int(TableLookup(fileName, 0, 0, 1));
	for (i=0; i<level.WpCount; i++)
	{
		waypoint = spawnstruct();
		level.Wp[i] = waypoint;
		strOrg = TableLookup(fileName, 0, i+1, 1);
		tokens = strtok(strOrg, " ");
		
		waypoint.origin = (atof(tokens[0]), atof(tokens[1]), atof(tokens[2]));
		waypoint.isLinking = false;
		waypoint.ID = i;
	}
	for (iii=0; iii<level.WpCount; iii++)
	{
		waypoint = level.Wp[iii]; 
		strLnk = TableLookup(fileName, 0, iii+1, 2);
		tokens = strtok(strLnk, " ");
		waypoint.linkedCount = tokens.size;
		for (ii=0; ii<tokens.size; ii++)
		waypoint.linked[ii] = level.Wp[atoi(tokens[ii])];
		
		if (!isdefined(waypoint.linked)) // Error catching
		{
			iprintlnbold("^1UNLINKED WAYPOINT: " + waypoint.ID + " AT: " +  waypoint.origin);
		}
	}
	//thread draw_wp();
}

draw_wp()
{
	while(1)
	{
	for (iii=0; iii<level.WpCount; iii++)
	{
		for (i=0; i<level.Wp[iii].linked.size; i++)
		line(level.Wp[iii].origin, level.Wp[iii].linked[i].origin);
	}
	wait 0.05;
	}
}

getNearestWp( origin )
{
  nearestWp = -1;
  nearestDistance = 9999999999;
  for(i = 0; i < level.WpCount; i++)
  {
    distance = distancesquared(origin, level.Wp[i].origin);
    
    if(distance < nearestDistance)
    {
      nearestDistance = distance;
      nearestWp = i;
    }
  }
  
  return nearestWp;
}

// ASTAR PATHFINDING ALGORITHM: CREDITS GO TO PEZBOTS!

AStarSearch(startWp, goalWp)
{
  pQOpen = [];
  pQSize = 0;
  closedList = [];
  listSize = 0;
  s = spawnstruct();
  s.g = 0; //start node
  s.h = distance(level.Wp[startWp].origin, level.Wp[goalWp].origin);
  s.f = s.g + s.h;
  s.wpIdx = startWp;
  s.parent = spawnstruct();
  s.parent.wpIdx = -1;
  
  //push s on Open
  pQOpen[pQSize] = spawnstruct();
  pQOpen[pQSize] = s; //push s on Open
  pQSize++;
  //while Open is not empty  
  while(!PQIsEmpty(pQOpen, pQSize))
  {
    level.waypointLoops++;
    //pop node n from Open  // n has the lowest f
    n = pQOpen[0];
    highestPriority = 9999999999;
    bestNode = -1;
    for(i = 0; i < pQSize; i++)
    {
	  level.waypointLoops++;
      if(pQOpen[i].f < highestPriority)
      {
        bestNode = i;
        highestPriority = pQOpen[i].f;
      }
    } 
    
    if(bestNode != -1)
    {
      n = pQOpen[bestNode];
      //remove node from queue    
      for(i = bestNode; i < pQSize-1; i++)
      {
        pQOpen[i] = pQOpen[i+1];
      }
      pQSize--;
    }
    else
    {
      return -1;
    }
    
    //if n is a goal node; construct path, return success
    if(n.wpIdx == goalWp)
    {
     
      x = n;
      for(z = 0; z < 1000; z++)
      {
	    level.waypointLoops++;
        parent = x.parent;
        if(parent.parent.wpIdx == -1)
        {
          return x.wpIdx;
        }
//        line(level.Wp[x.wpIdx].origin, level.Wp[parent.wpIdx].origin, (0,1,0));
        x = parent;
      }

      return -1;      
    }

    //for each successor nc of n
    for(i = 0; i < level.Wp[n.wpIdx].linkedCount; i++)
    {
	  level.waypointLoops++;
      //newg = n.g + cost(n,nc)
      newg = n.g + distance(level.Wp[n.wpIdx].origin, level.Wp[level.Wp[n.wpIdx].linked[i].ID].origin);
      
      //if nc is in Open or Closed, and nc.g <= newg then skip
      if(PQExists(pQOpen, level.Wp[n.wpIdx].linked[i].ID, pQSize))
      {
        //find nc in open
        nc = spawnstruct();
        for(p = 0; p < pQSize; p++)
        {
		  level.waypointLoops++;
          if(pQOpen[p].wpIdx == level.Wp[n.wpIdx].linked[i].ID)
          {
            nc = pQOpen[p];
            break;
          }
        }
       
        if(nc.g <= newg)
        {
          continue;
        }
      }
      else
      if(ListExists(closedList, level.Wp[n.wpIdx].linked[i].ID, listSize))
      {
        //find nc in closed list
        nc = spawnstruct();
        for(p = 0; p < listSize; p++)
        {
		  level.waypointLoops++;
          if(closedList[p].wpIdx == level.Wp[n.wpIdx].linked[i].ID)
          {
            nc = closedList[p];
            break;
          }
        }
        
        if(nc.g <= newg)
        {
          continue;
        }
      }
      
//      nc.parent = n
//      nc.g = newg
//      nc.h = GoalDistEstimate( nc )
//      nc.f = nc.g + nc.h
      
      nc = spawnstruct();
      nc.parent = spawnstruct();
      nc.parent = n;
      nc.g = newg;
      nc.h = distance(level.Wp[level.Wp[n.wpIdx].linked[i].ID].origin, level.Wp[goalWp].origin);
	    nc.f = nc.g + nc.h;
	    nc.wpIdx = level.Wp[n.wpIdx].linked[i].ID;

      //if nc is in Closed,
	    if(ListExists(closedList, nc.wpIdx, listSize))
	    {
	      //remove it from Closed
        deleted = false;
        for(p = 0; p < listSize; p++)
        {
		  level.waypointLoops++;
          if(closedList[p].wpIdx == nc.wpIdx)
          {
            for(x = p; x < listSize-1; x++)
            {
			  level.waypointLoops++;
              closedList[x] = closedList[x+1];
            }
            deleted = true;
            break;
          }
          if(deleted)
          {
            break;
          }
        }
	      listSize--;
	    }
	    
	    //if nc is not yet in Open, 
	    if(!PQExists(pQOpen, nc.wpIdx, pQSize))
	    {
	      //push nc on Open
        pQOpen[pQSize] = spawnstruct();
        pQOpen[pQSize] = nc;
        pQSize++;
	    }
	  }
	  
	  //Done with children, push n onto Closed
	  if(!ListExists(closedList, n.wpIdx, listSize))
	  {
      closedList[listSize] = spawnstruct();
      closedList[listSize] = n;
	    listSize++;
	  }
  }
}



////////////////////////////////////////////////////////////
// PQIsEmpty, returns true if empty
////////////////////////////////////////////////////////////
PQIsEmpty(Q, QSize)
{
  if(QSize <= 0)
  {
    return true;
  }
  
  return false;
}


////////////////////////////////////////////////////////////
// returns true if n exists in the pQ
////////////////////////////////////////////////////////////
PQExists(Q, n, QSize)
{
  for(i = 0; i < QSize; i++)
  {
    level.waypointLoops++;
    if(Q[i].wpIdx == n)
    {
      return true;
    }
  }
  
  return false;
}

////////////////////////////////////////////////////////////
// returns true if n exists in the list
////////////////////////////////////////////////////////////
ListExists(list, n, listSize)
{
  for(i = 0; i < listSize; i++)
  {
    level.waypointLoops++;
    if(list[i].wpIdx == n)
    {
      return true;
    }
  }
  
  return false;
}

// DEBUG AND TOOLS


drawWP()
{
	for (;;)
	{
		for (i=0; i<level.WpCount; i++)
		{
				wp = level.Wp[i];
				lineCol = (0,1,0);
				line(wp.origin, wp.origin + (0,0,96), lineCol);
				lineCol = (0,0,1);
				for (ii=0; ii<wp.linkedCount; ii++)
				line(wp.origin, wp.linked[ii].origin, lineCol);
		}

		wait .01;
	}
}

