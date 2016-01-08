// Just forwarding to the other gametype works pretty well
main()
{
	setDvar( "g_gametype", "surv" );
	maps\mp\gametypes\surv::main();
}
