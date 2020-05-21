# Script 3: VEH APPLY VALIDATION ----------------------------------------------------------

####$$$ VEH01 All vehicles $$$####

# VEH0101 ==========
validate_table(veh0101_gb,type="stock",style="bodytype",UK=FALSE)
validate_table(veh0101_uk,type="stock",style="bodytype",UK=TRUE)

# VEH0105 ==========
#validate_table(veh0105_uk,type="stock",style="bodytype",UK=TRUE)

# VEH0110 ==========
validate_table(veh0110_gb,type="sorn",style="bodytype",UK=FALSE)
validate_table(veh0110_uk,type="sorn",style="bodytype",UK=TRUE)

# # VEH0120 ==========
validate_table(veh0120_cars,type="stock",style="quarter",UK=TRUE)
# validate_table(veh0120_bikes,type="stock",style="quarter",UK=TRUE)
# validate_table(veh0120_lgvs,type="stock",style="quarter",UK=TRUE)
# validate_table(veh0120_hgvs,type="stock",style="quarter",UK=TRUE)
# validate_table(veh0120_buses,type="stock",style="quarter",UK=TRUE)
# validate_table(veh0120_others,type="stock",style="quarter",UK=TRUE)
# 
# # VEH0121 ==========
# validate_table(veh0121_cars,type="sorn",style="quarter",UK=TRUE)
# validate_table(veh0121_bikes,type="sorn",style="quarter",UK=TRUE)
# validate_table(veh0121_lgvs,type="sorn",style="quarter",UK=TRUE)
# validate_table(veh0121_hgvs,type="sorn",style="quarter",UK=TRUE)
# validate_table(veh0121_buses,type="sorn",style="quarter",UK=TRUE)
# validate_table(veh0121_others,type="sorn",style="quarter",UK=TRUE)
# 
# # VEH0124 ==========
# validate_table(veh0124_cars,type="stock",style="total",UK=TRUE)
# validate_table(veh0124_bikes,type="stock",style="total",UK=TRUE)
# validate_table(veh0124_lgvs,type="stock",style="total",UK=TRUE)
# validate_table(veh0124_hgvs,type="stock",style="total",UK=TRUE)
# validate_table(veh0124_buses,type="stock",style="total",UK=TRUE)
# validate_table(veh0124_others,type="stock",style="total",UK=TRUE)
# 
# # VEH0125 ==========
# validate_table(veh0125_cars,type="sorn",style="total",UK=TRUE)
# validate_table(veh0125_bikes,type="sorn",style="total",UK=TRUE)
# validate_table(veh0125_lgvs,type="sorn",style="total",UK=TRUE)
# validate_table(veh0125_hgvs,type="sorn",style="total",UK=TRUE)
# validate_table(veh0125_buses,type="sorn",style="total",UK=TRUE)
# validate_table(veh0125_others,type="sorn",style="total",UK=TRUE)
# 
# # VEH0126 ==========
# validate_table(veh0126_cars,type="stock",style="total",UK=TRUE)
# validate_table(veh0126_bikes,type="stock",style="total",UK=TRUE)
# validate_table(veh0126_lgvs,type="stock",style="total",UK=TRUE)
# validate_table(veh0126_hgvs,type="stock",style="total",UK=TRUE)
# validate_table(veh0126_buses,type="stock",style="total",UK=TRUE)
# validate_table(veh0126_others,type="stock",style="total",UK=TRUE)
# 
# # VEH0127 ==========
# validate_table(veh0127_cars,type="sorn",style="total",UK=TRUE)
# validate_table(veh0127_bikes,type="sorn",style="total",UK=TRUE)
# validate_table(veh0127_lgvs,type="sorn",style="total",UK=TRUE)
# validate_table(veh0127_hgvs,type="sorn",style="total",UK=TRUE)
# validate_table(veh0127_buses,type="sorn",style="total",UK=TRUE)
# validate_table(veh0127_others,type="sorn",style="total",UK=TRUE)
# 
# # VEH0128 ==========
# validate_table(veh0128_cars,type="stock",style="quarter",UK=TRUE)
# validate_table(veh0128_bikes,type="stock",style="quarter",UK=TRUE)
# validate_table(veh0128_lgvs,type="stock",style="quarter",UK=TRUE)
# validate_table(veh0128_hgvs,type="stock",style="quarter",UK=TRUE)
# validate_table(veh0128_buses,type="stock",style="quarter",UK=TRUE)
# validate_table(veh0128_others,type="stock",style="quarter",UK=TRUE)
# 
# # VEH0129 ==========
# validate_table(veh0129_cars,type="sorn",style="quarter",UK=TRUE)
# validate_table(veh0129_bikes,type="sorn",style="quarter",UK=TRUE)
# validate_table(veh0129_lgvs,type="sorn",style="quarter",UK=TRUE)
# validate_table(veh0129_hgvs,type="sorn",style="quarter",UK=TRUE)
# validate_table(veh0129_buses,type="sorn",style="quarter",UK=TRUE)
# validate_table(veh0129_others,type="sorn",style="quarter",UK=TRUE)

# VEH0150 ==========
validate_table(veh0150_gb,type="newreg",style="bodytype",UK=FALSE)
validate_table(veh0150_uk,type="newreg",style="bodytype",UK=TRUE)

