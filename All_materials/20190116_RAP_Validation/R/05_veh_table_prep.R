
# Script 5: VEH TABLE PREP ----------------------------------------------------------

## Small decimal notation
# paste0("[>=0.05]#,##0.0;[=0]0.0,;",shQuote("-"))

#library(openxlsx)

#preset each style for each of the 5 rows of the title
set_style_title <- c("header"
                     ,"hyperlink"
                     ,"table_title"
                     ,"title"
                     ,"title_units"
)

## Helper functions ------

# Function that shorterns the openxlsx::addStyle function to make code more readable
applyStyle <- function (style
                        ,rows
                        ,cols
                        ,ws_name
) {
  openxlsx::addStyle(wb = wb
                     ,sheet = ws_name
                     ,style = style
                     ,rows = rows
                     ,cols = cols
                     ,gridExpand = TRUE
                     ,stack = TRUE
  )  
}

# Function that pads and applies the admin footnote so that the input footnote list suffices
tidy_footer <- function(...) {
  return <- c(""
              ,...
              ,""
              ,footer_text_admin
  )
  
}

# Function to return the raw data height index for adjusting the row height
# Needs to be aligned using parent's startRow
# TODO Annual breaks for quarterly tables / misalignment for SORN etc.
default_row_height_index <- function(table_data
                                     ,ws_name
                                     ,row_quarter_start
) {
  index <- 4 * 1:1000 + 2 - row_quarter_start
  index <- index[index < nrow(table_data)]
  return(index)
  
}



## Style Library -------
styleDefault <- createStyle(fontSize = 10
                            ,fontColour = "black"
                            ,fontName = "Arial"
)
styleTitle <- createStyle(fontSize = 12
                          ,textDecoration = "bold"
)
styleTitleGreen <- createStyle(wrapText = TRUE
                               ,fontSize = 12
                               ,textDecoration = "bold"
                               ,fontColour = "#006853" # Hex for corporate green
                               ,valign = "top"
)
styleTitleUnits <- createStyle(halign = "right"
)
styleHeaderLeft <- createStyle(wrapText = TRUE
                               ,borderStyle = "medium"
                               ,textDecoration = "bold"
                               ,border = "TopBottom"
                               ,halign = "left"
)
styleHeaderRight <- createStyle(wrapText = TRUE
                                ,borderStyle = "medium"
                                ,textDecoration = "bold"
                                ,border = "TopBottom"
                                ,halign = "right"
)
styleDate <- createStyle(numFmt = "0"
                         ,halign = "left"
)
styleNumber <- createStyle(numFmt = "#,##0"
                           ,halign = "right"
)
styleThousand <- createStyle(numFmt = paste0("[>=0.05]#,##0.0;[=0]0.0,;",shQuote("-"))
                             ,halign = "right"
)
styleItalic1dp <- createStyle(numFmt = "0.0"
                              ,textDecoration = "italic"
                              ,halign = "right"
)
styleFooter <- createStyle(wrapText = TRUE
)

styleBottomTable <- createStyle(wrapText = TRUE
                                ,borderStyle = "medium"
                                ,border = "Top"
)

## Writing functions -------------

# Function to write the title, add the hyperlink and merge the cells - very rigid
write_title <- function (wb
                         ,ws_name
                         ,data
                         ,number
                         ,title
                         ,units
) {
  stopifnot(is.character(ws_name)
            ,is.character(number)
            ,is.character(title)
            ,is.character(units)
  )
  
  to_write <- c("Department for Transport Statistics"
                ,"Vehicle Statistics"
                ,paste0("Table ",number)
                ,title
                ,units
  )
  
  ## Apply hyperlink
  openxlsx::writeData(wb = wb
                      ,sheet = ws_name
                      ,x = hyperlink_veh ## FROM 04
                      ,startRow = 2
                      ,colNames = FALSE
  )
  
  for (r in 1:5) {
    mergeCells(wb = wb
               ,sheet = ws_name
               ,cols = 1:ncol(data)
               ,rows = r
    )
  }
  
  setRowHeights(wb, ws_name, rows = 4, heights = 32) #Double
  
  applyStyle(style = styleTitle,1,1:ncol(data),ws_name)
  applyStyle(style = styleTitleGreen,3:4,1:ncol(data),ws_name)
  applyStyle(style = styleTitleUnits,5,1:ncol(data),ws_name)
  
  openxlsx::writeData(wb = wb
                      ,sheet = ws_name
                      ,x = to_write
                      ,startRow = 1
                      ,colNames = FALSE
  )
  
}

