
# Landrace Gap Analysis: master code
# Chrystian Sosa, Julian Ramirez, Harold Achicanoy, Andres Mendez, Maria Diaz, Colin Khoury
# CIAT, 2019

# R options
g <- gc(reset = T); rm(list = ls()); options(warn = -1); options(scipen = 999)

#*********************************************************************************************************************************
#*************************** SECTION: LOAD R PACKAGES ****************************************************************************
#*********************************************************************************************************************************
require(tmap)
require(GapAnalysis)
suppressMessages(if(!require(pacman)){install.packages("pacman");library(pacman)}else{library(pacman)})
pacman::p_load(tcltk, adehabitatHR,   raster, rgdal, doSNOW, sdm, dismo,  rgeos, distances,   sp, 
               tidyverse, rlang, sf, gdistance, caret, earth, fastcluster,  FactoMineR, deldir,
               parallelDist, bindrcpp, foreach, doParallel,  pROC, maxnet, usdm)


#*********************************************************************************************************************************
#******************************* SECTION: SET UP DIRS ****************************************************************************
#*********************************************************************************************************************************

# Define base directory, according with your operative system
OSys <- Sys.info()[1]
baseDir   <- switch(OSys,
                   "Linux"   = "/mnt/workspace_cluster_9/gap_analysis_landraces/runs",
                   "Windows" = "D:/CGIAR/DS4Climate Action LAC-Bolder África - Bolder Africa - Gap analysis/data",
                   "Darwin"  = "~nfs/workspace_cluster_9/gap_analysis_landraces/runs")
rm(OSys)

# Define code's folder
srcDir <- paste(baseDir, "/scripts/bolder-gapanalysis-cwr-dev", sep = "")
# Define region of study
region <- "africa"

# Configuring crop directories
source(paste0(srcDir, "/00_config/config_crop.R"))

# Define crop
crop <- "Cenchrus caudatus"
# Define level of analysis
#level_1 <-  c("Amaranthus cruentus") #grupos equivalence to sp
level_1 <-  "Cenchrus caudatus"#c("baobab") #grupos equivalence to sp

level   <- "lvl_1"
# Define occurrence name: it is necessary to specify the group, e.g. Group = "3"
occName <- level_1[1]

# Load all packages and functions needed to develop the analysis
source(paste0(srcDir, "/00_config/config.R"))

#*********************************************************************************************************************************
#************************ SECTION: SET UP INPUT FILES ****************************************************************************
#*********************************************************************************************************************************

# not_run <- TRUE
# 
# if(!not_run){
# # Function to crop all rasters using a region mask extent (Just need to be run when you start the first group analysis)
# crop_raster(mask   = mask, 
#             region = region)
# 
#####################################################################
# Function to prepare passport data to run all the code  ###########
###################################################################

# Please verify the column position where the groups are defined, e.g. Column: 3
# A window will popup to select the .csv input file
# Input file: a .csv file with at least: longitude, latitude, and the status. Status must be G or H!

prepare_input_data(data_path = choose.files( caption = "Select a valid .csv file"), 
                   col_number         = NULL,  # Column position where the groups are
                   do.ensemble.models = FALSE, # Run classification models to measure the environmental separation of the classes
                   add.latitude       = FALSE, # Just for classification models: if you want to add latitude as a predictor
                   add.longitude      = FALSE, # Just for classification models: if you want to add longitude as a predictor
                   do.predictions     = FALSE, # Just for classification models: if you want to predict some accessions that do not have the classes or groups
                   sampling_mthd      = "none", # Just for classification models: for balancing the classes
                   mask               = "D:/CGIAR/DS4Climate Action LAC-Bolder África - Bolder Africa - Gap analysis/data/runs/input_data/mask/mask_africa.tif")  # Mask according with the region of analysis
# Output file: e.g. ./results/african_maize/lvl_1/3/africa/input_data/african_maize_lvl_1_bd.csv
#}
  
  
##########################################################################################
# CREATE OCCURRENCE FILE ONLY WITH GENEBANK ACCESSIONS (column 'status'=='G') ###########
########################################################################################

