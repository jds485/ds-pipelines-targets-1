#' Processes the data for plotting
#' @data the data to be processed
#' @filterStr the string to filter data in the exper_id column (e.g., season, similar). Default is no filtering.
#' @pltCols vector of plot colors for model types
#' @pltPchs vector of plot pch for model types
#' @outDir desired directory to save processed data
#' @fileName desired saved file name
#' @return dataframe of the processed data
processData <- function(data,
                       filterStr = 'similar',
                       pltCols = c('#1b9e77', '#d95f02', '#7570b3'),
                       pltPchs = c(21, 22, 23),
                       outDir,
                       fileName = 'model_summary_results.csv'
                       ){
  eval_data <- data %>%
    filter(str_detect(exper_id, paste0(filterStr,'_[0-9]+'))) %>%
    mutate(col = case_when(
      model_type == 'pb' ~ pltCols[1],
      model_type == 'dl' ~ pltCols[2],
      model_type == 'pgdl' ~ pltCols[3]
    ), pch = case_when(
      model_type == 'pb' ~ pltPchs[1],
      model_type == 'dl' ~ pltPchs[2],
      model_type == 'pgdl' ~ pltPchs[3]
    ), n_prof = as.numeric(str_extract(exper_id, '[0-9]+')))
  
  # Save the processed data
  readr::write_csv(eval_data, file = file.path(outDir, fileName))
  
  return(eval_data)
}

#' Write a file describing the diagnostic results
#' @data the dataframe with model_type, exper_id, and rmse columns
#' @outDir desired directory to save summary paragraph
#' @fileName desired saved file name
#' @return list of the mean rmse for the model runs
writeSummary <- function(data,
                        outDir,
                        fileName = 'model_diagnostic_text.txt'){
  # Get the model diagnostic data
  render_data <- diagnosticData(data)
  
  # Text paragraph describing the diagnostic results
  template_1 <- 'resulted in mean RMSEs (means calculated as average of RMSEs from the five dataset iterations) of {{pgdl_980mean}}, {{dl_980mean}}, and {{pb_980mean}}°C for the PGDL, DL, and PB models, respectively.
  The relative performance of DL vs PB depended on the amount of training data. The accuracy of Lake Mendota temperature predictions from the DL was better than PB when trained on 500 profiles 
  ({{dl_500mean}} and {{pb_500mean}}°C, respectively) or more, but worse than PB when training was reduced to 100 profiles ({{dl_100mean}} and {{pb_100mean}}°C respectively) or fewer.
  The PGDL prediction accuracy was more robust compared to PB when only two profiles were provided for training ({{pgdl_2mean}} and {{pb_2mean}}°C, respectively). '
  
  whisker.render(template_1 %>% str_remove_all('\n') %>% str_replace_all('  ', ' '), 
                 render_data) %>% cat(file = file.path(outDir, fileName))
  
  return(render_data)
}

#' Summarize the model performance
#' @data the dataframe with model_type, exper_id, and rmse columns
#' @return list of the mean rmse for the model runs
diagnosticData <- function(data){
  render_data <- list(pgdl_980mean = diagnosticFilter(data, model_type = 'pgdl', exper_id = "similar_980"),
                      dl_980mean = diagnosticFilter(data, 'dl', "similar_980"),
                      pb_980mean = diagnosticFilter(data, 'pb', "similar_980"),
                      dl_500mean = diagnosticFilter(data, 'dl', "similar_500"),
                      pb_500mean = diagnosticFilter(data, 'pb', "similar_500"),
                      dl_100mean = diagnosticFilter(data, 'dl', "similar_100"),
                      pb_100mean = diagnosticFilter(data, 'pb', "similar_100"),
                      pgdl_2mean = diagnosticFilter(data, 'pgdl', "similar_2"),
                      pb_2mean = diagnosticFilter(data, 'pb', "similar_2"))
  
  return(render_data)
}

#' Filter for mean RMSE
#' @data the dataframe with model_type, exper_id, and rmse columns
#' @model_type string of the model type to be filtered
#' @exper_id string of the ID to be filtered
#' @return mean rmse rounded to 2 decimal places
diagnosticFilter <- function(data, model_type, exper_id){
  a <- filter(data, model_type == !!model_type, exper_id == !!exper_id) %>% pull(rmse) %>% mean %>% round(2)
  return(a)
}