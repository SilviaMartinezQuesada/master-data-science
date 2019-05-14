###################################################################################
# In this code we are going to download the information published in the 
# World Bank of data related to the location of the countries, so that we have 
# standardized the names of the countries, codes, latitude, longitude and region.
####################################################################################

# 1. First, we load the necessary packages and choose where to save the file

if(!require(wbstats)){
  install.packages("wbstats")
  library(wbstats)
}

if(!require(data.table)){
  install.packages("data.table")
  library(data.table)
}


path_to_save <- getwd()

# 2. We download the information available by country and choose the columns of interest

countries <- data.table(wbcountries())
myDF      <- countries[ ! region %in% "Aggregates"]
myDF2     <- subset(myDF, select = c(iso3c, country, long, lat, region))

# 3. Save information by country as .csv

write.csv(myDF2, file = paste(path_to_save, "03_Output_Countries.csv", sep="/"), row.names = FALSE, na = "")
