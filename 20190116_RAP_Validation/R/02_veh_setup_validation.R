# Script 2: VEH SETUP VALIDATION ----------------------------------------------------------

# [1] Row check functions ------------

# Function to check that disaggregated columns add up to the total in the general case.
row_check_general = function(data) {
  
  # First, remove special columns and averages so they aren't included in the sum
  # grepl uses regex to return an index
  remove <- grepl("Sort|PerNum|Average.", colnames(data))
  check_data <- data[!remove]
  
  if (isTRUE(all.equal(rowSums(select(check_data,-Date,-Total))
                       ,check_data$Total))
  ) {
    "Success - Row consistency test"
  } else {
    "Validation error - Breakdown does not add up to total"
  }
}

# TODO Make this actually work on annual tables...
row_check_split_annual = function(data) {
  
  remove <- grepl("Sort|PerNum|Average.", colnames(data))
  
  check_data <- data[!remove]
  colnames(check_data)[1] <- "Date"
  
  if (isTRUE(all.equal(rowSums(select(check_data,-Date,-Total))
                       ,check_data$Total))
  ) {
    "Success - Row consistency test"
  } else {
    "Validation error - Breakdown does not add up to total"
  }
}

# Deprecated function that explicitly adds up bodytype columns - useful for mixed tables like VEH0150
row_check_bodytype = function(data) {
  if (isTRUE(all.equal(data$Cars + data$Motorcycles + data$`Light Goods Vehicles` +
                       data$`Heavy Goods Vehicles` + data$`Buses & coaches`
                       + data$`Other vehicles`
                       ,data$Total))
  ) {
    "Success - Row consistency test"
  } else {
    "Validation error - Vehicle type columns do not add up to total"
  }
}

# Function to make things roll more smoothly... 
# Tables that are structured with quarters along the top need a separate routine (or maybe a transpose?)
row_check_quarter = function(data) {
  # For now, we turn this off
  "Success - Row consistency test (no check made)"
}


# [2] Comparisons with master tables e.g. VEH0150 ------------

# Function to validate that entries match with the master tables:
#   - VEH0101
#   - VEH0110
#   - VEH0130 (coming soon)
#   - VEH0150
#   - VEH0170 (coming soon)    
master_check = function(data
                        ,type = "newreg"
                        ,check_tab_col = "Total"
                        ,check_master_col = "Total"
                        ,UK = FALSE
) {
  
  # Select the correct master table to validate against
  if (UK & type == "newreg") {
    check_master <- filter(veh0150_uk,PerNum != 3)
  } else if (!UK & type == "newreg") {
    check_master <- filter(veh0150_gb,PerNum != 3)
  } else if (UK & type == "stock") {
    check_master <- veh0101_uk
  } else if (!UK & type == "stock") {
    check_master <- veh0101_gb
  } else if (UK & type == "sorn") {
    check_master <- veh0110_uk
  } else if (!UK & type == "sorn") {
    check_master <- veh0110_gb
  } else {
    stop("Invalid type provided")
  }
  
  # Remove the Sort special column, which is only for sorting 
  if ("Sort" %in% colnames(data)) {
    check_data = filter(data,Sort=="Number" | is.na(Sort))
  } else {
    check_data = data
  }
  
  # If looking at annual stock figures, add on the Q4 label so the correct comparison is made
  if (is.numeric(check_data$Date) & type == "stock") {
    check_data <- mutate(check_data,Date = paste0(as.character(Date)," Q4"))
  }
  
  # Merge the two check datasets together (<<- writes this as a global variable - useful for checking your code!)
  check_join <<- merge(select(check_master,Date,check_master_col)
                       ,select(check_data,Date,check_tab_col)
                       ,by="Date"
  )
  
  # Compare the two check tables via the merge table
  if (nrow(check_join) == 0) { # No joins probably means that the date labels are invalid
    "Date join error occurred"
  } else if (isTRUE(all.equal(check_join[,2],check_join[,3]))) { # Check if each and every entry matches
    paste0("Success - Total for each date matches ",ifelse(UK,"UK ","GB "),type," master: ",check_master_col)
  } else {
    paste0("Validation error - Total does not match master ",type," table")
  }
}

