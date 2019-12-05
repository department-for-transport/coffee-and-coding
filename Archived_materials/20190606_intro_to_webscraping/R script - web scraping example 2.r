# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# R script - Web Scraping Example 2                                           #
# Web scraping from a fictional book store                                    #
#                                                                             #
# by Johannes Schulz-Knappe, Aviation, Maritime and Environment Statistics    #
# Date 06/06/2019                                                             #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #


# 1. Overview =================================================================

# This R script provides an example for web scraping information from an online 
# book store.

# It is a simplified adaption of the 'Web Scraping in R' tutorial by Arvid 
# Kingl on DataCamp. 
# Link: https://www.datacamp.com/community/tutorials/r-web-scraping-rvest

# The script extracts book title, price and and average 5-star 
# ratings from the fictional book store "http://books.toscrape.com/".


# Content of this script:

# 1) Overview
# 2) Set up
# 3) Identify URL pattern of book store pages
# 4) Write web scraping functions
# 5) Write functions to combine scraped information into a data frame
# 6) Run the main function



# 2. Set up ===================================================================


# Set working directory - change to your preferred folder
setwd(paste0("G:/AFP/EITAAll/AMES/006 Aviation/A001 General/coding resources/",
             "web-scraping-tutorial"))


# Load packages for:

# General-purpose data wrangling (includes curl, dplyr, stringr, purrr)
library(tidyverse)

# Parsing of HTML/XML files (includes xml2)
library(rvest)


# Change proxy settings to "jump" the DfT firewall
proxy <- curl::ie_get_proxy_for_url("http://www.google.com")

Sys.setenv("http_proxy" = proxy, 
           "https_proxy" = proxy)
rm(proxy)



# 3. Identify URL pattern of book store pages =================================


# Specify book store landing page URL
url <- "http://books.toscrape.com"


# Main landing page shows the "books" category. At the bottom of the webpage we
# see that it shows "page 1 of 50". Selecting "next" shows us the URL pattern
# in the address bar: http://books.toscrape.com/catalogue/page-2.html


# Write a line that creates all the subpage URLs by concatenating URL elements
# Test manually whether they work. Remember this line for later use
paste0(url, "/catalogue/page-", 1:50, ".html")


# Create an example HTML to use in the following development and testing of
# web scraping functions
html <- xml2::read_html("http://books.toscrape.com/catalogue/page-1.html")



# 4. Write web scraping functions =============================================


# This stage involves source code investigation and some trial-and-error.The 
# goal is to write extraction functions for the various data fields we are 
# interested in (e.g. title, price, rating).


# 4.1 Create the titles-scraping function -------------------------------------

get_titles <- function(html) {
  
  html %>% 
    
    # Extract html for the tags that include the title attribute
    rvest::html_nodes("h3") %>% 
    rvest::html_nodes("a") %>% 
    rvest::html_attrs() %>% 
    
    # The title is the second attribute, so only take every second
    purrr::map(2) %>%
    
    # Trim additional white space (not necessary, but better safe than sorry)
    stringr::str_trim() %>% 
    
    # Convert the list into a vector
    unlist()
}

# Test function
html %>% get_titles()

  
# 4.2 Create the ratings-scraping function ------------------------------------

get_star_ratings <- function(html) {

  html %>% 
    rvest::html_nodes(".star-rating") %>% 
    
    # Since the rating is a tag "attribute", we use html_attrs() instead of 
    # html_text()
    rvest::html_attrs() %>% 
    
    # Replace patterns using stringr
    stringr::str_replace("star-rating One",   "1") %>%
    stringr::str_replace("star-rating Two",   "2") %>%
    stringr::str_replace("star-rating Three", "3") %>%
    stringr::str_replace("star-rating Four",  "4") %>%
    stringr::str_replace("star-rating Five",  "5") %>%
    
    unlist()
}

# Test function
html %>% get_star_ratings()


# 4.3 Create the prices-scraping function -------------------------------------

get_prices <- function(html) {

html %>% 
    rvest::html_nodes("article") %>%
    rvest::html_nodes("div") %>%
    rvest::html_nodes(".price_color") %>% 
    rvest::html_text() %>% 
    
    # Remove pound sign (avoid later encoding issue)
    stringr::str_sub(2, 6) %>% 
  
    # Convert the list into a vector
    unlist()
}

# Test function
html %>% get_prices()



# 5. Write functions to combine scraped information into a data frame =========


# 5.1 Function that creates a combined table for subpage results --------------

get_data_table <- function(html) {
  
  # Extract the basic information from the HTML
  titles  <- get_titles(html)
  ratings <- get_star_ratings(html)
  prices  <- get_prices(html)
 
  # Combine into a tibble
  combined_data <- dplyr::tibble(title  = titles,
                                 rating = ratings,
                                 price  = prices)
}

# Test function
combined_data <- html %>% get_data_table()
rm(combined_data)

# 5.2 Function that creates XML files for subpages ----------------------------

get_data_from_url <- function(url) {
  html <- xml2::read_html(url)
  get_data_table(html)
}

# Test function
combined_data <- url %>% get_data_from_url()


# 5.3 Final function to construct subpage URLs and write results to csv -------

scrape_write_table <- function(url) {
  
  # Create list of URLs (see 3. step)
  list_of_pages <- paste0(url, "/catalogue/page-", 1:50, ".html")
  
  list_of_pages %>%
  
    # Apply all URLs to the webscraping functions, using map()
    purrr::map(get_data_from_url) %>%
  
    # Combine all resulting tibbles into one tibble
    dplyr::bind_rows() %>%
  
    # Write final tibble as a csv file (with time tag)
    readr::write_csv("book_store.csv")
}



# 6. Run the main function ====================================================

scrape_write_table(url)


# End of script ===============================================================