#Sue wallace
#15.09.2018
#Tidy the data

library(dplyr) #data manipulation
library(readr) #read in and read out data

# This is quite a messy data set. There are also some joins that need to be made
# before the data are ready to be worked with.

# Load data----

killing <- read_csv("Data/fatal-police-shootings-data.csv") #From Washinton Post

us_cities <- read_csv("Data/us_cities.csv")

states <- read_csv("Data/state_code.csv")

# Tidy data----

# Create a year column using the date varibale 

killing %>%
  mutate(Year=format(as.Date(killing$date, format="%d/%m/%Y"),"%Y")) -> killing

# Join onto state names and rename columns to be more sensible (with caps)

dplyr::left_join(x = killing, 
                 y = states, 
                 by = "state") %>%
  dplyr::select(name, date, manner_of_death, armed_1, age, gender, race, city,
                signs_of_mental_illness, Year, state_name, flee, body_camera) %>% 
  dplyr::rename(Name = name, Date = date, `Manner of Death` = manner_of_death,
                Age = age, Gender = gender, Race = race, State = state_name, 
                City = city, `Signs of mental illness` = signs_of_mental_illness,
                Armed = armed_1) -> killing


# I only need the lat, long and city data from us_cities. This also needs to be 
# joined onto the 'states' data to get the full state name

us_cities %>%
  dplyr::select(city, state_id, lat, lng) %>%
  dplyr::rename(City = city, state = state_id) -> us_cities

us_cities %>% 
  dplyr::left_join(
    x = us_cities,
    y = states,
    by =  "state"
  ) -> us_cities

# Rename values within the data

killing$Gender[killing$Gender == "M"] <- "Male"
killing$Gender[killing$Gender == "F"] <- "Female"
killing$Race[killing$Race == "A"] <- "Asian"
killing$Race[killing$Race == "B"] <- "Black"
killing$Race[killing$Race == "H"] <- "Hispanic"
killing$Race[killing$Race == "W"] <- "White"
killing$Race[killing$Race == "O"] <- "Other"
killing$Race[killing$Race == "NA"] <- "Unknown"
killing$Race[killing$Race == "N"] <- "First Nations"
killing$Race[is.na(killing$Race)] <- "Unknown"
killing$`Manner of Death`[killing$`Manner of Death` == "shot"] <- "Shot"
killing$`Manner of Death`[killing$`Manner of Death` == "shot and Tasered"] <- "Shot and tasered"
killing$body_camera[killing$body_camera == "FALSE"] <- "No"
killing$body_camera[killing$body_camera == "TRUE"] <- "Yes"
killing$`Signs of mental illness`[killing$`Signs of mental illness` == "FALSE"] <- "No"
killing$`Signs of mental illness`[killing$`Signs of mental illness` == "TRUE"] <- "Yes"
killing$Armed[killing$Armed == "armed"] <- "Armed"
killing$Armed[killing$Armed == "unarmed"] <- "Unarmed"
killing$Armed[killing$Armed == "unknown"] <- "Unknown"
killing$Armed[killing$Armed == "undetermined"] <- "Undetermined"
killing$Armed[killing$Armed == "unknown weapon"] <- "Unknown Weapon"


rm(states)

# In order o join the tables the values need to be set to 'city, state'
# This is because there are some cities and state names in the US that
# are duplicated throughout the country. The state suffix is needed
# to distinguish between the sanme named cities and towns. 


killing %>%
  mutate(city_state=paste(killing$City, killing$State, sep=", ")) %>%
  select(Name, Date, `Manner of Death`, Age, Gender, Race, Armed, State,
         City, Year, city_state, flee, body_camera, 
         `Signs of mental illness`) -> killing

us_cities %>%
  mutate(city_state=paste(us_cities$City, 
                          us_cities$state_name, sep=", ")) -> us_cities2

# Join the killing data to cities to get the city lat and long

killing <- dplyr::left_join(
  x = killing,  # to this table...
  y = us_cities2,   # ...join this table
  by = "city_state"  # on this key
) 

write_csv(killing, "Data/killing.csv") #The data is now loaded in the 'Data' 
#folder ready to be used in the corsstalk app.  

