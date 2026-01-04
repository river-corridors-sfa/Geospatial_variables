library(terra)
library(sf)
library(dplyr)
library(stringr)
library(tidyr)

ws_path    <- "C:/Users/gara009/OneDrive - PNNL/Documents/GitHub/Geospatial_variables/Example_Code/shape/v4_RCSFA.shp"
id_col     <- "comid"

modis_dir  <- "C:/Users/gara009/OneDrive - PNNL/Documents/GitHub/Geospatial_variables/Example_Code/data/MODIS"
start_year <- 2001
end_year   <- 2020

out_annual_csv <- sprintf("watershed_pet_npp_annual_%d_%d.csv", start_year, end_year)
out_mean_csv   <- sprintf("watershed_pet_npp_multiyearmean_%d_%d.csv", start_year, end_year)

get_year <- function(x) {
  y <- str_match(basename(x), "doy(\\d{4})")[,2]
  as.integer(y)
}

assert_one_per_year <- function(years_vec, label) {
  tab <- table(years_vec)
  if (any(tab > 1)) stop("Duplicate ", label, " files found for year(s): ",
                         paste(names(tab)[tab > 1], collapse=", "))
}

# ---- read watersheds ----
ws_sf <- st_read(ws_path, quiet = TRUE)
if (!(id_col %in% names(ws_sf))) stop("Watershed ID column '", id_col, "' not found.")
ws <- terra::vect(ws_sf)

# ---- list files ----
files_all <- list.files(modis_dir, pattern="\\.tif$", full.names=TRUE, recursive=TRUE)

pet_files_all <- files_all[str_detect(files_all, "MOD16A3GF\\.061_PET_500m_")]
npp_files_all <- files_all[str_detect(files_all, "MOD17A3HGF\\.061_Npp_500m_")]

years <- start_year:end_year

pet_years_all <- sapply(pet_files_all, get_year)
npp_years_all <- sapply(npp_files_all, get_year)

pet_files <- pet_files_all[!is.na(pet_years_all) & pet_years_all %in% years]
npp_files <- npp_files_all[!is.na(npp_years_all) & npp_years_all %in% years]

pet_years <- sapply(pet_files, get_year)
npp_years <- sapply(npp_files, get_year)

if (length(pet_files) == 0) stop("No PET files found in year range.")
if (length(npp_files) == 0) stop("No NPP files found in year range.")

assert_one_per_year(pet_years, "PET")
assert_one_per_year(npp_years, "NPP")

# sort
pet_ord <- order(pet_years); pet_files <- pet_files[pet_ord]; pet_years <- pet_years[pet_ord]
npp_ord <- order(npp_years); npp_files <- npp_files[npp_ord]; npp_years <- npp_years[npp_ord]

# ---- read rasters ----
pet <- terra::rast(pet_files) * 0.1     # PET needs scaling
npp <- terra::rast(npp_files)           # NPP already in kgC/m2/yr (per your global() check)

names(pet) <- paste0("PET_", pet_years)
names(npp) <- paste0("NPP_", npp_years)

# ---- project watersheds to EACH raster CRS (avoid resampling) ----
ws_pet <- terra::project(ws, terra::crs(pet))
ws_npp <- terra::project(ws, terra::crs(npp))

# ---- extract zonal means ----
pet_ws <- terra::extract(pet, ws_pet, fun = mean, na.rm = TRUE)
npp_ws <- terra::extract(npp, ws_npp, fun = mean, na.rm = TRUE)

ws_ids <- ws_sf |> st_drop_geometry() |> select(all_of(id_col))

pet_ws <- bind_cols(ws_ids, pet_ws |> select(-ID))
npp_ws <- bind_cols(ws_ids, npp_ws |> select(-ID))

# ---- long + join ----
pet_long <- pet_ws |>
  pivot_longer(starts_with("PET_"), names_to="layer", values_to="PET") |>
  mutate(year = as.integer(sub("PET_", "", layer))) |>
  select(-layer)

npp_long <- npp_ws |>
  pivot_longer(starts_with("NPP_"), names_to="layer", values_to="NPP") |>
  mutate(year = as.integer(sub("NPP_", "", layer))) |>
  select(-layer)

ws_annual <- pet_long |>
  inner_join(npp_long, by = c(id_col, "year")) |>
  arrange(!!sym(id_col), year)

ws_mean <- ws_annual |>
  group_by(!!sym(id_col)) |>
  summarise(
    PET_mean = mean(PET, na.rm=TRUE),
    NPP_mean = mean(NPP, na.rm=TRUE),
    .groups="drop"
  )

write.csv(ws_annual, out_annual_csv, row.names=FALSE)
write.csv(ws_mean, out_mean_csv, row.names=FALSE)

cat("PET annual mean range (mm/yr): ", range(ws_annual$PET, na.rm=TRUE), "\n")
cat("NPP annual mean range (kgC/m2/yr): ", range(ws_annual$NPP, na.rm=TRUE), "\n")
