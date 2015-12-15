#check for file in current director, download 
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
####################################################################################################

#Plot 1 - Histogram
png(file = "plot1.png", width = 480, height = 480)
plot <- as.numeric(subset$Global_active_power)
hist(plot, col = "red", main = paste("Global Active Power"), xlab = "Global Active Power (kilowatts)")
dev.off()
####################################################################################################

#Plot 2 - Line Chart

#assign variables 
timestamp <- subset$timestamp
Power <- as.numeric(subset$Global_active_power)

#create plot
png(file = "plot2.png", width = 480, height = 480)
plot(timestamp, Power, type = "l", xlab="", ylab = "Global Active Power (kilowatts)")
dev.off()
####################################################################################################

#Plot 3 - Line Chart w/3 Variables

#assign variables 
timestamp <- subset$timestamp
Meter1 <- subset$Sub_metering_1
Meter2 <- subset$Sub_metering_2
Meter3 <- subset$Sub_metering_3
#create plot
png(file = "plot3.png", width = 480, height = 480)
plot(timestamp, Meter1, type = "l", col="black", ylab="Energy sub metering")
lines(timestamp, Meter2, col="red")
lines(timestamp, Meter3, col="blue")
legend("topright", c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), lty=c(1,1), lwd=c(1,1),
       col=c("black", "red", "blue"))
dev.off()
####################################################################################################

#Plot 4 - 


png(file = "plot2.png", width = 480, height = 480)
par(mfrow = c(2, 2)) 
with(subset, { 
    plot(timestamp, Global_active_power, type = "l", xlab="", ylab = "Global Active Power") 
    plot(timestamp, Voltage, type = "l", xlab="datetime", ylab = "Voltage")
    plot(timestamp, Meter1, type = "l", col="black", ylab="Energy sub metering")
    lines(timestamp, Meter2, col="red")
    lines(timestamp, Meter3, col="blue")
    legend("topright", c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), lty=c(1,1), lwd=c(1,1),
           col=c("black", "red", "blue"), bty = "n")
    plot(timestamp, Global_reactive_power, type = "l", xlab="datetime")
    })


dev.off()




