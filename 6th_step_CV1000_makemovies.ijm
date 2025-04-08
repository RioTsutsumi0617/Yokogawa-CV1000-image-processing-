dir1 = getDirectory("Choose the folder to Open:");
Speed = getNumber("Frame/sec", 20);

folderlist = getFileList(dir1);

setBatchMode("hide");
	
for (i = 0; i < lengthOf(folderlist); i++) {
    if (endsWith(folderlist[i], File.separator)) {
    	name = split(folderlist[i], File.separator);
		name = name[lengthOf(name)-1];
		filelist = getFileList(dir1 + File.separator + folderlist[i] + File.separator);
		for (j = 0; j < lengthOf(filelist); j++) {
		    if (endsWith(filelist[j], ".tif")) {
		    	if (
				File.exists(dir1 + File.separator + folderlist[i] + File.separator + filelist[j])==1 
		    	 ) {
					open(dir1 + File.separator + folderlist[i] + File.separator + filelist[j]);
		    	 	}
		    }
		}
	run("Concatenate...", "all_open open");
	run("AVI... ", "compression=JPEG frame="+Speed+" save=["+dir1+name+".avi]");
	close();
    }
}
