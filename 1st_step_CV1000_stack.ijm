dir = getDir("Choose a Directory");
ImageFolder = dir + "hyperstack" + File.separator;
if (!File.exists(ImageFolder)) {
File.makeDirectory(ImageFolder);
}

  Well=1; Tile=1;Fmax = 1; Ch=2; Slice=1;Timeframe=1;
  Dialog.create("Input data structure");
  Dialog.addNumber("# of Wells:", Well);
  Dialog.addNumber("# of Tiles (1 or 4):", Tile);
  Dialog.addNumber("# of fields:", Fmax);
  Dialog.addNumber("# of channels:", Ch);
  Dialog.addNumber("# of Slices:", Slice);
  Dialog.addNumber("# of Time frames:", Timeframe);
  Dialog.show();
  Well = Dialog.getNumber();
  Tile = Dialog.getNumber();
  Fmax = Dialog.getNumber();
  Ch = Dialog.getNumber();
  Slice = Dialog.getNumber();
  Timeframe = Dialog.getNumber();

setBatchMode("hide");

for ( w = 1; w <= Well; w++) {
	if ( Tile == 1 ) {
	for ( f = 1; f <= Fmax; f++) {
	File.openSequence(dir + "image" + File.separator, "virtual filter=(W" + w + "F00" + f + ".*)" );
	filename = ImageFolder + "W" + w + "F00" + f + ".tif";
	run("Stack to Hyperstack...", "order=xyczt(default) channels=" + Ch + " slices=" + Slice + " frames=" + Timeframe + " display=Grayscale");
	run("Hyperstack to Stack");
	saveAs("Tiff",filename);
	close("*");
	}
	}
	
	if (Tile == 4) {
	fieldGroup = 1;
        for (f = 1; f <= Fmax; f += 4) {
            // Process fields in groups of 4
            for (fieldIndex = 0; fieldIndex < 4; fieldIndex++) {
                currentField = f + fieldIndex;
                if (currentField <= Fmax) {
                	fieldNumber = d2s(currentField, 0); // Convert number to string
              		if (currentField < 10) {
                		fieldNumber = "00" + fieldNumber;
				} else if (currentField < 100) {
                        		fieldNumber = "0" + fieldNumber;
                    		}
	                File.openSequence(dir + "image" + File.separator, "virtual filter=(W" + w + "F" + fieldNumber + ".*)" );
	                filename = ImageFolder + "W" + w + "F00" + currentField + ".tif";
	                run("Stack to Hyperstack...", "order=xyczt(default) channels=" + Ch + " slices=" + Slice + " frames=" + Timeframe + " display=Grayscale");
	                run("Hyperstack to Stack");
	                saveAs("Tiff", filename);
	                close("*");
	                }
	            }
            
	            // Create tile configuration for stitching
	            Config = "Config";
	            Table.create(Config);
	            Table.set("dim = 3", 0, "W" + w + "F00" + f + ".tif ; ; (0, 0, 0)", Config);
	            Table.set("dim = 3", 1, "W" + w + "F00" + (f + 1) + ".tif ; ; (512, 0, 0)", Config);
	            Table.set("dim = 3", 2, "W" + w + "F00" + (f + 2) + ".tif ; ; (0, 512, 0)", Config);
	            Table.set("dim = 3", 3, "W" + w + "F00" + (f + 3) + ".tif ; ; (512, 512, 0)", Config);
	            Table.save(ImageFolder + "TileConfiguration.txt", Config);
	            
	            // Perform stitching
	            run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[&ImageFolder] layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
	            saveAs("Tiff", ImageFolder + "W" + w + "S" + fieldGroup); // Save stitched image as WwSfieldGroup.tif
	            close("*");

            // Delete individual fields after stitching
	            for (fieldIndex = 0; fieldIndex < 4; fieldIndex++) {
    	            currentField = f + fieldIndex;
	                if (currentField <= Fmax) {
                    File.delete(ImageFolder + "W" + w + "F00" + currentField + ".tif");
                	}
            	}
            
            	fieldGroup++;
        	}
    	}
	}	
	if ( Tile == 9 || Tile == 18 ) {	
	for ( f = 1; f <= 9; f++) {
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
		Table.set("dim = 3", 2,  "W" + w + "F003.tif ; ; (1024, 0, 0)", Config);
		Table.set("dim = 3", 3,  "W" + w + "F004.tif ; ; (0, 512, 0)", Config);
		Table.set("dim = 3", 4,  "W" + w + "F005.tif ; ; (512, 512, 0)", Config);
		Table.set("dim = 3", 5,  "W" + w + "F006.tif ; ; (1024, 512, 0)", Config);
		Table.set("dim = 3", 6,  "W" + w + "F007.tif ; ; (0, 1024, 0)", Config);
		Table.set("dim = 3", 7,  "W" + w + "F008.tif ; ; (512, 1024, 0)", Config);
		Table.set("dim = 3", 8,  "W" + w + "F009.tif ; ; (1024, 1024, 0)", Config);
		Table.save(ImageFolder + "TileConfiguration.txt", Config);
		run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[&ImageFolder] layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
		
		saveAs("Tiff", ImageFolder + "W" + w);
		close("*");
		File.delete(ImageFolder + "W" + w + "F001.tif");
		File.delete(ImageFolder + "W" + w + "F002.tif");
		File.delete(ImageFolder + "W" + w + "F003.tif");
		File.delete(ImageFolder + "W" + w + "F004.tif");
		File.delete(ImageFolder + "W" + w + "F005.tif");
		File.delete(ImageFolder + "W" + w + "F006.tif");
		File.delete(ImageFolder + "W" + w + "F007.tif");
		File.delete(ImageFolder + "W" + w + "F008.tif");
		File.delete(ImageFolder + "W" + w + "F009.tif");
		
		if ( Tile == 18 ) {
			for ( f = 10; f <= 18; f++) {
			File.openSequence(dir + "image" + File.separator, "virtual filter=(W" + w + "F0" + f + ".*)" );
			filename = ImageFolder + "W" + w + "F0" + f + ".tif";
			run("Stack to Hyperstack...", "order=xyczt(default) channels=" + Ch + " slices=" + Slice + " frames=" + Timeframe + " display=Grayscale");
			run("Hyperstack to Stack");
			saveAs("Tiff",filename);
			close("*");
			}
		Config = "Config";
		Table.create(Config);
		Table.set("dim = 3", 0,  "W" + w + "F010.tif ; ; (0, 0, 0)", Config);
		Table.set("dim = 3", 1,  "W" + w + "F011.tif ; ; (512, 0, 0)", Config);
		Table.set("dim = 3", 2,  "W" + w + "F012.tif ; ; (1024, 0, 0)", Config);
		Table.set("dim = 3", 3,  "W" + w + "F013.tif ; ; (0, 512, 0)", Config);
		Table.set("dim = 3", 4,  "W" + w + "F014.tif ; ; (512, 512, 0)", Config);
		Table.set("dim = 3", 5,  "W" + w + "F015.tif ; ; (1024, 512, 0)", Config);
		Table.set("dim = 3", 6,  "W" + w + "F016.tif ; ; (0, 1024, 0)", Config);
		Table.set("dim = 3", 7,  "W" + w + "F017.tif ; ; (512, 1024, 0)", Config);
		Table.set("dim = 3", 8,  "W" + w + "F018.tif ; ; (1024, 1024, 0)", Config);
		Table.save(ImageFolder + "TileConfiguration.txt", Config);
		run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[&ImageFolder] layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");		
		saveAs("Tiff", ImageFolder + "W" + w + "_2");
		close("*");
		File.delete(ImageFolder + "W" + w + "F010.tif");
		File.delete(ImageFolder + "W" + w + "F011.tif");
		File.delete(ImageFolder + "W" + w + "F012.tif");
		File.delete(ImageFolder + "W" + w + "F013.tif");
		File.delete(ImageFolder + "W" + w + "F014.tif");
		File.delete(ImageFolder + "W" + w + "F015.tif");
		File.delete(ImageFolder + "W" + w + "F016.tif");
		File.delete(ImageFolder + "W" + w + "F017.tif");
		File.delete(ImageFolder + "W" + w + "F018.tif");
		}
	}