# [3] Core validation function ------

# Function to encapsulate all functions - aiming to be the one stop shop for table validation
# Currently outputs all the log output into the console - could be adapted to backend a report of some sort. 
validate_table = function (data
                           ,style = "bodytype"
                           ,type = "newreg"
                           ,UK = FALSE
) {
  
  ## [a] Calculate helpful information about the table ====
  
  # Provides the name of the variable being inputted
  table_name <- deparse(substitute(data))
  
  # Table log contains all of the output for the validation
  table_log <- c(paste0("Testing ",table_name))
  
  # The table number and name can be used to derive the vehicle type
  table_dataset <- left(table_name,5)
  table_veh_type <-
    case_when (
      table_dataset == "veh01" ~ "Total",
      table_dataset == "veh02" ~ "Cars",
      table_dataset == "veh03" ~ "Motorcycles",
      table_dataset == "veh04" ~ "Light Goods Vehicles",
      table_dataset == "veh05" ~ "Heavy Goods Vehicles",
      table_dataset == "veh06" ~ "Buses & coaches",
      TRUE ~ "ERROR in table variable name"
    )
  
  # VEH01 contains several tables with multiple vehicle types
  if (table_dataset == "veh01") {
    table_suffix <- substr(table_name,9,255)
    
    if (!(table_suffix %in% c("gb","uk"))) {
      table_veh_type <-
        case_when(
          table_suffix == "cars" ~ "Cars",
          table_suffix == "bikes" ~ "Motorcycles",
          table_suffix == "lgvs" ~ "Light Goods Vehicles",
          table_suffix == "hgvs" ~ "Heavy Goods Vehicles",
          table_suffix == "buses" ~ "Buses & coaches",
          table_suffix == "others" ~ "Other vehicles",
          TRUE ~ "ERROR in table variable name"
        )
    }
  }
  
  # This step illustrates the type of checks that will be done
  # Helps isolate any human error (e.g. incorrect style for a table)
  table_log <- c(table_log,paste0("Proposed table type: ",ifelse(UK,"UK ","GB "),table_veh_type," ",type))
  
  # Uses veh0101 (a master table) to calculate the latest quarter and full year, which are two useful values
  latest_quarter <<- (select(veh0101_gb,Date) %>%
                        arrange(desc(Date)))[1,]
  latest_year <<- (filter(veh0101_gb,right(Date,2)=="Q4") %>%
                     select(Date) %>%
                     arrange(desc(Date)))[1,]
  
  ## [b] Restructure quarterly tables as the sum of each column ====
  
  # "Quarter" tables have their columns summed to check again master tables
  # "Total" tables contain only one stock year of data, so this constructs a table of the right form
  # TODO Need to add a check of the full table for errors
  if (style == "quarter") {
    data <-
      colSums(base::Filter(is.numeric, data),na.rm = TRUE) %>%
      enframe(value="Total") %>%
      mutate(UK = left(name,2) == "UK"
             ,Date = right(name,7)
             ,Total = Total / 1000.0
      )
  } else if (style == "total") {
    data <-
      data.frame(list(latest_year
                      ,sum(data$Total)
      )
      ,stringsAsFactors = FALSE
      )
    names(data) <- c("Date","Total")
    data <- mutate(data,Total = Total / 1000.0)
  }
  
  ## [c] Row consistency test =======
  
  # Cut out cols with nulls
  columns_with_nulls = intersect(c("Year-on-year change in total vehicles")
                                 ,colnames(data))
  
  row_check_data <- select(data,-one_of(columns_with_nulls))
  
  # Cut out rows with nulls
  indx <- apply(row_check_data,1,function(x) any(is.na(x)))
  
  row_check_data <- filter(row_check_data,!indx)
  
  # Use style to pick the right row check
  if (style == "bodytype") {
    test_status <- row_check_bodytype(row_check_data)
  } else if (style %in% c("quarter","total")) {
    test_status <- row_check_quarter(row_check_data)
  } else if (style == "split") {
    test_status <- row_check_general(row_check_data)
  } else if (style == "split_annual") {
    test_status <- row_check_split_annual(row_check_data)
  } else (
    test_status <- "Style error"
  )
  table_log <- c(table_log,test_status)
  
  ## [d] Comparison with master test =======
  
  if (style == "bodytype") {
    table_log <- c(table_log,master_check(data,type = type,check_tab_col = "Cars",check_master_col = "Cars",UK=UK))
    table_log <- c(table_log,master_check(data,type = type,check_tab_col = "Motorcycles",check_master_col = "Motorcycles",UK=UK))
    table_log <- c(table_log,master_check(data,type = type,check_tab_col = "Light Goods Vehicles",check_master_col = "Light Goods Vehicles",UK=UK))
    table_log <- c(table_log,master_check(data,type = type,check_tab_col = "Heavy Goods Vehicles",check_master_col = "Heavy Goods Vehicles",UK=UK))
    table_log <- c(table_log,master_check(data,type = type,check_tab_col = "Buses & coaches",check_master_col = "Buses & coaches",UK=UK))
    table_log <- c(table_log,master_check(data,type = type,check_tab_col = "Other vehicles",check_master_col = "Other vehicles",UK=UK))
  } else if (style == "quarter") {
    table_log <- c(table_log
                   ,master_check(filter(data,UK==TRUE)
                                 ,type = type
                                 ,check_tab_col = "Total"
                                 ,check_master_col = table_veh_type
                                 ,UK=TRUE
                   )
    )
    table_log <- c(table_log
                   ,master_check(filter(data,UK==FALSE)
                                 ,type = type
                                 ,check_tab_col = "Total"
                                 ,check_master_col = table_veh_type
                                 ,UK=FALSE
                   )
    )
  } else {
    table_log <- c(table_log,master_check(data
                                          ,type = type
                                          ,check_tab_col = "Total"
                                          ,check_master_col = table_veh_type
                                          ,UK=UK
    )
    )
  }
  
  
  ## Internal sum test
  ## TO GENERALISE for annual and quarterly figures equalling each other - highly unlikely to be needed
  
  # data <- transform(data, year = case_when(PerNum == 1 ~ Date,
  #                                                 PerNum == 2 ~ left(Date,4),
  #                                                 PerNum == 3 ~ right(Date,4)
  #                                                 )
  #                       )
  # 
  # if (
  #     data %>% group_by(year,PerNum) %>%
  #          summarise(a = sum(Cars)
  #                    ,b = sum(Bikes)
  #                    ,c = sum(LGV)
  #                    ,d = sum(HGV)
  #                    ,e = sum(Other)
  #                    ,f = sum(Total)
  #                    ) %>%
  #          group_by(year) %>%
  #          summarise(a = max(a) - min(a)
  #                    ,b = max(b) - min(b)
  #                    ,c = max(c) - min(c)
  #                    ,d = max(d) - min(d)
  #                    ,e = max(e) - min(e)
  #                    ,f = max(f) - min(f)
  #                    ) %>%
  #          summarise(n = max(abs(c(a,b,c,d,e,f)))
  #                    ) > 1e-6
  # ) {
  #   table_log <- c(table_log,"Validation error - Mismatch between year, quarter, or monthly field")
  # } else {
  #   table_log <- c(table_log,"Success - Internal sum check")
  # }
  # 
  
  
  ## [e] Null test =======
  indx <- apply(data
                ,2                         # Columns
                ,function(x) any(is.na(x))
  ) 
  
  if (any(indx)) {
    table_log <- c(table_log,paste0("Validation error - Nulls present in columns: "
                                    ,paste(colnames(data)[colSums(is.na(data)) > 0],collapse = ","))
    )
  } else {
    table_log <- c(table_log,"Success - Null check across all columns")
  }
  
  cat(table_log, sep = "\n") # Print output vertically
}