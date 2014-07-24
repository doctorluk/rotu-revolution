#include scripts\include\admin;

myRanks()
{

	addRank("^3moderator", 50);
	
	addPlayer("mod", "guid1"); // replace guid
	addPlayer("mod", "guid2"); // replace guid
	
	addPlayer("admin", "guid3"); // replace guid

}

myCommands() {

	addCmd("saybold", ::saybold); // Print text on screen
//	addCmd(dvarname, ::function);
}

saybold(args) // args is an array created by tokenizing the corresponding dvar by the delimiter '&'
{
	for (i=0; i<args.size; i++)
	{
		iprintlnbold(args[i]);
		wait 1;
	}
}