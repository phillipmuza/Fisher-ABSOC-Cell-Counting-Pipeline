#### Cell Count Analysis in Registered Brain Slice Images####
  ### Phillip Muza ###
    ## 12.08.22 ##

#Set your parameters here:
pixel_resolution = 10 #This should be isometric so you only need one value in um
autofluorescence_file = "auto_downsampled_xyz.txt" #The file with the pixel coordinates of autofluorescent image
annotation_file = "annotation_xyz.txt" #The file with the pixel coordinates of annotation image
cell_centroids_file = "objects_xyz.csv" #The file with the coordinates of your cells
decoded_atlas_file = "R_scripts/ccfv3_functional.csv" #The PATH to your atlas file 
cell_counter = "R_scripts/cell_counter_config_easier.R" # The PATH to the cell counter script 

#Enter the path to your directory with the folders with your slice data
parent.folder <- " "

#This line assigns all the folders within your parent directory to a vector
sub.folders <- list.dirs(parent.folder, recursive = FALSE, full.names = TRUE)

#This line will allow you to filter out only the relevant folder you want to analyse
  #It is good practice to keep a common name to identify your folders of interest
    #Here I have used "AN" - change the green text to your identifier
#sub.folders <- sub.folders[grepl("AN53", sub.folders)]

r.script <- file.path(cell_counter)

#This for loop will iterate through your folders of interest and run the script
  #the script is the cell_counter_config.R file
for (i in sub.folders) {
  setwd(i)
  source(r.script)
}
