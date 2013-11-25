init(){
	thread onPlayerConnect();
}

onPlayerConnect(){
	level waittill("connected", player);
	iprintlnbold("Connecting " + player.name);
}