###################################################################################
# In this code we will access all available indicators in the world data bank 
# and choose the most suitable for our purpose.
#
# In this case, we have chosen the variables population, fertility, life expectancy 
# and the Gini index at the country and year level.
####################################################################################

# 1. First, we load the necessary packages.

if (!require(wbstats)) install.packages('wbstats')
if (!require(googleVis)) install.packages('googleVis')
if (!require(data.table)) install.packages('data.table')

# 2. Take a look at the "indicators" table and write down the "id" column 
#    for those indicators that are of interest to you.

cache <- wbcache()
indic <- cache$indicators

id_choose <-  c("SP.POP.TOTL",        # population
                "SP.DYN.LE00.IN",     # fertility
                "SP.DYN.TFRT.IN",     # life expectancy
                "SI.POV.GINI")        # Gini

# choose the path where you save the result as csv

path_to_save <- getwd()

download_data_worldBank <- function(id_choose, show_plot, save_csv, path_to_save) 
{
  # 3. Download World Bank data and turn into data.table
  myDF <- data.table(wb(indicator = id_choose))
  
  # 4. Download country mappings
  countries <- data.table(wbcountries())
  
  # 5. Set keys to join the data sets
  setkey(myDF, iso2c)
  setkey(countries, iso2c)
  
  # 6. Add regions to the data set, but remove aggregates
  myDF <- countries[myDF][ ! region %in% "Aggregates"]
  
  # 7. Reshape data into a wide format
  df <- reshape(myDF[, list(country, 
                            region, 
                            long, 
                            lat, 
                            date, 
                            value, 
                            indicator)], 
                v.names   = "value", 
                idvar     = c("date", "country", "region", "long", "lat"), 
                timevar   = "indicator",
                direction = "wide")
  
  # 8. Turn date, here year, from character into integer
  df[, date := as.integer(date)]
  
  setnames(df, names(df),c("Country", "Region", "long", "lat", "Year", "Population",
                           "Fertility", "LifeExpectancy", "Gini"))
  
  # 9. This interactive graphic will help you decide at the beginning if the variables 
  #    you have chosen are of your interest. 
  #    feel free to take a look (to make sure that your browser has a flash player installed)
  
  if(show_plot == "yes"){
    grph <- gvisMotionChart(df,
                            idvar    = "Country",
                            timevar  = "Year",
                            xvar     = "LifeExpectancy",
                            yvar     = "Fertility",
                            sizevar  = "Population",
                            colorvar = "Gini")
    
    plot(grph)
    print("The graphic has been generated successfully")
  } else {
    print("The graphic has not been generated because it has not been requested")
  }
  
  # 10. Save df as csv
  if(save_csv == "yes"){
    write.csv(df, file = paste(path_to_save, "04_Output_WorldBankData.csv", sep="/"))
    print("The csv has been generated successfully")
  } else {
    print("The csv has not been generated because it has not been requested")
  }
  
  return("The process has completed successfully")
}

download_data_worldBank(id_choose, show_plot = "no", save_csv = "yes", path_to_save) 
