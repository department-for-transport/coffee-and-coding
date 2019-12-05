
# Script 6: VEH TABLE PRODUCTION ----------------------------------------------------------

init_wb = function () {
  wb <- createWorkbook(creator = NULL)
  modifyBaseFont(wb = wb
                 ,fontSize = 10
                 ,fontColour = "black"
                 ,fontName = "Arial"
  )
  return(wb)
}

## VEH0101 ========

wb <- init_wb()

produce_table(wb = wb
              ,table_data = veh0101_gb
              ,type = "stock"
              ,ws_name = "GB"
              ,table_number = "VEH0101"
              ,table_name_vehicle = "vehicles"
              ,table_name_grouping = "by body type"
              ,table_footer_list = c(footer_text_others)
              ,col_widths = c(rep(12.5,ncol(veh0101_gb))
              )
              ,col_styles = c("styleDefault"
                              ,rep("styleThousand",8)
                              ,"styleItalic1dp"
              )
              ,row_quarter_start = 1
)

produce_table(wb = wb
              ,table_data = veh0101_uk
              ,type = "stock"
              ,ws_name = "UK"
              ,table_number = "VEH0101"
              ,table_name_vehicle = "vehicles"
              ,table_name_grouping = "by body type"
              ,table_footer_list = c(footer_text_others)
              ,col_widths = c(rep(12.5,ncol(veh0101_uk))
              )
              ,col_styles = c("styleDefault"
                              ,rep("styleThousand",8)
                              ,"styleItalic1dp"
              )
              ,row_quarter_start = 3
)

openxlsx::openXL(wb)

## VEH0105 ========

wb <- init_wb()

for (yr in sort(unique(veh0105_uk$Date),decreasing=TRUE))
{
  annual <- filter(veh0105_uk,Date==yr) %>% arrange(Sort) %>% select(-Sort,-Date)
  
  # Geographic indentation
  rowHeightIndex <- annual %>%
    mutate(
      D = case_when(
        is.na(GeoRank) ~ TRUE,
        GeoRank == 1 ~ TRUE,
        lag(GeoRank) - GeoRank > 0 ~ TRUE, 
        TRUE ~ FALSE
      )
    ) %>%
    select(D) %>%
    t() %>%
    which()
  
  annual <- select(annual,-GeoRank)
  
  produce_table(wb = wb
                ,table_data = annual
                ,type = "geography"
                ,ws_name = as.character(yr)
                ,table_number = "VEH0105"
                ,table_name_vehicle = "vehicles"
                ,table_name_grouping = "by upper and lower tier local authority"
                ,left_col_num = 2
                ,table_footer_list = c(footer_text_others)
                ,col_widths = c(12.5
                                ,35
                                ,rep(12.5,ncol(annual) - 2)
                )
                ,col_styles = c("styleDefault","styleDefault"
                                ,rep("styleThousand",ncol(annual)-2)
                )
                ,row_height_index = rowHeightIndex
  )
  
  rm(annual) # Remove from environment
}

openxlsx::openXL(wb)

## VEH0110 ========

wb <- init_wb()

produce_table(wb = wb
              ,table_data = veh0110_gb
              ,type = "sorn"
              ,ws_name = "GB"
              ,table_number = "VEH0110"
              ,table_name_vehicle = "Vehicles"
              ,table_name_grouping = "by body type"
              ,table_footer_list = c(footer_text_others
                                     ,footer_text_SORN)
              ,col_widths = c(rep(12.5,ncol(veh0110_gb))
              )
              ,col_styles = c("styleDefault"
                              ,rep("styleThousand",ncol(veh0110_gb)-2)
                              ,"styleItalic1dp"
              )
              ,row_quarter_start = 2
)

produce_table(wb = wb
              ,table_data = veh0110_uk
              ,type = "sorn"
              ,ws_name = "UK"
              ,table_number = "VEH0110"
              ,table_name_vehicle = "vehicles"
              ,table_name_grouping = "by body type"
              ,table_footer_list = c(footer_text_others
                                     ,footer_text_SORN)
              ,col_widths = c(rep(12.5,ncol(veh0110_uk))
              )
              ,col_styles = c("styleDefault"
                              ,rep("styleThousand",ncol(veh0110_uk)-2)
                              ,"styleItalic1dp"
              )
              ,row_quarter_start = 3
)

openxlsx::openXL(wb)

## VEH0120 ========

wb <- init_wb()

produce_table(wb = wb
              ,table_data = veh0120_cars
              ,type = "stock"
              ,ws_name = "Cars"
              ,table_number = "VEH0120"
              ,table_name_vehicle = "cars"
              ,table_name_grouping = "by make and model"
              ,left_col_num = 2
              ,table_footer_list = c(footer_text_model_missing)
              ,table_units = "Number"
              ,col_widths = c(table_column_width_wide
                              ,table_column_width_wide
                              ,rep(table_column_width_thin,ncol(veh0120_cars) - 2)
              )
              ,col_styles = c(rep("styleDefault",2)
                              ,rep("styleNumber",ncol(veh0120_cars) - 2)
              )
              
)

produce_table(wb = wb
              ,table_data = veh0120_bikes
              ,type = "stock"
              ,ws_name = "Motorcycles"
              ,table_number = "VEH0120"
              ,table_name_vehicle = "motorcycles, scooters and mopeds"
              ,table_name_grouping = "by make and model"
              ,left_col_num = 2
              ,table_footer_list = c(footer_text_model_missing)
              ,table_units = "Number"
              ,col_widths = c(table_column_width_wide
                              ,table_column_width_wide
                              ,rep(table_column_width_thin,ncol(veh0120_bikes) - 2)
              )
              ,col_styles = c(rep("styleDefault",2)
                              ,rep("styleNumber",ncol(veh0120_bikes) - 2)
              )
)

