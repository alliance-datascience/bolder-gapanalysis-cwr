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
dir <- "D:/DDD"

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
