# Import ISCO labels 
# Authors: Kristina Schüpbach
# Date: 19.01.2023

# This needs to be done on another server with internet connection.

# Intro -----
library(tidyverse)

# ISCO Labels ---------------------------------
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

# Import all german and english labels for levels 1,2,4
languages <- c("de", "en")
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

