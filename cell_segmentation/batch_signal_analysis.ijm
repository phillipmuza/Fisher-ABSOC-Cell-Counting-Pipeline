// "BatchProcessFolders"
//
// This macro batch processes all the files in a folder and any
// subfolders in that folder. For other kinds of processing,
// edit the processFile() function at the end of this macro.

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

//This function will list the files in the current directory and run processSignal function
   function processFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              processFiles(""+dir+list[i]);
          else {
             showProgress(n++, count);
             path = dir+list[i];
             processSignal(path);
          }
      }
  }

//This function will run cell segmentation - this function is generic, change to suit your needs/experiment 
  function processSignal(path) {
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
			run("High-Pass Gaussian Filter", "x=1 y=1 z=1");
//This line runs a threshold - QC this stage of the script and change accordingly 
			run("Auto Threshold", "method=Triangle ignore_black ignore_white white use_stack_histogram");
			saveAs("Tiff", dir + "_mask");
//This runs the BoneJ particle analyzers - change min & max of the size of objects you want to analyse
	//Here parameters are set for mouse NPY+ cell bodies -/+ 5%
			run("Particle Analyser", "exclude min=0 max=1575 surface_resampling=2 show_particle surface=Gradient split=0.000 volume_resampling=2 ");
			selectWindow("_mask_parts");
			saveAs("Tiff", dir + "mask_parts");
			selectWindow("Results");
			saveAs("Results", dir + "objects_xyz.csv");	
	close();
      }
  }


