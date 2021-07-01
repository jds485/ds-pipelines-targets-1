#' Gets the data from ScienceBase
#' @outDir desired location of the downloaded file
#' @sbID ScienceBase (SB) ID corresponding to the item
#' @fileName the name of the SB file
#' @outFileName the desired name of the saved file
#' @return dataframe of the data
getData = function(outDir,
                   sbID = '5d925066e4b0c4f70d0d0599',
                   fileName = 'me_RMSE.csv',
                   outFileName = 'model_RMSEs.csv'){
  
  mendota_file <- file.path(outDir, outFileName)
  a = item_file_download(sb_id = sbID, names = fileName, destinations = mendota_file, overwrite_file = TRUE)
  
  data = loadData(a)
  
  return(data)
}

#' Loads the data into a dataframe
#' @downloadCode the code returned from item_file_download
#' @return dataframe of the data
loadData = function(downloadCode){
  data = readr::read_csv(file = downloadCode, col_types = 'iccd')
  return(data)
}
