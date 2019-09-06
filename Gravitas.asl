//Blank state to avoid errors when starting and closing game
state("Drop-Win64-Shipping"){}
//We require a different pointer when running via Steam
//Will only work with the latest version
state("Drop-Win64-Shipping","1.3 Steam")
{
	bool load:0x1F90ED0,0x58,0x8,0x8,0x30,0x10;
}
//When running via the exe instead of Steam
state("Drop-Win64-Shipping","1.3")
{
	bool load:0x1FB85A0,0x10,0x48,0x318,0x30,0x10;
}
state("Drop-Win64-Shipping","1.2")
{
	bool load:0x1FB85A0,0x10,0x48,0x318,0x30,0x10;
}
state("Drop-Win64-Shipping","1.1")
{
	bool load:0x1FB85A0,0x10,0x48,0x318,0x30,0x10;
}
//1.0 requires a different pointer from later versions
state("Drop-Win64-Shipping","1.0")
{
	bool load:0x1FDEA30,0x10,0x48,0x318,0x30,0x10;
}
startup{settings.Add("loadRemoval", true, "Enable Load Removal");}
init
{
	//Unpause timer if game is relaunched
	timer.IsGameTimePaused=true;

	//Get game version by checking pak file size
	//1.4=???
	//1.3=7214753176
	//1.3a=7215027049
	//1.2=7213177061
	//1.1=7286976220
	//1.0=7286960627

	var f=modules.First().FileName;
	var p=new FileInfo(f.Substring(0,f.Length-38)+"Content\\Paks\\SkyArk-WindowsNoEditor.pak").Length;
	print("[ASL] Pak: "+p);
	if(p==7286960627){version="1.0";}
	else if(p==7286976220){version="1.1";}
	else if(p==7213177061){version="1.2";}
	else if(p==7215027049){version="1.3";}
	else{
		version="1.3";
		//Check if launched via Steam, sometimes doesn't work
		for(var i=0;i<modules.Length;i++){
			if(modules[i].FileName.Contains("gameoverlayrenderer64")){
				print("[ASL] Started via Steam");
				version+=" Steam";
			}
		}
	}
	
	//Prevent timer from starting when opening the game
	Thread.Sleep(5000);
}
exit
{
	//Pause timer if game crashes
	timer.IsGameTimePaused=true;
	//Set Livesplit to use blank state
	version="";
}
start{return !current.load&&old.load;}
isLoading{return settings["loadRemoval"]&&current.load;}
//update{if(current.load!=old.load)print("Loading: "+current.load);}
