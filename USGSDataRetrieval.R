#=======================================================================#
## This script generates csv files of USGS data based on the user's    ##
## specifications below.  Please make changes to the lines shown below ##
## (frequency, siteNumbers, parameterCd, startDate, endDate, statCd,   ##
## tz, and path).                                                      ##
## Author: Margaret Guyette             Date: January 9, 2018          ##
#=======================================================================#

## Required package, installs dataRetrieval if it isn't already available
if (!("dataRetrieval" %in% installed.packages())) {
    install.packages("dataRetrieval") 
}
library(dataRetrieval)

## Frequency
## Select "daily" (daily summaries), "instantaneous" (whichever frequency 
## the data is collected), or "daily","instantaneous"
## Must be in quotes
frequency <- c("daily", "instantaneous") # Frequency ####

## USGS site(s)
## For one station, place inside quotes within the parentheses below
##     e.g., siteNumbers <- c("02232500")
## For more than one station, place inside quotes separated by commas within the
## parentheses below
##     e.g., siteNumbers <- c("02232500", "02232400", "02234000")
siteNumbers <- c("02232500", "02232400", "02234000") # USGS Site Numbers ####

## Parameter(s)
## For one parameter code, place inside quotes within the parentheses below
##     e.g., parameterCd <- c("00065")
## For more than one parameter code, place inside quotes separated by commas 
## within the parentheses below
##     e.g., parameterCd <- c("00060", "00065")
## Common parameter codes include:
##     00060 - Discharge, cubic feet per second
##     00065 - Gage height, feet
##     63130 - Stream water level elevation above NAVD 1988, in feet
## For more parameter codes you can uncomment the line below to view
## a searchable data table of all USGS parameter codes
#View(parameterCdFile)
## Or you can search for parameter codes at the website:
## https://nwis.waterdata.usgs.gov/nwis/pmcodes/
parameterCd <- c("00065") # USGS Parameter Codes ####

## Start date
## May be left blank to retrieve the entire period of record
## (may take a long time if you ask for the entire record)
## Must be formatted as "YYYY-MM-DD" or ""
startDate <- "2017-11-01" # Start Date ####

## End date
## May be left blank to retrieve the entire period of record
## (may take a long time if you ask for the entire record)
## Must be formatted as "YYYY-MM-DD" or ""
endDate <- "2017-11-10" # End Date ####

## Statistic code
## Only used for daily summaries
## You can only select a single statistic code for any given query
## Place inside quotes below
##     e.g., statCd <- "00003"
## Common stat codes include:
##     00001 - Maximum
##     00002 - Minimum
##     00003 - Mean
##     00006 - Sum
##     00008 - Median
statCd <- "00003" # Statistic code ####
    
## Time Zone
## Change only if you prefer to show a different time zone
## If you are interested in EST, use "EST"
## If you are interested in EDT, use "America/New_York"
tz <- "EST" # Time Zone ####

## Export Path
## The path to the folder to which you would like to download 
## output files
path <- "./Exports" # Export path ####

#==========================================================#
## DO NOT MAKE MODIFICATIONS TO ANYTHING BELOW THIS POINT ##
#==========================================================#

## Function to query USGS
getUSGSdata <- function(frequency, siteNumbers, parameterCd,
                        startDate, endDate, statCd, tz, path) {
    ## Create a file prefix that includes all site numbers to be used in
    ## the file name
    filePrefix <- paste(siteNumbers, collapse = "_", sep = "")
    ## If daily values are requested
    if ("daily" %in% frequency) {
        ## Query NWIS
        dvData <- readNWISdv(siteNumbers, parameterCd, startDate, endDate, statCd)
        ## Rename columns, changing parameter codes to text
        dvData <- renameNWISColumns(dvData)
        ## Write the data to a CSV file
        write.csv(dvData,paste(path, "/", filePrefix, "_daily_",
                               Sys.Date(), ".csv", sep = ""),
                  row.names = F, na = "")
    }
    ## If instantaneous values are requested
    if ("instantaneous" %in% frequency) {
        ## Query NWIS
        uvData <- readNWISuv(siteNumbers, parameterCd, startDate, endDate, tz)
        ## Rename columns, changing parameter codes to text
        uvData <- renameNWISColumns(uvData)
        ## Write the data to a CSV file
        write.csv(uvData,paste(path, "/", filePrefix, "_inst_",
                               Sys.Date(), ".csv", sep = ""),
                  row.names = F, na = "")
    }
}

## Run the function
getUSGSdata(frequency, siteNumbers, parameterCd,
            startDate, endDate, statCd, tz, path)
