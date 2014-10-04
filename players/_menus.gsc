//
// ########   #######  ######## ##     ##         ########  ######## ##     ##  #######  ##       ##     ## ######## ####  #######  ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ###   ## 
// ##     ## ##     ##    ##    ##     ##         ##     ## ##       ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ####  ## 
// ########  ##     ##    ##    ##     ## ####### ########  ######   ##     ## ##     ## ##       ##     ##    ##     ##  ##     ## ## ## ## 
// ##   ##   ##     ##    ##    ##     ##         ##   ##   ##        ##   ##  ##     ## ##       ##     ##    ##     ##  ##     ## ##  #### 
// ##    ##  ##     ##    ##    ##     ##         ##    ##  ##         ## ##   ##     ## ##       ##     ##    ##     ##  ##     ## ##   ### 
// ##     ##  #######     ##     #######          ##     ## ########    ###     #######  ########  #######     ##    ####  #######  ##    ## 
//
// Reign of the Undead - Revolution ALPHA 0.7 by Luk and 3aGl3
// Code contains parts made by Luk, Bipo, Etheross, Brax, Viking, Rycoon and Activision (no shit)
// (Please keep in mind that I'm not the best coder and some stuff might be really dirty)
// If you consider yourself more skilled at coding and would enjoy further developing this, contact me and we could improve this mod even further! (Xfire: lukluk1992 or at http://puffyforum.com)
//
// You may modify this code to your liking (since I - Luk - learned scripting the same way)
// You may also reuse code you find here, as long as you give credit to those who wrote it (5 lines above)
//
// Based on Reign of the Undead 2.1 created by Bipo and Etheross
//

#include scripts\include\data;


init()
{
	game["menu_team"] = "team_marinesopfor";
	game["menu_class_allies"] = "class_marines";
	game["menu_changeclass_allies"] = "changeclass_marines_mw";
	game["menu_changeclass_ability"] = "changeclass_ability";
	game["menu_class_axis"] = "class_opfor";
	game["menu_changeclass_axis"] = "changeclass_opfor_mw";
	game["menu_class"] = "class";
	game["menu_changeclass"] = "changeclass_mw";
	game["menu_changeclass_offline"] = "changeclass_offline";
	
	game["menu_skillpoints"] = "skillpoints";

	game["menu_callvote"] = "callvote";
	game["menu_muteplayer"] = "muteplayer";
	game["menu_playermenu"] = "playermenu";
	game["menu_mapvoting"] = "mapvoting";
	game["menu_extras"] = "extras_shop";
	game["menu_admin"] = "admin";
	game["menu_quickstatements"] = "quickstatements";
	precacheMenu(game["menu_callvote"]);
	precacheMenu(game["menu_muteplayer"]);
	precacheMenu(game["menu_playermenu"]);
	precachemenu(game["menu_skillpoints"]);
	precachemenu(game["menu_extras"]);
	precachemenu(game["menu_mapvoting"]);
	precachemenu(game["menu_admin"]);
	

	

	
	// game summary popups
	/*game["menu_eog_unlock"] = "popup_unlock";
	game["menu_eog_summary"] = "popup_summary";
	game["menu_eog_unlock_page1"] = "popup_unlock_page1";
	game["menu_eog_unlock_page2"] = "popup_unlock_page2";
	
	precacheMenu(game["menu_eog_unlock"]);
	precacheMenu(game["menu_eog_summary"]);
	precacheMenu(game["menu_eog_unlock_page1"]);
	precacheMenu(game["menu_eog_unlock_page2"]);*/
	
	
	

	precacheMenu("scoreboard");
	precacheMenu(game["menu_team"]);
	precacheMenu(game["menu_class_allies"]);
	precacheMenu(game["menu_changeclass_allies"]);
	precacheMenu(game["menu_class_axis"]);
	precacheMenu(game["menu_changeclass_axis"]);
	precacheMenu(game["menu_class"]);
	precacheMenu(game["menu_changeclass"]);
	precacheMenu(game["menu_changeclass_offline"]);
	precacheMenu(game["menu_changeclass_ability"]);
	precacheMenu(game["menu_quickstatements"]);
	precacheString( &"MP_HOST_ENDED_GAME" );
	precacheString( &"MP_HOST_ENDGAME_RESPONSE" );
	
	//MY SCRIPTMENUS
	game["menu_clientcmd"] = "clientcmd";
	precacheMenu(game["menu_clientcmd"]);
	
	//thread maps\mp\gametypes\_quickmessages::init();

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		
		player setClientDvar("ui_3dwaypointtext", "1");
		player.enable3DWaypoints = true;
		player setClientDvars("ui_deathicontext", "1", "g_scriptMainMenu", game["menu_class"] );
		player.enableDeathIcons = true;
		player.classType = undefined;
		player.selectedClass = false;
		player.antispamtime = gettime();
		player thread onMenuResponse();
	}
}

