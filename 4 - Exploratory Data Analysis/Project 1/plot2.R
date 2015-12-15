#check for data file in current director, download if not found
if(!file.exists("exdata-data-household_power_consumption.zip")) {
  temp <- tempfile()
  download.file("http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip", temp)
  file <- unzip(temp)
  unlink(temp)
}

#import datatable 
power_data <- read.table(file, header=TRUE, sep=";", na.strings = "?", stringsAsFactors=FALSE)

#filter dates
power_data$Date <- as.Date(power_data$Date, format = "%d/%m/%Y")
subset <- power_data[(power_data$Date=="2007-02-01") | (power_data$Date=="2007-02-02"), ]
subset <- transform(subset, timestamp=as.POSIXct(paste(Date,Time)))

#Plot 2 - Line Chart

#assign variables
timestamp <- subset$timestamp
Power <- as.numeric(subset$Global_active_power)

#create plot
png(file = "plot2.png", width = 480, height = 480)
plot(timestamp, Power, type = "l", xlab="", ylab = "Global Active Power (kilowatts)")
dev.off()