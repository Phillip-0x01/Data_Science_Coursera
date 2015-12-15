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
  
  
  
  
  
  
  ## 'directory' is a character vector of length 1 indicating
  ## the location of the CSV files
  
  ## 'pollutant' is a character vector of length 1 indicating
  ## the name of the pollutant for which we will calculate the
  ## mean; either "sulfate" or "nitrate".
  
  ## 'id' is an integer vector indicating the monitor ID numbers
  ## to be used
  
  ## Return the mean of the pollutant across all monitors list
  ## in the 'id' vector (ignoring NA values)
}