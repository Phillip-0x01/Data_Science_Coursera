rankhospital <- function(state, outcome, num = "best") {
    
    ## Read outcome data
    data <- read.csv("outcome-of-care-measures.csv", colClasses = "character", na.strings="Not Available")
    
    ## Check that state and outcome are valid
    states <- data[ ,7]
    if (!state %in% states) {
      stop (print("Invalid State"))
    }
    outcomes <- c("heart attack", "heart failure", "pneumonia")
    if (!outcome %in% outcomes) {
      stop (print("Invalid Outcome"))
    }
    
    ## Return hospital name in that state with lowest 30-day death
    ## rate
    if (outcome == "heart attack") {
      sub.outcome <- 11
    }
    else if (outcome == "heart failure") {
      sub.outcome <- 17
    }
    else {
      sub.outcome <- 23
    }
    
    
    data.state <- data[data$State==state,]
    
    new.data <- data.state[order(as.numeric(data.state[[sub.outcome]]),data.state[["Hospital.Name"]],decreasing=FALSE,na.last=NA), ]
    
    if (num=="best") num = 1
    if (num=='worst') num = nrow(new.data)
    
    new.data[num, "Hospital.Name"]
  }