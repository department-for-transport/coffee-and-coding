#Coffee & Coding 19/09/2019 [Talk Like A Pirate Day]
#Augmenting yarrr pirate data set for use in stringR/regex demo 
#This does not need to be run and is just for interest 

# load packages -----------------------------------------------------------
library(tidyverse)
library(yarrr)
#https://cran.r-project.org/web/packages/yarrr/yarrr.pdf
library(reshape2)
library(openxlsx)

# create data for extra pirate characteristics ----------------------------
#read in datetimes and lengthen (dt_types is random sample of datetimes)
dt_types <- readRDS(file = "data/dt_types.rds")
dt_types_1000 <- purrr::map_df(seq_len(6), ~ dt_types) %>% 
  dplyr::sample_n(1000)
#sample of each date time type
dt_sample <- dt_types[seq(1, nrow(dt_types), 10), ]

#data has been collected by location
location <- dplyr::sample_n(
  tbl = tibble(location = c(
    "Gulf of Mexico", "Atlantic Ocean",  "North Pacific Ocean"
    , "Caribbean Sea"))
  , size = 1000
  , replace = TRUE
  , weight = c(2, 3, 4, 2)
)

#create pirate expression data
expression <- dplyr::sample_n(
  tbl = tibble(expression = c(
    "oooaaarrrggghhh", "ooaarrgghh", "ooooaargh", "ooarrrrrgh", "arrr"
    , "ooaaarrgh", "aaaarghh", "aargghh", "ooarrh", "oooarrrrghh"
    , "yaarrrrghh", "ooyarr", "yarrr"))
  , size = 1000
  , replace = TRUE
  , weight = c(2, 3, 4, 1, 2, 2, 1, 3, 1, 2, 3, 1, 1)
)


# combine data ------------------------------------------------------------
#use pirateerrors, col bind date times and pirate expressions and last known 
#location for 'sheet'
pirate_data <- pirateserrors %>% 
  dplyr::bind_cols(dt_types_1000, location, expression) %>% #combine
  dplyr::select( #select/reorder
    rdate, rtime, location, expression, favorite.pirate, parrots
    , sword.type, parrots, sex, age, beard.length, eyepatch, sword.time
    , headband, tchests, tattoos
  )



# save dataset ------------------------------------------------------------
saveRDS(
  object = pirate_data
  , file = "data/pirate_data.rds"
)

#save to excel, sheet = location (remove location column from data)
#create list of data sets to write to each sheet
pirate_list <- list(
  "Gulf of Mexico" = dplyr::filter(pirate_data, location == "Gulf of Mexico") %>% select(-location)
  , "Atlantic Ocean" = dplyr::filter(pirate_data, location == "Atlantic Ocean") %>% select(-location)
  , "North Pacific Ocean" = dplyr::filter(pirate_data, location == "North Pacific Ocean") %>% select(-location)
  , "Caribbean Sea" = dplyr::filter(pirate_data, location == "Caribbean Sea") %>% select(-location)
)

openxlsx::write.xlsx(
  x = pirate_list
  , file = "data/pirate_data.xlsx"
  , colnames = TRUE
)








# inspect data ------------------------------------------------------------
#to list unique values per column
pirate_data %>% 
  purrr::map(
    ~ unique(.)
  )

#to count number of unique values per column
pirate_data %>% summarise_all(funs(n_distinct(.)))
