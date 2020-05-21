
# Script 1: VEH DATA RETRIEVE ----------------------------------------------------------

## Packages used =================================

.libPaths(c("C:/Program Files/R/R-3.4.3/library","P:/My Documents/R/Win-Library/3.4"))

library(dplyr)
library(readr)
library(stringr)
library(lubridate)
library(reshape2)
library(xltabr)
library(openxlsx)
library(devtools)
library(dbplyr)
library(RODBC)
library(tidyverse)

# [1] Add helper functions ------------

# This function does a basic SQL table fetch of the premade output tables
# Equivalent of "select * from tablename"
extractSQL = function (conn,tablename) {
  RODBC::sqlFetch(channel = conn
                  ,sqtable = tablename
                  ,stringsAsFactors = FALSE
                #  ,na.strings = ""
                  ,max = 2000   ## Temporary filter to speed up development
  ) 
}

right = function (string, char) {
  substr(string,nchar(string)-(char-1),nchar(string))
}

left = function (string,char) {
  substr(string,1,char)
}  

# [2] Import stock data from SQL ------------

# It is worth noting that SQL tables are not explicitly sorted when stored on the server so resorting in R is mandatory
#
## Create connection to SQL and fetch stock data =================================

# if you don't have permission to access this database then this will not work!
conn_stock <- RODBC::odbcDriverConnect(
  'driver={SQL Server};server=TS03;database=Vehicles_Stock;trusted_connection=TRUE'
)



####$$$$$$$ VEH01 All vehicles####

### VEH0101 ###############
veh0101_gb <- extractSQL(conn_stock,"RAP.VEH0101_GB") %>% arrange(Date)
veh0101_uk <- extractSQL(conn_stock,"RAP.VEH0101_UK") %>% arrange(Date)

### VEH0105 ###############
veh0105_uk <- extractSQL(conn_stock,"RAP.VEH0105") %>% arrange(Date,Sort)

### VEH0110 ###############
veh0110_gb <- extractSQL(conn_stock,"RAP.VEH0110_GB") %>% arrange(Date)
veh0110_uk <- extractSQL(conn_stock,"RAP.VEH0110_UK") %>% arrange(Date)

### VEH0120 ###############
veh0120_cars <- extractSQL(conn_stock,"RAP.VEH0120_Cars") %>% arrange(Make,Model)
veh0120_bikes <- extractSQL(conn_stock,"RAP.VEH0120_Bikes") %>% arrange(Make,Model)
veh0120_lgvs <- extractSQL(conn_stock,"RAP.VEH0120_LGVs") %>% arrange(Make,Model)
veh0120_hgvs <- extractSQL(conn_stock,"RAP.VEH0120_HGVs") %>% arrange(Make,Model)
veh0120_buses <- extractSQL(conn_stock,"RAP.VEH0120_Buses") %>% arrange(Make,Model)
veh0120_others <- extractSQL(conn_stock,"RAP.VEH0120_Others") %>% arrange(Make,Model)

