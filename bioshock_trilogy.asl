state("bioshock")
{
    int isLoading : 0x8D666C;
}

state("Bioshock2")
{
    bool isSaving : 0xF42EE8;
    bool isLoading : 0x10B8010, 0x278;
}

state("BioshockInfinite")
{
    float isMapLoading :    0x14154E8, 0x4;
    int overlaysPtr :       0x1415A30, 0x124;
    int overlaysCount :     0x1415A30, 0x128;
    int afterLogo :         0x135697C;
}

isLoading
{
    if (timer.CurrentSplit.Name.ToLower().Contains("setup")) {
        return true;
    } else if (game.ProcessName.ToLower() == "bioshock") {
        return current.isLoading != 0;
    } else if (game.ProcessName.ToLower() == "bioshock2") {
        return current.isSaving || current.isLoading;
    } else {
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
}

exit
{
    timer.IsGameTimePaused = true;
}
