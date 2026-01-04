rm(list = ls(all = TRUE))

require(pacman)
p_load(
  readr, dplyr, tibble, tidyr,
  exactextractr, raster, sf
)

Net_Primary_Production <- "C:/Users/gara009/OneDrive - PNNL/Documents/GitHub/Geospatial_variables/Example_Code/KN_Data_R_Code/data_dir/CONUS2021_NPP_kgCm2.tif"
Evapotranspiration     <- "C:/Users/gara009/OneDrive - PNNL/Documents/GitHub/Geospatial_variables/Example_Code/KN_Data_R_Code/data_dir/CONUS2021_ET_kgm2year.tif"
watershed_bnd          <- "C:/Users/gara009/OneDrive - PNNL/Documents/GitHub/Geospatial_variables/Example_Code/shape/v4_RCSFA.shp"
sites_csv              <- "v4_RCSFA_Geospatial_Data_Package/v4_RCSFA_Geospatial_Site_Information.csv"

getNPPandET <- function(
    NPP = Net_Primary_Production,
    ET  = Evapotranspiration,
    watersheds = watershed_bnd,
    compute_totals = TRUE,
    out_csv = paste0("v4_RCSFA_Extracted_NPP_ET_Correct_", Sys.Date(), ".csv")
) {
  
  fire_wtrshd <- st_read(watersheds, quiet = TRUE)
  
  npp_raw <- raster(NPP)
  et_raw  <- raster(ET)
  
  # ---- CRS harmonization (FIXED) ----
  crs_r <- st_crs(npp_raw)
  if (is.na(st_crs(fire_wtrshd)) || st_crs(fire_wtrshd) != crs_r) {
    fire_wtrshd <- st_transform(fire_wtrshd, crs_r)
  }
  
  # ---- Mask special/fill codes ----
  npp_raw[npp_raw >= 32700] <- NA
  et_raw[et_raw >= 65500]   <- NA
  
  # ---- Apply scale factors (raw ints -> physical units) ----
  npp <- npp_raw * 0.0001  # kgC/m2/yr
  et  <- et_raw  * 0.1     # kg/m2/yr (mm/yr)
  
  # ---- Area-weighted means ----
  out <- fire_wtrshd %>%
    mutate(
      NPP_mean_kgC_m2_yr = exact_extract(npp, fire_wtrshd, "mean"),
      ET_mean_kg_m2_yr   = exact_extract(et,  fire_wtrshd, "mean")
    )
  
  # ---- Optional totals (kg/yr) ----
  if (compute_totals) {
    
    # cell area (km^2) -> m^2; works for lon/lat
    cell_area_m2 <- raster::area(npp) * 1e6
    
    npp_total <- exact_extract(
      npp, out,
      fun = function(df) {
        sum(df$value * df$coverage_fraction * cell_area_m2[df$cell], na.rm = TRUE)
      },
      include_cell = TRUE,
      summarize_df = TRUE
    )
    
    et_total <- exact_extract(
      et, out,
      fun = function(df) {
        sum(df$value * df$coverage_fraction * cell_area_m2[df$cell], na.rm = TRUE)
      },
      include_cell = TRUE,
      summarize_df = TRUE
    )
    
    out <- out %>%
      mutate(
        NPP_total_kgC_yr = npp_total,
        ET_total_kg_yr   = et_total,
        ET_total_m3_yr   = et_total / 1000
      )
  }
  
  out_tbl <- out %>% st_drop_geometry() %>% as_tibble()
  write.csv(out_tbl, out_csv, row.names = FALSE)
  out_tbl
}

data <- getNPPandET(
  NPP = Net_Primary_Production,
  ET  = Evapotranspiration,
  watersheds = watershed_bnd,
  compute_totals = TRUE
)

sites <- read_csv(sites_csv, show_col_types = FALSE) %>%
  filter(COMID != -9999) %>%
  transmute(site = Site_ID, comid = COMID)

final_df <- data %>%
  full_join(sites, by = "comid") %>%
  mutate(site = coalesce(site.x, site.y)) %>%
  dplyr::select(site, everything(), -site.x, -site.y)

write.csv(final_df, paste0("v4_RCSFA_Extracted_NPP_ET_Correct_", Sys.Date(), ".csv"), row.names = FALSE)

cat("NPP mean range (kgC/m2/yr): ", range(final_df$NPP_mean_kgC_m2_yr, na.rm=TRUE), "\n")
cat("ET mean range (kg/m2/yr):   ", range(final_df$ET_mean_kg_m2_yr,   na.rm=TRUE), "\n")
