dir1 = getDirectory("Choose the folder to Open:");
dir2 = getDirectory("Choose the folder to save:");

filelist = getFileList(dir1);

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")) {
    	if (
		File.exists(dir1 + File.separator + filelist[i])==1 
    	 ) { 
		open(dir1 + File.separator + filelist[i]);
		setMinAndMax(0, 65535);
		call("ij.ImagePlus.setDefault16bitRange", 16);
		Stack.setChannel(1);
		run("Green");
		Stack.setChannel(2);
		run("Magenta");
		Stack.setChannel(3);
		run("Grays");
		run("Make Composite");
		run("RGB Color", "slices frames keep");
		run("Z Project...", "projection=[Max Intensity] all");
		saveAs("Tiff", dir2 + File.separator + filelist[i]);
    	}
	close("*");
    }
} 
