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

/* Returns a String containing the origin and angle-orientation
that should be applied to all players when the game ends
to give a further overview of the battle and the "madness" :P
You can add your own map by executing /rcon getendview <your_player_id>
It will display a line of coordinates that is looking exacly like those below
your line has to look like:
case "YOUR_MAP_NAME":
	return "THE_COORDINATES_FROM_RCON";
and do NOT put them AFTER "default:", otherwise they will not be recognized
*/ 
getSpectateCoords(){
	switch(getdvar("mapname")){
		case "mp_fnrp_cube":
			return "739,-990,1999;46,124,0";
		case "mp_surv_village":
			return "-901,1201,430;33,-48,0";
		case "mp_fnrp_mountains":
			return "1121,-798,596;28,-131,0";
		case "mp_surv_trap":
			return "704,-681,154;13,135,0";
		case "mp_surv_pacman":
			return "-349,367,47;29,-45,0";
		case "mp_bsf_tunnel_v2":
			return "-224,-19,341;29,52,0";
		case "mp_fnrp_hl":
			return "17,487,79;11,-28,0";
		case "mp_fnrp_beach":
			return "595,-2037,309;19,-127,0";
		case "mp_fnrp_simpsons":
			return "-1163,974,599;27,0,0";
		case "mp_fnrp_snow":
			return "-612,1719,575;31,-61,0";
		case "mp_fnrp_treehouse":
			return "2668,-1417,1187;14,137,0";
		case "mp_fnrp_secret_base":
			return "1145,-543,-54;0,120,0";
		case "mp_fnrp_futurama_v3":
			return "-1828,3333,145;1,-53,0";
		case "mp_fnrp_circus":
			return "2623,-1352,296;11,-148,0";
		case "mp_fnrp_market":
			return "847,-1919,160;10,58,0";
		case "mp_surv_skatepark":
			return "1714,-1713,91;16,133,0";
		case "mp_surv_new_moon_lg":
			return "-2685,1733,361;4,-28,0";
		case "mp_fnrp_re4village_v2":
			return "-285,1120,88;3,-74,0";
		case "mp_fnrp_auto_cinema":
			return "-1692,1706,168;4,-54,0";
		case "mp_surv_ffc_arena":
			return "-507,1660,240;12,-66,0";
		case "mp_surv_seatown":
			return "1203,756,654;35,-139,0";
		case "mp_surv_dead_night":
			return "27,-1710,254;8,101,0";
		case "mp_surv_snow_haven":
			return "1362,671,269;2,-149,0";
		case "mp_surv_fregata":
			return "1883,-2431,224;2,142,0";
		case "mp_fnrp_piramides":
			return "-856,1624,138;1,-68,0";
		case "mp_fnrp_bridge":
			return "1225,-502,37;8,10,0";
		case "mp_fnrp_dock":
			return "156,1308,205;0,-132,0";
		case "mp_surv_graveyard":
			return "-1623,-523,142;5,45,0";
		case "mp_surv_gold_rush":
			return "2457,831,207;4,148,0";
		case "mp_fnrp_warehouse":
			return "1221,-335,119;6,164,0";
		case "mp_fnrp_meadow":
			return "1598,784,148;3,-167,0";
		case "mp_fnrp_soccer_match":
			return "-727,-823,99;1,49,0";
		case "mp_surv_toujane":
			return "253,1481,702;28,-103,0";
		case "mp_surv_plaza":
			return "-2092,897,154;14,-33,0";
		case "mp_surv_backlot":
			return "490,381,290;33,-147,0";
		case "mp_fnrp_quake3_arena":
			return "-744,-654,495;27,34,0";
		case "mp_surv_maniacmansion":
			return "1310,292,451;20,-171,0";
		case "mp_fnrp_smurfs":
			return "1243,-1281,342;25,121,0";
		case "mp_fnrp_gas":
			return "-1550,1014,374;20,-50,0";
		case "mp_fnrp_ancient_italy":
			return "-770,1234,398;25,-47,0";
		case "mp_surv_infection":
			return "819,-387,458;22,49,0";
		case "mp_fnrp_sewer":
			return "15,2669,102;15,-59,0";
		case "mp_fnrp_movies":
			return "-904,1189,435;11,-55,0";
		case "mp_fnrp_chocho":
			return "905,529,206;13,-145,0";
		case "mp_draw":
			return "10,1241,383;19,-49,0";
		case "mp_surv_city":
			return "-2109,-268,174;15,-37,0";
		case "mp_fnrp_mohbaazar":
			return "-600,-176,-8;11,-66,0";
		case "mp_fnrp_lighthouse":
			return "1574,-2241,407;11,29,0";
		case "mp_killhouse":
			return "1113,182,365;15,113,0";
		case "mp_fnrp_corridors":
			return "-51,371,173;19,-52,0";
			
			
		default:
			return undefined;
	}
}