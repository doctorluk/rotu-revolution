/**
* vim: set ft=cpp:
* file: scripts\players\_playermodels.gsc
*
* authors: Luk, 3aGl3, Bipo, Etheross
* team: SOG Modding
*
* project: RotU - Revolution
* website: http://survival-and-obliteration.com/
*
* Reign of the Undead - Revolution by Luk and 3aGl3
* You may modify this code to your liking or reuse it, as long as you give credit to those who wrote it
* Based on Reign of the Undead 2.1 created by Bipo and Etheross
*/

/***
*
*	Handles loading and applying of player models.
*
*/

/**
* Precaches all player models used in the gamemode.
*/
init()
{
	precacheModel("body_mp_usmc_rifleman");
	precacheModel("body_mp_usmc_support");
	precacheModel("body_mp_usmc_woodland_sniper");
	precacheModel("body_complete_mp_spetsnaz_vlad");
	precacheModel("body_mp_sas_urban_specops");
	precacheModel("body_mp_usmc_woodland_support");
	precacheModel("body_mp_usmc_woodland_recon");
//	precacheModel("body_mp_usmc_woodland_specops");
	precacheModel("body_mp_usmc_sniper");
	
	precacheModel("head_sp_usmc_zach_zach_body_goggles");
	precacheModel("head_sp_usmc_sami_goggles_zach_body");
	precacheModel("head_mp_usmc_ghillie");
	precacheModel("head_sp_opforce_derik_body_f");
	precacheModel("head_sp_sas_woodland_mac");
//	precacheModel("head_sp_opforce_geoff_headset_body_c");
	precacheModel("head_sp_sas_woodland_peter");
	precacheModel("head_sp_sas_woodland_todd");
	precacheModel("head_sp_sas_woodland_hugh");
	precacheModel("head_sp_spetsnaz_collins_vladbody");
}	/* init */

/**
* Sets the players model, based on his class.
*
*	@param class, String name of the class
*/
setPlayerClassModel( class )
{
	self detachAll();
	self.myBody = "";
	self.myHead = "";
	
	switch( class )
	{
	case "soldier":
		// pick a random number
		rI = randomInt(2);
		switch (rI)
		{
		case 0:		// pick a body based on the number
			self.myBody = "body_mp_usmc_rifleman";
			break;
		case 1:
			self.myBody = "body_mp_usmc_support";
			
			// pick a second random number
			rII = randomInt(2);
			if( rII == 0 )		// pick a head based on the second random number
				self.myHead = "head_sp_usmc_zach_zach_body_goggles";
			else
				self.myHead = "head_sp_usmc_sami_goggles_zach_body";
			break;
		}
		break;
	case "specialist":
		rI = randomInt(2);
		switch( rI )
		{
		case 0:
			self.myBody = "body_mp_usmc_woodland_sniper";
			self.myHead = "head_mp_usmc_ghillie";
			break;
		case 1:
			self.myBody = "body_mp_usmc_woodland_recon";
			rII = randomInt(2);
			if (rII == 0)
				self.myHead = "head_sp_sas_woodland_peter";
			else
				self.myHead = "head_sp_sas_woodland_todd";
		}
		break;
	case "armored":
		rI = randomint(2);
		switch (rI)
		{
		case 0:
			self.myBody = "body_mp_usmc_woodland_support";
			self.myHead = "head_sp_sas_woodland_mac";
			break;					
		case 1:
			self.myBody = "body_mp_usmc_woodland_support";
			self.myHead = "head_sp_opforce_derik_body_f";
			break;
		}
		break;
	case "engineer":
		rI = randomint(2);
		switch (rI)
		{
		case 0:
			self.myBody = "body_mp_sas_urban_specops";
			break;
		case 1:
			self.myBody = "body_complete_mp_spetsnaz_vlad";
			break;
		}
		break;
	case "medic":
		self.myBody = "body_mp_usmc_sniper";
				
		rI = randomint(2);
		switch (rI)
		{
		case 0:
			self.myHead = "head_sp_sas_woodland_hugh";
			break;
		case 1:
			self.myHead = "head_sp_spetsnaz_collins_vladbody";
			break;
		}
		break;
	}

	// throw an error, if we have no body
	assert( self.myBody != "", "No body defined for player!" );
	
	// apply the body model to the player
	self setModel( self.myBody );
		
	// attach the head model
	if( self.myHead != "" )
		self attach(self.myHead);
}	/* setPlayerClassModel */