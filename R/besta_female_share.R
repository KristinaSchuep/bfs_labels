
library(pxR)
library(tidyverse)
'%!in%' <- function(x,y)!("%in%"(x,y))

besta <- pxR::read.px("https://www.pxweb.bfs.admin.ch/DownloadFile.aspx?file=px-x-0602000000_101",
                      encoding="cp1252")

besta <- as.data.frame(besta)

besta <- 
  besta %>% 
  filter(Quartal == "2018Q3", 
         Besch�.ftigungsgrad == "Beschäftigungsgrad - Total",
         Geschlecht != "Geschlecht - Total") %>% 
    select(Geschlecht, Wirtschaftsabteilung, value) %>% 
    pivot_wider(id_cols = Wirtschaftsabteilung, names_from = Geschlecht,
                values_from = value) %>% 
    mutate(female = Frau / (Mann + Frau)) %>% 
    separate(Wirtschaftsabteilung, into = c("cod", "txt"), sep = " ", extra = "merge") %>% 
    mutate(cod2 = str_replace(cod, "-", ":") %>% str_replace("\\+", ",") %>% 
             str_replace("^", "c(") %>% str_replace("$", ")"))

besta <- besta %>% 
  filter(txt %!in% c("Total", "Sektor II", "Verarbeitendes Gewerbe/Herstellung von Waren",
                     "Baugewerbe/Bau", "Sektor III", "Handel, Instandhaltung und Rep. von Kraftfahrzeugen",
                     "Verkehr und Lagerei", "Gastgewerbe/Beherbergung und Gastronomie",
                     "Information und Kommunikation", "Erbringung von Finanz- und Versicherungsdienstl.",
                     "Rechts- und Steuerberatung, Wirtschaftsprüfung", "Erbringung von sonstigen wirtschaftlichen Dienstl.",
                     "Gesundheits- und Sozialwesen"))

# Parse sequences 
besta$cod2 <- lapply(besta$cod2, function(x) eval(parse(text = x)))

# NOGA-02 Labels and codes
label_noga_2st <- read.csv("~/Transfer/label_noga_2st_de.csv")
label_noga_2st$cod_noga_abt <- NA_character_

# Match NOGA-02 with partly aggregated BFS-NOGA-Wirtschaftsabteilungen
for(i in 1:nrow(label_noga_2st)){
  cod <- label_noga_2st$cod_noga_2st[i]
  index <- lapply(besta$cod2, function(x) cod %in% x)
  besta_row <- which(unlist(index))
  label_noga_2st$cod_noga_abt[i] <- ifelse(is_empty(besta_row), NA,
    besta$cod[besta_row])
}

# Female labor share with NOGA-02
female_share <- label_noga_2st %>% 
  left_join(besta %>% select(cod, txt, female), by = c("cod_noga_abt" = "cod")) %>% 
  select(cod_noga_2st, cod_noga_abt, txt, female) %>% 
  rename(txt_noga_abt = txt)

write.csv(female_share, "~/Transfer/besta_female_share.csv", row.names = FALSE)
