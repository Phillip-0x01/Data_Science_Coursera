#Exploratory Data Analysis - Course Project #2

#check for file in current director, download 
if(!file.exists("exdata_data_NEI_data.zip")) {
  temp <- tempfile()
  download.file("http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip", temp)
  file <- unzip(temp)
  unlink(temp)
}

NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")


#....PLOT 1.....
require(dplyr)

df1 <- NEI %>%
      group_by(year) %>%
      summarise(Total_Emissions = sum(Emissions))

png(file = "plot1.png", width = 480, height = 480)
with(df1, plot(year, Total_Emissions, main=expression(paste('Total PM' [2.5], " Emitted in The U.S.")), xaxt="n", col = "red", 
               type = "o", xlab = "Year", ylab = (expression(paste(PM[2.5], " ", "(in tons)")))))
axis(1, at = seq(1999, 2008, by = 3))
dev.off()

#....PLOT 2.....
require(dplyr)

df2 <- NEI %>%
  filter(fips == "24510") %>%
  group_by(year) %>%
  summarise(Total_Emissions = sum(Emissions))

png(file = "plot2.png", width = 480, height = 480)
with(df2, plot(year, Total_Emissions, main=expression(paste("Total PM"[2.5], " Emitted in Baltimore City")), xaxt="n", col = "red", 
               type = "o", xlab = "Year", ylab = (expression(paste(PM[2.5], " ", "(in tons)")))))
axis(1, at = seq(1999, 2008, by = 3))
dev.off()

#....PLOT 3.....
require(dplyr)
require(ggplot2)

df3 <- NEI %>%
  filter(fips == "24510") %>%
  group_by(year, type) %>%
  summarise(Total_Emissions = sum(Emissions))

png(file = "plot3.png", width = 480, height = 480)
qplot(year, Total_Emissions, data = df3, color = type, main = expression(paste("Total PM"[2.5], " Emitted in Balitmore City by Type")), 
        geom = c("point", "line")) +
        labs(x = "Year",  y = (expression(paste(PM[2.5], " ", "(in tons)"))), color = "Type") +
        scale_x_continuous(breaks=c(1999, 2002, 2005, 2008), labels=c("1999", "2002", "2005", "2008"))
dev.off()

#....PLOT 4.....
require(dplyr)
require(ggplot2)

coal <- filter(SCC, grepl("- Coal", EI.Sector)) 
coal <- coal$SCC
  
df4 <- subset(NEI, SCC %in% coal)

df4 <- df4 %>%
        group_by(year) %>%
        summarise(Total_Emissions = sum(Emissions))

png(file = "plot4.png", width = 480, height = 480)
qplot(year, Total_Emissions, data = df4, main = expression(paste("Total PM"[2.5], " Emitted From Coal in The U.S.")), geom = c("point", "line")) +
  labs(x = "Year",  y = (expression(paste(PM[2.5], " ", "(in tons)")))) +
  scale_x_continuous(breaks=c(1999, 2002, 2005, 2008), labels=c("1999", "2002", "2005", "2008"))
dev.off()

#....PLOT 5.....
require(dplyr)
require(ggplot2)

car <- filter(SCC, grepl("Vehicles", EI.Sector))
car <- car$SCC

df5 <- subset(NEI, SCC %in% car)

df5 <- df5 %>%
        filter(fips == "24510") %>%
        group_by(year) %>%
        summarise(Total_Emissions = sum(Emissions))

png(file = "plot5.png", width = 480, height = 480)
ggplot(df5, aes(year, Total_Emissions)) +
      geom_line(colour="#FF0066") +
      geom_point(size=3) + 
      labs(title = expression(paste("Total PM"[2.5], " Emitted from Motor Vehicle's in Baltimore City")), x = "Year", 
          y = (expression(paste(PM[2.5], " ", "(in tons)")))) +
      scale_x_continuous(breaks=c(1999, 2002, 2005, 2008), labels=c("1999", "2002", "2005", "2008"))
dev.off()

#....PLOT 6.....
require(dplyr)
require(ggplot2)

cities <- c("24510", "06037")
car <- filter(SCC, grepl("Vehicles", EI.Sector))
car <- car$SCC

df6 <- subset(NEI, SCC %in% car)
df6 <- subset(df6, fips %in% cities)

df6 <- df6 %>%
  group_by(year, fips) %>%
  summarise(Total_Emissions = sum(Emissions))

df6$fips <- gsub("24510", "Baltimore City", df6$fips)
df6$fips <- gsub("06037", "Los Angeles County", df6$fips)

png(file = "plot6.png", width = 480, height = 480)
ggplot(df6, aes(year, Total_Emissions, colour = fips)) +
  geom_line() +
  geom_point(size=3) + 
  labs(title = expression(paste("Total PM"[2.5], " Emitted from Motor Vehicles")), x = "Year", 
       y = (expression(paste(PM[2.5], " ", "(in tons)"))), colour = "County") +
  scale_x_continuous(breaks=c(1999, 2002, 2005, 2008), labels=c("1999", "2002", "2005", "2008"))
dev.off()