# # VEH0160 ==========
# validate_table(veh0160_cars,type="newreg",style="quarter",UK=TRUE)
# validate_table(veh0160_bikes,type="newreg",style="quarter",UK=TRUE)
# validate_table(veh0160_lgvs,type="newreg",style="quarter",UK=TRUE)
# validate_table(veh0160_hgvs,type="newreg",style="quarter",UK=TRUE)
# validate_table(veh0160_buses,type="newreg",style="quarter",UK=TRUE)
# validate_table(veh0160_others,type="newreg",style="quarter",UK=TRUE)
# 
# # VEH0161 ==========
# validate_table(veh0161_cars,type="newreg",style="quarter",UK=TRUE)
# validate_table(veh0161_bikes,type="newreg",style="quarter",UK=TRUE)
# validate_table(veh0161_lgvs,type="newreg",style="quarter",UK=TRUE)
# validate_table(veh0161_hgvs,type="newreg",style="quarter",UK=TRUE)
# validate_table(veh0161_buses,type="newreg",style="quarter",UK=TRUE)
# validate_table(veh0161_others,type="newreg",style="quarter",UK=TRUE)


####$$$$$ VEH02 Cars ####

# VEH0202 ==========
validate_table(veh0202_gb,type="stock",style="split",UK=FALSE)
validate_table(veh0202_uk,type="stock",style="split",UK=TRUE)

# VEH0203 ==========
validate_table(veh0203_gb,type="stock",style="split",UK=FALSE)
validate_table(veh0203_uk,type="stock",style="split",UK=TRUE)

# # VEH0205 ==========
# validate_table(veh0205_all_gb,type="stock",style="split",UK=FALSE)
# validate_table(veh0205_petrol_gb,type="stock",style="split",UK=FALSE)
# validate_table(veh0205_diesel_gb,type="stock",style="split",UK=FALSE)
# validate_table(veh0205_all_uk,type="stock",style="split",UK=TRUE)
# validate_table(veh0205_petrol_uk,type="stock",style="split",UK=TRUE)
# validate_table(veh0205_diesel_uk,type="stock",style="split",UK=TRUE)

# VEH0206 ==========
validate_table(veh0206_gb,type="stock",style="split",UK=FALSE)
validate_table(veh0206_uk,type="stock",style="split",UK=TRUE)

# # VEH0208 ==========
# validate_table(veh0208_gb,type="stock",style="split_annual",UK=FALSE)
# validate_table(veh0208_uk,type="stock",style="split",UK=TRUE)
# 
# # VEH0211 ==========
# validate_table(veh0211_all_gb,type="stock",style="split",UK=FALSE)
# validate_table(veh0211_petrol_gb,type="stock",style="split",UK=FALSE)
# validate_table(veh0211_diesel_gb,type="stock",style="split",UK=FALSE)
# validate_table(veh0211_all_uk,type="stock",style="split",UK=TRUE)
# validate_table(veh0211_petrol_uk,type="stock",style="split",UK=TRUE)
# validate_table(veh0211_diesel_uk,type="stock",style="split",UK=TRUE)

# VEH0252 ==========
validate_table(veh0252_gb,type="newreg",style="split",UK=FALSE)
validate_table(veh0252_uk,type="newreg",style="split",UK=TRUE)

# VEH0253 ==========
validate_table(veh0253_gb,type="newreg",style="split",UK=FALSE)
validate_table(veh0253_uk,type="newreg",style="split",UK=TRUE)

# VEH0256 ==========
validate_table(veh0256_gb,type="newreg",style="split",UK=FALSE)
validate_table(veh0256_uk,type="newreg",style="split",UK=TRUE)


####$$$$$ VEH03 Motorcycles ####

# VEH0302 ==========
validate_table(veh0302_gb,type="stock",style="split",UK=FALSE)
validate_table(veh0302_uk,type="stock",style="split",UK=TRUE)

# VEH0303 ==========
validate_table(veh0303_gb,type="stock",style="split",UK=FALSE)
validate_table(veh0303_uk,type="stock",style="split",UK=TRUE)

# VEH0305 ==========
validate_table(veh0305_gb,type="stock",style="split",UK=FALSE)
validate_table(veh0305_uk,type="stock",style="split",UK=TRUE)


####$$$$$ VEH04 LGVs ####

# VEH0402 ==========
validate_table(veh0402_gb,type="stock",style="split",UK=FALSE)
validate_table(veh0402_uk,type="stock",style="split",UK=TRUE)

# VEH0403 ==========
validate_table(veh0403_gb,type="stock",style="split",UK=FALSE)
validate_table(veh0403_uk,type="stock",style="split",UK=TRUE)


####$$$$$ VEH05 HGVs ####

# VEH0502 ==========
validate_table(veh0502_gb,type="stock",style="split",UK=FALSE)
validate_table(veh0502_uk,type="stock",style="split",UK=TRUE)

# VEH0503 ==========
validate_table(veh0503_gb,type="stock",style="split",UK=FALSE)
validate_table(veh0503_uk,type="stock",style="split",UK=TRUE)


####$$$$$ VEH06 HGVs ####

# VEH0602 ==========
validate_table(veh0602_gb,type="stock",style="split",UK=FALSE)
validate_table(veh0602_uk,type="stock",style="split",UK=TRUE)

# VEH0603 ==========
validate_table(veh0603_gb,type="stock",style="split",UK=FALSE)
validate_table(veh0603_uk,type="stock",style="split",UK=TRUE)

