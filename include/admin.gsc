addRank(title, power)
{
	scripts\server\_ranks::addRank(title, power);
}

addPlayer(rank, guid)
{
	scripts\server\_ranks::addGuid(rank, guid);
}

addCmd(name, script)
{
	scripts\server\_admin::addCmd(name, script);
}