//dir1 = getDirectory("Choose the folder to Open:");
//dir2 = getDirectory("Choose the folder to save:");
Folder = getDir("Choose a Directory");
dir1 = Folder + "hyperstack" + File.separator;
dir2 = Folder + "merge" + File.separator;
if (!File.exists(dir2)) {
File.makeDirectory(dir2);
}

filelist = getFileList(dir1);

setBatchMode("hide");

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")) {
    	if (
		File.exists(dir1 + File.separator + filelist[i])==1 
    	 ) { 
		open(dir1 + File.separator + filelist[i]);
		call("ij.ImagePlus.setDefault16bitRange", 16);
		Stack.setChannel(1);
		run("Green");
		setMinAndMax(4000, 11500);
		Stack.setChannel(2);
		run("Magenta");
		setMinAndMax(0, 65535);
		Stack.setChannel(3);
		run("Grays");
		setMinAndMax(0, 65535);
		run("Make Composite");
		run("RGB Color", "slices frames keep");
		run("Z Project...", "projection=[Max Intensity] all");
		saveAs("Tiff", dir2 + File.separator + filelist[i]);
    	}
	close("*");
    }
} 
