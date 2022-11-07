# Fisher-ABSOC-Cell-Counting-Pipeline
A custom-made pipeline developed using open source software, ImageJ/Fiji, Python, and R in order to quantify cell density in multiple brain regions from cleared brain slices. Similar packages for whole brain have been developed by Tyson et al., (2021) - CellFinder and Reiner et al., (2016) - ClearMap, however at the time when I started developing this pipeline these packages were not compatible with brain subvolumes. 

This pipeline is composed of two distinct processes - image registration and cell segmentation (Figure 1), which are combined to produce a table describing cell density for a given brain region in the brain slice.
  ![image](https://user-images.githubusercontent.com/67151814/200360006-92c4c832-e91b-4dad-8334-3247a8993f17.png)

**Figure 1. Two images of the brain slice are required – autofluorescence image which is used in python and ImageJ/Fiji to register to the Allen Brain Common Coordinate Frame version 3 (CCFv3), and the cell signal image which, in ImageJ/Fiji, developed plug-ins are used to individually segment cells. Anatomical region coordinates produced from the autofluorescence image and transformed CCFv3 and cell coordinates from the cell signal are combined in R (RStudio) to generated a table describing the cell density of each anatomical region in the brain slice.** 

## Directory Tree Organisation 
It is recommended you seperate your images for registation and cell segmentation into seperate directories, such that image registration can be run recursively in one directory and cell segmentation in another directory. For example, for animals AN1 and AN2, the directories will be organised like so:
 ```
 registrations
              |___AN1
                    |___auto.tif
              |___AN2
                    |___auto.tif
 cell_segmentation
              |___AN1
                    |___signal.tif
              |___AN2
                    |___signal.tif
 ```
## Image Registration
**The ReadMe.txt in /registrations/ is more detailed**
It is recommnended to use an autofluorescence image to register to the CCFv3, however we have found from experience that yellow/red channels imaged with sufficient anatomical detail can be used to register to the CCFv3.

Summary of the registration workflow:
  1. Pre-process your images in ImageJ/Fiji - record your processing as this will be applied to the cell signal image 
  2. Run the [batch_registrations.ijm](../registration/fiji) macro - this can run recursively 
  3. In Python run [registration_script.py](../registration/python) - if you want to run recursively, it can be done using [registration_recursive.py](../registration/python)
    - This script will need your input to the path of the atlas you want to register
  4. Export pixel coordinates from auto_downsampled.tif and annotation.tif using [export_coordinates.imj](../registration/fiji) - this can run recursively
    - It is recommended to only leave auto_downsampled.tif and annotation.tif in your working directory, otherwise all .tif files will get processed 

## Cell Segmentation 
Summary of the cell segmentation workflow:
  1. Pre-process images in ImageJ/Fiji - if you have the macro from the registration workflow, run it for the cell signal images - this way you are operating in the same space for both images (VERY IMPORTANT)
  2. Run [batch_signal_analysis.imj](../cell_segmentation) macro - this can run recursively
      - **Note: this macro is a generic script - you need to modify it to suit your experimental needs **
      
 ## Register cells to appropriate brain regions
 This process is completed entirely in R (RStudio). You will "auto_downsampled_xyz.txt", "annotation_xyz.txt", "objects_xyz.csv" for a given animal in the same directory. You can either move them to a new directory or move files from registrations to cell_segmentation - whichever you prefer, as long as they are in the same directory. Following that, to register cells to appropriate brain regions:
  1. Run ["cell_counting_pipeline.R"](../R_scripts) - this script runs recursively, **make sure to set the correct parameters** 
  2. Output should be datatable (csv) of the total cell counts and volume of every brain region in the brain slice with > 1 cell  