# Function to write the top header
# TODO Add multi row support for complex headers
# TODO Automate column number
write_topheader <- function (wb
                             ,ws_name
                             ,data
                             ,left_col_num = 1
                             ,startRow = 6
) {
  # Input validation
  stopifnot(is.character(ws_name)
            ,is.numeric(left_col_num)
            ,is.numeric(startRow)
  )
  
  to_write <- t(c(colnames(data)))
  
  # Footnote system test
  to_write[2] <- paste0(to_write[2]," [1]") 
  
  applyStyle(style = styleHeaderLeft,startRow,1:left_col_num,ws_name)
  applyStyle(style = styleHeaderRight,startRow,(left_col_num+1):ncol(data),ws_name)
  
  openxlsx::writeData(wb = wb
                      ,sheet = ws_name
                      ,x = to_write
                      ,startRow = startRow
                      ,colNames = FALSE
  )
}

# Function to write the data table
write_data <- function (wb
                        ,ws_name
                        ,data
                        ,col_widths
                        ,col_styles
                        ,startRow = 7
                        ,disclosure
) {
  # Input validation
  stopifnot(is.character(ws_name)
            ,is.numeric(startRow)
  )
  
  # Apply provided column widths to sheet 
  setColWidths(wb = wb
               ,sheet = ws_name
               ,cols = 1:ncol(data)
               ,widths = col_widths
               ,ignoreMergedCells = TRUE
  )
  
  # Apply provided column styles to sheet 
  for (i in seq_along(col_styles)) {
    applyStyle(style = get(col_styles[i])
               ,rows = 1:nrow(data) + startRow - 1
               ,cols = i
               ,ws_name = ws_name
    )
  }
  
  # Write dataset to sheet
  openxlsx:::writeData(wb = wb
                       ,sheet = ws_name
                       ,x = data
                       ,startRow = startRow
                       ,colNames = FALSE
  )
  
  # If disclosure control mode - find all NAs and overwrite individually 
  # Will take a while for a big table (around 10-15 cells per second)
  if (disclosure) {
    for (k in which(is.na(data))) {
      # which provides a vector index that goes down the column of the table
      # adjust k into x,y coordinates
      x <- startRow - 1 + (k %% nrow(data))
      y <- 1 + (k %/% nrow(data))
      
      openxlsx:::writeData(wb = wb
                           ,sheet = ws_name
                           ,x = "c"
                           ,startRow = x
                           ,startCol = y
                           ,colNames = FALSE
      )
    }
  }
}

