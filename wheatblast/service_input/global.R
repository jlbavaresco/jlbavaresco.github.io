library(dplyr)
library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(jsonlite)
## KY 113 2009-2014
#experiment <- 120
#startingDate <- "2015-07-28"
experiment <- 93
startingDate <- "2010-06-16"

numberHeads <- 300

#servidor <- "localhost:8080/agroservice"
servidor <- "187.7.88.182:6889/AgroService"
