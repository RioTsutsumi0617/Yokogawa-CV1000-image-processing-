dir1 = "/Volumes/G-DRIVE Thunderbolt 3/CV1000/20221215T012125/merge";
dir2 = "/Volumes/G-DRIVE Thunderbolt 3/CV1000/20221215T205140/merge";
//dir3 = "/Volumes/G-DRIVE Thunderbolt 3/CV1000/20210609T235911/Zprojected_AllStack";
//dir4 = "/Volumes/G-DRIVE Thunderbolt 3/CV1000/20210813T193105/Zprojected_AllStack";
//dir5 = "/Volumes/G-DRIVE Thunderbolt 3/CV1000/20210815T194102/Zprojected_AllStack";
//dir6 = "/Volumes/G-DRIVE Thunderbolt 3/CV1000/20211218T220438/Zprojected_AllStack";
dir7 = "/Volumes/G-DRIVE Thunderbolt 3/CV1000/20221215_combined/";


close("*");

setBatchMode("hide");

if (File.exists(dir7) == 0) {
	File.makeDirectory(dir7);	
}

filelist = getFileList(dir1);

for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".tif")) {
    	if (
		File.exists(dir1 + File.separator + filelist[i])==1 
		&& File.exists(dir2 + File.separator + filelist[i])==1
//		&& File.exists(dir3 + File.separator + filelist[i])==1
//		&& File.exists(dir4 + File.separator + filelist[i])==1
//		&& File.exists(dir5 + File.separator + filelist[i])==1
//		&& File.exists(dir6 + File.separator + filelist[i])==1 	  
    	 ) { 
		open(dir1 + File.separator + filelist[i]);
		open(dir2 + File.separator + filelist[i]);
//		open(dir3 + File.separator + filelist[i]);
//		open(dir4 + File.separator + filelist[i]);
//		open(dir5 + File.separator + filelist[i]);
//		open(dir6 + File.separator + filelist[i]);
        run("Concatenate...", "all_open open");
        saveAs("Tiff", dir7 + File.separator + filelist[i]);
    }
        close("*");
    } 
}
