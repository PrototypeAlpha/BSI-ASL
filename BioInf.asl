state("BioshockInfinite")
{
    float isMapLoading :    0x14154E8, 0x4;
    int overlaysPtr : 		0x1415A30, 0x124;
    int overlaysCount :     0x1415A30, 0x128;
    int afterLogo :         0x135697C;
	int loadingScreen :		0x137CF94, 0x3BC, 0x19C;
	byte collision : 		0x013DA2DC, 0x10, 0x38, 0xa0, 0x60;
}

start
{
	current.cutsceneCount = 0;
	current.lighthouseGlitch = false;
    return current.afterLogo == 1 && old.afterLogo == 0;
}

isLoading
{
	if(current.loadingScreen != old.loadingScreen && current.loadingScreen != 0)
		print("[BSI-ASL] Loading Screen ID: "+current.loadingScreen.ToString());
	
	if(settings.SplitEnabled && settings["enable"] && timer.CurrentSplitIndex == 0 && current.cutsceneCount > 8 && current.isMapLoading == -1 && old.isMapLoading > 0.000000000)
		current.cutsceneCount = 8;
	
	if(settings.SplitEnabled && settings["enable"] && timer.CurrentSplitIndex == 0 && current.loadingScreen == 14)
		current.cutsceneCount = 4;
	
	if(settings.SplitEnabled && settings["enable"] && timer.CurrentSplitIndex == 0 && current.loadingScreen == 15)
		current.cutsceneCount = 8;
	
	if(settings.SplitEnabled && settings["enable"] && timer.CurrentSplitIndex == 17 && current.loadingScreen == 27)
	{
		current.cutsceneCount = 2;
		if(current.cutsceneCount != old.cutsceneCount)
			print("[BSI-ASL] Cutscene count: "+current.cutsceneCount.ToString());
	}
	
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

split
{
	if(settings["enable"])
	{
		//Baptised
		if(settings["split1"] && timer.CurrentSplitIndex == 0 && current.cutsceneCount == 10)
		{
			current.cutsceneCount = 0;
			return true;
		}
		//Welcome to Columbia
		if(timer.CurrentSplitIndex == 1 && current.loadingScreen == 25)
		{
			return true;
		}
		//Order of the Raven
		if(timer.CurrentSplitIndex == 2 && current.loadingScreen == 15)
		{
			return true;
		}
		//Monument Island
		if(timer.CurrentSplitIndex == 3 && current.loadingScreen == 15)
		{
			return true;
		}
		//Battleship Bay
		if(timer.CurrentSplitIndex == 4 && current.loadingScreen == 9)
		{
			return true;
		}
		//Soldiers Field
		if(timer.CurrentSplitIndex == 5 && current.loadingScreen == 15)
		{
			return true;
		}
		//Hall of Heroes
		if(timer.CurrentSplitIndex == 6 && current.loadingScreen == 31)
		{
			return true;
		}
		//Return to Soldiers Field
		if(timer.CurrentSplitIndex == 7 && current.loadingScreen == 14)
		{
			return true;
		}
		//Finkton Docks
		if(timer.CurrentSplitIndex == 8 && current.loadingScreen == 15)
		{
			return true;
		}
		//Finkton Proper
		if(timer.CurrentSplitIndex == 9 && current.loadingScreen == 12)
		{
			return true;
		}
		//The Factory
		if(timer.CurrentSplitIndex == 10 && current.loadingScreen == 8)
		{
			return true;
		}
		//Emporia
		if(timer.CurrentSplitIndex == 11 && current.loadingScreen == 17)
		{
			return true;
		}
		//Downtown Emporia
		if(timer.CurrentSplitIndex == 12 && current.loadingScreen == 15)
		{
			return true;
		}
		//Comstock House
		if(timer.CurrentSplitIndex == 13 && current.loadingScreen == 24)
		{
			return true;
		}
		//The Hand of the Prophet
		if(timer.CurrentSplitIndex == 14 && current.loadingScreen == 17)
		{
			return true;
		}
		//Engineering Deck
		if(settings["split2"] && timer.CurrentSplitIndex == 15 && current.cutsceneCount == 3)
		{
			current.cutsceneCount = 0;
			return true;
		}
		//Final Fight
		if(settings["split3"] && timer.CurrentSplitIndex == 16 && current.cutsceneCount == 2)
		{
			current.cutsceneCount = 0;
			return true;
		}
		//Smother
		if(settings["split4"] && timer.CurrentSplitIndex == 17 && current.cutsceneCount == 18)
		{
			current.cutsceneCount = 0;
			return true;
		}
	}
}

startup
{
	settings.Add("enable", false, "Enable Autosplitting (WIP)");
	settings.Add("split1", true, "Autosplit 'Baptised'", "enable");
	settings.Add("split2", false, "Autosplit 'Engineering Deck'", "enable");
	settings.Add("split3", false, "Autosplit 'Final Fight'", "enable");
	settings.Add("split4", true, "Autosplit 'Smother'", "enable");
}

update
{
	if(((settings["split1"] && timer.CurrentSplitIndex == 0) || (settings["split2"] && timer.CurrentSplitIndex == 15) || (settings["split3"] && timer.CurrentSplitIndex == 16) || (settings["split4"] && timer.CurrentSplitIndex == 17)) && settings.SplitEnabled && settings["enable"]){
		
		if(timer.CurrentSplitIndex == 0 && current.afterLogo == 0)
			current.cutsceneCount = 0;
		
		if(timer.CurrentSplitIndex == 17 && current.cutsceneCount == 5 && current.isMapLoading == -1 && old.isMapLoading > 0.000000000 && !current.lighthouseGlitch)
		{
			print("[BSI-ASL] Lighthouse glitch detected");
			current.lighthouseGlitch = true;
			current.cutsceneCount = 4;
		}
		
		if((current.collision == 114 || current.collision == 98) && (old.collision == 118 || old.collision == 102)){
			current.cutsceneCount++;
			print("[BSI-ASL] Cutscene count: "+current.cutsceneCount.ToString());
		}
	}
}

init
{
    timer.IsGameTimePaused = false;
	current.cutsceneCount = 0;
	current.lighthouseGlitch = false;
}

exit
{
    timer.IsGameTimePaused = true;
}
