#' Plots the processed data
#' @param data the dataframe returned from the processData function
#' @param outDir the directory to save the figure with trailing /
#' @param figName the figure name with png extension.
#' @param xlim plot x limits
#' @param ylim plot y limits
#' @param width figure width (in)
#' @param height figure height (in)
#' @param res figure resolution (dpi)
#' @return printed statement
plotDiagnostics <- function(data,
                           outDir,
                           figName = 'figure_1.png',
                           xlim = c(2, 1000),
                           ylim = c(4.7, 0.75),
                           width = 8,
                           height = 10,
                           res = 200
                           ){
  #number of profiles
  n_profs <- sort(unique(data$n_prof))
  
  # make slight horizontal offsets so the plot markers don't overlap:
  offsets <- data.frame(pgdl = c(0.15, 0.5, 3, 7, 20, 30)) %>%
    mutate(dl = -pgdl, pb = 0, n_prof = n_profs)
  
  #make plot
  png(file = file.path(outDir, figName), width = width, height = height, res = res, units = 'in')
  par(omi = c(0,0,0.05,0.05), mai = c(1,1,0,0), las = 1, mgp = c(2,.5,0), cex = 1.5)
  
  plot(NA, NA, xlim = xlim, ylim = ylim,
       ylab = "Test RMSE (°C)", xlab = "Training temperature profiles (#)", log = 'x', axes = FALSE)
  
  axis(1, at = c(-100, n_profs, 1e10), labels = c("", n_profs, ""), tck = -0.01)
  axis(2, at = seq(0,10), las = 1, tck = -0.01)
  
  #Plot data
  for (mod in c('pb','dl','pgdl')){
    mod_data <- filter(data, model_type == mod)
    mod_profiles <- unique(mod_data$n_prof)
    for (mod_profile in mod_profiles){
      d <- filter(mod_data, n_prof == mod_profile) %>% summarize(y0 = min(rmse), y1 = max(rmse), col = unique(col))
      x_pos <- offsets %>% filter(n_prof == mod_profile) %>% pull(!!mod) + mod_profile
      lines(c(x_pos, x_pos), c(d$y0, d$y1), col = d$col, lwd = 2.5)
    }
    d <- group_by(mod_data, n_prof) %>% summarize(y = mean(rmse), col = unique(col), pch = unique(pch)) %>%
      rename(x = n_prof) %>% arrange(x)
    
    lines(d$x + tail(offsets[[mod]], nrow(d)), d$y, col = d$col[1], lty = 'dashed')
    points(d$x + tail(offsets[[mod]], nrow(d)), d$y, pch = d$pch[1], col = d$col[1], bg = 'white', lwd = 2.5, cex = 1.5)
    
  }
  
  #Add legend
  points(2.2, 0.79, col = data$col[data$model_type == 'pgdl'][1], pch = data$pch[data$model_type == 'pgdl'][1], bg = 'white', lwd = 2.5, cex = 1.5)
  text(2.3, 0.80, 'Process-Guided Deep Learning', pos = 4, cex = 1.1)
  
  points(2.2, 0.94, col = data$col[data$model_type == 'dl'][1], pch = data$pch[data$model_type == 'dl'][1], bg = 'white', lwd = 2.5, cex = 1.5)
  text(2.3, 0.95, 'Deep Learning', pos = 4, cex = 1.1)
  
  points(2.2, 1.09, col = data$col[data$model_type == 'pb'][1], pch = data$pch[data$model_type == 'pb'][1], bg = 'white', lwd = 2.5, cex = 1.5)
  text(2.3, 1.1, 'Process-Based', pos = 4, cex = 1.1)
  
  dev.off()
  
  return('Figure generated.')
}