state("BioshockInfinite")
{
    float isMapLoading :    0x14154E8, 0x4;
    int overlaysPtr :       0x1415A30, 0x124;
    int overlaysCount :     0x1415A30, 0x128;
	int loadingScreen :		0x137CF94, 0x3BC, 0x19C;
	byte collision :		0x013DA2DC, 0x10, 0x38, 0xa0, 0x60;
}

start
{
	current.cutsceneCount = 0;
    return current.loadingScreen == 0 && (old.loadingScreen == 22 || old.loadingScreen == 27);
}

isLoading
{
	if(settings.SplitEnabled && timer.CurrentSplitIndex == 2 && current.loadingScreen == 20)
		current.cutsceneCount = 0;
	
	if(settings.SplitEnabled && timer.CurrentSplitIndex == 4 && current.loadingScreen == 29)
		current.cutsceneCount = 4;
	
    /*
	This is the variable used to track when map data is being loaded.
    This includes load screens and OOB load zones.
    Note, this doesn't include the load screen transition time.
    We have to look for the overlay otherwise the timer will be delayed when starting/stoppping.
	*/
    if (current.isMapLoading != -1 ||  current.loadingScreen > 0 || timer.CurrentSplit.Name.ToLower().Contains("setup"))
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

split
{
	// Burial at Sea Ep1
	if(vars.bas == 1 || vars.bas == 3){
		// 1st time Cohen's door
		if(timer.CurrentSplitIndex == 0 && current.cutsceneCount == 6)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// 2nd time Cohen's door
		if(timer.CurrentSplitIndex == 1 && current.cutsceneCount == 5)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// Fontaine's Station Elevator
		if(timer.CurrentSplitIndex == 2 && current.cutsceneCount == 7)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// Tram to Housewares
		if(timer.CurrentSplitIndex == 3 && current.cutsceneCount == 1)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// 1st/2nd Vent
		if(vars.addSplits > 0 && (timer.CurrentSplitIndex == 4 || timer.CurrentSplitIndex == 5) && current.cutsceneCount == 1)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// 3rd Vent
		if(vars.addSplits > 0 && timer.CurrentSplitIndex == 6 && current.cutsceneCount == 2)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// 4th Vent
		if(vars.addSplits > 0 && timer.CurrentSplitIndex == 7 && current.cutsceneCount == 1)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// 5th Vent
		if(vars.addSplits > 0 && timer.CurrentSplitIndex == 8 && current.cutsceneCount == 1)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// Final Fight start
		if(timer.CurrentSplitIndex == (4 + vars.addSplits) && current.cutsceneCount == 3)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// Run End
		if(timer.CurrentSplitIndex == 10 && current.cutsceneCount == 1)
		{
			current.cutsceneCount = 0;
			return true;
		}
	}
	// Burial at Sea Ep1&2
	if(vars.bas == 3 && timer.CurrentSplit.Name.ToLower().Contains("setup") && current.loadingScreen == 0 && old.loadingScreen == 27)
	{
		current.cutsceneCount = 0;
		return true;
	}
	// Burial at Sea Ep2
	if(vars.bas == 2){
		// Sally door Cutscene
		if(timer.CurrentSplitIndex == 0 && current.cutsceneCount == 3)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// Toy Department Exit Cutscene
		if(timer.CurrentSplitIndex == 1 && (current.collision == 98 && old.collision == 118))
		{
			current.cutsceneCount = 0;
			return true;
		}
		// Lutece Device
		if(timer.CurrentSplitIndex == 2 && current.cutsceneCount == 4)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// Columbia
		if(timer.CurrentSplitIndex == 3 && current.loadingScreen == 9 && old.loadingScreen == 0)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// Hair Sample
		if(timer.CurrentSplitIndex == 4 && current.cutsceneCount == 12)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// Return to Rapture
		if(timer.CurrentSplitIndex == 5 && current.loadingScreen == 17 && old.loadingScreen == 0)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// The Room
		if(timer.CurrentSplitIndex == 6 && current.loadingScreen == 9 && old.loadingScreen == 0)
		{
			current.cutsceneCount = 0;
			return true;
		}
		// Run End
		if(timer.CurrentSplitIndex == 7 && current.cutsceneCount == 2)
		{
			current.cutsceneCount = 0;
			return true;
		}
	}
}

update
{
	// Check if timer is running, autosplitting is enabled, and split isn't a setup one
	if(timer.CurrentSplitIndex != -1 && settings.SplitEnabled && !timer.CurrentSplit.Name.ToLower().Contains("setup")){
		print("Cutscene count: "+current.cutsceneCount.ToString());
		// Update cutsceneCount when entering a cutscene
		if((current.collision == 114 || current.collision == 98) && (old.collision == 118 || old.collision == 102)){
			current.cutsceneCount++;
		}
	}
}

init
{
    timer.IsGameTimePaused = false;
	current.cutsceneCount = 0;
}

startup
{
	// Get splits metadata
	vars.game = timer.Run.GameName.ToLower();
	vars.category = timer.Run.CategoryName.ToLower();
	vars.bas = 0;
	vars.aS = 0;
	if(vars.game.Contains("dlc")){
		if(vars.category.Split(' ')[1] == "1&2"){vars.bas = 3;}
		else{vars.bas = Convert.ToInt32(vars.category.Split(' ')[1]);}
	}
	
	// Autosplitting will only work on Any% runs
	//if(!vars.category.Contains("any%"))
	//	settings.SplitEnabled = false;
	
	// Detect extra splits to ensure correct autosplitting
	if(vars.bas == 0 && timer.Run.Count == 19){vars.aS = 1;}
	else if(vars.bas == 1 && timer.Run.Count == 11){vars.aS = 5;}
	else if(vars.bas == 3 && timer.Run.Count == 13){vars.aS = 1;}
	else if(vars.bas == 3 && timer.Run.Count == 19){vars.aS = 6;}
	
	// Print list of splits to console
	/*var i = 0;
	var printSplits = "\n";
	while(timer.Run.Count > i){
		printSplits += i + " " + timer.Run[i].Name + "\n";
		i++;
	}
	print(printSplits);*/
	
	print(vars.game + "\n" + vars.category + "\n" + vars.bas);
}

exit
{
    timer.IsGameTimePaused = true;
}
