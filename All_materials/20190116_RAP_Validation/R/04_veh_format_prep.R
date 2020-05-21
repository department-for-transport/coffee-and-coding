
# Script 4: VEH FORMAT PREP ----------------------------------------------------------

# Manually updated variables ------------------------------

#table_name_date variables - update these variables as required
latest_month <- "December 2018"

#footer_text_admin footnote dates and information used - update these variables as required
last_updated <- "11 April 2019"
next_update_month <- "9 May 2019"
next_update_quarter <- "June 2019"
next_update_annual <- "April 2020"

contact_telephone <- "020 7944 3077"
contact_email <- "vehicles.stats@dft.gov.uk"

#hyperlink addresses used
hyperlink_veh <- "https://www.gov.uk/government/collections/vehicles-statistics"
names(hyperlink_veh) <- "Vehicle Statistics"
class(hyperlink_veh) <- "hyperlink"

hyperlink_email <- "mailto::vehicles.stats@dft.gov.uk"
names(hyperlink_email) <- "Email: vehicles.stats@dft.gov.uk"
class(hyperlink_email) <- "hyperlink"

hyperlink_plugin_grant <- "https://www.gov.uk/plug-in-car-van-grants/eligibility"
names(hyperlink_plugin_grant) <- "https://www.gov.uk/plug-in-car-van-grants/eligibility"
class(hyperlink_plugin_grant) <- "hyperlink"

# Titles ------------------------------------------------------------------

table_name_date_ulevlic <- ", United Kingdom from 2011 Q4"
table_name_date_lic <- ", Great Britain from 1994 Q4; also United Kingdom from 2014 Q4"
table_name_date_sorn <- ", Great Britain from 2007 Q4; also United Kingdom from 2014 Q4"
table_name_date_geography <- ", United Kingdom, "

table_name_date_new_month <- ", Great Britain from January 2001; also United Kingdom from July 2014"


#function to minimise reptition in input for table titles
set_text_title <- function (type
                            ,table_name_vehicle
                            ,table_name_grouping
                            ,year = NA # for annual tables only
) {
  
  
  #check input is char and length 1, and output is length 5
  stopifnot(type %in% c("stock","sorn","newreg","ulevstock","geography")
            ,is.character(table_name_vehicle)
            ,is.character(table_name_grouping)
            ,length(table_name_vehicle) == 1
            ,length(table_name_grouping) == 1
            ,length(year) == 1
  )
  
  return(case_when(
    type == "stock" ~ paste0("Licensed ",table_name_vehicle," at the end of the quarter ",table_name_grouping,table_name_date_lic)
    ,type == "ulevstock" ~ paste0("Licensed ",table_name_vehicle," at the end of the quarter ",table_name_grouping,table_name_date_ulevlic)
    ,type == "sorn" ~ paste0(table_name_vehicle," with a Statutory Off Road Notification (SORN)  at the end of the quarter ",table_name_grouping,table_name_date_sorn)
    ,type == "newreg" ~ paste0(table_name_vehicle," registered for the first time ",table_name_grouping,table_name_date_new_month)
    ,type == "geography" ~ paste0("Licensed ",table_name_vehicle," at the end of the quarter ",table_name_grouping,table_name_date_geography,year)
  )
  )
}


# Footnotes ---------------------------------------------------------------

footer_text_model_missing <- "Entries containing 'MISSING' are either for vehicles that have never been allocated a make/model code (most likely older vehicles manufactured before 1972) or new vehicles when the code lookup has not yet been published. Missing models for new vehicles will be updated in future releases."

footer_text_plugin <- c("Plug-in yadda yadda:"
                        ,hyperlink_plugin_grant)

footer_text_others <- "Refers to any other vehicle not in the main body type tables. Includes rear diggers, lift trucks, rollers, ambulances, Hackney Carriages, three wheelers, tricycles and agricultural vehicles." 

footer_text_c <- "c. Value has been suppressed to avoid disclosing personal information."