### VEH0121 ###############
# veh0121_cars <- extractSQL(conn_stock,"RAP.VEH0121_Cars") %>% arrange(Make,Model)
# veh0121_bikes <- extractSQL(conn_stock,"RAP.VEH0121_Bikes") %>% arrange(Make,Model)
# veh0121_lgvs <- extractSQL(conn_stock,"RAP.VEH0121_LGVs") %>% arrange(Make,Model)
# veh0121_hgvs <- extractSQL(conn_stock,"RAP.VEH0121_HGVs") %>% arrange(Make,Model)
# veh0121_buses <- extractSQL(conn_stock,"RAP.VEH0121_Buses") %>% arrange(Make,Model)
# veh0121_others <- extractSQL(conn_stock,"RAP.VEH0121_Others") %>% arrange(Make,Model)
#
# ### VEH0124 ###############
# veh0124_cars <- extractSQL(conn_stock,"RAP.VEH0124_Cars") %>% arrange(Make,Model)
# veh0124_bikes <- extractSQL(conn_stock,"RAP.VEH0124_Bikes") %>% arrange(Make,Model)
# veh0124_lgvs <- extractSQL(conn_stock,"RAP.VEH0124_LGVs") %>% arrange(Make,Model)
# veh0124_hgvs <- extractSQL(conn_stock,"RAP.VEH0124_HGVs") %>% arrange(Make,Model)
# veh0124_buses <- extractSQL(conn_stock,"RAP.VEH0124_Buses") %>% arrange(Make,Model)
# veh0124_others <- extractSQL(conn_stock,"RAP.VEH0124_Others") %>% arrange(Make,Model)
#
# ### VEH0125 ###############
# veh0125_cars <- extractSQL(conn_stock,"RAP.VEH0125_Cars") %>% arrange(Make,Model)
# veh0125_bikes <- extractSQL(conn_stock,"RAP.VEH0125_Bikes") %>% arrange(Make,Model)
# veh0125_lgvs <- extractSQL(conn_stock,"RAP.VEH0125_LGVs") %>% arrange(Make,Model)
# veh0125_hgvs <- extractSQL(conn_stock,"RAP.VEH0125_HGVs") %>% arrange(Make,Model)
# veh0125_buses <- extractSQL(conn_stock,"RAP.VEH0125_Buses") %>% arrange(Make,Model)
# veh0125_others <- extractSQL(conn_stock,"RAP.VEH0125_Others") %>% arrange(Make,Model)
#
# ### VEH0126 ###############
# veh0126_cars <- extractSQL(conn_stock,"RAP.VEH0126_Cars") %>% arrange(Make,Model)
# veh0126_bikes <- extractSQL(conn_stock,"RAP.VEH0126_Bikes") %>% arrange(Make,Model)
# veh0126_lgvs <- extractSQL(conn_stock,"RAP.VEH0126_LGVs") %>% arrange(Make,Model)
# veh0126_hgvs <- extractSQL(conn_stock,"RAP.VEH0126_HGVs") %>% arrange(Make,Model)
# veh0126_buses <- extractSQL(conn_stock,"RAP.VEH0126_Buses") %>% arrange(Make,Model)
# veh0126_others <- extractSQL(conn_stock,"RAP.VEH0126_Others") %>% arrange(Make,Model)
#
# ### VEH0127 ###############
# veh0127_cars <- extractSQL(conn_stock,"RAP.VEH0127_Cars") %>% arrange(Make,Model)
# veh0127_bikes <- extractSQL(conn_stock,"RAP.VEH0127_Bikes") %>% arrange(Make,Model)
# veh0127_lgvs <- extractSQL(conn_stock,"RAP.VEH0127_LGVs") %>% arrange(Make,Model)
# veh0127_hgvs <- extractSQL(conn_stock,"RAP.VEH0127_HGVs") %>% arrange(Make,Model)
# veh0127_buses <- extractSQL(conn_stock,"RAP.VEH0127_Buses") %>% arrange(Make,Model)
# veh0127_others <- extractSQL(conn_stock,"RAP.VEH0127_Others") %>% arrange(Make,Model)
#
# ### VEH0128 ###############
# veh0128_cars <- extractSQL(conn_stock,"RAP.VEH0128_Cars") %>% arrange(desc(get(colnames(.)[2]))
#                                                                       ,`Generic model`
# )
# veh0128_bikes <- extractSQL(conn_stock,"RAP.VEH0128_Bikes") %>% arrange(`Generic model`)
# veh0128_lgvs <- extractSQL(conn_stock,"RAP.VEH0128_LGVs") %>% arrange(desc(get(colnames(.)[2]))
#                                                                       ,`Generic model`
# )
# veh0128_hgvs <- extractSQL(conn_stock,"RAP.VEH0128_HGVs") %>% arrange(`Generic model`)
# veh0128_buses <- extractSQL(conn_stock,"RAP.VEH0128_Buses") %>% arrange(`Generic model`)
# veh0128_others <- extractSQL(conn_stock,"RAP.VEH0128_Others") %>% arrange(`Generic model`)
#
# ### VEH0129 ###############
# veh0129_cars <- extractSQL(conn_stock,"RAP.VEH0129_Cars") %>% arrange(desc(get(colnames(.)[2]))
#                                                                       ,`Generic model`
# )
# veh0129_bikes <- extractSQL(conn_stock,"RAP.VEH0129_Bikes") %>% arrange(`Generic model`)
# veh0129_lgvs <- extractSQL(conn_stock,"RAP.VEH0129_LGVs") %>% arrange(desc(get(colnames(.)[2]))
#                                                                       ,`Generic model`
# )
# veh0129_hgvs <- extractSQL(conn_stock,"RAP.VEH0129_HGVs") %>% arrange(`Generic model`)
# veh0129_buses <- extractSQL(conn_stock,"RAP.VEH0129_Buses") %>% arrange(`Generic model`)
# veh0129_others <- extractSQL(conn_stock,"RAP.VEH0129_Others") %>% arrange(`Generic model`)

