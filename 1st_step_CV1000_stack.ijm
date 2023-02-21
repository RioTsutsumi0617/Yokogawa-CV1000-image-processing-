dir = getDir("Choose a Directory");
ImageFolder = dir + "hyperstack" + File.separator;
if (!File.exists(ImageFolder)) {
File.makeDirectory(ImageFolder);
}

  Well=1; Tile=1;Ch=2; Slice=1;Timeframe=1;
  Dialog.create("Input data structure");
  Dialog.addNumber("# of Wells:", Well);
  Dialog.addNumber("# of Tiles (1 or 4):", Tile);
  Dialog.addNumber("# of channels:", Ch);
  Dialog.addNumber("# of Slices:", Slice);
  Dialog.addNumber("# of Time frames:", Timeframe);
  Dialog.show();
  Well = Dialog.getNumber();
  Tile = Dialog.getNumber();
  Ch = Dialog.getNumber();
  Slice = Dialog.getNumber();
  Timeframe = Dialog.getNumber();

for ( w = 1; w <= Well; w++) {
	if ( Tile == 1 ) {
	File.openSequence(dir + "image" + File.separator, "virtual filter=(W" + w +  "F.*)" );
	filename = ImageFolder + "W" + w + ".tif";
	run("Stack to Hyperstack...", "order=xyczt(default) channels=" + Ch + " slices=" + Slice + " frames=" + Timeframe + " display=Grayscale");
	run("Hyperstack to Stack");
	saveAs("Tiff",filename);
	close("*");
	}
	
	if ( Tile == 4 ) {	
		for ( f = 1; f <= Tile; f++) {
		File.openSequence(dir + "image" + File.separator, "virtual filter=(W" + w + "F00" + f + ".*)" );
		filename = ImageFolder + "W" + w + "F00" + f + ".tif";
		run("Stack to Hyperstack...", "order=xyczt(default) channels=" + Ch + " slices=" + Slice + " frames=" + Timeframe + " display=Grayscale");
		run("Hyperstack to Stack");
		saveAs("Tiff",filename);
		close("*");
		}
			Config = "Config";
			Table.create(Config);
			Table.set("dim = 3", 0,  "W" + w + "F001.tif ; ; (0, 0, 0)", Config);
			Table.set("dim = 3", 1,  "W" + w + "F002.tif ; ; (512, 0, 0)", Config);
			Table.set("dim = 3", 2,  "W" + w + "F003.tif ; ; (0, 512, 0)", Config);
			Table.set("dim = 3", 3,  "W" + w + "F004.tif ; ; (512, 512, 0)", Config);
			Table.save(ImageFolder + "TileConfiguration.txt", Config);
			run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[&ImageFolder] layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
			saveAs("Tiff", ImageFolder + "W" + w);
			close("*");
			File.delete(ImageFolder + "W" + w + "F001.tif");
			File.delete(ImageFolder + "W" + w + "F002.tif");
			File.delete(ImageFolder + "W" + w + "F003.tif");
			File.delete(ImageFolder + "W" + w + "F004.tif");
	}
}
