state("BioshockInfinite")
{
	float 		isMapLoading 		:	0x14154E8, 0x4;
	int 		overlaysPtr 		:   0x1415A30, 0x124;
	int 		overlaysCount 		:   0x1415A30, 0x128;
	byte 		afterLogo 			:	0x135697C;
	byte		anyKey				:	0x13D2AA2;
	string64 	loadingScreenText 	:	0x137CF94, 0x3BC, 0x198, 0x0;
	byte 		collision 			:	0x13DA2DC, 0x10, 0x38, 0xA0, 0x60;
	byte 		playerState			:	0x13DA2DC, 0x10, 0x38, 0xA0, 0x84;
	float 		health				:	0x14278E8, 0x0, 0x6C, 0x25FC;
}

startup
{
	settings.Add("split1", 	true, 	"Autosplit 'Baptised'");
	settings.Add("split1.1",false, 	"Split at the door instead of the preacher","split1");
	settings.Add("split2", 	true, 	"Autosplit 'Engineering Deck'");
	settings.Add("split3", 	true, 	"Autosplit 'Final Fight'");
	settings.Add("split4", 	true, 	"Autosplit 'Smother'");
}

init
{
	var lang = "english";
	vars.langID = "int";
	var dir = modules.First().FileName;
	dir = dir.Substring(0,dir.Length-36);
	var readmeFile = Directory.GetFiles(dir, "README*");
	if(readmeFile.Length > 1){
		lang = readmeFile[1].Substring(dir.Length+8).TrimEnd(".txt".ToCharArray());
	}
	
	switch (lang)
	{
		case "english"	: 	break;
		case "german"	: 	vars.langID = "deu"; break;
		case "french"	: 	vars.langID = "fra"; break;
		case "italian"	: 	vars.langID = "ita"; break;
		case "spanish"	: 	vars.langID = "esn"; break;
		case "portguese":	vars.langID = "por"; break;
		case "polish"	: 	vars.langID = "pol"; break;
		case "japanese"	:	vars.langID = "jpn"; break;
		default			: 	vars.langID = "uns"; break;
	}
	print("[BSI-ASL] Lang: "+lang+" ("+vars.langID+")");
	vars.checkpoints = new List<string>(121);
	if(vars.langID != "uns"){
		foreach (string line in File.ReadLines(dir+"\\XGame\\Localization\\"+vars.langID+"\\Arc_XGameInfo."+vars.langID)){
			if (line.Contains("StructArray")){
				var txt = line.Split(new char[]{'"'},4)[1].Replace("\\", null);
				if(vars.langID == "jpn")
					txt = Encoding.UTF8.GetString(Encoding.Unicode.GetBytes(txt)).Trim('\0');
				
				vars.checkpoints.Add(txt);
			}
		}
	}
	else if(settings.SplitEnabled){
		MessageBox.Show("The "+lang+" language is currently not supported for automatic splitting.\n\n"+
		"To disable this message, disable the \"Split\"option in\n\"Edit Splits...\" -> \"Settings\"\n"+
		"or change your game language to English to enable automatic splitting.\n",
		"BSI ASL | LiveSplit",MessageBoxButtons.OK,MessageBoxIcon.Warning);
	}
	
    timer.IsGameTimePaused = false;
	current.cutsceneCount = 0;
	current.respawning = false;
	vars.delayedTime = null;
	
	//Prevent timer from starting automatically when opening the game
	if(timer.CurrentPhase==TimerPhase.NotRunning) Thread.Sleep(5000);
}

start
{
	
	current.cutsceneCount = 0;
	current.respawning = false;
	
	return current.anyKey != 0 && current.afterLogo == 1 && old.afterLogo == 0;
}

isLoading
{
	if(vars.langID != "uns"){
		
		if(current.loadingScreenText != null && current.loadingScreenText != old.loadingScreenText)
			print("[BSI-ASL] Loading: "+current.loadingScreenText);
	
		if(settings.SplitEnabled && timer.CurrentSplitIndex == 0){
			if(current.cutsceneCount > 0 && current.isMapLoading == -1 && old.isMapLoading != -1){
				if(old.loadingScreenText == vars.checkpoints[0]){current.cutsceneCount = 97;}
				else{current.cutsceneCount = 98;}
				print("[BSI-ASL] cutsceneCount set to "+current.cutsceneCount+", was "+old.cutsceneCount);
			}
			
		}
		
		if(settings.SplitEnabled && timer.CurrentSplitIndex == 15 && old.loadingScreenText == null &&
		(current.loadingScreenText == vars.checkpoints[35] || current.loadingScreenText == vars.checkpoints[65])){
			current.cutsceneCount = 0;
			current.respawning = false;
		}
		
		if(settings.SplitEnabled && timer.CurrentSplitIndex == 17 && old.loadingScreenText == null){
			
			if(current.cutsceneCount > 3 && old.isMapLoading != -1 && current.isMapLoading == -1){
				current.cutsceneCount = 4;
				print("[BSI-ASL] cutsceneCount set to "+current.cutsceneCount+", was "+old.cutsceneCount);
			}
			else if(current.loadingScreenText == vars.checkpoints[37]){
				current.cutsceneCount = 1;
				print("[BSI-ASL] cutsceneCount set to "+current.cutsceneCount+", was "+old.cutsceneCount);
				vars.delayedTime = null;
			}
			else if(current.loadingScreenText == vars.checkpoints[116]){
				current.cutsceneCount = 2;
				print("[BSI-ASL] cutsceneCount set to "+current.cutsceneCount+", was "+old.cutsceneCount);
				vars.delayedTime = null;
			}
			else if(current.loadingScreenText == vars.checkpoints[66]){
				timer.CurrentSplitIndex--;
				vars.delayedTime = null;
			}
		}
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
		if (name == "GFXScriptReferenced.GameThreadloadingScreenTitl_Data_Oct22")
			return true;
	}
	return false;
}