### VEH0132 ###############
veh0131_uk <- extractSQL(conn_stock,"RAP.VEH0131") %>% arrange(Sort)

### VEH0132 ###############
veh0132_uk <- extractSQL(conn_stock,"RAP.VEH0132") %>% arrange(Sort)

####$$$$$$$ VEH02 Cars ####

### VEH0202 ###############
veh0202_gb <- extractSQL(conn_stock,"RAP.VEH0202_GB") %>% arrange(Date)
veh0202_uk <- extractSQL(conn_stock,"RAP.VEH0202_UK") %>% arrange(Date)

### VEH0203 ###############
veh0203_gb <- extractSQL(conn_stock,"RAP.VEH0203_GB") %>% arrange(Date)
veh0203_uk <- extractSQL(conn_stock,"RAP.VEH0203_UK") %>% arrange(Date)

### VEH0204 ###############
veh0204_uk <- extractSQL(conn_stock,"RAP.VEH0204") %>% arrange(Date)

### VEH0205 ###############
veh0205_all_gb <- extractSQL(conn_stock,"RAP.VEH0205_All_GB") %>% arrange(Date)
veh0205_petrol_gb <- extractSQL(conn_stock,"RAP.VEH0205_Petrol_GB") %>% arrange(Date)
veh0205_diesel_gb <- extractSQL(conn_stock,"RAP.VEH0205_Diesel_GB") %>% arrange(Date)
veh0205_all_uk <- extractSQL(conn_stock,"RAP.VEH0205_All_UK") %>% arrange(Date)
veh0205_petrol_uk <- extractSQL(conn_stock,"RAP.VEH0205_Petrol_UK") %>% arrange(Date)
veh0205_diesel_uk <- extractSQL(conn_stock,"RAP.VEH0205_Diesel_UK") %>% arrange(Date)

### VEH0206 ###############
veh0206_gb <- extractSQL(conn_stock,"RAP.VEH0206_GB") %>% arrange(Date)
veh0206_uk <- extractSQL(conn_stock,"RAP.VEH0206_UK") %>% arrange(Date)

### VEH0208 ###############
veh0208_gb <- extractSQL(conn_stock,"RAP.VEH0208_GB") %>% arrange(Date)
veh0208_uk <- extractSQL(conn_stock,"RAP.VEH0208_UK") %>% arrange(Date)

### VEH0211 ###############
veh0211_all_gb <- extractSQL(conn_stock,"RAP.VEH0211_All_GB") %>% arrange(Date)
veh0211_petrol_gb <- extractSQL(conn_stock,"RAP.VEH0211_Petrol_GB") %>% arrange(Date)
veh0211_diesel_gb <- extractSQL(conn_stock,"RAP.VEH0211_Diesel_GB") %>% arrange(Date)
veh0211_all_uk <- extractSQL(conn_stock,"RAP.VEH0211_All_UK") %>% arrange(Date)
veh0211_petrol_uk <- extractSQL(conn_stock,"RAP.VEH0211_Petrol_UK") %>% arrange(Date)
veh0211_diesel_uk <- extractSQL(conn_stock,"RAP.VEH0211_Diesel_UK") %>% arrange(Date)

####$$$$$$$ VEH03 Motorcycles ####

### VEH0302 ###############
veh0302_gb <- extractSQL(conn_stock,"RAP.VEH0302_GB") %>% arrange(Date)
veh0302_uk <- extractSQL(conn_stock,"RAP.VEH0302_UK") %>% arrange(Date)

### VEH0303 ###############
veh0303_gb <- extractSQL(conn_stock,"RAP.VEH0303_GB") %>% arrange(Date)
veh0303_uk <- extractSQL(conn_stock,"RAP.VEH0303_UK") %>% arrange(Date)

