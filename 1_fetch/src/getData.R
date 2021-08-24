#' Gets the data from ScienceBase
#' @param outDir desired location of the downloaded file
#' @param sbID ScienceBase (SB) ID corresponding to the item
#' @param fileName the name of the SB file
#' @param outFileName the desired name of the saved file
#' @return dataframe of the data
getData <- function(outDir,
                   sbID = '5d925066e4b0c4f70d0d0599',
                   fileName = 'me_RMSE.csv',
                   outFileName = 'model_RMSEs.csv'){
  
  mendotaFile <- file.path(outDir, outFileName)
  out_filepath <- item_file_download(sb_id = sbID, names = fileName, destinations = mendotaFile, overwrite_file = TRUE)
  
  return(out_filepath)
}

#' Loads the data into a dataframe
#' @param filepath the full path to the file to be loaded
#' @return dataframe of the data
loadData <- function(filepath){
  data <- readr::read_csv(file = filepath, col_types = 'iccd')
  return(data)
}
