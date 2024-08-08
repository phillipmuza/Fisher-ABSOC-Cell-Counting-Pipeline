#### GENERIC SCRIPT TO CALCULATE VOLUMES AND ANNOTATE CELLS IN APPROPRIATE BRAIN REGIONS 

#### PHILLIP MUZA - 11.08.2022 ####

## UPDATED: to include sizes of cells - 04.12.2023
## UPDATED: saves separate files for cells numbers and volumes per region, and descriptors of cell volumes

if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse,
               stringr,
               janitor,
               splitstackshape)

### 1. Functions to upload your tables appropriately  --------------------------

# This function uploads the pixel data from the transformed atlas
upload_annotation_xyz <- function(txt_file) {
  if(missing(txt_file)){
    stop('Annotation file is missing. Please provide annotation.txt file.')
  }
  df <- read.table(txt_file, header =F)
  colnames(df) <- c("x", "y", "z", "id")
  return(df)
}

#This function uploads the pixel data from the autofluorescence slice
upload_autofluorescence_xyz <- function(txt_file) {
  if(missing(txt_file)){
    stop('Autofluorescence file is missing. Please provide autofluorescence.txt file.')
  }
  df <- read.table(txt_file, header =F)
  colnames(df) <- c("x", "y", "z", "pixel_values")
  return(df)
}

#This function uploads the cells ("objects") coordinates 
upload_cells_xyz <- function(csv_file) {
  if(missing(csv_file)){
    stop('Objects_xyz file is missing. Please provide objects_xyz.csv file.')
  }
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
    mutate("volume(mm^3)" = Freq * ((pixel_resolution/1000)^3)) #each pixel x um in xyz 
  df$id <- as.factor(df$id)
  decoded_data <- inner_join(atlas_tree, df)
  return(decoded_data)
}

### 2. Functions to collate Cell Numbers by Anatomical Location -----------------------------

# Function to count the number of cells in each region, with an optional argument to include cell size
cell_locations <- function(cell_coordinates, region_coordinates, include_cell_size = FALSE){
  
  # Combine cells with region coordinates
  df <- inner_join(cell_coordinates, region_coordinates)
  
  # Count the number of cells in each region
  if (include_cell_size) {
    # Count the number of cells in each region, including cell size
    df_sum <- df %>% 
      count(id, cell_size)
  } else {
    # Count the number of cells in each region, without cell size
    df_sum <- df %>% 
      count(id)
  }
  
  # Convert id column to factor
  df_sum$id <- as.factor(df_sum$id)
  
  # Join with atlas tree to get region information
  decoded_df <- inner_join(df_sum, atlas_tree) 
  
  # Return the resulting data frame
  return(decoded_df)
}

### 3. Add column giving a qualitative description of cell size -------------------------------

#Subset unique volumes in cell_xyz dataframe into threes
#his only works when you have a list of =< 3 unique volumes 
subset_volumes_in_threes <- function(dataframe) {
  volumes <- c(unique(dataframe$Volume)) #Create a list of the unique values of volumes
  volumes_sorted <- sort(volumes) #Sort volumes in ascending order
  volume_chunks <- split(volumes_sorted, cut(seq_along(volumes_sorted), breaks=3, labels = FALSE)) #Split volumes into a list of 3
  sizes <- c('small', 'medium', 'large')
  volume_chunks <- setNames(as.list(volume_chunks), sizes) #Give volume chunks names
  volume_chunks_df <- as.data.frame(do.call(cbind, volume_chunks)) #convert list of volume_chunks into a dataframe
  return(volume_chunks_df)
}

#This function identifies a unique volume value and categories it based on its size
get_column_name <- function(dataframe, target_value) {
  for (col in names(dataframe)) {
    
    #if the unique volume value is in the volumes_df it will return description of volume size (column name)
    if (target_value %in% dataframe[[col]]) { 
      return(col)
    }
  }
  #otherwise it will return an error
  return(print(paste(target_value, ' - Volume value not identified'))) 
}