### VEH0304 ###############
veh0304_uk <- extractSQL(conn_stock,"RAP.VEH0304") %>% arrange(Date)

### VEH0305 ###############
veh0305_gb <- extractSQL(conn_stock,"RAP.VEH0305_GB") %>% arrange(Date)
veh0305_uk <- extractSQL(conn_stock,"RAP.VEH0305_UK") %>% arrange(Date)

### VEH0308 ###############
veh0308_gb <- extractSQL(conn_stock,"RAP.VEH0308_GB") %>% arrange(Date)
veh0308_uk <- extractSQL(conn_stock,"RAP.VEH0308_UK") %>% arrange(Date)

### VEH0311 ###############
veh0311_gb <- extractSQL(conn_stock,"RAP.VEH0311_GB") %>% arrange(Date)
veh0311_uk <- extractSQL(conn_stock,"RAP.VEH0311_UK") %>% arrange(Date)

####$$$$$$$ VEH04 LGVs ####

### VEH0402 ###############
veh0402_gb <- extractSQL(conn_stock,"RAP.VEH0402_GB") %>% arrange(Date)
veh0402_uk <- extractSQL(conn_stock,"RAP.VEH0402_UK") %>% arrange(Date)

### VEH0403 ###############
veh0403_gb <- extractSQL(conn_stock,"RAP.VEH0403_GB") %>% arrange(Date)
veh0403_uk <- extractSQL(conn_stock,"RAP.VEH0403_UK") %>% arrange(Date)

### VEH0404 ###############
veh0404_uk <- extractSQL(conn_stock,"RAP.VEH0404") %>% arrange(Date)

### VEH048 ###############
veh0408_gb <- extractSQL(conn_stock,"RAP.VEH0408_GB") %>% arrange(Date)
veh0408_uk <- extractSQL(conn_stock,"RAP.VEH0408_UK") %>% arrange(Date)

### VEH0411 ###############
veh0411_all_gb <- extractSQL(conn_stock,"RAP.VEH0411_All_GB") %>% arrange(Date)
veh0411_petrol_gb <- extractSQL(conn_stock,"RAP.VEH0411_Petrol_GB") %>% arrange(Date)
veh0411_diesel_gb <- extractSQL(conn_stock,"RAP.VEH0411_Diesel_GB") %>% arrange(Date)
veh0411_all_uk <- extractSQL(conn_stock,"RAP.VEH0411_All_UK") %>% arrange(Date)
veh0411_petrol_uk <- extractSQL(conn_stock,"RAP.VEH0411_Petrol_UK") %>% arrange(Date)
veh0411_diesel_uk <- extractSQL(conn_stock,"RAP.VEH0411_Diesel_UK") %>% arrange(Date)

####$$$$$$$ VEH05 HGVs ####

### VEH0502 ###############
veh0502_gb <- extractSQL(conn_stock,"RAP.VEH0502_GB") %>% arrange(Date)
veh0502_uk <- extractSQL(conn_stock,"RAP.VEH0502_UK") %>% arrange(Date)

### VEH0503 ###############
veh0503_gb <- extractSQL(conn_stock,"RAP.VEH0503_GB") %>% arrange(Date)
veh0503_uk <- extractSQL(conn_stock,"RAP.VEH0503_UK") %>% arrange(Date)

### VEH0504 ###############
veh0504_uk <- extractSQL(conn_stock,"RAP.VEH0504") %>% arrange(Date)

### VEH0508 ###############
veh0508_gb <- extractSQL(conn_stock,"RAP.VEH0508_GB") %>% arrange(Date)
veh0508_uk <- extractSQL(conn_stock,"RAP.VEH0508_UK") %>% arrange(Date)

### VEH0511 ###############
veh0511_gb <- extractSQL(conn_stock,"RAP.VEH0511_GB") %>% arrange(Date)
veh0511_uk <- extractSQL(conn_stock,"RAP.VEH0511_UK") %>% arrange(Date)

####$$$$$$$ VEH06 Buses ####

### VEH0602 ###############
veh0602_gb <- extractSQL(conn_stock,"RAP.VEH0602_GB") %>% arrange(Date)
veh0602_uk <- extractSQL(conn_stock,"RAP.VEH0602_UK") %>% arrange(Date)

