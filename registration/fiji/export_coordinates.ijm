//Author: Phillip Muza
//Date: 07.11.22

//ImageJ Macro to export coordinates of all non-zero pixels from "auto_downsampled.tif" and "annotation.tif" 
	//IMPORTANT: it is recommended you only have "annotation.tif" and "auto_downsampled.tif" in your directory before running this macro

   requires("1.33s"); 
   dir = getDirectory("Choose your registration folder... ");
   setBatchMode(true);
   count = 0;
   countFiles(dir);
   n = 0;
   processFiles(dir);
   //print(count+" files processed");
   
//This funcion lists the directories it will process 
   function countFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              countFiles(""+dir+list[i]);
          else
              count++;
      }
  }

//This function will list the files in the current directory and run processExport function
   function processFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFiles(""+dir+list[i]);
          else {
             showProgress(n++, count);
             path = dir+list[i];
             processExport(path);
          }
      }
  }

//For every .tif file in the directory, this function will export all non-zero pixel coordinates and values
	//IMPORTANT: it is recommended you only have "annotation.tif" and "auto_downsampled.tif" in your directory before running this macro
  function processExport(path) {
       if (endsWith(path, ".tif")) {
            open(path);
            name = getTitle();
            name = replace(name, ".tif", "");
//Save your image and export the pixel coordinates
			txtPath = dir+name+"_xyz.txt";
			run("Save XY Coordinates...", "background = 0 invert process save=["+txtPath+"]");
	close();
      }
  }