split
{
	if(vars.langID == "uns") return;
	
	switch(timer.CurrentSplitIndex)
	{
		default	: break;
		case 1	: //Comstock Center Rooftops
			return current.loadingScreenText == vars.checkpoints[2];
		case 2	: //Monument Tower
			return current.loadingScreenText == vars.checkpoints[4];
		case 3	: //Battleship Bay
			return current.loadingScreenText == vars.checkpoints[5];
		case 4	: //Soldiers Field
			return current.loadingScreenText == vars.checkpoints[6];
		case 5	: //Hall of Heroes
			return current.loadingScreenText == vars.checkpoints[109];
		case 6	: //Return to Hall of Heroes Plaza
			return current.loadingScreenText == vars.checkpoints[10];
		case 7	: //Finkton Docks
			return current.loadingScreenText == vars.checkpoints[41];
		case 8	: //Finkton Proper
			return current.loadingScreenText == vars.checkpoints[114];
		case 9	: //The Factory
			return current.loadingScreenText == vars.checkpoints[24];
		case 10	: //Emporia
			return current.loadingScreenText == vars.checkpoints[25];
		case 11	: //Downtown Emporia
			return current.loadingScreenText == vars.checkpoints[27];
		case 12	: //Comstock House
			return current.loadingScreenText == vars.checkpoints[29];
		case 13	: //The Hand Of The Prophet
			return current.loadingScreenText == vars.checkpoints[33] || (current.loadingScreenText != null && current.loadingScreenText.Length == 2);
		case 14	: //Engineering Deck
			return current.loadingScreenText == vars.checkpoints[35];
		case 0	: //Baptised
		case 15	: //Prophet's Cabin
		case 16	: //Final Fight
		case 17	: //Smother
			if( (settings["split1"] && timer.CurrentSplitIndex == 0 && current.cutsceneCount == 100 + Convert.ToInt32(settings["split1.1"]))||
				(settings["split2"] && timer.CurrentSplitIndex == 15 && current.cutsceneCount == 2)||
				(settings["split3"] && timer.CurrentSplitIndex == 16 && current.loadingScreenText == null && current.isMapLoading != -1)||
				(settings["split4"] && timer.CurrentSplitIndex == 17 && current.cutsceneCount == 16))
			{
				current.cutsceneCount = 0;
				return true;
			}
			else break;
	}
}

update
{	
	if(vars.langID != "uns" && settings.SplitEnabled){
		
		if(settings["split1"] && timer.CurrentSplitIndex == 0)
		{
			if(current.afterLogo == 0){current.cutsceneCount = 0; return;}
			
			if(current.isMapLoading == -1 && current.playerState == 0 && old.playerState > 0){
				current.cutsceneCount++;
				print("[BSI-ASL] cutsceneCount: "+current.cutsceneCount);
			}
		}
		
		if((settings["split2"] && timer.CurrentSplitIndex == 15)){
			if(current.collision == 102 && old.collision == 118){
				if(!current.respawning && current.health == 0 && current.isMapLoading == -1){
					current.respawning = true;
				}
			}
			if((current.collision == 114 && old.collision == 118) || (current.collision == 98 && old.collision == 102)){
				if(current.respawning){current.respawning = false;}
				else{current.cutsceneCount++;}
			}
		}
		
		if(settings["split4"] && timer.CurrentSplitIndex == 17 && current.loadingScreenText == null)
		{
			if(current.cutsceneCount == 10 && vars.delayedTime != null && timer.CurrentTime.RealTime.GetValueOrDefault() < vars.delayedTime){
				print("[BSI-ASL] cutsceneCount check delayed");
				return;
			}
			
			if(current.isMapLoading == -1 && current.playerState == 0 && old.playerState > 0){
				current.cutsceneCount++;
				print("[BSI-ASL] cutsceneCount: "+current.cutsceneCount);
				
				if(current.cutsceneCount == 10 && vars.delayedTime == null)
					vars.delayedTime = timer.CurrentTime.RealTime.GetValueOrDefault()+TimeSpan.FromSeconds(5);
			}
			
			if(current.cutsceneCount == 11 && vars.delayedTime != null){
					vars.delayedTime = null;
			}
		}
	}
}
reset
{
	if(vars.langID == "uns") return current.afterLogo == 0 && old.afterLogo == 1;
	return current.loadingScreenText == vars.checkpoints[38] && old.loadingScreenText == null;
}
exit{timer.IsGameTimePaused=true;}
