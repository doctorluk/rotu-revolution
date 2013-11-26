#include scripts\include\strings;

init(){
	thread onPlayerConnect();
}

onPlayerConnect(){
	level waittill("connected", player);
	player thread check();
}

check(){
	self thread CheckValidGuid();
	self thread watchName();
}

CheckValidGuid(){
	self endon( "disconnect" );
	lpGuidChar = "";
	lpGuid = self getGuid();
	while(1){
		lpGuid = self getGuid();
		for(i = 0; i < 32; i++){
			lpGuidChar = GetSubStr(lpGuid, i, i+1);
			
			if( lpGuid == "" || !isHexadecimal(lpGuidChar) || lpGuidChar == "" || lpGuidChar == " " )
				Kick(self getEntityNumber());
			
			
			wait 0.1;
		}
		wait 5;
	}
}

watchName(){
	self endon("disconnect");
	violations = 0;
	while(1){
		lpName = self.name;
		lpNameChars = GetSubStr(lpName, 0, 3);
		lpNameCharsLower = toLower(lpNameChars);
		if(lpNameCharsLower == "bot"){
			self iprintlnbold("^1Warning: bot is not allowed as name/prefix!");
			violations++;
		}
		else{
			if(violations > 0)
				violations--;
		}
		
		if(violations >= 10)
			Kick(self getEntityNumber());
		wait 2;
	}
}