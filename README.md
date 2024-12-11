# bolder-gapanalysis-cwr

# Crop Wild Relatives GapAnalysis R
______
# The GapAnalysis R package is under development nowadays! (THIS IS NOT THE OFFICIAL REPO!)

#### changes 
gbuffer has been revamped to use terra. This still returns a sp object so it's not package wide alternation. 

FCSex, ERSex, GRSex functions have remove name space funciton calls when calling (gBuffer, ERSex, GRSex) to allow these replacement function to be source directly from this repo. 

## Description
This repo was designed for BOLDER project Gap Analysiss

## Installation
GapAnalysis can be installed as follows
```r
#CRAN
install.packages("GapAnalysis")
#Alternative: GitHub
library(devtools)
remotes::install_github("ccsosa/GapAnalysis")
```
A full list of libraries needed for the package is included below.

**Dependencies:** `raster`

**Imports:** `base, utils, sp, tmap, data.table, sf, methods, geosphere, data.table, fasterize, rmarkdown`

**Suggests:** `knitr, rgdal, rgeos, kableExtra, DT`
