library(targets)
source('1_fetch/src/getData.R')
source('2_process/src/processData.R')
source('3_visualize/src/plotDiagnostics.R')
tar_option_set(packages = c("tidyverse", "stringr", "sbtools", "whisker"))

list(
  #1_fetch----
  # Get the data from ScienceBase
  tar_target(
    model_RMSEs_csv,
    getData(outDir = "1_fetch/out", outFileName = "model_RMSEs.csv"),
    format = "file"
  ), 
  # Load the data
  tar_target(
    raw_data,
    loadData(filepath = model_RMSEs_csv)
  ),
  #2_process----
  # Prepare the data for plotting
  tar_target(
    eval_data,
    processData(data = raw_data),
  ),
  # Save the processed data
  tar_target(
    model_summary_results_csv,
    writeSummaryData(data = eval_data, outDir = "2_process/out", fileName = "model_summary_results.csv"), 
    format = "file"
  ),
  # Save the model diagnostics
  tar_target(
    model_diagnostic_text_txt,
    writeSummaryText(data = eval_data, outDir = "2_process/out", fileName = "model_diagnostic_text.txt"), 
    format = "file"
  ),
  #3_visualize----
  # Create a plot
  tar_target(
    figure_1_png,
    plotDiagnostics(data = eval_data, outDir = "3_visualize/out", figName = "figure_1.png"), 
    format = "file"
  )
)