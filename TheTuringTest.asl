state("theturingtest")
{
	byte chapter: 0x2DB9060,0x110;
	int	 sector: 0x2DB9060,0x114;
	bool loading: 0x2DB9070,0x19;
	bool loading2: 0x2D8CCC0;
}
startup
{
	vars.splitOnSector=false;
	vars.startOffset="-00:00:51.3200000";
	vars.printFormat="[TheTuringTestASL] {0} change: {1} -> {2}";
	vars.specialSectors=new string[]{
	"Prologue","Planetarium","Crew Quarters",
    "Maintenance","The Brig","Bio Lab",
    "Drilling Site",null,"Epilogue",};
	settings.Add("Offset",true,"Set Start Offset to -00:51.32");
	settings.Add("Debug",false);
}
init
{
	version="1.3 DX11";
	vars.splits = timer.Run.Count;
	var message = "";
	if(vars.splits<9||vars.splits>72||!settings.SplitEnabled){
		settings.SplitEnabled=false;
		message="Autosplitting is disabled.";
	}
	else if(vars.splits==72){
		vars.splitOnSector=true;
		message="Will split on Sector change.";
	}
	else{message="Will split on Chapter change.";}
	
	print("[TheTuringTestASL] "+vars.splits+" splits found. "+message);
	MessageBox.Show(vars.splits+" splits found.\n"+
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
	return current.chapter== 0&&current.sector==-1&&!current.loading&&old.loading;
}
update
{
	if (settings["Debug"]&&current.chapter!=old.chapter){
		print(String.Format(vars.printFormat,"Chapter",
			old.chapter,current.chapter));
	}
	if(settings["Debug"]&&current.sector!=old.sector){
		print(String.Format(vars.printFormat,"Sector",
			old.sector,current.sector));
	}
}
isLoading{return current.loading||current.loading2;}
reset{return current.chapter== 0&&current.sector==-1&&current.loading;}
split
{
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
		else{return current.sector>old.sector&&current.sector<1000;}
	}
	else{return current.chapter>old.chapter;}
}
exit{timer.IsGameTimePaused=true;}