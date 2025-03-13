Native Area Generator Function Documentation

#' Generate Native Area Shapefiles for Crop Species
#'
#' This function creates native area shapefiles for a list of crop species by
#' downloading administrative boundary data for countries where each species is native.
#' It reads species and country information from an input file, converts country names 
#' to ISO3 codes, and downloads and combines boundary data into shapefiles.
#'
#' @param input_file Character string. Path to an Excel file containing species and country data.
#'                   Must have columns named 'species' and 'country'.
#' @param output_dir Character string. Directory where species folders and shapefiles will be saved.
#' @param admin_level Numeric. Level of administrative boundaries to download (default: 0 for national level).
#' @param resolution Numeric. Resolution of boundary data (1: low, 2: high) (default: 1).
#' @param version Character string. Version of GADM data to use (default: "latest").
#'
#' @return List of paths to the created shapefiles, named by species.
#'
#' @importFrom readxl read_xlsx
#' @importFrom countrycode countrycode
#' @importFrom geodata gadm
#' @importFrom sf st_as_sf write_sf
#'
#' @examples
#' \dontrun{
#' # Generate native area shapefiles for crop species
#' shp_paths <- generate_native_areas(
#'   input_file = "path/to/species_countries.xlsx",
#'   output_dir = "path/to/output"
#' )
#' }
#'
#' @export

require(geodata)
require(countrycode)
require(readxl)
#***Preprocessing***#
#obtain data
data <- readxl::read_xlsx("D:/GAP_ANALYSIS_LANDRACE/input_data/by_crop/Native_areas.xlsx")
#transforming countries to ISO3
data$ISO3 <- countrycode::countrycode(data$country,origin = 'country.name', destination = 'iso3c')
#obtaining data to obtain native area shp
species <- unique(data$species)

#***creating folder structure***#
dir <- ""

for(i in 1:length(species)){
    #creating subfolders
  sp_dir <- paste0(dir,"/",species[[i]])
  if(!dir.exists(sp_dir)){dir.create(sp_dir)}
  #subsetting nareas per species
  countries <-data[which(data$species==species[[i]]),]
  countries <- countries$ISO3
  #downloading adm0 per country
  x <- geodata::gadm(countries, 
                     level=0,
                     path=sp_dir,
                     version="latest",
                     resolution=1)
  x <- sf::st_as_sf(x)
  #saving
  sf::write_sf(x,paste0(sp_dir,"/","narea.shp"))
  }