produce_table(wb = wb
              ,table_data = veh0120_lgvs
              ,type = "stock"
              ,ws_name = "LGVs"
              ,table_number = "VEH0120"
              ,table_name_vehicle = "light goods vehicles"
              ,table_name_grouping = "by make and model"
              ,left_col_num = 2
              ,table_footer_list = c(footer_text_model_missing)
              ,table_units = "Number"
              ,col_widths = c(table_column_width_wide
                              ,table_column_width_wide
                              ,rep(table_column_width_thin,ncol(veh0120_lgvs) - 2)
              )
              ,col_styles = c(rep("styleDefault",2)
                              ,rep("styleNumber",ncol(veh0120_lgvs) - 2)
              )
)

produce_table(wb = wb
              ,table_data = veh0120_hgvs
              ,type = "stock"
              ,ws_name = "HGVs"
              ,table_number = "VEH0120"
              ,table_name_vehicle = "heavy goods vehicles"
              ,table_name_grouping = "by make and model"
              ,left_col_num = 2
              ,table_footer_list = c(footer_text_model_missing)
              ,table_units = "Number"
              ,col_widths = c(table_column_width_wide
                              ,table_column_width_wide
                              ,rep(table_column_width_thin,ncol(veh0120_hgvs) - 2)
              )
              ,col_styles = c(rep("styleDefault",2)
                              ,rep("styleNumber",ncol(veh0120_hgvs) - 2)
              )
)

produce_table(wb = wb
              ,table_data = veh0120_buses
              ,type = "stock"
              ,ws_name = "Buses"
              ,table_number = "VEH0120"
              ,table_name_vehicle = "buses & coaches"
              ,table_name_grouping = "by make and model"
              ,left_col_num = 2
              ,table_footer_list = c(footer_text_model_missing)
              ,table_units = "Number"
              ,col_widths = c(table_column_width_wide
                              ,table_column_width_wide
                              ,rep(table_column_width_thin,ncol(veh0120_buses) - 2)
              )
              ,col_styles = c(rep("styleDefault",2)
                              ,rep("styleNumber",ncol(veh0120_buses) - 2)
              )
)

produce_table(wb = wb
              ,table_data = veh0120_others
              ,type = "stock"
              ,ws_name = "Others"
              ,table_number = "VEH0120"
              ,table_name_vehicle = "other vehicles"
              ,table_name_grouping = "by make and model"
              ,left_col_num = 2
              ,table_footer_list = c(footer_text_others
                                     ,footer_text_model_missing
              )
              ,table_units = "Number"
              ,col_widths = c(table_column_width_wide
                              ,table_column_width_wide
                              ,rep(table_column_width_thin,ncol(veh0120_others) - 2)
              )
              ,col_styles = c(rep("styleDefault",2)
                              ,rep("styleNumber",ncol(veh0120_others) - 2)
              )
)

openxlsx::openXL(wb)

## VEH0132 ========

wb <- init_wb()

annual <- arrange(veh0132_uk,Sort) %>% select(-Sort)

# Geographic indentation
rowHeightIndex <- annual %>%
  mutate(
    D = case_when(
      is.na(GeoRank) ~ TRUE,
      GeoRank == 1 ~ TRUE,
      lag(GeoRank) - GeoRank > 0 ~ TRUE, 
      TRUE ~ FALSE
    )
  ) %>%
  select(D) %>%
  t() %>%
  which()

annual <- select(annual,-GeoRank)

produce_table(wb = wb
              ,table_data = annual
              ,type = "ulevstock"
              ,table_number = "VEH0132"
              ,table_name_vehicle = "ultra low emission vehicles (ULEVs)"
              ,table_name_grouping = "by upper and lower tier local authority"
              ,table_units = "Number"
              ,left_col_num = 2
              ,table_footer_list = c(footer_text_c
                                     ,footer_text_plugin
                                     ,footer_text_ulev
                                     ,footer_text_address
                                     ,footer_text_incomplete_postcode
                                     )
              ,col_widths = c(12.5
                              ,35
                              ,rep(8.5,ncol(annual) - 2)
              )
              ,col_styles = c("styleDefault","styleDefault"
                              ,rep("styleNumber",ncol(annual)-2)
              )
              ,row_height_index = rowHeightIndex
            #  ,disclosure = TRUE
              
)

openxlsx::openXL(wb)


## VEH0150 ========

wb <- init_wb()

mdf <- select(veh0150_gb,-PerNum,-Sort)

produce_table(wb = wb
              ,table_data = mdf
              ,type = "newreg"
              ,ws_name = "VEH0150_GB"
              ,table_number = "VEH0150"
              ,table_name_vehicle = "Vehicles"
              ,table_name_grouping = "by body type, including average CO2 emissions for cars and breakdown by ULEVs and plug-in grant eligibility"
              ,table_footer_list = c("Loadsa footers"
              )
              ,col_widths = c(rep(12.5,ncol(mdf))
              )
              ,col_styles = c("styleDate"
                              ,rep("styleThousand",7)
                              ,rep("styleItalic1dp",2)
                              ,rep("styleThousand",4)
              )
)
openxlsx::openXL(wb)

