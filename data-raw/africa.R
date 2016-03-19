library(dplyr)
library(raster)
library(readr)

# Make list of African Nations
continent.url <- "http://dev.maxmind.com/static/csv/codes/country_continent.csv"
wrld.list <- raster::ccodes() %>%
  data.frame(., stringsAsFactors = FALSE) %>% tbl_df() %>%
  dplyr::select(ISO3, ISO2)

afr.list <- readr::read_csv(continent.url, na = "", skip = 1,
                                    col_names = c("ISO2", "continent")) %>%
  dplyr::filter(continent == "AF", !is.na(ISO2)) %>%
  dplyr::select(ISO2) %>%
  dplyr::left_join(x = .,
                   y = wrld.list,
                   by = "ISO2") %>%
  mutate(ISO3 = ifelse(is.na(ISO3), "NAM", ISO3))

# Get data
load_rasters <- function(cc) {
  data <- raster::getData(name = "GADM", country = cc,
                  level = 0, path = "data-raw")
  sp::spChFIDs(data, data$ISO)
}

countries <- lapply(afr.list$ISO3, load_rasters)
africa <- do.call(rbind, countries)
# summary(africa)
# plot(africa)

# Clean up
file.remove(list.files(path = "data-raw", pattern = "*.rds$", full.names = TRUE))
rm(countries, afr.list, wrld.list, continent.url)

# Package data
devtools::use_data(africa, overwrite = TRUE)

# rgdal::writeOGR(africa, dsn = "africa.geojson",
#                 layer = "africa", driver = "GeoJSON")
