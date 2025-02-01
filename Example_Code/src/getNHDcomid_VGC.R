getNHDcomid_VGC <- function(df = sites){
  #install.packages("crayons")
  #library('crayons')
  #Select NHD flowlines that df are located on, subsequently getting NHD metadata for each sample location.
  subset_nhdplus(comids = df$comid,
                 output_file = 'data/site_flowlines.gpkg',
                 nhdplus_data = 'download',
                 overwrite = TRUE,
                 return_data = FALSE,
                 flowline_only = TRUE,
                 out_prj = 4269)
  
  
  df_points <- st_read('data/site_flowlines.gpkg', quiet = T)
  
  # st_read only has one entry for each comid which is a problem for duplicated comids
  # Find the duplicated comids in df and then add the extra rows
  if (nrow(df_points) != nrow(df)) {
    print("Your data has duplicate or triplicate COMIDs")
    
    # Create a new data frame to combine the rows
    dat <- NULL
    new_df <- NULL
    
    for (i in 1:nrow(df)) {
      # Find all rows in df_points that match the current comid
      temp <- df_points[df_points$comid == df$comid[i],]
      dat <- rbind(dat, temp)  # Add these rows to the combined data frame
      new_df <- rbind(new_df, df[i,])  # Keep a corresponding row in new_df
    }
    
    # Update df_points and df with combined data
    df_points <- dat
    df <- new_df
    
    # Ensure both df and df_points do not have duplicate or triplicate comids
    df_points <- df_points[!duplicated(df_points$comid),]
    df <- df[!duplicated(df$comid),]
    # Update df to only include comids in df_points
    df <- df[df$comid %in% df_points$comid,]
  }
  
  
  
  
  # Now df and df_points should have the correct rows, removing duplicates and adding extra rows where necessary
  
  
  coords <- vector("list", length = nrow(df_points))
  
  for(i in 1:nrow(df_points)){
    
    coords[[i]] <- df_points[i,] %>%
      st_coordinates() %>%
      as_tibble() %>%
      head(., 1)
  }
  
  coords <- bind_rows(coords) %>%
    cbind(df, .) %>%
    dplyr::select(site, comid, longitude = X, latitude = Y) %>%
    st_as_sf(., coords = c('longitude','latitude'), crs = 4269)
  
  # Link NHD hydrologic unit code (HUC, essentially sub-watershed polygons) data to each sample.
  site_hucs <- list()
  
  for(i in 1:nrow(coords)){
    site_hucs[[i]] <- get_huc(coords[i,], t_srs=4269, type = 'huc12') #VGC: get_huc12 is deprecated, using new fuction 'get_huc' and adding huc12 to the fuction spects 
  }
  
  site_hucs <- do.call('rbind',site_hucs) %>%
    mutate(huc2 = paste0('HUC-',str_sub(huc12,end = 2)),
           huc4 = paste0('HUC-',str_sub(huc12,end = 4)),
           huc6 = paste0('HUC-',str_sub(huc12,end = 6)),
           huc8 = paste0('HUC-',str_sub(huc12,end = 8)),
           huc10 = paste0('HUC-',str_sub(huc12,end = 10)),
           huc12 = paste0('HUC-',huc12)) %>%
    dplyr::select(huc2,huc4,huc6,huc8,huc10,huc12)
  
  
  site_lines <- st_read('data/site_flowlines.gpkg', quiet = T) %>%
    #if necessary, remove duplicates that happen due to multiple samples on the same NHD feature:
    distinct(comid,.keep_all=TRUE) %>% 
    st_join(.,site_hucs) %>%
    distinct(comid,.keep_all=TRUE) %>%
    as_tibble()
  
  # st_read removes duplicates again but there is no need to fix it by hand because coords has all the sites and the duplicates are added again with the left join
  # 
  #join site points to NHD data
  coords <- coords %>%
    left_join(site_lines,by='comid') %>%
    dplyr::select(-c(geometry, geom)) %>%
    mutate(across(1:145, as.character)) %>%
    mutate(comid = as.integer(comid))
  
  print(paste0(nrow(coords), " locations linked to the NHD."))
  
  return(coords)
  
}