footer_text_ulev <- "Ultra low emission vehicles (ULEVs) are vehicles that emit less than 75g of carbon dioxide (CO2) from the tailpipe for every kilometre travelled. In practice, the term typically refers to battery electric, plug-in hybrid and fuel cell electric vehicles."

footer_text_address <- "Vehicles are allocated to a local authority according to the postcode of the registered keeper. This is the keeper's address for privately kept vehicles or the company's registered address for company kept vehicles. Significant changes in the number of vehicles from year to year can occur when companies with a large number of vehicles change their registered address. Vehicles are not necessarily driven or stored at their keeper's address."

footer_text_incomplete_postcode <- "The exact geographical location is sometimes unavailable due to vehicles with incomplete postcodes."

footer_text_SORN <- "To avoid paying vehicle excise duty the keeper must declare the vehicle off the road using the Statutory Off Road Notification (SORN) process. Prior to December 2013 SORN declarations had to be renewed annually. From 16th December 2013, continuous SORN was introduced so a SORN declaration from then onwards lasts until the vehicle is re-taxed, sold, permanently exported or scrapped. This resulted in significantly higher year-on-year increases from 2013 Q4 onwards."



## Footnote used in all tables with contact info etc.
footer_text_admin <- c(paste0("Telephone: ", contact_telephone)
                       ,paste0("Email: ", contact_email)
                       ,""
                       ,"Source: DVLA / DfT"
                       ,paste0("Last updated: ", last_updated)
                       ,paste0("Next update: ", next_update_quarter)
                       ,""
                       ,"The figures in this table are National Statistics."
)

#function to piece together individual footnotes for each table, based on those set above
set_text_footer <- function(table_pad = 0,...) {
  #check arguments are all char
  
  footer_text <- c(rep(NA,table_pad)
                   ,""
                   ,...
                   ,""
                   ,footer_text_admin
  )
  
}

#function to preset styles for footnotes (number of footnotes varies per table)
#all footnotes are in style "footer" except the first which is style "source"
#and the second to last 2 which are style "footer_italics"

set_style_footer <- function(table_pad = 0,footer_text){
  c(rep(NA,table_pad)
    ,"source"
    ,rep("footer", length(footer_text)-8-table_pad)
    ,"hyperlink"
    ,rep("footer", 6)
  ) 
}

#function to calculate the sheet row holding certain footer text, the search_text
#to be used in overiding row heights, (eg for wrapped text that goes over one line) and configuring hyperlinks
#if you give this function a vector it returns a vector of row positions
footer_text_row <- function(tab,search_text){
  return (
    length(tab$title$title_text) #number of rows in title
    + length(tab$top_headers$top_headers_list) #number of rows in top header (usually 1)
    + dim(tab$body$body_df)[1]  #number of rows in body (not including header)
    + match(search_text, tab$footer$footer_text) #number of rows to search_text in footer
  ) #may be a single row number or a vector of row numbers
}

# Hyperlinks --------------------------------------------------------------
#functions to set the hyperlinks, function works by searching for the hyperlink text
#function uses variables that are already in the global environment
set_title_hyperlink <- function(tab,sheet = 1){
  openxlsx::writeData(wb = tab$wb
                      ,sheet = sheet
                      ,startRow = match(x = names(hyperlink_veh), table = tab$title$title_text) #find row of hyperlink by matching its 'name' the text that shows
                      ,startCol = 1
                      ,x = hyperlink_veh
  )
}

set_footer_hyperlink <- function (tab,sheet = 1){
  openxlsx::writeData(wb = tab$wb
                      ,sheet = sheet
                      ,startRow = footer_text_row(tab=tab,search_text = names(hyperlink_email))
                      ,startCol = 1,
                      x = hyperlink_email
  )
}




# Table column widths -----------------------------------------------------
#assign to set consistent column width across all tables
table_column_width_thin <- 8
table_column_width_normal <- 16
table_column_width_plus <- 24
table_column_width_wide <- 32
table_column_width_ultra <- 40



