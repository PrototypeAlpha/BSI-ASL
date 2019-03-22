state("BioshockInfinite")
{
    float isMapLoading :    0x14154E8, 0x4;
    int overlaysPtr :       0x1415A30, 0x124;
    int overlaysCount :     0x1415A30, 0x128;
	int loadingScreen :		0x137CF94, 0x3BC, 0x19C;
}

start
{
    return current.loadingScreen == 0 && (old.loadingScreen == 22 || old.loadingScreen == 27);
}

isLoading
{
    /*
	This is the variable used to track when map data is being loaded.
    This includes load screens and OOB load zones.
    Note, this doesn't include the load screen transition time.
    We have to look for the overlay otherwise the timer will be delayed when starting/stoppping.
	*/
    if (current.isMapLoading != -1 ||  current.loadingScreen > 0)
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
    timer.IsGameTimePaused = false;
}

exit
{
    timer.IsGameTimePaused = true;
}
