# Import BFS country codes and labels 
# Authors: Kristina Schüpbach
# Date: 03.06.2024

# This needs to be done on another server with internet connection.

# Intro -----
library(tidyverse)

# Import data ---------------------------------
httr::GET("https://dam-api.bfs.admin.ch/hub/api/dam/assets/32028071/master/", 
          httr::write_disk(tf <- tempfile(fileext = ".xlsx")))
df <- readxl::read_excel(tf, sheet = "Stat_Geb")
unlink(df)


# Clean ----------------------------------------
df2 <- df[, 1:15]
colnames(df2) <- c("cod_country_bfs",
                   "cod_country_uno",
                   "cod_country_iso2",
                   "cod_country_iso3",
                   "txt_country_de",
                   "txt_country_fr",
                   "txt_country_it",
                   "txt_country_en",
                   "txt_country_official_de",
                   "txt_country_official_fr",
                   "txt_country_official_it",
                   "cod_continent",
                   "cod_country_region",
                   "is_country",
                   "territory_belongs_to_country")

data.table::fwrite(df2, file = paste0("data/label_country_bfs_codes.csv"), row.names = FALSE)