# Input file: e.g. ./results/african_maize/lvl_1/3/africa/input_data/african_maize_lvl_1_bd.csv


create_occ_shp(file_path   = classResults,
               file_output = paste0(occDir,"/Occ.shp"),
               validation  = FALSE)
# Output file: e.g. ./results/african_maize/lvl_1/3/africa/input_data/Occ.csv
# Output file: e.g. ./results/african_maize/lvl_1/3/africa/input_data/Occ.shp
# Output file: e.g. ./input_data/by_crop/african_maize/lvl_1/3/africa/occurrences/Occ.csv
# Output file: e.g. ./input_data/by_crop/african_maize/lvl_1/3/africa/occurrences/Occ.shp

# Function to estimate the cost distance according with the level of analysis
# Input file: e.g. ./input_data/by_crop/african_maize/lvl_1/3/africa/occurrences/Occ.shp
# Input file: e.g. ./input_data/auxiliar_rasters/friction_surface.tif


#********************************************************************************************************************************
#*************************** SECTION: SPATIAL MODEL DISTRIBUTION (MAXENT) *******************************************************
#********************************************************************************************************************************


#######################################################################################################
# Function for preparing which variables will be selected to run SDMs and creation of SWD files ######
#####################################################################################################

# Input file: e.g. ./input_data/by_crop/african_maize/lvl_1/3/africa/occurrences/Occ.csv
# Input file: e.g. ./input_data/mask/mask_africa.tif
# Input file: e.g. ./input_data/generic_rasters/africa (Generic rasters)
# Input file: e.g. ./input_data/by_crop/african_maize/raster/africa (Specific rasters by crop)
spData <- pseudoAbsences_generator(file_path = classResults,
                                   correlation = 3, # 1. Correlation, 2. VIF, 3. PCA + VIF
                                   pa_method = "ecoreg",
                                   clsModel = "ensemble",
                                   overwrite = F,
                                   rm_bg_region = NULL)
names(spData)[1] <- occName
var_names <- read.csv(paste0(sp_Dir, "/sdm_variables_selected.csv"), stringsAsFactors = F) %>% dplyr::pull(x)

# Output file: ./results/african_maize/lvl_1/3/africa/sdm_variables_selected.csv (Selected variables to do SDM)
# Output file: ./results/african_maize/lvl_1/3/africa/input_data/pseudo_abs_file_3.csv (Pseudo-absences created)
# Output file: ./input_data/by_crop/african_maize/lvl_1/3/africa/background/background_3.shp (Pseudo-absences created)
# Output file: ./input_data/by_crop/african_maize/lvl_1/3/africa/background/bg_3.shp (Pseudo-absences created)
# Output file: ./input_data/by_crop/african_maize/lvl_1/3/africa/swd/swd_3.csv (Samples with data)
# Output file: ./input_data/by_crop/african_maize/lvl_1/3/africa/swd/swd_Complete_3.csv (Samples with data)


#######################################################################################################
# Function to tuning MaxEnt parameters (Regularity and Features) #####################################
#####################################################################################################

params_tunned <- Calibration_function(spData = spData,
                                      sp_Dir = sp_Dir, 
                                      ommit = F, 
                                      use.maxnet = TRUE)


# Loading environmental raster files


##########################################################################################
# Function to develop the Spatial Distribution Modelling (SDM) ##########################
########################################################################################

# Input file: e.g. ./input_data/by_crop/african_maize/lvl_1/3/africa/swd/swd_3.csv (Samples with data file)
# Input file: e.g. ./results/african_maize/lvl_1/3/africa/sdm_variables_selected.csv (Selected variables to do SDM)
# Input file: clim_layer (environmental information)

sdm_maxnet_approach_function(occName      = occName,
                             spData       = spData,
                             var_names    = var_names,
                             model_outDir = model_outDir,
                             eval_sp_Dir = eval_sp_Dir,
                             sp_Dir        = sp_Dir,
                             nFolds       = 5,
                             beta         = params_tunned$beta,
                             feat         = params_tunned$features,
                             doSDraster   = TRUE,
                             varImp       = TRUE,
                             validation   = FALSE)

