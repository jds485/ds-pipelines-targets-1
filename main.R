
library(dplyr)
library(readr)
library(stringr)
library(sbtools)
library(whisker)

#1_fetch----
#~\ds-pipelines-targets-1\1_fetch\src
source('getData.R')
data = getData(outDir = '../out')

#2_process----
setwd('../../2_process/src/')
source('processData.R')
# Prepare the data for plotting and save to file
data = processData(data,
                   outDir = '../out/')

RMSEs = writeSummary(data, 
                     outDir = '../out/')

#3_visualize----
setwd('../../3_visualize/src/')
source('plotDiagnostics.R')
plotDiagnostics(data, outDir = '../out/')
