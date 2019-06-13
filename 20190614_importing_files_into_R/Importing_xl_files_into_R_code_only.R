# Data import to R
# This code only script contains ways of reading in excel data, in various formats, into R. 



# Libraries ---------------------------------------------------------------
library(tidyverse)
library(fs) #cross-platform file systems operations (based on libuv C library)


# .csv --------------------------------------------------------------------
# read_csv, specify file only
pokemon <- readr::read_csv(
file = "data/messy_pokemon_data.csv"
)

View(pokemon)

# read_csv specify col_types
# c = character, d = double, D = Date, t = time
pokemon <- readr::read_csv(
  file = "data/messy_pokemon_data.csv"
  , col_types = "cdddcdcccDt"
)
tibble::glimpse(pokemon)

# check out problems
problems(pokemon) %>% 
head()

# check out combat_power problems
problems(pokemon) %>% 
  dplyr::filter(col == "combat_power") %>% 
  head()



# rectangular .xlsx and .xls data -----------------------------------------
# single worksheet - single workbook --------------------------------------
port <- readxl::read_excel(
  path = "data/port0499.xlsx"
  , sheet = 1 #number or name of sheet, default is first sheet
  , col_names = TRUE #default
  , col_types = "text" #a single type will recycle to all columns, specify each using character vector of the same length eg c("numeric", "text", ...)
  , n_max = 10 #set max number of rows to read
) 

View(port)


# single worksheet - many workbooks ---------------------------------------
pokemon <- fs::dir_ls(path = "data", regex = "pokemon_player_.\\.xlsx$")  %>% 
  purrr::map_dfr(readxl::read_excel, .id = "player")

tibble::glimpse(pokemon)

View(pokemon)

# many worksheets - single workbook ---------------------------------------
path <- "data/multi_tab_messy_pokemon_data.xlsx"

pokemon_collections <- readxl::excel_sheets(path = path) %>% 
  purrr::set_names() %>% 
  purrr::map_dfr(
    ~ readxl::read_excel(path = path, sheet = .x)
    , .id = "sheet"
  )

View(pokemon_collections)

# turn the above into bespoke function "read_and_combine_sheets" to combine 
# worksheets from a single workbook
read_and_combine_sheets <- function(path){
  readxl::excel_sheets(path = path) %>% 
    purrr::set_names() %>% 
    purrr::map_dfr(
      ~ readxl::read_excel(path = path, sheet = .x)
      , .id = "sheet"
    )
}

# many worksheets - many workbooks ----------------------------------------
# code to iterate over many workbooks, using bespoke function "read_and_combine_sheets" 
pokemon_monthly_collections <- fs::dir_ls(
  path = "data", regex = "pokemon_2019\\d{2}\\.xlsx$")  %>% 
  purrr::map_df(
    read_and_combine_sheets
    , .id = "month"
  )

View(pokemon_monthly_collections)

# alternatively use "anonymous function" syntax. Here you don't bother 
# creating the bespoke function as a named object but just use it in the 
# same place like so
pokemon_monthly_collections_af <- fs::dir_ls(
  path = "data", regex = "pokemon_2019\\d{2}\\.xlsx$")  %>% 
  purrr::map_df(
    function(path){
      readxl::excel_sheets(path = path) %>% 
        purrr::set_names() %>% 
        purrr::map_df(
          ~ readxl::read_excel(path = path, sheet = .x)
          , .id = "sheet"
        )
    }
    , .id = "month"
  )

View(pokemon_monthly_collections_af)


# non-rectangular .xlsx and .xls data -------------------------------------

# non-rectangular data - single worksheet - single workbook ---------------
# data is dotted all over the place, disconnected in a single worksheet

# Let's see what we get if we naively try to read in one of these forms.
readxl::read_excel(
  path = "data/pet_form_1.xlsx"
)

#It's not what we wanted, let's try again, now using the "range" argument
readxl::read_excel(
  path = "data/pet_form_1.xlsx"
  , col_names = FALSE
  , range = "A2:B2" #specify range Excel style
)

# read in data from cells in one worksheet
purrr::map_df(
  .x = c("B2", "D5", "E8") #vector of specific cells containing the data
  , ~ readxl::read_excel(
    path = "data/pet_form_1.xlsx"
    , range = .x
    , col_names = "cells"
    , col_types = "text" #have to use text to preserve all data in single column
  ) 
)



# realise we actually wanted to column bind each cell, so use map_dfc
purrr::map_dfc(
  .x = c("B2", "D5", "E8") #vector of specific cells containing the data
  , ~ readxl::read_excel(
    path = "data/pet_form_1.xlsx"
    , range = .x
    , col_names = FALSE
  ) 
)



# now realise we can get the column names as the same time with map2_dfc 
purrr::map2_dfc(
  .x = c("B2", "D5", "E8") #vector of specific cells containing the data
  , .y = c("Name", "Age", "Species")
  , ~ readxl::read_excel(
    path = "data/pet_form_1.xlsx"
    , range = .x
    , col_names = .y
    #, col_types = "text" #have to use text to preserve all data in single column
  ) 
)


# functionalise 
cells_to_rows <- function(path, cells, col_names){
  purrr::map2_dfc(
    .x = cells
    , .y = col_names
    , ~ readxl::read_excel(
      path = path
      , range = .x
      , col_names = .y
    ) 
  )
}

# try function
cells_to_rows(
  path = "data/pet_form_1.xlsx"
  , cells = c("B2", "D5", "E8")
  , col_names = c("Name", "Age", "Species")
)


# Non-rectangular data - single worksheet - many workbooks ----------------
# set parameters
cells <- c("B2", "D5", "E8")
col_names <- c("Name", "Age", "Species")
# apply function
all_pet_forms <- fs::dir_ls(
  path = "data", regex = "pet_form_\\d\\.xlsx$")  %>% 
  purrr::map_dfr(
    ~ cells_to_rows(path = .x, cells = cells, col_names = col_names)
    , .id = "path"
  )

all_pet_forms


# Non-rectangular data - many worksheets - single workbook ----------------
# rejig function to include a "sheet" argument
sheet_cells_to_rows <- function(path, sheet, cells, col_names){
  purrr::map2_dfc(
    .x = cells
    , .y = col_names
    , ~ readxl::read_excel(
      path = path
      , sheet = sheet
      , range = .x
      , col_names = .y
    ) 
  )
}

#set arguments and apply function to all worksheets of the workbook
path <- "data/pet_house_1.xlsx"
cells <- c("B2", "D5", "E8")
col_names <- c("Name", "Age", "Species")

pet_house_1 <- readxl::excel_sheets(path = path) %>% 
  purrr::set_names() %>% 
  purrr::map_dfr(
    ~ sheet_cells_to_rows(path = path
                          , sheet = .x
                          , cells = cells
                          , col_names = col_names)
    , .id = "sheet"
  )

pet_house_1


# Non-rectangular data - many worksheets - many workbooks -----------------
# set parameters
cells <- c("B2", "D5", "E8")
col_names <- c("Name", "Age", "Species")
# use earlier function and anonymous function
pet_house_all <- fs::dir_ls(
  path = "data", regex = "pet_house_\\d\\.xlsx$")  %>% 
  purrr::map_dfr(
    function(path){
      readxl::excel_sheets(path = path) %>% 
        purrr::set_names() %>% 
        purrr::map_dfr(
          ~ sheet_cells_to_rows(path = path
                                , sheet = .x
                                , cells = cells
                                , col_names = col_names)
          , .id = "sheet"
        )
    }
    , .id = "path"
  )

pet_house_all
