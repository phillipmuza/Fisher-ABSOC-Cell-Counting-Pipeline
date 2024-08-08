#### Cell Count Analysis in Registered Brain Slice Images####
  ### Phillip Muza ###
    ## 12.08.22 ##

#Set your parameters here:
  # This should be isometric so you only need one value in um
pixel_resolution = 10 

  # The file with the pixel coordinates of autofluorescent image
autofluorescence_file = "auto_downsampled_xyz.txt" 

  # The file with the pixel coordinates of annotation image
annotation_file = "annotation_xyz.txt" 

  # The file with the coordinates of your cells
cell_centroids_file = "objects_xyz.csv" 

  # The PATH to your atlas file
decoded_atlas_file = "path/to/atlas_file"  

  # The PATH to the cell counter script
cell_counter = "path/to/cell_counter_config.R"  


# Enter the path to your directory with the folders with your slice data
parent.folder <- "path/to/folder_with_slice_data"

# This line assigns all the folders within your parent directory to a vector
sub.folders <- list.dirs(parent.folder, recursive = FALSE, full.names = TRUE)

# This line will allow you to filter out only the relevant folder you want to analyse
  # It is good practice to keep a common name to identify your folders of interest
    # Here I have used "AN" - change the green text to your identifier
# sub.folders <- sub.folders[grepl("AN53", sub.folders)]

r.script <- file.path(cell_counter)

# This for loop will iterate through your folders of interest and run  cell_counter_config.R file
for (i in sub.folders) {
  setwd(i)
  working_directory <- getwd()
  print(paste('Running script in:', working_directory))
  source(r.script)
}
