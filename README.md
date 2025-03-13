# bolder-gapanalysis-cwr
______
# Crop Wild Relatives GapAnalysis R
______
# The GapAnalysis R package is under development nowadays! (THIS IS NOT THE OFFICIAL REPO!)

#### changes 
gbuffer has been revamped to use terra. This still returns a sp object so it's not package wide alternation. 

FCSex, ERSex, GRSex functions have remove name space funciton calls when calling (gBuffer, ERSex, GRSex) to allow these replacement function to be source directly from this repo. 

## Description
This repo was designed for BOLDER project Gap Analysis in order to obtain a spevies distribution model using the approach used in Ramirez-Villegas et al.,(2022). In consequence this set of codes were modified to perform the following steps:
- Load a data frame with accessions info
- Remove coordinates in sea
- obtain pseudoabsences using ecorregions
- Calibrate SDM maxent hyper parameters and variables with low VIF + PCA correlations
- Obtain species distribution model using Maxent via Maxnet R approach
- obtain an ensemble using the median
- create a threshold SDM using the maximum sum of specificity and sensitivity
- Save a CSV file with evaluation metrics
- Polish species distribution model using native areas (Shapefile) and land use (resampled file from https://esa-worldcover.org/en)
- Run Ex-situ Gap Analysis and obtain gap map per species
- Save maps in tif format
- Save gap metrics

## Installation of GapAnalysis (First step)
GapAnalysis can be installed as follows
```r
#CRAN
install.packages("GapAnalysis")
#Alternative: GitHub
library(devtools)
remotes::install_github("ccsosa/GapAnalysis")
```
______
## Installation of this repo (Second step)
Please download this repo by:
- Click on <> Code
- Download ZIP
- Unzip in your local computer
______
## Prepare your files (Third step)
Please download the following files: 
- land_cover_5km_for_cleaning.tif
- Crop and mask WorldClim layers v2.1.
- A mask for Africa in tif format
- World_ELU_2015 (https://www.aag.org/wp-content/uploads/2021/12/AAG_Global_Ecosyst_bklt72.pdf)
- Alternatively native areas (Please see narea_approach.R code)
- Prepare your data with the following columns: 

  - CROPNAME (Species name)
  - DECLATITUDE (Latitude in decimal format)
  - DECLONGITUDE (Longitude in decimal format)
  - database_id  (Source database)
  - status (G for Germplasm, and H for other sources)

 ________

# Other steps:
 - prepare native areas: Prepare a Excel file with the species name, and country. please see narea_approach.R. This code will create shapefiles using the geodata R package.


# Crop Wild Relatives Gap Analysis: Master Code Documentation
Overview
This R script performs a comprehensive gap analysis using part of the Species distribution model of the Landraces Gap Analysis.
 The analysis integrates species distribution modeling (SDM) with ex-situ conservation assessments to identify geographical areas where crop genetic diversity is underrepresented in genebank collections. The workflow combines data preparation, environmental variable selection, species distribution modeling, and conservation gap analysis.

1. Setup and Configuration

Initial cleanup and R options configuration
Loading required R packages
Setting up directory structure based on operating system
Loading crop-specific configuration

2. Input Data Preparation

prepare_input_data(): Processes passport data (latitude, longitude, and conservation status)
create_occ_shp(): Creates occurrence shapefiles from genebank accession data

3. Species Distribution Modeling

pseudoAbsences_generator(): Creates background points for modeling and selects environmental variables
Calibration_function(): Tunes MaxEnt parameters (regularization multiplier and feature types)
sdm_maxnet_approach_function(): Runs the species distribution model with cross-validation

4. Ex-situ Conservation Gap Analysis

Preparation of modeling outputs:

Crops SDM to native area
Filters by land use suitability
Formats occurrence data

FCSex(): Calculates conservation metrics including:

Sampling Representativeness Score (SRS)
Geographic Representativeness Score (GRS)
Ecological Representativeness Score (ERS)
Final Conservation Score (FCS)

Output Files

Species distribution model projections (mean, median, standard deviation)
Thresholded distribution maps
Gap analysis metrics in CSV format
Gap maps identifying priority areas for collection

