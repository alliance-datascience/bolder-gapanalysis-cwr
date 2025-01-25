#### FUNCTION TO CREATE THE SHAPEFILE OF OCCURRENCES ####
# AUTHOR: ANDRES CAMILO MENDEZ ALZATE
###############################################


create_occ_shp <- function(file_path, file_output, validation ){
  
  message("Importing data base \n")
  msk <- terra::rast(mask)
  db_path <- paste0(file_path, "/", crop, "_", level, "_bd.csv")

  Occ <- read.csv(db_path, header  = TRUE, stringsAsFactors = F)
  Occ$ID <- 1:nrow(Occ)

  if("status" %in% names(Occ)){
    Occ <- Occ %>% dplyr::filter(., status == "G") %>% dplyr::select(., "Longitude", "Latitude", one_of(c("Y", "ensemble")), ID)  
  } else{
    Occ <- Occ  %>% dplyr::select(., "Longitude", "Latitude", one_of(c("Y", "ensemble")), ID)
  }
  
  
  
  names(Occ) <- c("Longitude", "Latitude", "ensemble", "ID")
  Occ$ensemble <- as.character(Occ$ensemble)
  #Occ <- Occ[which(Occ$ensemble == occName),]
  
  message("Removing coordinates on the ocean/sea \n")
  Occ <- Occ[which(!is.na(terra::extract(x = msk, y = Occ[,c("Longitude", "Latitude")]))),]
  
  message("Removing duplicated coordinates \n")
  
  #remove repeated coordinates
  #rep <- which(duplicated( raster::extract(msk, Occ[, c("Longitude", "Latitude")], cellnumbers = TRUE)  ))
  #if(length(rep) != 0){
   # Occ  <- Occ[-rep, ]
  #}
  
  #spData <- spData[-rep, ]
  Occ <- Occ[which(!is.na(Occ$Longitude)),]
  Occ$cellID <-NA
  Occ$cellID <-terra::extract(msk, Occ[,1:2], cellnumbers=TRUE) 
  Occ <-Occ[!duplicated(Occ$cellID),-which(names(Occ) %in% c("cellID"))]
  
  
  #add column to identifiers bd and fill it based on valid occurrences
  ids_path <- paste0(file_path, "/", crop, "_bd_identifiers.csv")
  if(file.exists(ids_path) & !validation){
    ids_db <- read.csv(ids_path, header = T, stringsAsFactors = F)
    
    if(is.null(ids_db$used)){
      ids_db$used <- FALSE
    }
    ids_db$used[Occ$ID] <- TRUE
    
    write.csv(ids_db, ids_path, row.names = F)
    rm(ids_db)
  } 
  
Occ$ID <- NULL
  
  #save occurrences in csv format
  write.csv(Occ, paste0(occDir, "/Occ.csv"), row.names = FALSE)
  write.csv(Occ, paste0(input_data_aux_dir, "/Occ.csv"), row.names = FALSE)
  
  coordinates(Occ) <- ~Longitude+Latitude
  terra::crs(Occ)  <- terra::crs(msk)
  #Occ@bbox <- matrix(raster::extent(msk), ncol = 2, byrow = T)
  message("Saving occurrences \n")
  if(!file.exists(file_output)){
    sf::st_write(sf::st_as_sf(Occ), file_output, overwrite = T)
  } else {
    sf::st_read(file_output)
    
  }

  
  #save the same file but into the results folder
  if(!validation){
    if(!file.exists(paste0(input_data_aux_dir, "/Occ.shp"))){
      sf::st_write(sf::st_as_sf(Occ), paste0(input_data_aux_dir, "/Occ.shp"), overwrite = T)
    } else {
      sf::st_read(paste0(input_data_aux_dir, "/Occ.shp"))
      
    }
    
  }
  
  
  #writeOGR(Occ, paste0(occDir,"/Occ.shp"), "Occ", driver="ESRI Shapefile", overwrite_layer=TRUE)
  
  message(">>> Total number of occurrences:", nrow(Occ), " \n")
  

  
}






