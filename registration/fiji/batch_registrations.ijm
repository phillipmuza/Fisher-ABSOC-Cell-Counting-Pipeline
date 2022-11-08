//Author: Phillip Muza
//Date: 07.11.22

//ImageJ Macro to downsample brain slices before registration

   requires("1.33s"); 
   dir = getDirectory("Choose a Directory ");
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

//This function will list the files in the current directory and run processDownsample function
   function processFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFiles(""+dir+list[i]);
          else {
             showProgress(n++, count);
             path = dir+list[i];
             processDownsample(path);
          }
      }
  }
  
//This function will find a .tif file in your directory, run a median filter and downsample to a 10x10x10 um^3 resolution
  function processDownsample(path) {
       if (endsWith(path, ".tif")) {
            open(path);
            name = getTitle();
//This is where the filtering starts
	//You can modify how you want to process the images from here
			run("8-bit");
            run("Median 3D...", "x=2 y=2 z=2");
			Stack.setXUnit("um");
			Stack.setYUnit("um");
			Stack.setZUnit("um");
//Make sure the pixel width, height, and voxel depth (z-step) is correct in the properties 
			image_width = getWidth;
			image_height = getHeight;
			image_stack = nSlices;
			getPixelSize(unit, pixel_width, pixel_height, pixel_depth);
//The scaled_*** line downsample the image to 10*10*10
			scaled_width = (image_width*pixel_width)/10;
			scaled_height = (image_height*pixel_height)/10;
			scaled_stack = (image_stack*pixel_depth)/10;
			run("Scale...", "width=" + scaled_width + " height=" + scaled_height + " depth=" + scaled_stack + " interpolation=Bicubic average process create title=filtered.tif");
//Save your image and export the pixel coordinates
			selectWindow("filtered.tif");
			saveAs("Tiff", dir + "auto_downsampled");
	close();
      }
  }


