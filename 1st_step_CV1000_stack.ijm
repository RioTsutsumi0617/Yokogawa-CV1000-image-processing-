function createDirectory(path) {
    if (!File.exists(path)) {
        File.makeDirectory(path);
    }
}

function getUserInput() {
    Dialog.create("Input data structure");
    Dialog.addNumber("# of Wells:", 1);
    Dialog.addNumber("# of Tiles (1 or 4):", 1);
    Dialog.addNumber("# of fields:", 1);
    Dialog.addNumber("# of channels:", 2);
    Dialog.addNumber("# of Slices:", 1);
    Dialog.addNumber("# of Time frames:", 1);
    Dialog.show();
    return [Dialog.getNumber(), Dialog.getNumber(), Dialog.getNumber(), Dialog.getNumber(), Dialog.getNumber(), Dialog.getNumber()];
}

function processImages(w, fmax, ch, slice, timeframe, imageFolder, dir, tile, startF, endF) {
    for (f = startF; f <= endF; f++) {
        File.openSequence(dir + "image" + File.separator, "virtual filter=(W" + w + "F00" + f + ".*)");
        filename = imageFolder + "W" + w + "F00" + f + ".tif";
        run("Stack to Hyperstack...", "order=xyczt(default) channels=" + ch + " slices=" + slice + " frames=" + timeframe + " display=Grayscale");
        run("Hyperstack to Stack");
	Stack.setChannel(1);
	run("Green");
	setMinAndMax(0, 65535);
	call("ij.ImagePlus.setDefault16bitRange", 16);
	Stack.setChannel(2);
	run("Magenta");
	setMinAndMax(0, 65535);
	call("ij.ImagePlus.setDefault16bitRange", 16);
	Stack.setChannel(3);
	run("Grays");
	setMinAndMax(0, 65535);
	Property.set("CompositeProjection", "Sum");
	Stack.setDisplayMode("composite");
        saveAs("Tiff", filename);
        close("*");
    }
}

function createTileConfig(imageFolder, configName, tileCoords) {
    Config = configName;
    Table.create(Config);
    for (i = 0; i < tileCoords.length; i++) {
        Table.set("dim = 3", i, tileCoords[i], Config);
    }
    Table.save(imageFolder + "TileConfiguration.txt", Config);
}

function runStitching(imageFolder, outputName) {
    run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory=[&ImageFolder] layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
    saveAs("Tiff", imageFolder + outputName);
    close("*");
}

function deleteTempFiles(imageFolder, startF, endF) {
    for (f = startF; f <= endF; f++) {
        File.delete(imageFolder + "W" + w + "F00" + f + ".tif");
    }
}

function main() {
    dir = getDir("Choose a Directory");
    imageFolder = dir + "hyperstack" + File.separator;
    createDirectory(imageFolder);
    
    [Well, Tile, Fmax, Ch, Slice, Timeframe] = getUserInput();
    
    setBatchMode("hide");

    for (w = 1; w <= Well; w++) {
        if (Tile == 1) {
            processImages(w, Fmax, Ch, Slice, Timeframe, imageFolder, dir, Tile, 1, Fmax);
        } else if (Tile == 4) {
            processImages(w, Tile, Ch, Slice, Timeframe, imageFolder, dir, Tile, 1, 4);
            createTileConfig(imageFolder, "Config", [
                "W" + w + "F001.tif ; ; (0, 0, 0)",
                "W" + w + "F002.tif ; ; (512, 0, 0)",
                "W" + w + "F003.tif ; ; (0, 512, 0)",
                "W" + w + "F004.tif ; ; (512, 512, 0)"
            ]);
            runStitching(imageFolder, "W" + w);
            deleteTempFiles(imageFolder, 1, 4);
        } else if (Tile == 9 || Tile == 18) {
            processImages(w, Tile, Ch, Slice, Timeframe, imageFolder, dir, Tile, 1, 9);
            createTileConfig(imageFolder, "Config", [
                "W" + w + "F001.tif ; ; (0, 0, 0)",
                "W" + w + "F002.tif ; ; (512, 0, 0)",
                "W" + w + "F003.tif ; ; (1024, 0, 0)",
                "W" + w + "F004.tif ; ; (0, 512, 0)",
                "W" + w + "F005.tif ; ; (512, 512, 0)",
                "W" + w + "F006.tif ; ; (1024, 512, 0)",
                "W" + w + "F007.tif ; ; (0, 1024, 0)",
                "W" + w + "F008.tif ; ; (512, 1024, 0)",
                "W" + w + "F009.tif ; ; (1024, 1024, 0)"
            ]);
            runStitching(imageFolder, "W" + w);
            deleteTempFiles(imageFolder, 1, 9);

            if (Tile == 18) {
                processImages(w, Tile, Ch, Slice, Timeframe, imageFolder, dir, Tile, 10, 18);
                createTileConfig(imageFolder, "Config", [
                    "W" + w + "F010.tif ; ; (0, 0, 0)",
                    "W" + w + "F011.tif ; ; (512, 0, 0)",
                    "W" + w + "F012.tif ; ; (1024, 0, 0)",
                    "W" + w + "F013.tif ; ; (0, 512, 0)",
                    "W" + w + "F014.tif ; ; (512, 512, 0)",
                    "W" + w + "F015.tif ; ; (1024, 512, 0)",
                    "W" + w + "F016.tif ; ; (0, 1024, 0)",
                    "W" + w + "F017.tif ; ; (512, 1024, 0)",
                    "W" + w + "F018.tif ; ; (1024, 1024, 0)"
                ]);
                runStitching(imageFolder, "W" + w + "_2");
                deleteTempFiles(imageFolder, 10, 18);
            }
        }
    }
}

main();