onMenuResponse()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("menuresponse", menu, response);
		
		// self iprintlnbold( self.name + " menuresponse: " + menu + " " + response );
		
		if (response == "prestige") {
			self closeMenu();
			self closeInGameMenu();
			self scripts\players\_rank::prestigeUp();
		}	
		if ( response == "back" )
		{
			self closeMenu();
			self closeInGameMenu();
			if ( menu == game["menu_changeclass_ability"] )
				self openMenu( game["menu_changeclass_allies"] );
				
			continue;
		}
		
		if( getSubStr( response, 0, 7 ) == "loadout" )
		{
			//self maps\mp\gametypes\_modwarfare::processLoadoutResponse( response );
			continue;
		}
		
		if( response == "join" )
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu(game["menu_changeclass_allies"]);
		}
		
		if( response == "gospec" )
		{
			self closeMenu();
			self closeInGameMenu();
			self scripts\players\_players::joinSpectator();
		}
		
		if( response == "removefromqueue" )
		{
			self closeMenu();
			self closeInGameMenu();
			self scripts\players\_players::removeFromQueue();
		}
	
		if( response == "changeclass_marines" )
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu( game["menu_changeclass_allies"] );
			continue;
		}

		if( response == "changeclass_opfor" )
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu( game["menu_changeclass_axis"] );
			continue;
		}
		if (response == "admin")
		{
			self closeMenu();
			self closeInGameMenu();
			//self openMenu(game["menu_eog_unlock"]);
			/*if (self.isAdmin)
			{
				self closeMenu();
				self closeInGameMenu();
				self openMenu( "bxmod_admin" );
			}
			else
			self iprintlnbold("You are not allowed to use this menu");*/
		}
				
		if( response == "endgame" )
		{
			continue;
		}
		if ( isSubStr(response, "SC_") ) // Process secondary abilities
		{
			ability = GetSubStr(response, 3);
			self thread  scripts\players\_classes::pickSecondary(ability);
		}
		if ( menu == game["menu_changeclass_ability"])
		{
			if (response == "accept")
			{
				self closeMenu();
				self closeInGameMenu();
				// self scripts\players\_players::joinAllies();
				//self openmenu(game["menu_changeweapon"]);
				
			}
			self thread scripts\players\_classes::acceptClass();
			
		}
		if ( menu == game["menu_skillpoints"]) {
			switch(response)
			{
			case "upgr_soldier":
				self scripts\players\_classes::incClassRank("soldier");
			break;

			case "upgr_stealth":
				self scripts\players\_classes::incClassRank("stealth");
			break;

			case "upgr_armored":
				self scripts\players\_classes::incClassRank("armored");
			break;
			
			case "upgr_engineer":
				self scripts\players\_classes::incClassRank("engineer");
			break;
			case "upgr_scout":
				self scripts\players\_classes::incClassRank("scout");
			break;
			case "upgr_medic":
				self scripts\players\_classes::incClassRank("medic");
			break;
			}
		}
		if ( menu == game["menu_quickstatements"]) {
			time = gettime();
			switch(response)
			{
			case "1":
				modifier = "";
				if(time - self.antispamtime < 3000)
					break;
				if(self.isDown)
					modifier = "_down";
				self sayteam("^5I need a medic!");
				self playsound("need_medic" + modifier);
				self.antispamtime = gettime();
				break;

			case "2":
				if(time - self.antispamtime < 3000)
					break;
				self sayteam("^5I need ammo!");
				self playsound("need_ammo");
				self.antispamtime = gettime();
				break;

			case "3":
				if(time - self.antispamtime < 3000)
					break;
				self sayteam("^5Thank you!");
				self playsound("thanks");
				self.antispamtime = gettime();
				break;
			}
		}
		
		if (menu == game["menu_extras"])
		{
			self closeMenu();
			self closeInGameMenu(
			scripts\players\_shop::processResponse(response));
		}

		if( menu == game["menu_team"] )
		{
			switch(response)
			{
			case "allies":
				self closeMenu();
				self closeInGameMenu();
				self scripts\players\_players::joinAllies();
				self openMenu(game["menu_changeclass_allies"]);
				break;

			case "autoassign":
				self closeMenu();
				self closeInGameMenu();
				self scripts\players\_players::joinAllies();
						self openMenu(game["menu_changeclass_allies"]);
				break;

			case "spectator":
				self closeMenu();
				self closeInGameMenu();
				self scripts\players\_players::joinSpectator();
				break;
			}
		}	// the only responses remain are change class events
		else if( menu == game["menu_changeclass_allies"]  )
		{
			self closeMenu();
			self closeInGameMenu();
			thread scripts\players\_classes::pickClass(response);
			continue;
		}
		else if( menu == game["menu_changeclass"] )
		{
			self closeMenu();
			self closeInGameMenu();

			self.selectedClass = true;
			//self maps\mp\gametypes\_modwarfare::menuAcceptClass();
		}
		else
		{
			//if(menu == game["menu_playermenu"])
			//	maps\mp\gametypes\_players::processPlayerMenu(response);
			//else if(menu == game["menu_playermenu"])
			//	zombiesurvival\_main::processPlayerMenu(response);
		}

	}
}