# Output file: e.g. ./results/african_maize/lvl_1/3/africa/prj_models/3_prj_mean.tif
# Output file: e.g. ./results/african_maize/lvl_1/3/africa/prj_models/3_prj_median.tif
# Output file: e.g. ./results/african_maize/lvl_1/3/africa/prj_models/3_prj_std.tif
# Output file: e.g. ./results/african_maize/lvl_1/3/africa/prj_models/replicates/3_prj_rep-[1:5].tif (Five model repetitions complete distribution)
# Output file: e.g. ./results/african_maize/lvl_1/3/africa/prj_models/replicates/3_prj_th_rep-[1:5].tif (Five model repetitions thresholded distribution)


#*****************************************************************************************************************
#***************        SECTION: Ex situ GAP ANALYSIS CALCULATION             ***********************************
#***************************************************************************************************************#
#x <- readRDS("D:/GAP_ANALYSIS_LANDRACE/results/Miracle_fruit/lvl_1/Cucurbita maxima/africa/sdm.rds")

#reading land use raster
lu_raster <- terra::rast(paste0(input_data_dir,"/generic_rasters/","land_cover_5km_for_cleaning.tif"))
#reading native area 
narea_shp <- sf::st_read(paste0(input_data_dir,"/nareas/",occName,"/narea.shp"))
#cropping land use to native area
lu_raster_narea <- terra::crop(lu_raster,narea_shp, mask=TRUE)

#lu_raster_narea <- terra::mask(lu_raster_narea,narea_shp)
#obtaining binary SDM
sdm <- terra::rast(paste0(model_outDir,"/", occName, "_prj_median_th.tif" ))
#masking data to native areas
sdm_crop <- terra::crop(x = sdm_crop,narea_shp, mask=TRUE)

lu_raster_narea = terra::resample(lu_raster_narea, sdm_crop,method="near")

#polishing results
sdm_crop <- sdm_crop*lu_raster_narea
#saving species
terra::writeRaster(sdm_crop,paste0(model_outDir,"/", occName, "_prj_median_th_cropped.tif" ))

#transforming 0 into NA
sdm_crop[sdm_crop[]==0]<- NA


#Loading original data for Gap Analysis
data_orig <- choose.files()
data_orig <- read.csv(data_orig)
#formatting data
data_orig <- data_orig[data_orig$CROPNAME %in% occName,]
data_orig <- data_orig[,c("CROPNAME","DECLATITUDE","DECLONGITUDE","status")]
colnames(data_orig) <- c("species", "latitude", "longitude", "type")
#GapAnalysis::GetDatasets() #RUN ONCE


# mask_africa <- terra::rast("D:/GAP_ANALYSIS_LANDRACE/input_data/mask/mask_africa.tif")
# mask_africa[which(mask_africa[]==1)] <- 0
#data(ecoregions)



# x1 <- SRSex(Species_list = occName,
#       Occurrence_data = data_orig)
# x2 <- GRSex(Species_list = occName,
#             Occurrence_data = data_orig,
#             Raster_list = sdm,
#             Buffer_distance = 50000,
#             Gap_Map = T)
# 
# 
# x3 <- ERSex(Species_list = occName,
#             Occurrence_data = data_orig,
#             Raster_list = sdm,
#             Buffer_distance = 50000,
#            Gap_Map = T)

#Run all Gap Analysis in one function
FCSex_df <- FCSex(Species_list=occName,
                  Occurrence_data=data_orig,
                  Raster_list=sdm_crop,
                  Buffer_distance=50000,
                  Ecoregions_shp=NULL,Gap_Map = TRUE
)

#save gap map
terra::writeRaster(FCSex_df$GRSex_maps[[1]],paste0(gap_outDir,"/","gap_map.tif"),overwrite=T)
write.csv(FCSex_df$FCSex,paste0(gap_outDir,"/","gap_exsitu_results.csv"),na = "",row.names = F)


# plot(mask_africa,col="black")
# plot(FCSex_df$GRSex_maps[[1]],add=T,col="green")
