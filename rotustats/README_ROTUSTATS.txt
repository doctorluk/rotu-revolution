//
// ########   #######  ######## ##     ##          ######  ########    ###    ########  ######  
// ##     ## ##     ##    ##    ##     ##         ##    ##    ##      ## ##      ##    ##    ## 
// ##     ## ##     ##    ##    ##     ##         ##          ##     ##   ##     ##    ##       
// ########  ##     ##    ##    ##     ## #######  ######     ##    ##     ##    ##     ######  
// ##   ##   ##     ##    ##    ##     ##               ##    ##    #########    ##          ## 
// ##    ##  ##     ##    ##    ##     ##         ##    ##    ##    ##     ##    ##    ##    ## 
// ##     ##  #######     ##     #######           ######     ##    ##     ##    ##     ###### 

//										//
//			WHAT IS IT?!?!				//
//										//
RotU-Stats is a way of logging all your player's stats after a game to a MySQL database!
You can then use the database data to make yourself some nice statistics, graphs, or just get an eye of how much interaction your players create during a game!


//										//
//			Requirements				//
//										//
- MySQL server, preferrably on the same host as the RotU-R server.
- MySQL database
- MySQL user and his password
- Permission to modify the database
- Manu Admin Mod
- RotU-Revolution 0.6 alpha or higher


//										//
//			Installation				//
//		(MANU 	ADMIN 	MOD)			//
//										//
- Import the rotustats.sql file via phpmyadmin or manually per SSH. MAKE SURE YOU HAVE SELECTED A DATABASE!
- Copy the manuadminmod/plugins/rotustats.php into your adminmod/plugins folder (and NOT into adminmod/config/plugins)
- Put this into your config.cfg and replace everything in "" with correct values:

[rotustats]
mysqlserver 	= "localhost"
mysqluser 		= "rotustats"
mysqlpassword 	= "mysqlpassword"
mysqldatabase 	= "db_rotustats"

If your Manu Admin Mod was running, make sure to restart it!


//										//
//			Installation				//
//		(BIG 	BROTHER 	BOT)		//
//				(B3)					//
//										//
- Read the README.txt in the b3 folder!