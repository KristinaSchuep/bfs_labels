# Import NOGA labels 
# Authors: Kristina Schüpbach
# Date: 19.01.2023

# This needs to be done on another server with internet connection.

# Intro -----
library(tidyverse)

# NOGA labels -------------

# Function to import labels
get_noga_labels <- function(path, language, level, annotations = "false"){
  query <- paste0("language=", language, 
                  "&level=", level, 
                  "&annotations=", annotations)
  call <- paste0("https://www.i14y.admin.ch/api/Nomenclatures/HCL_NOGA/levelexport/CSV?", query)
  df <- read.csv(call)
  df <- df %>%
    rename(!!paste0("cod_noga", level) := Code,
           !!paste0("txt_noga", level) := !!paste0("Name_", language)) 
  if(level==1) df <- df %>% select(-Parent)
  if(level==2) df <- df %>% rename("cod_noga1" = "Parent")
  if(level==4) df <- df %>% rename("cod_noga2" = "Parent")
  write.csv(df, file = paste0(path, "label_noga", level, "_", language, ".csv"), row.names = FALSE)
  message(paste0("Labels for NOGA-0", level, " , language = ", language, " downloaded." ))
}

# Import all german and english labels for levels 1,2,4
languages <- c("de", "en")
nogalevels <- c(1,2,4)

for(lang in languages){
  for(lev in nogalevels){
    get_noga_labels(path = "data/", language = lang, level = lev)
  }
}

# Additionally get short labels for NOGA-01
get_noga_labels(path = "data/", language = "de", level = 1, annotations = "true")

# Add better short names for NOGA-01
label_noga_1st <- read.csv("data/label_noga1_de.csv", sep = ",", fileEncoding = "UTF-8")

label_noga_1st <- label_noga_1st %>% 
  select(cod_noga1, txt_noga1, ABBREV_Text_de) %>% 
  rename(txt_noga1_short = ABBREV_Text_de,
         txt_noga1_long = txt_noga1) %>% 
  mutate(txt_noga1 = factor(recode(cod_noga1,
                                      "A"="Land- und Forstwirtschaft",
                                      "B"="Industrie",
                                      "C"="Industrie",
                                      "D"="Industrie",
                                      "E"="Industrie",
                                      "F"="Baugewerbe",
                                      "G"="Handel",
                                      "H"="Verkehr und Lagerei",
                                      "I"="Gastgewerbe",
                                      "J"="Information und Komm.",
                                      "K"="Finanzbranche",
                                      "L"="Immobilienwesen",
                                      "M"="Wissensch. u. techn. DL",
                                      "N"="Sonstige wirtschaft. DL",
                                      "O"="Öffentliche Verwaltung",
                                      "P"="Bildungswesen",
                                      "Q"="Gesund.- und Sozialwesen",
                                      "R"="Kunst und Unterhaltung",
                                      "S"="Übrige Dienstleistungen",
                                      "T"="Übrige Dienstleistungen",
                                      "U"="Übrige Dienstleistungen")))
write.csv(label_noga_1st, "data/label_noga1_de.csv", row.names = FALSE)