### VEH0603 ###############
veh0603_gb <- extractSQL(conn_stock,"RAP.VEH0603_GB") %>% arrange(Date)
veh0603_uk <- extractSQL(conn_stock,"RAP.VEH0603_UK") %>% arrange(Date)

### VEH0604 ###############
veh0604_uk <- extractSQL(conn_stock,"RAP.VEH0604") %>% arrange(Date)

### VEH0608 ###############
veh0608_gb <- extractSQL(conn_stock,"RAP.VEH0608_GB") %>% arrange(Date)
veh0608_uk <- extractSQL(conn_stock,"RAP.VEH0608_UK") %>% arrange(Date)

### VEH0611 ###############
veh0611_gb <- extractSQL(conn_stock,"RAP.VEH0611_GB") %>% arrange(Date)
veh0611_uk <- extractSQL(conn_stock,"RAP.VEH0611_UK") %>% arrange(Date)


close(conn_stock)



# [3] Import newreg data from SQL ------------

## Create connection to SQL and fetch newreg data =================================

# if you don't have permission to access this database then this will not work!
conn_new <- RODBC::odbcDriverConnect(
  'driver={SQL Server};server=TS03;database=Vehicles_NewReg;trusted_connection=TRUE'
)

### VEH0150 ###########
veh0150_gb <- extractSQL(conn_new,"RAP.VEH0150_GB") %>% arrange(PerNum,Sort)
veh0150_uk <- extractSQL(conn_new,"RAP.VEH0150_UK") %>% arrange(PerNum,Sort)

# ### VEH0160 ###############
# veh0160_cars <- extractSQL(conn_new,"RAP.VEH0160_Cars") %>% arrange(Make,Model)
# veh0160_bikes <- extractSQL(conn_new,"RAP.VEH0160_Bikes") %>% arrange(Make,Model)
# veh0160_lgvs <- extractSQL(conn_new,"RAP.VEH0160_LGVs") %>% arrange(Make,Model)
# veh0160_hgvs <- extractSQL(conn_new,"RAP.VEH0160_HGVs") %>% arrange(Make,Model)
# veh0160_buses <- extractSQL(conn_new,"RAP.VEH0160_Buses") %>% arrange(Make,Model)
# veh0160_others <- extractSQL(conn_new,"RAP.VEH0160_Others") %>% arrange(Make,Model)
# 
# ### VEH0161 ###############
# veh0161_cars <- extractSQL(conn_new,"RAP.VEH0161_Cars") %>% arrange(desc(get(colnames(.)[2]))
#                                                                       ,`Generic model`
# )
# veh0161_bikes <- extractSQL(conn_new,"RAP.VEH0161_Bikes") %>% arrange(`Generic model`)
# veh0161_lgvs <- extractSQL(conn_new,"RAP.VEH0161_LGVs") %>% arrange(desc(get(colnames(.)[2]))
#                                                                       ,`Generic model`
# )
# veh0161_hgvs <- extractSQL(conn_new,"RAP.VEH0161_HGVs") %>% arrange(`Generic model`)
# veh0161_buses <- extractSQL(conn_new,"RAP.VEH0161_Buses") %>% arrange(`Generic model`)
# veh0161_others <- extractSQL(conn_new,"RAP.VEH0161_Others") %>% arrange(`Generic model`)
# 

### VEH0252 ###############
veh0252_gb <- extractSQL(conn_new,"RAP.VEH0252_GB")
veh0252_uk <- extractSQL(conn_new,"RAP.VEH0252_UK")

### VEH0253 ###############
veh0253_gb <- extractSQL(conn_new,"RAP.VEH0253_GB") %>% arrange(PerNum,Date)
veh0253_uk <- extractSQL(conn_new,"RAP.VEH0253_UK") %>% arrange(PerNum,Date)
# 
# ### VEH0256 ###############
veh0256_gb <- extractSQL(conn_new,"RAP.VEH0256_GB") %>% arrange(PerNum,Date)
veh0256_uk <- extractSQL(conn_new,"RAP.VEH0256_UK") %>% arrange(PerNum,Date)

close(conn_new)

