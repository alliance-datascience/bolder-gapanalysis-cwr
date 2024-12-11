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

