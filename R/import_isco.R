# Import ISCO labels 
# Authors: Kristina Schüpbach
# Date: 19.01.2023

# This needs to be done on another server with internet connection.

# Intro -----
library(tidyverse)

# NEW VERSION:
"https://www.i14y.admin.ch/de/catalog/datasets/HCL_CH_ISCO_19_PROF_1_2_1/api"
"https://www.i14y.admin.ch/api/Nomenclatures/HCL_CH_ISCO_19_PROF_1_2_1/levelexport/CSV?language=de&level=1&annotations=false"

# ISCO Labels (de / fr / it) ---------------------------------
df <- read.csv("https://www.i14y.admin.ch/api/Nomenclatures/HCL_CH_ISCO_19_PROF/levelexport/CSV?language=de&level=4&annotations=false")

# Function to import labels
get_isco_labels <- function(path, language, level, annotations = "false"){
  query <- paste0("language=", language, 
                  "&level=", level, 
                  "&annotations=", annotations)
  call <- paste0("https://www.i14y.admin.ch/api/Nomenclatures/HCL_CH_ISCO_19_PROF/levelexport/CSV?", query)
  df <- read.csv(call)
  df <- df %>%
    rename(!!paste0("cod_isco", level) := Code,
           !!paste0("txt_isco", level) := !!paste0("Name_", language)) 
  if(level==1) df <- df %>% select(-Parent)
  if(level==2) df <- df %>% rename("cod_isco1" = "Parent")
  if(level==4) df <- df %>% rename("cod_isco2" = "Parent")
  write.csv(df, file = paste0(path, "label_isco", level, "_", language, ".csv"), row.names = FALSE)
  message(paste0("Labels for ISCO-0", level, " , language = ", language, " downloaded." ))
}

# Import all german labels for levels 1,2,4
languages <- c("de")
iscolevels <- c(1,2,3,4)

for(lang in languages){
  for(lev in iscolevels){
    get_isco_labels(path = "data/", language = lang, level = lev)
  }
}

# Import all labels for level 6
languages <- c("de", "fr", "it", "en")
iscolevels <- c(6)

for(lang in languages){
  for(lev in iscolevels){
    get_isco_labels(path = "data/", language = lang, level = lev)
  }
}

# All languages together for level 6
level <- 6
query <- paste0("&level=", level, 
                "&annotations=", "false")
call <- paste0("https://www.i14y.admin.ch/api/Nomenclatures/HCL_CH_ISCO_19_PROF/levelexport/CSV?", query)
df <- read.csv(call)
df <- df %>% rename(!!paste0("cod_isco", level) := Code)
colnames(df) <- str_replace(colnames(df), "Name_", "txt_isco_")
write.csv(df, file = paste0("data/", "label_isco", level, "_", "all", ".csv"), row.names = FALSE)



# English isco -----------------------
label_isco_en <- readxl::read_excel(here::here("data-raw", "isco", "label_isco_en.xlsx"), sheet="ISCO-08 English version")

# label_isco_en <- label_isco_en %>% 
#   mutate(name = paste0("cod_isco", nchar(isco)),
#          value = as.numeric(isco))

label_isco_en <- label_isco_en %>% 
  mutate(isco_level = nchar(isco),
         cod_isco = as.numeric(isco)) %>% 
  select(isco_level, cod_isco, txt_isco = isconame_clean)

for(i in 1:4){
  lab <- label_isco_en %>% 
    filter(isco_level == i) %>% 
    select(cod_isco, txt_isco)
  colnames(lab) <- paste0(c("cod_isco", "txt_isco"), i)
  write.csv(lab, file = paste0("data/", "label_isco", i, "_en.csv"), row.names = FALSE)
}

