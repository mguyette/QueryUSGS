
I had colleagues interested in simple access to USGS gauge data, but
they had limited experience with R. I developed the
[script](https://github.com/mguyette/QueryUSGS/blob/master/USGSDataRetrieval.R)
in this GitHub repo to generate a quick CSV export of USGS data based on
a user’s input parameters. Users simply update the frequency, site
numbers, parameter codes, start date, end date, statistic code, time
zone, and the path for downloads. This project briefly summarizes the
steps used in the script.

Note that the script in the GitHub repo is designed to allow users to
easily jump to the lines of code that need to be changed for each use by
making use of the [Code
Sections](https://support.rstudio.com/hc/en-us/articles/200484568-Code-Folding-and-Sections)
functionality in RStudio (at least four \# in a row at the end of line
creates a new Section).

## dataRetrieval package

USGS gauge data can be queried using the USGS R package,
**dataRetrieval**.

``` r
if (!("dataRetrieval" %in% installed.packages())) {
    install.packages("dataRetrieval") 
}
library(dataRetrieval)
```

## Input arguments

#### frequency

The user can choose “daily”, “instantaneous”, or both, as shown here.
This selection will call different functions in the **dataRetrieval**
package, **readNWISdv** for daily values and **readNWISuv** for
instantaneous values.

``` r
frequency <- c("daily", "instantaneous")
```

#### siteNumbers

This argument takes one or many USGS site numbers, which are eight or
fifteen digit numbers such as 02232500 or 291442081384201. If a user
doesn’t already know their site number(s) of interest, they can be found
through the [National Water Information System
Mapper](https://maps.waterdata.usgs.gov/mapper/index.html).

``` r
siteNumbers <- c("02232500", "02232400", "02234000")
```

#### parameterCd

This argument takes one 5-digit USGS parameter code. Common parameters
include:

  - 00060 - Discharge, cubic feet per second  
  - 00065 - Gage Height, feet  
  - 63130 - Stream water level elevation above NAVD 1988, in feet

<!-- end list -->

``` r
parameterCd <- "00065"
```

The **dataRetrieval** package includes a table of parameter codes called
**parameterCdfile**. Users can view this to look up parameter codes of
interest, or you can search for parameter codes on the [NWIS
website](https://nwis.waterdata.usgs.gov/nwis/pmcodes/). The first few
rows of the data frame stored with the package are shown here:

| parameter\_cd | parameter\_group\_nm |                                 parameter\_nm                                 | casrn | srsname | parameter\_units |
| :-----------: | :------------------: | :---------------------------------------------------------------------------: | :---: | :-----: | :--------------: |
|     00001     |     Information      |  Location in cross section, distance from right bank looking upstream, feet   |  NA   |   NA    |        ft        |
|     00002     |     Information      | Location in cross section, distance from right bank looking upstream, percent |  NA   |   NA    |        %         |
|     00003     |     Information      |                             Sampling depth, feet                              |  NA   |   NA    |        ft        |
|     00005     |     Information      |          Location in cross section, fraction of total depth, percent          |  NA   |   NA    |        %         |
|     00008     |     Information      |                           Sample accounting number                            |  NA   |   NA    |        nu        |
|     00009     |     Information      |  Location in cross section, distance from left bank looking downstream, feet  |  NA   |   NA    |        ft        |

#### startDate and endDate

Designating the start date and end date is optional, but depending on
the frequency, siteNumbers, and parameterCd selections, omitting these
parameters could result in a very long run time for the function.

Note that the dates must be ISO 8601 formatted (“YYYY-MM-DD”). If
omitting a date variable, simply assign the variable to "".

``` r
startDate <- "2017-10-10"
endDate <- "2017-11-10"
```

#### statCd

If you select a “daily” frequency, you can select a statistic that you’d
like to have the retrieval report for the daily summary. This argument
makes use of NWIS statistic codes, which are 5-digit codes. Common
statistic codes include:

  - 00001 - Maximum
  - 00002 - Minimum
  - 00003 - Mean
  - 00006 - Sum
  - 00008 - Median

By default, the mean statCd, “00003”, is used.

``` r
statCd <- c("00003")
```

You can view a comprehensive list of statistic codes on the [NWIS
website](https://help.waterdata.usgs.gov/stat_code).

#### tz

By default, this query retrieves data in UTC. If you are interested in a
different time zone, designate it here. For example, if you are
interested in Eastern Standard Time, use “EST”. If you are interested in
Eastern Daylight Time, use “America/New\_York”.

``` r
tz <- "EST"
```

#### Export Path

The function in this script retrieves data and writes these data as a
CSV to a designated location. The script stores your desired path for
your CSV download(s) here:

``` r
path <- "./Exports"
```

## getUSGSdata function

The remainder of the script contains the definition of a function,
**getUSGSdata**, and a call to this function using the arguments defined
above.

This function calls the appropriate function(s) in **dataRetrieval**,
depending on the frequency (or frequencies) designated, and writes the
retrieved data to you designated **path**.

``` r
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

getUSGSdata(frequency, siteNumbers, parameterCd,
            startDate, endDate ,statCd, tz, path)
```

## Exported files

Example exports can be viewed in the GitHub repo
[here](https://github.com/mguyette/QueryUSGS/tree/master/Exports).

The first few rows of the daily values output, imported as a data frame,
look like this:

| agency\_cd | site\_no |    Date    | Flow | Flow\_cd |  GH   | GH\_cd |
| :--------: | :------: | :--------: | :--: | :------: | :---: | :----: |
|    USGS    | 02232400 | 2017-10-10 | 7370 |    P     | 17.29 |   P    |
|    USGS    | 02232400 | 2017-10-11 | 7100 |    P     | 17.22 |   P    |
|    USGS    | 02232400 | 2017-10-12 | 7060 |    P     | 17.13 |   P    |
|    USGS    | 02232400 | 2017-10-13 | 7040 |    P     | 17.09 |   P    |
|    USGS    | 02232400 | 2017-10-14 | 7100 |    P     | 17.12 |   P    |
|    USGS    | 02232400 | 2017-10-15 | 7160 |    P     | 17.09 |   P    |

The first few rows of the instantaneous values output, imported as a
data frame, look like this:

| agency\_cd | site\_no |      dateTime       | Flow\_Inst | Flow\_Inst\_cd | GH\_Inst | GH\_Inst\_cd | tz\_cd |
| :--------: | :------: | :-----------------: | :--------: | :------------: | :------: | :----------: | :----: |
|    USGS    | 02232400 | 2017-10-09 23:00:00 |    7390    |       P        |  17.32   |      P       |  EST   |
|    USGS    | 02232400 | 2017-10-09 23:15:00 |    7510    |       P        |  17.33   |      P       |  EST   |
|    USGS    | 02232400 | 2017-10-09 23:30:00 |    7530    |       P        |  17.33   |      P       |  EST   |
|    USGS    | 02232400 | 2017-10-09 23:45:00 |    7440    |       P        |  17.32   |      P       |  EST   |
|    USGS    | 02232400 |     2017-10-10      |    7690    |       P        |  17.32   |      P       |  EST   |
|    USGS    | 02232400 | 2017-10-10 00:15:00 |    7550    |       P        |  17.32   |      P       |  EST   |

Return to [Data
Preparation](https://mguyette.github.io/DataPreparation/)
[Languages](https://mguyette.github.io/Languages/) [Data Science
Portfolio](https://mguyette.github.io/)