# Function to write the footer
# TODO Improve input validation
# TODO Improve hyperlink finder which doesn't work
write_footer <- function (wb
                          ,ws_name
                          ,data
                          ,footer_list
                          ,startRow
) {
  
  # Input validation
  stopifnot(is.character(ws_name)
            ,is.numeric(startRow)
  )
  
  # Tidy footer essentially just adds the admin footer to the list
  to_write = tidy_footer(footer_list)
  
  # Draw thick bottom line under the table
  applyStyle(style = styleBottomTable
             ,rows = startRow
             ,cols = 1:ncol(data)
             ,ws_name = ws_name
  )
  
  # Format all footers with styleFooter
  applyStyle(style = styleFooter
             ,rows = startRow + 1:length(footer_list)
             ,cols = 1:ncol(data)
             ,ws_name = ws_name
  )
  
  # Write the footer text under the table
  openxlsx:::writeData(wb = wb
                       ,sheet = ws_name
                       ,x = to_write
                       ,startRow = startRow
                       ,colNames = FALSE
  )
  
  # Merge footnotes either across the table or 18 columns across (stops wide tables having silly footnotes)
  for (r in seq_along(footer_list)) {
    mergeCells(wb = wb
               ,sheet = ws_name
               ,cols = 1:min(ncol(data),18)
               ,rows = startRow + r
    )
  }
  
  # Make footer rows 2 rows high to allow for long footnotes
  # TODO Make this more responsive so that all footnotes can be seen - openxlsx doesn't have an auto row adjust
  setRowHeights(wb = wb
                ,sheet = ws_name
                ,rows = startRow + 1:length(footer_list)
                ,heights = rep(28,length(footer_list))
  )
  
  ## Apply hyperlink
  openxlsx::writeData(wb = wb
                      ,sheet = ws_name
                      ,x = hyperlink_email ## FROM 04
                      ,startRow = startRow + 3 + length(footer_list)
                      ,colNames = FALSE
  )
  
}

## Main function -----

# Function to pull the writing functions together and apply it to a given workbook
produce_table <- function (wb
                           ,table_data
                           ,type
                           ,ws_name = table_number
                           ,table_number
                           ,table_name_vehicle
                           ,table_name_grouping
                           ,left_col_num = 1
                           ,table_footer_list
                           ,table_units = "Thousand"
                           ,col_widths
                           ,col_styles
                           ,row_height_index = NULL # Optional
                           ,row_quarter_start = NA # ONLY used for row separation 
                           ,disclosure = FALSE # Replaces ALL NAs with c
) {
  # Input validation
  stopifnot(is.character(ws_name)
            ,is.character(table_number)
            ,is.character(table_name_vehicle)
            ,is.character(table_name_grouping)
            ,is.numeric(left_col_num)
            ,is.character(table_footer_list)
            ,length(col_widths) == ncol(table_data)
            ,length(col_styles) == ncol(table_data)
  )
  
  # Deal with optional row height arguments
  if(is.null(row_height_index) & !is.na(row_quarter_start)) {
    row_height_index <- default_row_height_index(table_data
                                                 ,ws_name
                                                 ,row_quarter_start = row_quarter_start
    )
  } else if (is.na(row_quarter_start)) {
    row_quarter_start <- 0
  }
  
  addWorksheet(wb = wb
               ,sheetName = ws_name
               ,gridLine = FALSE
  )
  
  # setRowHeights(wb = wb
  #               ,sheet = ws_name
  #               ,rows = 1:(nrow(table_data) + 100)
  #               ,heights = 14
  # )
  
  # Constructs the table title from all the bespoke input
  table_title <- set_text_title(type = type
                                ,table_name_vehicle = table_name_vehicle
                                ,table_name_grouping = table_name_grouping
                                ,year = ws_name
  )
  
  #table_file <- paste0(str_to_lower(table_number),".xlsx")
  
  write_title(wb = wb
              ,ws_name = ws_name
              ,data = table_data
              ,number = table_number
              ,title = table_title
              ,units = table_units
  )
  
  write_topheader(wb = wb
                  ,ws_name = ws_name
                  ,data = table_data
                  ,left_col_num = left_col_num
                  ,startRow = 6
  )
  
  write_data(wb = wb
             ,ws_name = ws_name
             ,data = table_data
             ,col_widths = col_widths
             ,col_styles = col_styles
             ,startRow = 7
             ,disclosure = disclosure
  )
  
  if (!is.na(row_quarter_start)) {
    setRowHeights(wb = wb
                  ,sheet = ws_name
                  ,rows = row_height_index + 7 - 1
                  ,heights = rep(20,length(row_height_index))
    )
  }
  
  footer_row_number = 7 + nrow(table_data)
  
  write_footer(wb = wb
               ,ws_name = ws_name
               ,data = table_data
               ,footer_list = table_footer_list
               ,startRow = footer_row_number
  )
  
}


