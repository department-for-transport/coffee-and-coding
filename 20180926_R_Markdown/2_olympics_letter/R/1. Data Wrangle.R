#Sue Wallace
#25 August 2018

# Using loops to create multiple documents in R markdown

lintr::lint("R/1. Data Wrangle.R")

# a) Load libaries----
library (readr) #reading in data and writing out data
library (dplyr) #data wrangle
library (tidyverse) #learn more about the philosophy of tidy verse here
#https://www.tidyverse.org/
library (tidyr) #cleaning a data set

# b) Read in data----

# I only want the data for 2008 so I'll filter anything else out at this point
olympics <- read_csv ("Data/Summer Olympic medallists 1896 to 2008.csv") %>%
  dplyr::filter (Edition=="2008")

# I also need a look up to the country codes
codes <- read_csv ("Data/noc_regions.csv")

#c) Data wrangle

#Let's have a look at the data
dplyr::glimpse (olympics)

# Let's add a unique number to each athlete
olympics <- tibble::rowid_to_column (olympics, "ID") 

# Next we're going to use tidyr to seperate out the 'Athelete' variable into
# two seperate variables 'FirstName' and 'LastName'. 

olympics <- tidyr::extract (olympics, Athlete, c ("LastName", "FirstName"),
                    "([^ ]+) (.*)")

# Next we need to decapitalise the LastName variable and add a capital to the 
# first letter of the name

# decapitalise using 'tolower'
olympics$LastName <- tolower(olympics$LastName)

# Function to add a capital on the first letter

firstup <- function(x) {
  substr (x, 1, 1) <- toupper (substr(x, 1, 1))
  x
}

# Run the function on the variable you want to capitalise

olympics$LastName <- firstup (olympics$LastName)

# Join the data using the NOC variable so that the country of the athlete is
#part of the olympics dataframe

olympics <- dplyr::left_join(
  x = olympics,  # to this table...
  y = codes,   # ...join this table
  by = "NOC"  # on this key
)

# We can see that there are 2,042 medals that were awarded in 2008. I would like
# to send a letter of congratulations to every athlete that won a medal.

# I would also like the letters to be personalised and specific to the
# recipient, rather than a generic letter.

# In order to do this I'm going to use a loop which will create a vector
# for each athlete that won a medal. The vector will then be fed into 
# R Markdown to create the letters.

# The loop----

for (athletes in unique (olympics$ID)) {
  rmarkdown::render ('R/R Markdown Loop.Rmd',  
                    output_file =  paste (athletes, " Letter", ".docx", sep=''), 
                    output_dir = 'Exports')}





