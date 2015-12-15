## Part 1 

pollutantmean <- function(directory, pollutant, id = 1:332) {
    dy <- list.files(directory, full.names = T)
    Dtarget <- dy[id]
    df <- data.frame()
    for(i in 1:length(id)){ 
      df <- rbind(df, read.csv(Dtarget[i]))
    }
    
    df_subset <- (df[, pollutant]) 
    meandata <- mean(df_subset, na.rm=TRUE)
    round(meandata,3)
  }




