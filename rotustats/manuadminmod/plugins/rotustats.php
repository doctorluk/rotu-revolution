<?php
/*
Author: Luk
Date: 19.10.2014
Used for: Reign of the Undead - Revolution, a Call of Duty 4: Modern Warfare mod

Requirements: RotU-Revolution 0.6 or higher, MySQL access and database, manuadminmod 0.12 beta (other version are untested)

Feel absolutely free to modify this file to your liking!

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
		global $mod;
		
		$this->rotustats_id = -1;
		$this->server = $mod->getCV("rotustats", "mysqlserver");
		$this->user = $mod->getCV("rotustats", "mysqluser");
		$this->password = $mod->getCV("rotustats", "mysqlpassword");
		$this->database = $mod->getCV("rotustats", "mysqldatabase");
	}
	
	public function getID(){
		return $this->rotustats_id;
	}
	
	public function setID($id){
		$this->rotustats_id = $id;
	}
	
	public function startConnection(){
		$GLOBALS["logging"]->write(MOD_NOTICE, "RotU-STATS: Establishing MySQL connection.");
		$this->mysql_con = mysql_connect($this->server, $this->user, $this->password);
		if(!$this->mysql_con){
			$GLOBALS["logging"]->write(MOD_WARNING, "RotU-STATS: Could not connect to the rotustats-database!");
			return;
		}
		mysql_select_db($this->database, $this->mysql_con);
	}
	
	public function closeConnection(){
		if(!$this->mysql_con){
			return;
		}
		$GLOBALS["logging"]->write(MOD_NOTICE, "RotU-STATS: Closing MySQL connection.");
		mysql_close($this->mysql_con);
	}
}


function processRotustats($line) {
	global $rotustats;
	
	$lineTokens = explode(";", $line["line"]);

	if( 	$lineTokens[0] == "ROTU_STATS_GAME" 	){
		$rotustats->startConnection();
		writeRotuStatsGame($lineTokens, $rotustats->mysql_con);
	}
	elseif( $lineTokens[0] == "ROTU_STATS_PLAYER" 	)
		writeRotuStatsPlayer($lineTokens, $rotustats->mysql_con);
	elseif( $lineTokens[0] == "ROTU_STATS_DONE" 	){
		$rotustats->closeConnection();
		$rotustats->setID(-1);
	}
}

function writeRotuStatsGame($lineTokens, $con){
	global $rotustats;
	global $mod;
	
	if( !$con )
		return;
	
	$ip = $mod->getCV("main", "ip");
	$port = $mod->getCV("main", "port");
	
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
	mysql_query($query, $con);
	
	// Get the ID of this submission
	$id = mysql_query("SELECT max(id) FROM rotustats_game;", $con);
	$id = mysql_fetch_row($id);
	$rotustats->setID($id[0]);
}

function writeRotuStatsPlayer($lineTokens, $con){
	global $rotustats;
	global $mod;
	
	if( !$con )
		return;

	if( $rotustats->getID() == -1 ){
		$GLOBALS["logging"]->write(MOD_NOTICE, "The ID of the recent rotustats_game is INVALID, we can't collect any player stats! Is the table filled with at least one result?");
		return;
	}
	
	$query = "INSERT INTO rotustats_player(id, guid, name, role, kills, assists, deaths, downtime, revives, healsGiven, ammoGiven, damageDealt, damageDealtToBoss, turretKills, upgradepoints, upgradepointsspent, explosiveKills, knifeKills, timesZombie, ignitions, poisons, headshotKills, barriersRestored) VALUES('" . $rotustats->getID() . "'";
	for( $i = 1; $i < count($lineTokens); $i++ )
		$query .= ( ", '" . mysql_real_escape_string($lineTokens[$i]) . "'" );
		
	$query .= ");";
	
	mysql_query($query, $con);
}
?>