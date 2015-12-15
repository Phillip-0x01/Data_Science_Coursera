rankall <- function(outcome, num="best") {
  ## Read outcome data
  ## Check that state and outcome are valid
  ## For each state, find the hospital of the given rank
  ## Return a data frame with the hospital names and the
  ## (abbreviated) state name
  
  data <- read.csv("outcome-of-care-measures.csv", colClasses = "character", na.strings="Not Available")
  
  if(! (outcome == "heart attack" || outcome == "heart failure" || outcome == "pneumonia") ) {
    stop("invalid outcome")
  }
  
  if(class(num) == "character"){
    if (! (num == "best" || num == "worst")){
      stop("invalid number")
    }
  }
  
  ## For each state, find the hospital of the given rank
  ## Return a data frame with the hospital names and the (abbreviated) state name
  
  # Remove columns by outcome, only left HospitalName and Deaths by outcome
  if(outcome == "heart attack") {
    data = data[,c(1,2,3)]
  } else if(outcome == "heart failure") {
    data = data[,c(1,2,4)]
  } else if(outcome == "pneumonia") {
    data = data[,c(1,2,5)]
  }
  names(data)[3] = "Deaths"
  data[, 3] = suppressWarnings( as.numeric(data[, 3])
                                
                                
  data <- data[order(data$"State", data[sub.outcome], data$"Hospital.Name", na.last=NA),]
  data <- data[!is.na(outcome)]
  
  l <- split(data[,c("Hospital.Name")], data$State)
  
  rankHospitals <- function(x, num) {
    if (num=="best") {
      head(x, 1)
    } else if (num=="worst") {
      tail(x, 1)
    } else {
      x[num]
    }
  }
  
  result <- lapply(l, rankHospitals, num)
  data.frame(hospital = unlist(result), state = names(result), row.names = names(result))
}
