# Author: Kristian Nelson
# Date: 5/15/2023
# This script calculates Net Primary Productivity and 
# Evapotranspiration of fire watersheds.
##
# ########## #
# ########## #

# Set up packages.
rm(list=ls(all=T))
require(pacman)
p_load(readr,
       dplyr,
       tibble,
       exactextractr,
       tidyr,
       raster, 
       sf) 

# Required Datasets
Net_Primary_Production <- "C:/Users/gara009/OneDrive - PNNL/Documents/GitHub/Geospatial_variables/Example_Code/KN_Data_R_Code/data_dir/CONUS2021_NPP_kgCm2.tif"
Evapotranspiration <- "C:/Users/gara009/OneDrive - PNNL/Documents/GitHub/Geospatial_variables/Example_Code/KN_Data_R_Code/data_dir/CONUS2021_ET_kgm2year.tif"
watershed_bnd <-"C:/Users/gara009/OneDrive - PNNL/Documents/GitHub/Geospatial_variables/Example_Code/shape/v4_RCSFA.shp"


getNPPandET <- function(NPP = Net_Primary_Production, 
                          ET = Evapotranspiration, 
                          watersheds = watershed_bnd){
  # Read in shapefiles
  st_read(watersheds, quiet = TRUE) -> fire_wtrshd  
  
  # Read in NPP and ET rasters
  raster(NPP) -> npp
  raster(ET) -> et
  
  # Set up loop to extract data
  #fire_wtrshd[1:100,] -> fire_wtrshd2
  watershed_count <- 1:nrow(fire_wtrshd)
  watershed_list <- list()
  
  pb <- txtProgressBar(min = 1, max = nrow(fire_wtrshd), initial = 1)
  
  # Run through all watersheds and get NPP and ET values.
  for(i in watershed_count){
    setTxtProgressBar(pb,i)
    fire_wtrshd[i,] -> single_watershed
    
    # Get net primary productivity
    suppressWarnings(exact_extract(npp,single_watershed)) %>% 
      as.data.frame()-> npp_values
    npp_values$value * npp_values$coverage_fraction -> npp_amount
    sum(npp_amount, na.rm = TRUE) -> Total_kgCm2
    single_watershed$NPP_kgCm2 <- Total_kgCm2
    
    # Get evapotranspiration
    suppressWarnings(exact_extract(et,single_watershed)) %>% 
      as.data.frame()-> et_values
    et_values$value * et_values$coverage_fraction -> et_amount
    sum(et_amount, na.rm = TRUE) -> Total_kgm2year
    single_watershed$ET_kgm2year <- Total_kgm2year
    single_watershed %>% as_tibble %>% dplyr::select(c(1,2,4,5)) -> final
    i -> n
    watershed_list[[n]] <- final
  }
  close(pb)
  
  bind_rows(watershed_list) -> watersheds
  
  write.csv(watersheds,paste0("v4_RCSFA_Extracted_NPP_ET_Data_",Sys.Date(),".csv"),row.names = F)
  #return(watersheds)
  
}

getNPPandET(NPP = Net_Primary_Production, 
                  ET = Evapotranspiration, 
                  watersheds = watershed_bnd)

data = read.csv("v4_RCSFA_Extracted_NPP_ET_Data_2025-01-31.csv")
sites <- read_csv("v4_RCSFA_Geospatial_Data_Package/v4_RCSFA_Geospatial_Site_Information.csv")
sites = sites %>%
  filter(COMID!=-9999) %>% dplyr::select(site = 'Site_ID', comid = 'COMID')

final_df <- data %>%
  full_join(sites, by = "comid") %>%
  mutate(site = coalesce(site.x, site.y)) %>%
  dplyr::select(site, everything(), -site.x, -site.y)

write.csv(final_df,paste0("v4_RCSFA_Extracted_NPP_ET_Data_",Sys.Date(),".csv"), row.names = F)
