state("theturingtest")
{
	byte chapter:   0x2DB9060,0x110;
	short sector:   0x2DB9060,0x114;
	bool loading:   0x2DB9070,0x19;
	bool stream:    0x2D5ADB0,0x70,0x268,0x238,0x4E0,0x558;
	bool started: 0x2F5B8A0,0x6F8,0x370,0x69C;
	float xSpeed:   0x2D89400,0x0,0x3E8,0xDC;
	float ySpeed:   0x2D89400,0x0,0x3E8,0xE0;
	float zSpeed:   0x2D89400,0x0,0x3E8,0xE4;
}
startup
{
	vars.splitOnSector=false;
	vars.startOffset="-00:00:51.3200000";
	vars.printFormat="[TheTuringTestASL] {0} change: {1} -> {2}";
	settings.Add("Offset",true,"Set Start Offset to -00:51.32");
	settings.Add("Debug",false);
	vars.speedAbs=0f;
}
init
{
	version="1.3 DX11";
	var splits=timer.Run.Count;
	var message="";
	if(splits<9||splits>72||!settings.SplitEnabled){
		settings.SplitEnabled=false;
		message="Autosplitting is disabled.";
	}
	else if(splits==72){
		vars.splitOnSector=true;
		message="Will split on Sector change.";
	}
	else{message="Will split on Chapter change.";}
	
	print("[TheTuringTestASL] "+splits+" splits found. "+message);
	MessageBox.Show(splits+" splits found.\n"+
		message,"TheTuringTestASL | LiveSplit",
		MessageBoxButtons.OK,MessageBoxIcon.Information);
	
	if(settings["Offset"] && timer.Run.Offset.ToString()!=vars.startOffset){
		MessageBox.Show("Timer start offset is currently set to: "+
			timer.Run.Offset.ToString()+".\nThis will be changed to "+
			vars.startOffset+".\nThis can be disabled in the autosplitter settings window.",
			"TheTuringTestASL | LiveSplit",
			MessageBoxButtons.OK, MessageBoxIcon.Warning);
	}
	timer.IsGameTimePaused=false;
}
start
{
	if(settings["Offset"]&&timer.Run.Offset.ToString()!=vars.startOffset){
		print("[TheTuringTestASL] Run start offset was "+
			timer.Run.Offset.ToString()+", setting to "+vars.startOffset);
			timer.Run.Offset=TimeSpan.Parse(vars.startOffset);
	}
	return current.chapter==0&&current.sector==-1&&!current.loading&&old.loading;
}
update
{
	if (settings["Debug"]&&current.chapter!=old.chapter)
		print(String.Format(vars.printFormat,"Chapter",
			old.chapter,current.chapter));
	
	if(settings["Debug"]&&current.sector!=old.sector)
		print(String.Format(vars.printFormat,"Sector",
			old.sector,current.sector));
	//Speed absolute value
	if(current.stream)
		vars.speedAbs=Math.Sqrt(
			Math.Pow(current.xSpeed,2)+
			Math.Pow(current.ySpeed,2)+
			Math.Pow(current.zSpeed,2));
}
isLoading{
	//Don't pause game time while moving during streaming load
	if(current.stream&&current.loading&&vars.speedAbs!=0)
		return false;
	
	return current.loading;
}
reset{return current.chapter==0&&current.sector==-1&&current.loading;}
split
{
	if(current.started != old.started)
		print(""+current.started);
	
	if(vars.splitOnSector&&current.sector>old.sector){
		//C26 OoB
		if(old.sector==26&&current.sector>27&&current.sector<30){
			timer.CurrentSplitIndex=timer.CurrentSplitIndex+
				(current.sector-old.sector);
		}
		//D36 OoB
		else if(old.sector==36&&current.sector>37&&current.sector<40){
			timer.CurrentSplitIndex=timer.CurrentSplitIndex+
				(current.sector-old.sector);
		}
		//G66 OoB
		else if(old.sector==66&&current.sector>37&&current.sector<40){
			timer.CurrentSplitIndex=timer.CurrentSplitIndex+
				(current.sector-old.sector);
		}
		//Normal Sectors
		else{return current.sector>old.sector&&current.sector<1000;}
	}
	//else if(current.chapter==8&&!current.started&&old.started)
	//{
	//	return old.started;
	//}
	else{return current.chapter>old.chapter;}
}
exit{timer.IsGameTimePaused=true;}
