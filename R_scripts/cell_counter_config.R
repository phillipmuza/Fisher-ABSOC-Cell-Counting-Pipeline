#### GENERIC SCRIPT TO CALCULATE VOLUMES AND ANNOTATE CELLS IN APPROPRIATE BRAIN REGIONS 

  #### PHILLIP MUZA - 11.08.2022 ####
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse,
               stringr,
               janitor)

### 1. Functions to upload your tables appropriately  --------------------------

# This function uploads the pixel data from the transformed atlas
upload_annotation_xyz <- function(txt_file) {
  df <- read.table(txt_file, header =F)
  colnames(df) <- c("x", "y", "z", "id")
  return(df)
}

#This function uploads the pixel data from the autofluorescence slice
upload_autofluorescence_xyz <- function(txt_file) {
  df <- read.table(txt_file, header =F)
  colnames(df) <- c("x", "y", "z", "pixel_values")
  return(df)
}

#This function uploads the cells ("objects") coordinates 
upload_cells_xyz <- function(csv_file) {
  df <- read.csv(csv_file, header = T, fileEncoding = "Latin1")
  df = subset(df, select = -c(Label, X)) 
  colnames(df) <- c("Object", "Volume", "x", "y", "z")
  #Bonej particle analyser outputs the real spatial location of centriods
    #so you will need to divide by the pixel resolution to map the centriods to the same space as the autofluorescence & annotation images
  df$x <- as.numeric(as.character(df$x))/ pixel_resolution 
  df$y <- as.numeric(as.character(df$y))/ pixel_resolution
  df$z <- as.numeric(as.character(df$z))/ pixel_resolution
  df[3:5] <- lapply(df[3:5], as.integer) #Convert xyz to intergers
  return(df)
}


# This function calculates the volume of anatomical structures in the brain slice


volume_calculation <- function(auto_slice){
  df <- as.data.frame(table(auto_slice$id))
  colnames(df) <- c("id", "Freq")
  df <- df %>%
    select(id, Freq) %>%
    mutate("volume(mm^3)" = Freq * ((pixel_resolution/1000)^3)) #each pixel 7um in xyz 
  df$id <- as.factor(df$id)
  decoded_data <- inner_join(atlas_tree, df)
  return(decoded_data)
}

### 2. Functions to collate Cell Numbers by Anatomical Location -----------------------------

#This function combines the coordinates of the cells with the coordinates of the
  #anatomical region - it will also save a csv of this data
cell_locations <- function(cell_coordinates, region_coordinates){
  df <- inner_join(cell_coordinates, region_coordinates) #Combine cells with region coordinates
  df_sum <- df %>% 
    count(id)
  df_sum$id <- as.factor(df_sum$id)
  decoded_df <- inner_join(df_sum, atlas_tree) #This gives a df of the regions present in the dataset and number of cells/regions
  return(decoded_df)
}


### 3. Functions to combine Cell Numbers and Region Volumes  --------------------------------

cell_and_volume_df <- function(cell_regions, volume_regions, save_filename){
  df <- inner_join(cell_regions, volume_regions)
  df <- subset(df, select = -c(Freq))
  df <- df[, c("name","acronym","structure_id_path","id",
               "parent_structure_id","n","volume(mm^3)")]
  df$parent_structure_id <- as.factor(df$parent_structure_id)
  write.csv(df, file = save_filename)
  return(df)
}

            
### Importing your files  -----

auto_xyz <- upload_autofluorescence_xyz(autofluorescence_file) #autofluorescence file 
anno_xyz <- upload_annotation_xyz(annotation_file) #annotations file

#THIS IS IMPORTANT - THIS NEXT LINE MERGES PIXELS PRESENT IN AUTOFLUO SLICE WITH ANNOTATIONS 
  #WHAT YOU WILL HAVE IS A FILE WITH ANATOMICAL IDS OF THE PIXEL LOCATIONS IN YOUR RAW DATA
pixel_ids_xyz <- inner_join(auto_xyz, anno_xyz)

cells_xyz <- upload_cells_xyz(cell_centroids_file) #segmented cells and locations

 
atlas_tree <- read.csv(decoded_atlas_file)
atlas_tree$id <- as.factor(atlas_tree$id)

# Merging Data from Autofluorescence and Transformed Atlas 
region_volumes <- volume_calculation(pixel_ids_xyz)
cell_regions <- cell_locations(cells_xyz, pixel_ids_xyz)
combined_cells_volumes <- cell_and_volume_df(cell_regions, region_volumes, "cell_and_region_volumes.csv")


