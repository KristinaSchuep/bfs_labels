# Import Gemeindenummern und Kantone 
# Authors: Kristina Schüpbach
# Date: 29.03.2023

# This needs to be done on another server with internet connection.

# Intro -----
library(tidyverse)

# Gemeindelabels ------------------------------------------------------------

cant <- read.csv("https://www.i14y.admin.ch/api/Nomenclatures/CL_KT_BEZ_GDE_SNAP_2022-05-01/levelexport/CSV?language=de&level=2&annotations=false")
bez <- read.csv("https://www.i14y.admin.ch/api/Nomenclatures/CL_KT_BEZ_GDE_SNAP_2022-05-01/levelexport/CSV?language=de&level=3&annotations=false")
gem <- read.csv("https://www.i14y.admin.ch/api/Nomenclatures/CL_KT_BEZ_GDE_SNAP_2022-05-01/levelexport/CSV?language=de&level=4&annotations=false")

df <- gem %>% 
  left_join(bez %>% select(-Name_de), by = c("Parent" = "Code")) %>% 
  select(-Parent) %>% 
  rename(cod_gemeinde = Code,
         canton = Parent.y,
         txt_gemeinde = Name_de) %>% 
  arrange(cod_gemeinde)

write.csv(df, file = paste0("data/label_gemeinde_kanton.csv"), row.names = FALSE)

# Stand 2018 -----------------
# Download data for each year here: https://www.agvchapp.bfs.admin.ch/de/state/query 

l <- lapply(2018:2022, function(x){
  df <- readxl::read_xlsx(paste0("data-raw/gemeindenummer/Gemeindestand_", x, ".xlsx"))
  df <- df %>% mutate(year = x)
  return(df)
})

df <- l %>% 
  bind_rows() %>% 
  select(year, 
         cod_gemeinde = `BFS Gde-nummer`,
         txt_gemeinde = Gemeindename,
         canton = Kanton)

# Some diagnostics -----
# df %>% 
#   distinct(cod_gemeinde, canton) %>% 
#   nrow()
# 
# df %>% 
#   group_by(cod_gemeinde) %>% 
#   mutate(unique_name = n_distinct(txt_gemeinde)) %>% 
#   filter(unique_name > 1) %>% 
#   arrange(cod_gemeinde)
# 
# df %>% 
#   group_by(txt_gemeinde) %>% 
#   mutate(unique_cod = n_distinct(cod_gemeinde)) %>% 
#   filter(unique_cod > 1) %>% 
#   arrange(txt_gemeinde)

df <- df %>%
  distinct(cod_gemeinde, txt_gemeinde, canton, year) 

# Save ----
write.csv(df, file = "data/label_gemeinden.csv", row.names = FALSE)
write.csv(df, file = "U:/My Documents/Transfer/label_gemeinden.csv", row.names = FALSE)
