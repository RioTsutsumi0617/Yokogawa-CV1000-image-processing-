dir1 = getDirectory("Choose the folder to Open:");
Speed = getNumber("Frame/sec", 10);

name = split(dir1, File.separator);
name = name[lengthOf(name)-1];
filelist = getFileList(dir1);
	
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")) {
    	if (
		File.exists(dir1 + File.separator + filelist[i])==1 
    	 ) {
			open(dir1 + File.separator + filelist[i]);
    	 	}
    }
}
run("Concatenate...", "all_open open");
run("AVI... ", "compression=JPEG frame="+Speed+" save=["+dir1+name+".avi]");
close();