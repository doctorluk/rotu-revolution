<?php
/*
	ADD THIS TO YOUR config.cfg:
[rotustats]
mysqlserver = mysqlserver
mysqluser = mysqluser
mysqlpassword = mysqlpassword
mysqldatabase = mysqldatabase
*/

$rotustats = new rotustats();

$GLOBALS["mod"]->registerEvent("logAction", "processRotustats");


class rotustats {
	public function __construct() {
		$this->rotustats_id = -1;
	}
	
	public function getID(){
		return $this->rotustats_id;
	}
	
	public function setID($id){
		$this->rotustats_id = $id;
	}
}


function processRotustats($line) {
	global $rotustats;
	
	$lineTokens = explode(";", $line["line"]);

	if( 	$lineTokens[0] == "ROTU_STATS_GAME" 	)
		writeRotuStatsGame($lineTokens);
	elseif( $lineTokens[0] == "ROTU_STATS_PLAYER" 	)
		writeRotuStatsPlayer($lineTokens);
	elseif( $lineTokens[0] == "ROTU_STATS_DONE" 	)
		$rotustats->setID(-1);
}

function writeRotuStatsGame($lineTokens){
	global $rotustats;
	global $mod;
	
	$server = $mod->getCV("rotustats", "mysqlserver");
	$user = $mod->getCV("rotustats", "mysqluser");
	$password = $mod->getCV("rotustats", "mysqlpassword");
	$database = $mod->getCV("rotustats", "mysqldatabase");
	
	$ip = $mod->getCV("main", "ip");
	$port = $mod->getCV("main", "port");
	
	$con = mysql_connect($server, $user, $password);
	if(!$con){
		$GLOBALS["logging"]->write(MOD_ERROR, "Could not connect to the rotustats-database!");
		return;
	}
	
	mysql_select_db($database, $con);
	
	$query = "INSERT INTO rotustats_game(id, version, win, zombiesKilled, gameDuration, waveNumber, mapname, ip, port, date) VALUES(NULL, '" . 
	$lineTokens[1] 		. "','" .
	$lineTokens[2] 		. "','" .
	$lineTokens[3] 		. "','" .
	$lineTokens[4] 		. "','" .
	$lineTokens[5] 		. "','" .
	$lineTokens[6] 		. "','" .
	$ip 				. "','" .
	$port				. "','" .
	date("Y-m-d H:i:s") . "');";
	// $GLOBALS["logging"]->write(MOD_NOTICE, "writeRotuStatsGame query: $query");
	mysql_query($query, $con);
	
	// Get the ID of this submission
	$id = mysql_query("SELECT max(id) FROM rotustats_game;", $con);
	$id = mysql_fetch_row($id);
	$rotustats->setID($id[0]);
	
	mysql_close($con);
}

function writeRotuStatsPlayer($lineTokens){
	global $rotustats;
	global $mod;
	
	$server = $mod->getCV("rotustats", "mysqlserver");
	$user = $mod->getCV("rotustats", "mysqluser");
	$password = $mod->getCV("rotustats", "mysqlpassword");
	$database = $mod->getCV("rotustats", "mysqldatabase");

	if( $rotustats->getID() == -1 ){
		$GLOBALS["logging"]->write(MOD_NOTICE, "The ID of the recent rotustats_game is INVALID, we can't collect any player stats! Is the table filled with at least one result?");
		return;
	}
	
	$con = mysql_connect($server, $user, $password);
	if(!$con){
		// $GLOBALS["logging"]->write(MOD_ERROR, "Could not connect to the rotustats-database!");
		return;
	}
	
	mysql_select_db($database, $con);
	
	$query = "INSERT INTO rotustats_player(id, guid, name, role, kills, assists, deaths, downtime, healsGiven, ammoGiven, damageDealt, damageDealtToBoss, turretKills, upgradepoints, upgradepointsspent, explosiveKills, knifeKills, timesZombie, ignitions, poisons, headshotKills, barriersRestored) VALUES('" . $rotustats->getID() . "'";
	for( $i = 1; $i < count($lineTokens); $i++ )
		$query .= ( ", '" . mysql_real_escape_string($lineTokens[$i]) . "'" );
	$query .= ");";
	// $GLOBALS["logging"]->write(MOD_NOTICE, "writeRotuStatsPlayer query: $query");
	
	mysql_query($query, $con);
	
	mysql_close($con);
}
?>