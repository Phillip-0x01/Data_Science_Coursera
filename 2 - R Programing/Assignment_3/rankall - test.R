rankall <- function(outcome, num="best") {
  ## Read outcome data
  ## Check that state and outcome are valid
  ## For each state, find the hospital of the given rank
  ## Return a data frame with the hospital names and the
  ## (abbreviated) state name
  
  data <- read.csv("outcome-of-care-measures.csv", colClasses = "character", na.strings="Not Available")
  
  if (outcome == "heart attack") {
    sub.outcome <- 11
  }
  else if (outcome == "heart failure") {
    sub.outcome <- 17
  }
  else {
    sub.outcome <- 23
  }

  data <- data[order(data$"State", data[sub.outcome], data$"Hospital.Name", na.last=NA),]
  data <- data[!is.na(outcome)]
  
  l <- split(data[,c("Hospital.Name")], data$State)
  
  rankHospitals <- function(x, num) {
    
    if (num=="best") num = 1
    else if (num=='worst') num = nrow(data)
    else num = num
    }
    

  
  result <- lapply(l, rankHospital, num)
  data.frame(hospital = unlist(result), state = names(result), row.names = names(result))

}