# This function will categorise cell volumes in cell_xyz
categorise_cell_volumes <- function(){ 
  #Create an empty column to add descriptive cell sizes to
  cells_xyz$cell_size <- NA 
  
  #generate list of all volumes in cells_xyz
  list_of_volumes <- c(cells_xyz$Volume) 
  
  #if your list of volumes is less than 3 it will return a WARNING otherwise it will create a new column categorising your volumes
  if (length(unique(list_of_volumes)) < 3){
    print(paste("WARNING: Only ", length(unique(list_of_volumes)), " unique volume values in ", getwd()))
    return(cells_xyz)
  }  else{ 
    #initialise an empty list which will contain the cell volume categories
    names_of_cells <- list() 
    #create dataframe with unique cell volume descriptions
    cell_size_descriptions <- subset_volumes_in_threes(cells_xyz) 
    
    #This for loop will add all the cell categories into a list 
    for (i in list_of_volumes){
      names_of_cells <- append(names_of_cells, get_column_name(cell_size_descriptions, i)) 
    }
    
    #Add descriptive cells sizes to 'cell_size' column in cells_xyz
    cells_xyz[["cell_size"]] <- names_of_cells
    return(cells_xyz) }
}

### 4. Functions to combine Cell Numbers and Region Volumes  --------------------------------

cell_and_volume_df <- function(cell_regions, volume_regions, save_filename){
  # Perform inner join on cell regions and volume regions
  df <- inner_join(cell_regions, volume_regions)
  
  # Remove Freq column
  df <- df %>% 
    select(-Freq)
  
  # Check if cell_size column is present
  if ("cell_size" %in% colnames(df)) {
    # Subset columns including cell_size, remove commas from cell_size, and rename volume column
    df <- df %>% 
      select(name, acronym, structure_id_path, id, parent_structure_id, n, cell_size, volume_mm3 = `volume(mm^3)`) %>% 
      mutate(cell_size = gsub(",", "", cell_size))
  } else {
    # Subset columns without cell_size and rename volume column
    df <- df %>% 
      select(name, acronym, structure_id_path, id, parent_structure_id, n, volume_mm3 = `volume(mm^3)`)
  }
  
  # Write data frame to CSV file
  write.csv(df, file = save_filename, row.names = FALSE)
  
  # Return data frame
  return(df)
}


### Importing your files  -----

auto_xyz <- upload_autofluorescence_xyz(autofluorescence_file) #autofluorescence file 
anno_xyz <- upload_annotation_xyz(annotation_file) #annotations file

#THIS IS IMPORTANT - THIS NEXT LINE MERGES PIXELS PRESENT IN AUTOFLUO SLICE WITH ANNOTATIONS 
#WHAT YOU WILL HAVE IS A FILE WITH ANATOMICAL IDS OF THE PIXEL LOCATIONS IN YOUR RAW DATA
pixel_ids_xyz <- inner_join(auto_xyz, anno_xyz)

# Segmented cells and locations
cells_xyz <- upload_cells_xyz(cell_centroids_file) 

# Add column qualitatively describing cell sizes
cells_with_volume_descriptors <- categorise_cell_volumes() 

# .csv with decoded brain regions 
atlas_tree <- read.csv(decoded_atlas_file)
atlas_tree$id <- as.factor(atlas_tree$id)

# Merging Data from Autofluorescence and Transformed Atlas 
region_volumes <- volume_calculation(pixel_ids_xyz) # Volumes of the regions in your brain slice

# Count your cells per brain region
  # Without cell sizes
cell_regions <- cell_locations(cells_xyz, pixel_ids_xyz) # count your cells per region
  
  # With cell sizes
cell_regions_with_volume_descriptors <- cell_locations(cells_with_volume_descriptors, pixel_ids_xyz, include_cell_size = TRUE) # count your cells per region including cell volume descriptors 

cell_and_volume_df(cell_regions, region_volumes, "cell_and_region_volumes.csv") # combine cell and volume data
cell_and_volume_df(cell_regions_with_volume_descriptors, region_volumes, "cell_and_region_volumes_with_volume_descriptors.csv") # combine cell and volume data


