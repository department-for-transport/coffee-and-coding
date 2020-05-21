# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
# R script - Web Scraping Example 1                                           #
# Olympic Medals Table                                                        #
#                                                                             #
# by Johannes Schulz-Knappe, Aviation, Maritime and Environment Statistics    #
# Date 06/06/2019                                                             #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #

# Load packages
library(tidyverse)
library(rvest)


# Change proxy settings to "jump" the DfT firewall
proxy <- curl::ie_get_proxy_for_url("http://www.google.com")
Sys.setenv("http_proxy" = proxy, 
           "https_proxy" = proxy)
rm(proxy)

# Set webpage URL
url <- "https://www.bbc.co.uk/sport/winter-olympics/medals/countries"


# Scrape the Winter Olympics 2018 Medals table
medals_table <- url %>% 
  xml2::read_html() %>%
  rvest::html_nodes('.medals-table__table') %>%
  rvest::html_table() %>%
  as.data.frame