state("BioshockInfinite")
{
	float isMapLoading  : 0x14154E8, 0x4;
	int   overlaysPtr   : 0x1415A30, 0x124;
	int   overlaysCount : 0x1415A30, 0x128;
	byte  afterLogo     : 0x135697C;
	long  area          : 0x1423D18, 0x124, 0x1A4;
}

state("BioshockInfinite", "Steam Current Patch")
{
	float isMapLoading  : 0x0FEC7C8, 0x4;
	int   overlaysPtr   : 0x0FED290, 0x124;
	int   overlaysCount : 0x0FED290, 0x128;
	byte  afterLogo     : 0x0F30854;
	long  area          : 0x1007160, 0x124, 0x1A4;
}

start{return current.area == 17179869188 && current.afterLogo == 1 && old.afterLogo == 0;}

isLoading
{
	//This is the variable used to track when map data is being loaded.
	//This includes load screens and OOB load zones.
	//Note, this doesn't include the load screen transition time.
	//We have to look for the overlay otherwise the timer will be delayed when starting/stoppping.
	if (current.isMapLoading != -1)
		return true;
	
	var count = current.overlaysCount;
	if (count < 0 || count > 8)
		return false;
	
	//Look for the load screen overlay.
	for(var i = 0; i < count; i++) {    
		var overlayPtr = memory.ReadValue<int>(new IntPtr(current.overlaysPtr+(i*4)));
		
		var namePtr = memory.ReadValue<int>(new IntPtr(overlayPtr));
		var nameLen = memory.ReadValue<int>(new IntPtr(overlayPtr + 0x4)) - 1;
		
		if (nameLen != 0x36)
			continue;            
		
		var name = memory.ReadString(new IntPtr(namePtr), nameLen*2);
		if (name == "GFXScriptReferenced.GameThreadLoadingScreen_Data_Oct22")
			return true;
	}
	return false;
}

init
{
	if(modules.First().ModuleMemorySize == 19197952)
		version = "Steam Current Patch";
	
	timer.IsGameTimePaused=false;
}

reset{return current.area == 17179869188 && current.afterLogo == 0 && old.afterLogo == 1;}

exit{timer.IsGameTimePaused=true;}
