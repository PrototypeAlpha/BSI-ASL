//We require a different pointer when running via Steam
//Will only work with the latest version
state("Drop-Win64-Shipping","1.4 Steam")
{
	bool load:0x2004FA0,0xB8,0x8,0x328,0x30,0x10;
}
//When running via the exe instead of Steam
state("Drop-Win64-Shipping","1.4")
{
	bool load:0x1FBB5C0,0x10,0x48,0x318,0x30,0x10;
}
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
state("Drop-Win64-Shipping","1.0")
{
	bool load:0x1FDEA30,0x10,0x48,0x318,0x30,0x10;
}
init
{
	timer.IsGameTimePaused=false;

	//Get game version by checking pak file size
	//1.4a=7232244389
	//1.4=7232307574
	//1.3a=7214753176
	//1.3=7215027049
	//1.2=7213177061
	//1.1=7286976220
	//1.0=7286960627

	var f=modules.First().FileName;
	var p=new FileInfo(f.Substring(0,f.Length-38)+"Content\\Paks\\SkyArk-WindowsNoEditor.pak").Length;
	print("[GASL] Pak: "+p);
	if(p==7286960627){version="1.0";}
	else if(p==7286976220){version="1.1";}
	else if(p==7213177061){version="1.2";}
	else if(p==7215027049||p==7214753176){version="1.3";}
	else if(p==7232307574||p==7232244389){
		version="1.4";
		//Check if launched via Steam
		//TODO: Find a better way of doing this
		for(var i=0;i<modules.Length;i++){
			if(modules[i].FileName.Contains("gameoverlayrenderer64")){
				print("[GASL] Started via Steam");
				version+=" Steam";
			}
		}
	}
	else{
		MessageBox.Show("Found unknown version with pak '"+p+"'\n\n"+
		"Please mention PrototypeAlpha on the Gravitas Speedrunning discord with the message above.",
		"Gravitas ASL | LiveSplit",MessageBoxButtons.OK,MessageBoxIcon.Error);
	}
	
	//Prevent timer from starting when opening the game
	Thread.Sleep(5000);
}
exit{timer.IsGameTimePaused=true;}
start{return !current.load&&old.load;}
isLoading{return current.load;}
//update{if(current.load!=old.load)print("[GASL] Loading: "+current.load);}