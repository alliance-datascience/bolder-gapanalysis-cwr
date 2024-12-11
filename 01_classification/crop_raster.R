#ANDRES CAMILO MENDEZ
#SCRIPT TO CROP ALL GENERIC AND SPECIFIC RASTERS


crop_raster <- function(mask, region){
  
  
  mask <- terra::rast(mask)
  #crop rasters from by_crop folders
  
  files <- data.frame(fullnames = list.files(clim_spWorld, pattern = ".tif$", full.names = TRUE),
                names = list.files(clim_spWorld, pattern = ".tif$", full.names = FALSE))
  if(nrow(files) != 0){
  apply(files, 1,function(x){
    
  if(!file.exists(paste0(clim_spReg, "/", x[2]))) { 
    cat("Croping: ", x[2], "\n")
    x[1] %>% terra::rast(.) %>% terra::crop(x = ., y = terra::ext(mask)) %>% raster::mask(x = ., mask = mask) %>%
      writeRaster(., paste0( clim_spReg, "/", x[2]), overwrite = TRUE)
 }
    
  })
   }
#   #crop rasters from generic_rasters
#   clim_world <- paste0(input_data_dir, "/generic_rasters/world")
#   files <- data.frame(fullnames = list.files(clim_world, pattern = ".tif$", full.names = TRUE),
#   names = list.files(clim_world, pattern = ".tif$", full.names = FALSE))
# 
#   apply(files, 1,function(x){
#     
#  #   if(!file.exists(paste0(climDir, "/", x[2]))) { 
#       cat("Croping: ", x[2], "\n")
#       x[1] %>% terra::raster(.) %>% terra::crop(x = ., y = terra::ext(mask)) %>% terra::mask(x = ., mask = mask) %>%
#         terra::writeRaster(., paste0( climDir, "/", x[2]), overwrite = TRUE)
# #    }
#     
#   })
  
  
}#end function
