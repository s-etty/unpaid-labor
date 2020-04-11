######################################
#
# a script to pull the data from the downloaded csv. The data comes from the UN
# sustainable development goals indicators database. 
# https://unstats.un.org/sdgs/indicators/database/
# read this article to learn how to pull API data:
# https://www.dataquest.io/blog/r-api-tutorial/
#
######################################

#install.packages('httr')
#install.packages('jsonlite')

library(httr)
library(jsonlite)

url <- 'https://unstats.un.org/SDGAPI/v1/sdg/Indicator/Data?indicator=5.4.1'
#the API URL where the data will come from. This page helps build API URL's
#https://unstats.un.org/SDGAPI/swagger/

data <- fromJSON(url)
#pulling the data using the JSON library

names(data) #print the things within data. We are looking for a specific column
#where the data we want lives. In this case it's called data. However, the above API only returns one
#page worth of data. So we will need to pull all the pages worth of data first. Get the total pages
#from the first call and repeat calls in a for loop

num_elements <- data$totalElements
#total number of elements (items) in the UN SDG database
url <- paste('https://unstats.un.org/SDGAPI/v1/sdg/Indicator/Data?indicator=5.4.1&pageSize=',
             num_elements, sep = "")
data <- fromJSON(url)
#extracting all the data

##########################################
#taking the data and flattening it to be stored in a csv file
#this will allow this script to be run anytime to update the data

unpaid_labor <- data$data
#extracting the data from the data dataframe from the JSON request

unpaid_labor <- unpaid_labor[, c('seriesDescription', 'seriesCount', 'geoAreaCode', 'geoAreaName',
                                 'timePeriodStart', 'value')]
#selecting only the columns we need

#unpaid_test <- tidyr::unnest(unpaid_labor, cols = c('dimensions'))
#the above line should take the dimensions column and turn it into 4 separate columns
#not working though. always freezes my computer. Will work on later

unpaid_labor_dim <- data$data['dimensions']
unpaid_labor <- cbind(unpaid_labor, unpaid_labor_dim$dimensions['Age'])
unpaid_labor <- cbind(unpaid_labor, unpaid_labor_dim$dimensions['Location'])
unpaid_labor <- cbind(unpaid_labor, unpaid_labor_dim$dimensions['Sex'])
#flattening the dataframe. Taking the dimensions df out of the original JSON data request,
#adding a column to the unpaid_labor df for each column in the dimensions df

write.csv(unpaid_labor, 'data/un-unpaid-labor-data.csv', row.names = FALSE)
#export as a csv in the data folder of this project
